Version = "1.24"
AutoUpdate = true

if myHero.charName ~= "Riven" then
  return
end

require 'SourceLib'
require 'VPrediction'

function ScriptMsg(msg)
  print("<font color=\"#00fa9a\"><b>HTTF Riven:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

----------------------------------------------------------------------------------------------------

Host = "raw.github.com"

ServerPath = "/BolHTTF/BoL/master/Server.status".."?rand="..math.random(1,10000)
ServerData = GetWebResult(Host, ServerPath)

ScriptMsg("Server check...")

assert(load(ServerData))()

print("<font color=\"#00fa9a\"><b>HTTF Riven:</b> </font><font color=\"#FFFFFF\">Server status: </font><font color=\"#ff0000\"><b>"..Server.."</b></font>")

if Server == "Off" then
  return
end

ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

ScriptPath = "/BolHTTF/BoL/master/HTTF/HttfRiven.lua".."?rand="..math.random(1,10000)
UpdateURL = "https://"..Host..ScriptPath

VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HttfRiven.version".."?rand="..math.random(1,10000)
VersionData = GetWebResult(Host, VersionPath)
Versiondata = tonumber(VersionData)

if AutoUpdate then

  if VersionData then
  
    ServerVersion = type(Versiondata) == "number" and Versiondata or nil
    
    if ServerVersion then
    
      if tonumber(Version) < ServerVersion then
        ScriptMsg("New version available: v"..VersionData)
        ScriptMsg("Updating, please don't press F9.")
        DelayAction(function() DownloadFile(UpdateURL, ScriptFilePath, function () ScriptMsg("Successfully updated.: v"..Version.." => v"..VersionData..", Press F9 twice to load the updated version.") end) end, 3)
      else
        ScriptMsg("You've got the latest version: v"..Version)
      end
      
    end
    
  else
    ScriptMsg("Error downloading version info.")
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnLoad()
  
  Variables()
  RivenMenu()
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Variables()

  Target = nil
  Player = GetMyHero()
  EnemyHeroes = GetEnemyHeroes()
  
  if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
    Ignite = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
    Ignite = SUMMONER_2
  end
  
  if myHero:GetSpellData(SUMMONER_1).name:find("smite") then
    Smite = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("smite") then
    Smite = SUMMONER_2
  end
  
  CanTurn = false
  CanMove = true
  CanAA = true
  CanQ = true
  CanW = true
  CanE = true
  BeingAA = false
  BeingQ = false
  BeingW = false
  BeingE = false
  AnimationTime = 1.6
  WindUpTime = 0
  LastAA = 0
  LastQ = 0
  LastW = 0
  LastE = 0
  LastR = 0
  Recall = false
  
  P = {stack = 0}
  Q = {radius = 275, range = 225, level = 0, ready, state = 0}
  W = {radius = 260, level = 0, ready}
  E = {range = 250, level = 0, ready}
  R = {delay = 0, angle = 45, range = 900, speed = 1200, level = 0, ready, state = false}
  I = {range = 600, ready}
  S = {range = 760, ready}
  
  Items =
  {
  ["Tiamat"] = {id=3077, range = 150, maxrange = 400, slot = nil, ready},
  ["Hydra"] = {id=3074, range = 150, maxrange = 400, slot = nil, ready},
  ["Stalker"] = {id=3706, range = 760, slot = nil, ready},
  ["StalkerW"] = {id=3707, slot = nil},
  ["StalkerM"] = {id=3708, slot = nil},
  ["StalkerJ"] = {id=3709, slot = nil},
  ["StalkerD"] = {id=3710, slot = nil}
  }
  
  MyminBBox = 39.44
  TrueRange = 125.5+MyminBBox
  TrueminionRange = TrueRange
  TruejunglemobRange = TrueRange
  TrueTargetRange = TrueRange
  TargetAddRange = 0
  
  AutoQEQW = {1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2}
  
  S5SR = false
  TT = false
  
  if GetGame().map.index == 15 then
    S5SR = true
  elseif GetGame().map.index == 4 then
    TT = true
  end
  
  if S5SR then
    FocusJungleNames =
    {
    ["Dragon6.1.1"] = true,
    ["Worm12.1.1"] = true,
    ["GiantWolf8.1.1"] = true,
    ["AncientGolem7.1.1"] = true,
    ["Wraith9.1.1"] = true,
    ["LizardElder10.1.1"] = true,
    ["Golem11.1.2"] = true,
    ["GiantWolf2.1.1"] = true,
    ["AncientGolem1.1.1"] = true,
    ["Wraith3.1.1"] = true,
    ["LizardElder4.1.1"] = true,
    ["Golem5.1.2"] = true,
    ["GreatWraith13.1.1"] = true,
    ["GreatWraith14.1.1"] = true
    }
  JungleMobNames =
    {
    ["Wolf8.1.2"] = true,
    ["Wolf8.1.3"] = true,
    ["YoungLizard7.1.2"] = true,
    ["YoungLizard7.1.3"] = true,
    ["LesserWraith9.1.3"] = true,
    ["LesserWraith9.1.2"] = true,
    ["LesserWraith9.1.4"] = true,
    ["YoungLizard10.1.2"] = true,
    ["YoungLizard10.1.3"] = true,
    ["SmallGolem11.1.1"] = true,
    ["Wolf2.1.2"] = true,
    ["Wolf2.1.3"] = true,
    ["YoungLizard1.1.2"] = true,
    ["YoungLizard1.1.3"] = true,
    ["LesserWraith3.1.3"] = true,
    ["LesserWraith3.1.2"] = true,
    ["LesserWraith3.1.4"] = true,
    ["YoungLizard4.1.2"] = true,
    ["YoungLizard4.1.3"] = true,
    ["SmallGolem5.1.1"] = true
    }
  elseif TT then
    FocusJungleNames =
    {
    ["TT_NWraith1.1.1"] = true,
    ["TT_NGolem2.1.1"] = true,
    ["TT_NWolf3.1.1"] = true,
    ["TT_NWraith4.1.1"] = true,
    ["TT_NGolem5.1.1"] = true,
    ["TT_NWolf6.1.1"] = true,
    ["TT_Spiderboss8.1.1"] = true
    }   
    JungleMobNames =
    {
    ["TT_NWraith21.1.2"] = true,
    ["TT_NWraith21.1.3"] = true,
    ["TT_NGolem22.1.2"] = true,
    ["TT_NWolf23.1.2"] = true,
    ["TT_NWolf23.1.3"] = true,
    ["TT_NWraith24.1.2"] = true,
    ["TT_NWraith24.1.3"] = true,
    ["TT_NGolem25.1.1"] = true,
    ["TT_NWolf26.1.2"] = true,
    ["TT_NWolf26.1.3"] = true
    }
  end
  
  VP = VPrediction()
  TS = TargetSelector(TARGET_NEAR_MOUSE, Q.range+E.range+TrueRange, DAMAGE_PHYSICAL, false)
  RTS = TargetSelector(TARGET_LESS_CAST, R.range, DAMAGE_PHYSICAL, false)
  
  EnemyMinions = minionManager(MINION_ENEMY, Q.range+E.range+TrueRange, player, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, Q.range+E.range+TrueRange, player, MINION_SORT_MAXHEALTH_DEC)
  
end

----------------------------------------------------------------------------------------------------

function RivenMenu()

  Menu = scriptConfig("HTTF Riven", "HTTF Riven")
    
  Menu:addSubMenu("Combo Settings", "Combo")
  
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Info", "Use E to stick if Health Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Combo:addParam("E2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Combo:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R", "Use R Combo", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("FR", "Use First R (FR): Do not work yet", SCRIPT_PARAM_LIST, 2, { "None", "Easy to Kill", "Normal to Kill", "Hard to Kill"})
      Menu.Combo:addParam("SR", "Use Second R (SR)", SCRIPT_PARAM_LIST, 2, { "None", "Killable", "Max Damage or Killable"})
      Menu.Combo:addParam("Rearly", "Use Second R early", SCRIPT_PARAM_ONOFF, false)
      Menu.Combo:addParam("DontR", "Do not use FR, SR if Killable with Q or W", SCRIPT_PARAM_ONOFF, false)
      Menu.Combo:addParam("Blank5", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("AutoR", "Auto Second R on Combo", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Rmin", "Auto Second R Min Count", SCRIPT_PARAM_SLICE, 4, 2, 5, 0)
      Menu.Combo:addParam("Item", "Use Items", SCRIPT_PARAM_ONOFF, true)
      
  Menu:addSubMenu("Clear Settings", "Clear")  
  
    Menu.Clear:addSubMenu("Lane Clear Settings", "Farm")
    
      Menu.Clear.Farm:addParam("On", "Lane Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("TH", "Use Tiamat or Ravenous Hydra", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("THmin", "Use Item Min Count", SCRIPT_PARAM_SLICE, 3, 1, 6, 0)
        
    Menu.Clear:addSubMenu("Jungle Clear Settings", "JFarm")
    
      Menu.Clear.JFarm:addParam("On", "Jungle Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("TH", "Use Tiamat or Ravenous Hydra", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("THmin", "Use Item Min Count", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)
        
  Menu:addSubMenu("Harass Settings", "Harass")
  
    Menu.Harass:addParam("On", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Item", "Use Items", SCRIPT_PARAM_ONOFF, true)
      
  Menu:addSubMenu("LastHit Settings", "LastHit")
  
    Menu.LastHit:addParam("On", "LastHit Key 1", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
      Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
      Menu.LastHit:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)
      Menu.LastHit:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Orbwalk", "Use Orbwalk", SCRIPT_PARAM_ONOFF, true)
      
  Menu:addSubMenu("Jungle Steal Settings", "JSteal")
  
    Menu.JSteal:addParam("On", "Jungle Steal", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Q", "Use Q1, Q2", SCRIPT_PARAM_ONOFF, true)
      Menu.JSteal:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.JSteal:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("QW", "Use QW", SCRIPT_PARAM_ONOFF, true)
    if Smite ~= nil then
      Menu.JSteal:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("S", "Use Smite", SCRIPT_PARAM_ONOFF, true)
    end
    
  Menu:addSubMenu("KillSteal Settings", "KillSteal")
  
    Menu.KillSteal:addParam("On", "KillSteal", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("R", "Use Second R", SCRIPT_PARAM_ONOFF, true)
    if Ignite ~= nil then
      Menu.KillSteal:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("I", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
    end
    if Smite ~= nil then
      Menu.KillSteal:addParam("Blank5", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("S", "Use Stalker's Blade", SCRIPT_PARAM_ONOFF, true)
    end
    
  Menu:addSubMenu("AutoCast Settings", "Auto")
  
    Menu.Auto:addParam("On", "AutoCast", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoW", "Auto W", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Wmin", "Auto W Min Count", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
      Menu.Auto:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoR", "Auto Second R", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Rmin", "Auto Second R Min Count", SCRIPT_PARAM_SLICE, 5, 1, 5, 0)
    if Smite ~= nil then
      Menu.Auto:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoS", "Auto Smite", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey('N'))
    end
    
  Menu:addSubMenu("Flee Settings", "Flee")
  
    Menu.Flee:addParam("On", "Flee (Only Use KillSteal)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
    
  Menu:addSubMenu("Misc Settings", "Misc")
  
    if VIP_USER then
    Menu.Misc:addParam("UsePacket", "Use Packet", SCRIPT_PARAM_ONOFF, false)
    end
   
  Menu:addSubMenu("Draw Settings", "Draw")
  
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("R", "Draw R range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("S", "Draw Smite range", SCRIPT_PARAM_ONOFF, true)
      --Menu.Draw:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    --Menu.Draw:addParam("On2", "Use PermaShow", SCRIPT_PARAM_ONOFF, false)
    
    if Menu.Draw.On2 then
    
      Menu.Combo:permaShow("On")
      Menu.Clear.Farm:permaShow("On")
      Menu.Clear.JFarm:permaShow("On")
      Menu.Harass:permaShow("On")
      Menu.LastHit:permaShow("On")
      Menu.JSteal:permaShow("On")
      Menu.Flee:permaShow("On")
      
    end
    
  Menu:addTS(TS)
    
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnTick()

  if myHero.dead then
    return
  end
  
  Check()
  Target = SpellTarget()
  RTarget = SpellRTarget()
  
  if Menu.KillSteal.On then
    KillSteal()
  end
  
  if Menu.Auto.On then
    Auto()
  end
  
  if Menu.Combo.On then
    Combo()
  end
  
  if Menu.Clear.Farm.On then
    Farm()
  end
  
  if Menu.Clear.JFarm.On then
    JFarm()
  end
  
  if Menu.JSteal.On then
    JSteal()
  end
  
  if Menu.Harass.On then
    Harass()
  end
  
  if Menu.LastHit.On then
    LastHit()
  end
  
  if Menu.Flee.On then
    Flee()
  end
  
  if VIP_USER and Menu.Misc.Skin then
    Skin()
  end
  
  if Menu.Misc.AutoLevel then
    AutoLevel()
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Check()
  
  if CanTurn and os.clock()-LastQ > 0.2 then --0.35
    CanTurn = false
  end
  
  if not CanMove and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastAA > WindUpTime and os.clock()-LastQ > 0.25 and os.clock()-LastW > 0.2667 and os.clock()-LastE > 0.5 then
    CanMove = true
  end
  
  if not CanAA and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastAA > math.max(WindUpTime, AnimationTime) then
    CanAA = true
  end
  
  --[[if not CanQ and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-FirstQ > spell.cd then
    CanQ = true
  end]]
  
  if not CanW and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastW > 4.2 then
    CanW = true
  end
  
  if not CanE and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastE > 3.6 then
    CanE = true
  end
  
  if BeingAA and os.clock()-LastAA > WindUpTime then
    BeingAA = false
    CanMove = true
    CanQ = true
    CanW = true
    CanE = true
  end
  
  if BeingQ and os.clock()-LastQ > 0.25 then
    BeingQ = false
    CanMove = true
    CanAA = true
  end
  
  if BeingW and os.clock()-LastW > 0.2667 then
    BeingW = false
    CanMove = true
  end
  
  if BeingE and os.clock()-LastE > 0.5 then
    BeingE = false
    CanMove = true
  end
  
  if R.state and os.clock()-LastR > 15 then
    R.state = false
  end
  
  for _, item in pairs(Items) do
    item.slot = GetInventorySlotItem(item.id)
  end

  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  I.ready = Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY
  S.ready = Smite ~= nil and myHero:CanUseSpell(Smite) == READY
  Items["Tiamat"].ready = Items["Tiamat"].slot and myHero:CanUseSpell(Items["Tiamat"].slot) == READY
  Items["Hydra"].ready = Items["Hydra"].slot and myHero:CanUseSpell(Items["Hydra"].slot) == READY
  Items["Stalker"].ready = Smite ~= nil and (Items["Stalker"].slot or Items["StalkerW"].slot or Items["StalkerM"].slot or Items["StalkerJ"].slot or Items["StalkerD"].slot) and myHero:CanUseSpell(Smite) == READY
  
  EnemyMinions:update()
  JungleMobs:update()
  
  HealthPercent = (myHero.health/myHero.maxHealth)*100
  
  TrueRange = 125.5+GetDistance(myHero.minBBox, myHero)
  
  if Target ~=nil then
  
    local AddRange = GetDistance(Target.minBBox, Target)
    
    TrueTargetRange = TrueRange+AddRange
    TargetAddRange = AddRange
    
  end
  
  if RTarget ~= nil then
    RTargetHealthPercent = (RTarget.health/RTarget.maxHealth)*100
  end
  
  Q.level = player:GetSpellData(_Q).level
  W.level = player:GetSpellData(_W).level
  E.level = player:GetSpellData(_E).level
  R.level = player:GetSpellData(_R).level
  
end

----------------------------------------------------------------------------------------------------

function SpellTarget()

  TS:update()
  
  if TS.target then
    return TS.target
  end
  
end

function SpellRTarget()

  RTS:update()
  
  if RTS.target then
    return RTS.target
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Combo()

  Orbwalk(Combo)
  
  if RTarget == nil or not (Q.ready or W.ready or E.ready or R.ready) then
    return
  end
  
  local ComboQ = Menu.Combo.Q
  local ComboW = Menu.Combo.W
  local ComboE = Menu.Combo.E
  local ComboE2 = Menu.Combo.E2
  local ComboR = Menu.Combo.R
  local ComboFR = Menu.Combo.FR
  local ComboSR = Menu.Combo.SR
  local ComboRearly = Menu.Combo.Rearly
  local ComboDontR = Menu.Combo.DontR
  local ComboAutoR = Menu.Combo.AutoR
  local ComboItem = Menu.Combo.Item
  
  local QTargetDmg = GetDmg("Q", RTarget)
  local WTargetDmg = GetDmg("W", RTarget)
  local RTargetDmg = GetDmg("R", RTarget)
  
  if R.ready and R.state and ComboAutoR and ValidTarget(RTarget, R.range) then
    CastR2(RTarget, Combo)
  end
  
  if R.ready and R.state and ComboR and ComboSR ~= 1 then
  
    if ValidTarget(RTarget, R.range) then
    
      if ComboSR == 2 and RTargetDmg >= RTarget.health then
        CastR(RTarget)
        return
      elseif ComboSR == 3 and (RTargetDmg >= RTarget.health or 25 >= RTargetHealthPercent) then
        CastR(RTarget)
        return
      end
      
    end
    
    if ValidTarget(RTarget, Q.radius) then
    
      if ComboRearly and QTargetDmg+WTargetDmg+RTargetDmg >= RTarget.health then
        CastR(RTarget)
        DelayAction(function() CastQ(RTarget) end, 0.25)
        DelayAction(function() CastW() end, 0.5)
        return
      end
      
      if not ComboDontR then
      
        if Q.ready and ComboQ and W.ready and ComboW and QTargetDmg+WTargetDmg+RTargetDmg >= RTarget.health then
          CastQ(RTarget)
          DelayAction(function() CastW() end, 0.25)
          DelayAction(function() CastR(RTarget) end, 0.5167)
          return
        elseif Q.ready and ComboQ and QTargetDmg+RTargetDmg >= RTarget.health then
          CastQ(RTarget)
          DelayAction(function() CastR(RTarget) end, 0.25)
          return
        elseif W.ready and ComboW and WTargetDmg+RTargetDmg >= RTarget.health then
          CastW()
          DelayAction(function() CastR(RTarget) end, 0.2667)
          return
        end
        
      end
        
      elseif ComboDontR then
      
        if Q.ready and ComboQ and W.ready and ComboW and QTargetDmg+WTargetDmg >= RTarget.health then
          CastQ(RTarget)
          DelayAction(function() CastW() end, 0.25)
          return
        elseif Q.ready and ComboQ and QTargetDmg >= RTarget.health then
          CastQ(RTarget)
        elseif W.ready and ComboW and WTargetDmg >= RTarget.health and ValidTarget(RTarget, W.radius) then
          CastW()
        end
      
    end
    
  end
  
  if Target == nil then
    return
  end
  
  if E.ready and ComboE and ComboE2 <= HealthPercent and CanE then
  
    if GetDistance(Target, myHero) >= E.range-TrueTargetRange+50 and ValidTarget(Target, E.range+TrueTargetRange-50) then
      CastE(Target)
    elseif Q.ready and ComboQ and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, Q.radius+E.range-50) then
      CastE(Target)
      DelayAction(function() CastQ(Target) end, 0.5)
      return
    end
    
  end
  
  if Items["Tiamat"].ready and ComboItem and not BeingAA and os.clock()-LastE > 0.5 and ValidTarget(Target, Items["Tiamat"].range+TargetAddRange) then
    CastT()
  elseif Items["Hydra"].ready and ComboItem and not BeingAA and os.clock()-LastE > 0.5 and ValidTarget(Target, Items["Hydra"].range+TargetAddRange) then
    CastH()
  end
  
  if W.ready and ComboW and CanW and os.clock()-LastE > 0.5 and ValidTarget(Target, W.radius) then
    CastW()
  end
  
  if Q.ready and ComboQ and CanQ and os.clock()-LastE > 0.5 and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  elseif Q.ready and ComboQ and os.clock()-LastE > 0.5 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function Farm()

  Orbwalk(Farm)
  
  if not (Q.ready or W.ready or E.ready) then
    return
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil then
      return
    end
    
    local AddRange = GetDistance(minion.minBBox, minion)
    local TrueminionRange = TrueRange+AddRange
    
    local FarmQ = Menu.Clear.Farm.Q
    local FarmW = Menu.Clear.Farm.W
    local FarmE = Menu.Clear.Farm.E
    local FarmTH = Menu.Clear.Farm.TH
    local FarmTHmin = Menu.Clear.Farm.THmin
    
    local AAMinionDmg = GetDmg("AD", minion)
    local QMinionDmg = GetDmg("Q", minion)
    local WMinionDmg = GetDmg("W", minion)
    
    if E.ready and FarmE and CanE then
    
      if ValidTarget(minion, E.range+TrueminionRange-50) then
        CastE(minion)
      elseif Q.ready and JFarmQ and ValidTarget(junglemob, Q.radius+E.range-50) then
        CastE(minion)
        DelayAction(function() CastQ(minion) end, 0.5)
        return
      end
      
    end
    
    if Items["Tiamat"].ready and FarmTH and not BeingAA and os.clock()-LastE > 0.5 and FarmTHmin <= MinionCount(Items["Tiamat"].maxrange+AddRange) then
      CastT()
    elseif Items["Hydra"].ready and FarmTH and not BeingAA and os.clock()-LastE > 0.5 and FarmTHmin <= MinionCount(Items["Hydra"].maxrange+AddRange) then
      CastH()
    end
    
    if W.ready and FarmW and CanW and (WMinionDmg+AAMinionDmg <= minion.health or WMinionDmg >= minion.health) and os.clock()-LastE > 0.5 and ValidTarget(minion, W.radius) then
      CastW()
    end
    
    if Q.ready and FarmQ and CanQ and (QMinionDmg+AAMinionDmg <= minion.health or QMinionDmg >= minion.health) and os.clock()-LastE > 0.5 and ValidTarget(minion, Q.radius) then
      CastQ(minion)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function MinionCount(range)

  local count = 0
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion ~= nil and ValidTarget(minion, range) then
      count = count + 1
    end
    
  end
  
  return count
  
end

----------------------------------------------------------------------------------------------------

function JFarm()

  Orbwalk(JFarm)
  
  if not (Q.ready or W.ready or E.ready) then
    return
  end
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob == nil then
      return
    end
    
    local AddRange = GetDistance(junglemob.minBBox, junglemob)
    local TruejunglemobRange = TrueRange+AddRange
    
    local JFarmQ = Menu.Clear.JFarm.Q
    local JFarmW = Menu.Clear.JFarm.W
    local JFarmE = Menu.Clear.JFarm.E
    local JFarmTH = Menu.Clear.JFarm.TH
    local JFarmTHmin = Menu.Clear.JFarm.THmin
    
    if E.ready and JFarmE and CanE then
    
      if ValidTarget(junglemob, E.range+TruejunglemobRange-50) then
        CastE(junglemob)
      elseif Q.ready and JFarmQ and ValidTarget(junglemob, Q.radius+E.range-50) then
        CastE(junglemob)
        DelayAction(function() CastQ(junglemob) end, 0.5)
        return
      end
      
    end
    
    if Items["Tiamat"].ready and JFarmTH and not BeingAA and os.clock()-LastE > 0.5 and JFarmTHmin <= JungleMobCount(Items["Tiamat"].range+AddRange) then
      CastT()
    end
    
    if Items["Hydra"].ready and JFarmTH and not BeingAA and os.clock()-LastE > 0.5 and JFarmTHmin <= JungleMobCount(Items["Hydra"].range+AddRange) then
      CastH()
    end
    
    if Q.ready and JFarmQ and CanQ and W.ready and JFarmW and os.clock()-LastE > 0.5 and ValidTarget(junglemob, Q.radius) then --CanW and
      CastQ(junglemob)
      DelayAction(function() CastW() end, 0.25)
      return
    end
    
    if W.ready and JFarmW and CanW and os.clock()-LastE > 0.5 and ValidTarget(junglemob, W.radius) then
      CastW()
    end
    
    if Q.ready and JFarmQ and CanQ and os.clock()-LastE > 0.5 and ValidTarget(junglemob, Q.radius) then
      CastQ(junglemob)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function JungleMobCount(range)

  local count = 0
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob ~= nil and ValidTarget(junglemob, range) then
      count = count + 1
    end
    
  end
  
  return count
  
end

----------------------------------------------------------------------------------------------------

function JSteal()

  Orbwalk(JSteal)
  
  if not (Q.ready or W.ready or S.ready) then
    return
  end
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob == nil then
      return
    end
    
    local JStealQ = Menu.JSteal.Q
    local JStealW = Menu.JSteal.W
    local JStealQW = Menu.JSteal.QW
    local JStealS = Menu.JSteal.S
    
    local QjunglemobDmg = GetDmg("Q", junglemob)
    local WjunglemobDmg = GetDmg("W", junglemob)
    local SjunglemobDmg = GetDmg("SMITE", junglemob)
    
    if S.ready and JStealS then
    
      if SjunglemobDmg >= junglemob.health and ValidTarget(junglemob, S.range) then
        CastS(junglemob)
        return
      end
      
    elseif ValidTarget(junglemob, Q.radius) then
    
      if Q.ready and JStealQ and Q.state <=1 and W.ready and JStealW and QjunglemobDmg+WjunglemobDmg >= junglemob.health then
        CastQ(junglemob)
        DelayAction(function() CastW() end, 0.25)
        return
      elseif Q.ready and JStealQ and Q.state <=1 and QjunglemobDmg >= junglemob.health then
        CastQ(junglemob)
      elseif W.ready and JStealW and WjunglemobDmg >= junglemob.health and ValidTarget(junglemob, W.radius) then
        CastW()
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Harass()

  Orbwalk(Harass)
  
  if Target == nil or not (Q.ready or W.ready or E.ready) then
    return
  end
  
  local HarassQ = Menu.Harass.Q
  local HarassW = Menu.Harass.W
  local HarassE = Menu.Harass.E
  local HarassItem = Menu.Harass.Item
  
  if E.ready and HarassE and CanE then
  
    if GetDistance(Target, myHero) >= E.range-TrueTargetRange+50 and ValidTarget(Target, E.range+TrueTargetRange-50) then
      CastE(Target)
    elseif Q.ready and HarassQ and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, Q.radius+E.range-50) then
      CastE(Target)
      DelayAction(function() CastQ(Target) end, 0.5)
      return
    end
    
  end
  
  if Items["Tiamat"].ready and HarassItem and not BeingAA and os.clock()-LastE > 0.5 and ValidTarget(Target, Items["Tiamat"].range) then
    CastT()
  end
  
  if Items["Hydra"].ready and HarassItem and not BeingAA and os.clock()-LastE > 0.5 and ValidTarget(Target, Items["Hydra"].range) then
    CastH()
  end
  
  if W.ready and HarassW and CanW and os.clock()-LastE > 0.5 and ValidTarget(Target, W.radius) then
    CastW()
  end
  
  if Q.ready and HarassQ and CanQ and os.clock()-LastE > 0.5 and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  elseif Q.ready and HarassQ and os.clock()-LastE > 0.5 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function LastHit()

  local LastHitOrbwalk = Menu.LastHit.Orbwalk
  
  if LastHitOrbwalk then
    Orbwalk(LastHit)
  end
  
  if not (Q.ready or W.ready) then
    return
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil then
      return
    end
    
    local LastHitQ = Menu.LastHit.Q
    local LastHitW = Menu.LastHit.W
    
    local QminionDmg = GetDmg("Q", minion)
    local WminionDmg = GetDmg("W", minion)
    
    if W.ready and LastHitW and WminionDmg >= minion.health and ValidTarget(minion, W.radius) then
      CastW()
    end
    
    if Q.ready and LastHitQ and QminionDmg >= minion.health and ValidTarget(minion, Q.radius) then
      CastQ(minion)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function KillSteal()

  if RTarget == nil or not (Q.ready or W.ready or R.ready or I.ready or S.ready) then
    return
  end
  
  local KillStealR = Menu.KillSteal.R
  local KillStealI = Menu.KillSteal.I
  local KillStealS = Menu.KillSteal.S
  
  local RTargetDmg = GetDmg("R", RTarget)
  local ITargetDmg = GetDmg("IGNITE", RTarget)
  local SBTargetDmg = GetDmg("STALKER", RTarget)
  
  if R.ready and KillStealR and R.state and ComboSR ~= 1 and RTargetDmg >= RTarget.health and ValidTarget(RTarget, R.range) then
    CastR(RTarget)
  end
  
  if I.ready and KillStealI and ITargetDmg >= RTarget.health and ValidTarget(RTarget, I.range) then
    CastI(RTarget)
  end
  
  if Items["Stalker"].ready and KillStealS and SBTargetDmg >= RTarget.health and ValidTarget(RTarget, Items["Stalker"].range) then
    CastS(RTarget)
  end
  
  if Target == nil then
    return
  end
  
  local KillStealQ = Menu.KillSteal.Q
  local KillStealW = Menu.KillSteal.W
  
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  
  if W.ready and KillStealW and WTargetDmg >= Target.health and ValidTarget(Target, W.radius) then
    CastW(Target)
  end
  
  if Q.ready and KillStealQ and QTargetDmg >= Target.health and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function Auto()
  
  if Recall then
    return
  end
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob == nil or not S.ready then
      return
    end
    
    local AutoAutoS = Menu.Auto.AutoS
    
    local SjunglemobDmg = GetDmg("SMITE", junglemob)
    
    if S.ready and AutoAutoS and SjunglemobDmg >= junglemob.health and ValidTarget(junglemob, S.range) then
      CastS(junglemob)
    end
    
  end
  
  if RTarget == nil or not (W.ready or R.ready) then
    return
  end
  
  local AutoAutoW = Menu.Auto.AutoW
  local AutoWmin = Menu.Auto.Wmin
  local AutoAutoR = Menu.Auto.AutoR
  
  local ComboOn = Menu.Combo.On
  local HarassOn = Menu.Harass.On
  local JStealOn = Menu.JSteal.On
  
  if R.ready and R.state and AutoAutoR and ValidTarget(RTarget, R.range) then
    CastR2(RTarget, Auto)
  end
  
  if W.ready and AutoAutoW and not (ComboOn or HarassOn or JStealOn) and AutoWmin <= AutoEnemyCount(W.radius) then
    CastW()
  end
  
end

function AutoEnemyCount(range)

  local enemies = {}
  
  for _, enemy in ipairs(EnemyHeroes) do
  
    if ValidTarget(enemy, range) then
      table.insert(enemies, enemy)
    end
    
  end
  
  return #enemies, enemies
  
end

----------------------------------------------------------------------------------------------------

function Flee()

  Orbwalk(Flee)
  
  if Q.ready and os.clock()-LastE > 0.5 then
    CastQ(mousePos)
  end
  
  if E.ready and os.clock()-LastQ > 0.25 then
    CastE(mousePos)
  end
  
end

----------------------------------------------------------------------------------------------------

function AutoLevel()

  if Menu.Misc.ALOpt == 1 then
  
    if Q.level+W.level+E.level+R.level < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoQEQW[i]] = level[AutoQEQW[i]]+1
      end
      
      for i, v in ipairs({ Q.level, W.level, E.level, R.level }) do
      
        if v < level[i] then
          LevelSpell(spell[i])
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Orbwalk(State)

  if State == Flee then
    MoveToMouse()
    return
  end
  
  if CanAA and CanMove then
  
    if Target ~= nil and State == Combo and ValidTarget(Target, TrueTargetRange) then
      CanTurn = false
      CanMove = false
      CanQ = false
      CanW = false
      CanE = false
      CastAA(Target)
    elseif State == Farm then
    
      for i, minion in pairs(EnemyMinions.objects) do
      
        if minion == nil then
          return
        end
        
        local AddRange = GetDistance(minion.minBBox, minion)
        local TrueminionRange = TrueRange+AddRange
        
        local AAMinionDmg = GetDmg("AD", minion)
        
        if AAMinionDmg >= minion.health and ValidTarget(minion, TrueminionRange) then
          CanTurn = false
          CanMove = false
          CanQ = false
          CanW = false
          CanE = false
          CastAA(minion)
        end
        
      end
    
      for i, minion in pairs(EnemyMinions.objects) do
      
        if minion == nil then
          return
        end
        
        local AddRange = GetDistance(minion.minBBox, minion)
        local TrueminionRange = TrueRange+AddRange
        
        local AAMinionDmg = GetDmg("AD", minion)
        
        if minion.health >= 2*AAMinionDmg and ValidTarget(minion, TrueminionRange) then
          CanTurn = false
          CanMove = false
          CanQ = false
          CanW = false
          CanE = false
          CastAA(minion)
        end
        
      end
    
      for i, minion in pairs(EnemyMinions.objects) do
      
        if minion == nil then
          return
        end
        
        local AddRange = GetDistance(minion.minBBox, minion)
        local TrueminionRange = TrueRange+AddRange
        
        local AAMinionDmg = GetDmg("AD", minion)
        
        if ValidTarget(minion, TrueminionRange) then
          CanTurn = false
          CanMove = false
          CanQ = false
          CanW = false
          CanE = false
          CastAA(minion)
        end
        
      end
      
    elseif State == JFarm then
    
      for i, junglemob in pairs(JungleMobs.objects) do
      
        if junglemob == nil then
          return
        end
        
        local AddRange = GetDistance(junglemob.minBBox, junglemob)
        local TruejunglemobRange = TrueRange+AddRange
        
        if ValidTarget(junglemob, TruejunglemobRange) then
          CanTurn = false
          CanMove = false
          CanQ = false
          CanW = false
          CanE = false
          CastAA(junglemob)
        end
        
      end
    
    elseif Target ~= nil and State == Harass and ValidTarget(Target, TrueTargetRange) then
      CanTurn = false
      CanMove = false
      CanQ = false
      CanW = false
      CanE = false
      CastAA(Target)
    elseif State == LastHit then
    
      for i, minion in pairs(EnemyMinions.objects) do
      
        if minion == nil then
          return
        end
        
        local AddRange = GetDistance(minion.minBBox, minion)
        local TrueminionRange = TrueRange+AddRange
        
        local AAminionDmg = GetDmg("AD", minion)
        
        if AAminionDmg >= minion.health and ValidTarget(minion, TrueminionRange) then
          CanTurn = false
          CanMove = false
          CanQ = false
          CanW = false
          CanE = false
          CastAA(minion)
        end
        
      end
      
    end
    
  end
  
  if CanTurn then
    CancelPos = myHero+(Vector(mousePos)-myHero):normalized()*-300
    MoveToPos(CancelPos)
    return
  end
  
  if CanMove then
    MoveToMouse()
  end
  
end

----------------------------------------------------------------------------------------------------

function GetDmg(spell, enemy)

  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local AddDmg = myHero.addDamage
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local TargetLossHealth = 1-(enemy.health/enemy.maxHealth)
  
  if spell == "IGNITE" then
  
    local TrueDmg = 50+20*Level
    
    return TrueDmg
    
  elseif spell == "SMITE" then
  
    if Level <= 4 then
    
      local TrueDmg = 370+20*Level
      
      return TrueDmg
      
    elseif Level <= 9 then
    
      local TrueDmg = 330+30*Level
      
      return TrueDmg
      
    elseif Level <= 14 then
    
      local TrueDmg = 240+40*Level
      
      return TrueDmg
      
    else
    
      local TrueDmg = 100+50*Level
      
      return TrueDmg
      
    end
    
  elseif spell == "STALKER" then
  
    local TrueDmg = 20+8*Level
    
    return TrueDmg
    
  elseif spell == "AD" then
    PureDmg = TotalDmg
  elseif spell == "PAD" then
    PureDmg = TotalDmg+(20+math.floor(Level/3)*5)*TotalDmg/100
  elseif spell == "Q" then
    PureDmg = 20*Q.level-10+(.05*Q.level+.35)*TotalDmg
  elseif spell == "W" then
    PureDmg = 30*W.level+20+AddDmg
  elseif spell == "R" then
    PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+TargetLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
  end
  
  local TrueDmg = PureDmg*(1-ArmorPercent)
  
  return TrueDmg
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnDraw()

  if myHero.dead then
    return
  end

  if Menu.Draw.On then
  
    if Menu.Draw.AA then
      DrawCircle(Player.x, Player.y, Player.z, TrueRange, ARGB(0xFF,0,0xFF,0))
    end
    
    if Menu.Draw.Q then
      DrawCircle(Player.x, Player.y, Player.z, Q.range, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.W and W.ready then
      DrawCircle(Player.x, Player.y, Player.z, W.radius, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.E and E.ready then
      DrawCircle(Player.x, Player.y, Player.z, E.range, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.R and R.ready then
      DrawCircle(Player.x, Player.y, Player.z, R.range, ARGB(0xFF,0xFF,0,0))
    end
    
    if Menu.Draw.S and S.ready and ((Menu.Auto.On and Menu.Auto.AutoS) or (Menu.JSteal.On and Menu.JSteal.S)) then
      DrawCircle(Player.x, Player.y, Player.z, S.range, ARGB(0xFF,0xFF,0x14,0x93))
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function CastAA(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_MOVE", {sourceNetworkId = myHero.networkID, type = 7, x = enemy.x, y = enemy.z}):send()
  else
    myHero:Attack(enemy)
  end
  
  LastAA = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastQ(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _Q, toX = enemy.x, toY = enemy.z, fromX = enemy.x, fromY = enemy.z}):send()
  else
    CastSpell(_Q, enemy.x, enemy.z)
  end
  
  LastQ = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastW()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _W}):send()
  else
    CastSpell(_W)
  end
  
  LastW = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastE(Pos)

  if Pos == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E, toX = Pos.x, toY = Pos.z, fromX = Pos.x, fromY = Pos.z}):send()
  else
    CastSpell(_E, Pos.x, Pos.z)
  end
  
  LastE = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastR(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet('S_CAST', {spellId = _R, toX = enemy.x, toY = enemy.z, fromX = enemy.x, fromY = enemy.z}):send()
  else
    CastSpell(_R, enemy.x, enemy.z)
  end
  
  LastR = os.clock()
  
end

function CastR2(enemy, State)

  if enemy == nil then
    return
  end
  
  local AoECastPosition, MainTargetHitChance, NT = VP:GetConeAOECastPosition(enemy, R.delay, R.angle, R.range, R.speed, myHero, false)
  
  if State == Combo then
  
    if NT >= Menu.Combo.Rmin then
    
      if MainTargetHitChance >=2 then
        CastR(AoECastPosition)
      end
      
    end
    
  elseif State == Auto then
  
    if NT >= Menu.Auto.Rmin then
    
      if MainTargetHitChance >=2 then
        CastR(AoECastPosition)
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function CastI(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Ignite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Ignite, enemy)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastS(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Smite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Smite, enemy)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastT()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["Hydra"].slot}):send()
  else
    CastSpell(Items["Tiamat"].slot)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastH()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["Hydra"].slot}):send()
  else
    CastSpell(Items["Hydra"].slot)
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function MoveToPos(MovePos)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_MOVE", {MovePos.x, MovePos.z}):send()
  else
    myHero:MoveTo(MovePos.x, MovePos.z)
  end
  
end

function MoveToMouse()

  if GetDistance(mousePos) then
    MousePos = myHero+(Vector(mousePos)-myHero):normalized()*300
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_MOVE", {MousePos.x, MousePos.z}):send()
  else
    myHero:MoveTo(MousePos.x, MousePos.z)
  end
  
end

----------------------------------------------------------------------------------------------------

function OnProcessSpell(object, spell)

  if object.isMe then
  
    if spell.name:find("RivenBasicAttack" or "RivenBasicAttack2" or "RivenBasicAttack3") then
      LastAA = os.clock()
      BeingAA = true
      CanAA = false
      AnimationTime = spell.animationTime
      WindUpTime = spell.windUpTime+0.05
    end
    
    if spell.name:find("RivenTriCleave") then
      LastQ = os.clock()
      BeingQ = true
      
      if not Menu.Flee.On then
        CanTurn = true
      end
      
      CanQ = false
    end
    
    if spell.name:find("RivenMartyr") then
      LastW = os.clock()
      BeingW = true
      CanW = false
    end
    
    if spell.name:find("RivenFeint") then
      LastE = os.clock()
      BeingE = true
      CanE = false
    end
    
    if spell.name:find("RivenFengShuiEngine") then
      LastR = os.clock()
      R.state = true
    end
    
    if spell.name:find("rivenizunablade") then
      R.state = false
    end
    
  end
  
  --[[if object == nil or object.name ~= myHero.name then
    return
  end
  
  print("OnProcessSpell: "..spell.name)]]
  
end

--[[function OnGainBuff(unit, buff)

  if unit.isMe then
  
    if buff.name == "rivenpassiveaaboost" then
      P.stack = buff.stack
    end
    
    if buff.name == "RivenFengShuiEngine" then
      R.state = true
    end
    
    if buff.name == "RivenTriCleave" then
      Q.state = buff.stack
    end
    
    if buff.name == "recall" then
      Recall = true
    end
    
  end
  
  if unit == nil or unit.name ~= myHero.name then
    return
  end
  
  print("OnGainBuff: "..buff.name)
  
end

function OnLoseBuff(unit, buff)

  if unit.isMe then
  
    if buff.name == "rivenpassiveaaboost" then
      P.stack = buff.stack
    end
    
    if buff.name == "RivenTriCleave" then
      Q.state = 0
    end
    
    if buff.name == "recall" then
      Recall = false
    end
    
  end
  
  if unit == nil or unit.name ~= myHero.name then
    return
  end
  
  print("OnLoseBuff: "..buff.name)
  
end]]
