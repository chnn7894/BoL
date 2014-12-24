Version = "3.02"
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
  
else
  ScriptMsg("AutoUpdate: false")
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
  
  if myHero:GetSpellData(SUMMONER_1).name:find("summonerflash") then
    Flash = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerflash") then
    Flash = SUMMONER_2
  end
  
  AnimationTime = 1.6
  WindUpTime = 0
  BeingAA = false
  BeingQ = false
  BeingW = false
  BeingE = false
  StartFullCombo = false
  StartFullCombo2 = false
  StartFullCombo3 = false
  AfterCombo = true
  CanTurn = false
  CanMove = true
  CanAA = true
  CanQ = true
  CanW = true
  CanE = true
  CanFR = true
  CanSR = true
  LastAA = 0
  LastQ = 0
  LastW = 0
  LastE = 0
  LastFR = 0
  Recall = false
  
  P = {stack = 0}
  Q = {radius = 300, range = 225, level = 0, ready, state = 0}
  W = {radius = 250, level = 0, ready}
  E = {range = 250, level = 0, ready}
  R = {delay = 0, angle = 45, range = 900, speed = 1200, level = 0, ready, state = false}
  I = {range = 600, ready}
  S = {range = 760, ready}
  F = {range = 400, ready}
  
  Items =
  {
  ["Tiamat"] = {id=3077, range = 150, maxrange = 300, slot = nil, ready},
  ["Hydra"] = {id=3074, range = 150, maxrange = 300, slot = nil, ready},
  ["Stalker"] = {id=3706, range = 760, slot = nil, ready},
  ["StalkerW"] = {id=3707, slot = nil},
  ["StalkerM"] = {id=3708, slot = nil},
  ["StalkerJ"] = {id=3709, slot = nil},
  ["StalkerD"] = {id=3710, slot = nil}
  }
  
  MyFirstminBBox = 39.44
  TrueRange = myHero.range+MyFirstminBBox
  TrueTargetRange = TrueRange
  TargetAddRange = 0
  KSTargetAddRange = 0
  TrueminionRange = TrueRange
  TruejunglemobRange = TrueRange
  
  AutoEQWQ = {3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3}
  
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
  TS = TargetSelector(TARGET_NEAR_MOUSE, R.range, DAMAGE_PHYSICAL, false)
  KSTS = TargetSelector(TARGET_LESS_CAST, R.range, DAMAGE_PHYSICAL, false)
  
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
      
  Menu:addSubMenu("Full Combo Settings", "FCombo")
  
    Menu.FCombo:addParam("On", "Full Combo (ERFW>AA>Item>RQ)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))
      Menu.FCombo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.FCombo:addParam("F", "Use Flash (F)", SCRIPT_PARAM_ONOFF, true)
    
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
    Menu.Misc:addParam("AutoLevel", "Auto Level Spells", SCRIPT_PARAM_ONOFF, false)
    Menu.Misc:addParam("ALOpt", "Skill order : ", SCRIPT_PARAM_LIST, 1, {"R>Q>W>E (EQWQ)"})
    
  Menu:addSubMenu("Draw Settings", "Draw")
  
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("R", "Draw R range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("S", "Draw Smite range", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addTS(TS)
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnTick()

  if myHero.dead then
    return
  end
  
  Check()
  Target = NormalTarget()
  KSTarget = KsTarget()
  
  if Menu.KillSteal.On then
    KillSteal()
  end
  
  if Menu.Auto.On then
    Auto()
  end
  
  if Menu.Combo.On then
    Combo()
  end
  
  if Menu.FCombo.On then
    FCombo()
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
  
  if Menu.Misc.AutoLevel then
    AutoLevel()
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Check()

  if BeingAA and os.clock()-LastAA >= WindUpTime then
    BeingAA = false
    DelayAction(function() CanMove = true end, 0.002)
    CanQ = true
    CanW = true
    CanE = true
    CanFR = true
    CanSR = true
  end
  
  if BeingQ and os.clock()-LastQ >= 0.25+0.15 then
    BeingQ = false
    CanMove = true
    CanAA = true
  end
  
  if BeingW and os.clock()-LastW >= 0.2667 then
    BeingW = false
    CanMove = true
  end
  
  if BeingE and os.clock()-LastE >= 0.5 then
    BeingE = false
    CanMove = true
  end
  
  if not CanMove and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastAA >= WindUpTime then
    CanMove = true
  end
  
  if not CanAA and not (BeingQ or BeingW or BeingE) and os.clock()-LastAA >= AnimationTime then
    CanAA = true
  end
  
  --[[if not CanQ and not (BeingAA or BeingW or BeingE) and os.clock()-FirstQ > 13*(1-myHero.cdr) then
    CanQ = true
  end]]
  
  if not CanW and not (BeingAA or BeingQ or BeingE) and W.ready then
    CanW = true
  end
  
  if not CanE and not (BeingAA or BeingQ or BeingW) and E.ready then
    CanE = true
  end
  
  if not CanFR and not BeingAA and not R.state and R.ready then
    CanFR = true
  end
  
  if not CanSR and not BeingAA and R.state and R.ready then
    CanSR = true
  end
  
  if R.state and os.clock()-LastFR >= 15 then
    R.state = false
  end
  
  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  I.ready = Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY
  S.ready = Smite ~= nil and myHero:CanUseSpell(Smite) == READY
  F.ready = Flash ~= nil and myHero:CanUseSpell(Flash) == READY
  
  for _, item in pairs(Items) do
    item.slot = GetInventorySlotItem(item.id)
  end
  
  Items["Tiamat"].ready = Items["Tiamat"].slot and myHero:CanUseSpell(Items["Tiamat"].slot) == READY
  Items["Hydra"].ready = Items["Hydra"].slot and myHero:CanUseSpell(Items["Hydra"].slot) == READY
  Items["Stalker"].ready = Smite ~= nil and (Items["Stalker"].slot or Items["StalkerW"].slot or Items["StalkerM"].slot or Items["StalkerJ"].slot or Items["StalkerD"].slot) and myHero:CanUseSpell(Smite) == READY
  
  EnemyMinions:update()
  JungleMobs:update()
  
  HealthPercent = (myHero.health/myHero.maxHealth)*100
  
  if R.state then
    Q.radius = 400
    Q.range = 325
    W.radius = 270
  elseif not R.state then
    Q.radius = 300
    Q.range = 225
    W.radius = 250
  end
  
  TrueRange = myHero.range+GetDistance(myHero.minBBox, myHero)
  
  if Target ~=nil then
  
    local AddRange = GetDistance(Target.minBBox, Target)
    
    TrueTargetRange = TrueRange+AddRange
    TargetAddRange = AddRange
    
  end
  
  if KSTarget ~= nil then
    KSTargetHealthPercent = (KSTarget.health/KSTarget.maxHealth)*100
    KSTargetAddRange = GetDistance(KSTarget.minBBox, KSTarget)
  end
  
  Q.level = player:GetSpellData(_Q).level
  W.level = player:GetSpellData(_W).level
  E.level = player:GetSpellData(_E).level
  R.level = player:GetSpellData(_R).level
  
end

----------------------------------------------------------------------------------------------------

function NormalTarget()

  TS:update()
  
  if TS.target then
    return TS.target
  end
  
end

function KsTarget()

  KSTS:update()
  
  if KSTS.target then
    return KSTS.target
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Combo()

  Orbwalk(Combo)
  
  if KSTarget == nil then
    return
  end
  
  local ComboItem = Menu.Combo.Item
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
  
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  local RTargetDmg = GetDmg("R", Target)
  local QRTargetDmg = RGetDmg("QR", Target)
  local WRTargetDmg = RGetDmg("WR", Target)
  local QWRTargetDmg = RGetDmg("QWR", Target)
  local RKSTargetDmg = GetDmg("R", KSTarget)
  local SBKSTargetDmg = GetDmg("STALKER", KSTarget)
  
  if Items["Stalker"].ready and ComboItem and SBKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Items["Stalker"].range) then
    CastS(KSTarget)
  end
  
  if R.ready and R.state and ComboAutoR and ValidTarget(KSTarget, R.range) then
    CastR2(KSTarget, Combo)
  end
  
  if R.ready and R.state and ComboR and ComboSR ~= 1 then
  
    if ValidTarget(KSTarget, R.range) then
    
      if ComboSR == 2 and RKSTargetDmg >= KSTarget.health then
        CastSR(KSTarget)
        return
      elseif ComboSR == 3 and (RKSTargetDmg >= KSTarget.health or 25 >= KSTargetHealthPercent) then
        CastSR(KSTarget)
        return
      end
      
    end
    
    if ValidTarget(Target, Q.radius) then
    
      if ComboRearly and RTargetDmg+QTargetDmg+WTargetDmg >= Target.health then
        CastSR(Target)
        DelayAction(function() CastQ(Target) end, 0.25)
        DelayAction(function() CastW() end, 0.5)
        return
      end
      
      if not ComboDontR then
      
        if Q.ready and ComboQ and W.ready and ComboW and QTargetDmg+WTargetDmg+QWRTargetDmg >= Target.health then
          CastQ(Target)
          DelayAction(function() CastW() end, 0.25)
          DelayAction(function() CastSR(Target) end, 0.5167)
        elseif Q.ready and ComboQ and QTargetDmg+QRTargetDmg >= Target.health then
          CastQ(Target)
          DelayAction(function() CastSR(Target) end, 0.25)
        elseif W.ready and ComboW and WTargetDmg+WRTargetDmg >= Target.health and ValidTarget(Target, W.radius) then
          CastW()
          DelayAction(function() CastSR(Target) end, 0.2667)
        end
        
      elseif ComboDontR then
      
        if Q.ready and ComboQ and W.ready and ComboW and QTargetDmg+WTargetDmg >= Target.health then
          CastQ(Target)
          DelayAction(function() CastW() end, 0.25)
        elseif Q.ready and ComboQ and QTargetDmg >= Target.health then
          CastQ(Target)
        elseif W.ready and ComboW and WTargetDmg >= Target.health and ValidTarget(Target, W.radius) then
          CastW()
        end
        
      end
      
    end
    
  end
  
  if Target == nil then
    return
  end
  
  if CanTurn then
    CancelPos = myHero+(Vector(Target)-myHero):normalized()*300
    MoveToPos(CancelPos)
    CanTurn = false
  end
  
  if Items["Tiamat"].ready and ComboItem and not BeingAA and ValidTarget(Target, Items["Tiamat"].range+TargetAddRange) then
    CastT()
  elseif Items["Hydra"].ready and ComboItem and not BeingAA and ValidTarget(Target, Items["Hydra"].range+TargetAddRange) then
    CastH()
  end
  
  if not (Q.ready or W.ready or E.ready) then
    return
  end
  
  if E.ready and ComboE and ComboE2 <= HealthPercent and CanE then
  
    if not ValidTarget(Target, E.range-TrueTargetRange+50)--[[GetDistance(Target, myHero) >= E.range-TrueTargetRange+50]] and ValidTarget(Target, E.range+TrueTargetRange-50) then
      CastE(Target)
    elseif Q.ready and ComboQ and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, Q.radius+E.range-50) then
      CastE(Target)
    end
    
  end
  
  if W.ready and ComboW and CanW and os.clock()-LastE >= 0.25 and ValidTarget(Target, W.radius) then
    CastW()
  elseif Q.ready and ComboQ and CanQ and os.clock()-LastE >= 0.25 and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  elseif Q.ready and ComboQ and os.clock()-LastE >= 0.25 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function FCombo()

  Orbwalk(FCombo)
  
  if Target == nil then
    return
  end
    
  local ADTargetDmg = GetDmg("AD", Target)
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  local FCRTargetDmg = RGetDmg("FCR", Target)
  
  local RADTargetDmg = GetDmg("RAD", Target)
  local RQTargetDmg = GetDmg("RQ", Target)
  local RWTargetDmg = GetDmg("RW", Target)
  local RFCRTargetDmg = RGetDmg("RFCR", Target)
  
  local SBTargetDmg = GetDmg("STALKER", Target)
  
  local FComboF = Menu.FCombo.F
  
  if Items["Stalker"].ready and SBTargetDmg >= Target.health and ValidTarget(Target, Items["Stalker"].range) then
    CastS(Target)
  end
  
  if Q.ready and W.ready and E.ready and R.ready then
  
    AfterCombo = false
    
    if not R.state then
    
      if FComboF and F.ready and ValidTarget(Target, E.range+F.range+W.radius-50) then
        CastE(Target)
        DelayAction(function() CastFR() end, 0.2)
        DelayAction(function() CastF(Target) end, 0.25)
      elseif not (FComboF and F.ready) and ValidTarget(Target, E.range+W.radius-50) then
        CastE(Target)
        DelayAction(function() CastFR() end, 0.25)
      end
      
    elseif R.state then
    
      if FComboF and F.ready and ValidTarget(Target, E.range+F.range+W.radius-50) then
        CastE(Target)
        DelayAction(function() CastF(Target) end, 0.25)
      elseif not (FComboF and F.ready) and ValidTarget(Target, E.range+W.radius-50) then
        CastE(Target)
      end
      
    end
    
  end
  
  if not AfterCombo then
    
    if StartFullCombo and ValidTarget(Target, W.radius) then
      CastW()
    end
    
    if Items["Tiamat"].ready and not BeingAA and ValidTarget(Target, Items["Tiamat"].range+TargetAddRange) then
      CastT()
    elseif Items["Hydra"].ready and not BeingAA and ValidTarget(Target, Items["Hydra"].range+TargetAddRange) then
      CastH()
    end
    
    if StartFullCombo2 and R.state and CanSR then
      CastSR(Target)
    end
    
    if StartFullCombo3 then
      CastQ(Target)
    end
    
  elseif AfterCombo then
  
    if CanTurn then
      CancelPos = myHero+(Vector(Target)-myHero):normalized()*-500
      MoveToPos(CancelPos)
      CanTurn = false
    end
    
    if Items["Tiamat"].ready and not BeingAA and ValidTarget(Target, Items["Tiamat"].range+TargetAddRange) then
      CastT()
    elseif Items["Hydra"].ready and not BeingAA and ValidTarget(Target, Items["Hydra"].range+TargetAddRange) then
      CastH()
    end
    
    if not (Q.ready or W.ready or E.ready) then
      return
    end
    
    if E.ready and CanE then
    
      if not ValidTarget(Target, E.range-TrueTargetRange+50)--[[GetDistance(Target, myHero) >= E.range-TrueTargetRange+50]] and ValidTarget(Target, E.range+TrueTargetRange-50) then
        CastE(Target)
      elseif Q.ready and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, Q.radius+E.range-50) then
        CastE(Target)
      end
      
    end
    
    if W.ready and CanW and os.clock()-LastE >= 0.25 and ValidTarget(Target, W.radius) then
      CastW()
    elseif Q.ready and CanQ and os.clock()-LastE >= 0.25 and ValidTarget(Target, Q.radius) then
      CastQ(Target)
    elseif Q.ready and os.clock()-LastE >= 0.25 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, Q.radius) then
      CastQ(Target)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Farm()

  Orbwalk(Farm)
  
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

    if CanTurn then
      CancelPos = myHero+(Vector(minion)-myHero):normalized()*-500
      MoveToPos(CancelPos)
      CanTurn = false
    end
    
    if Items["Tiamat"].ready and FarmTH and not BeingAA and os.clock()-LastE >= 0.5 and FarmTHmin <= MinionCount(Items["Tiamat"].maxrange+AddRange) then
      CastT()
    elseif Items["Hydra"].ready and FarmTH and not BeingAA and os.clock()-LastE >= 0.5 and FarmTHmin <= MinionCount(Items["Hydra"].maxrange+AddRange) then
      CastH()
    end
    
    if not (Q.ready or W.ready or E.ready) then
      return
    end
    
    if E.ready and FarmE and CanE then
    
      if Q.ready and FarmQ and ValidTarget(minion, Q.radius+E.range+AddRange-50) then
        CastE(minion)
      elseif ValidTarget(minion, E.range+TrueminionRange-50) then
        CastE(minion)
      end
      
    end
    
    if W.ready and FarmW and CanW and (WMinionDmg+AAMinionDmg <= minion.health or WMinionDmg >= minion.health) and os.clock()-LastE > 0.25 and ValidTarget(minion, W.radius) then
      CastW()
    elseif Q.ready and FarmQ and CanQ and (QMinionDmg+AAMinionDmg <= minion.health or QMinionDmg >= minion.health) and ValidTarget(minion, Q.radius) then
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
    
    if CanTurn then
      CancelPos = myHero+(Vector(junglemob)-myHero):normalized()*-500
      MoveToPos(CancelPos)
      CanTurn = false
    end
    
    if Items["Tiamat"].ready and JFarmTH and not BeingAA and os.clock()-LastE >= 0.5 and JFarmTHmin <= JungleMobCount(Items["Tiamat"].range+AddRange) then
      CastT()
    end
    
    if Items["Hydra"].ready and JFarmTH and not BeingAA and os.clock()-LastE >= 0.5 and JFarmTHmin <= JungleMobCount(Items["Hydra"].range+AddRange) then
      CastH()
    end
    
    if not (Q.ready or W.ready or E.ready) then
      return
    end
    
    if E.ready and JFarmE and CanE then
    
      if Q.ready and JFarmQ and ValidTarget(junglemob, Q.radius+E.range+AddRange-50) then
        CastE(junglemob)
      elseif ValidTarget(junglemob, E.range+TruejunglemobRange-50) then
        CastE(junglemob)
      end
      
    end
    
    if W.ready and JFarmW and CanW and os.clock()-LastE > 0.5 and ValidTarget(junglemob, W.radius) then
      CastW()
    elseif Q.ready and JFarmQ and CanQ and ValidTarget(junglemob, Q.radius) then
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
      end
      
    elseif ValidTarget(junglemob, Q.radius) then
    
      if not (Q.ready or W.ready) then
        return
      end
      
      if Q.ready and JStealQ and Q.state <=1 and W.ready and JStealW and QjunglemobDmg+WjunglemobDmg >= junglemob.health then
        CastQ(junglemob)
        DelayAction(function() CastW() end, 0.25)
      elseif W.ready and JStealW and WjunglemobDmg >= junglemob.health and ValidTarget(junglemob, W.radius) then
        CastW()
      elseif Q.ready and JStealQ and Q.state <=1 and QjunglemobDmg >= junglemob.health then
        CastQ(junglemob)
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Harass()

  Orbwalk(Harass)
  
  if Target == nil then
    return
  end
  
  local HarassItem = Menu.Harass.Item
  local HarassQ = Menu.Harass.Q
  local HarassW = Menu.Harass.W
  local HarassE = Menu.Harass.E
  
  if CanTurn then
    CancelPos = myHero+(Vector(Target)-myHero):normalized()*300
    MoveToPos(CancelPos)
    CanTurn = false
  end
  
  if Items["Tiamat"].ready and HarassItem and not BeingAA and ValidTarget(Target, Items["Tiamat"].range) then
    CastT()
  end
  
  if Items["Hydra"].ready and HarassItem and not BeingAA and ValidTarget(Target, Items["Hydra"].range) then
    CastH()
  end
  
  if not (Q.ready or W.ready or E.ready) then
    return
  end
  
  if E.ready and HarassE and CanE then
  
    if GetDistance(Target, myHero) >= E.range-TrueTargetRange+50 and ValidTarget(Target, E.range+TrueTargetRange-50) then
      CastE(Target)
    elseif Q.ready and HarassQ and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, Q.radius+E.range-50) then
      CastE(Target)
    end
    
  end
  
  if W.ready and HarassW and CanW and os.clock()-LastE > 0.25 and ValidTarget(Target, W.radius) then
    CastW()
  elseif Q.ready and HarassQ and CanQ and os.clock()-LastE > 0.25 and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  elseif Q.ready and HarassQ and os.clock()-LastE > 0.25 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function LastHit()

  local LastHitOrbwalk = Menu.LastHit.Orbwalk
  
  if LastHitOrbwalk then
    Orbwalk(LastHit)
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil then
      return
    end
    
    local LastHitQ = Menu.LastHit.Q
    local LastHitW = Menu.LastHit.W
    
    local QminionDmg = GetDmg("Q", minion)
    local WminionDmg = GetDmg("W", minion)
  
    if CanTurn then
      CancelPos = myHero+(Vector(minion)-myHero):normalized()*-500
      MoveToPos(CancelPos)
      CanTurn = false
    end
    
    if not (Q.ready or W.ready) then
      return
    end
    
    if W.ready and LastHitW and WminionDmg >= minion.health and ValidTarget(minion, W.radius) then
      CastW()
    elseif Q.ready and LastHitQ and QminionDmg >= minion.health and ValidTarget(minion, Q.radius) then
      CastQ(minion)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function KillSteal()

  if KSTarget == nil or not (Q.ready or W.ready or R.ready or I.ready or S.ready) then
    return
  end
  
  local KillStealQ = Menu.KillSteal.Q
  local KillStealW = Menu.KillSteal.W
  local KillStealR = Menu.KillSteal.R
  local KillStealI = Menu.KillSteal.I
  local KillStealS = Menu.KillSteal.S
  
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  local RTargetDmg = GetDmg("R", KSTarget)
  local ITargetDmg = GetDmg("IGNITE", KSTarget)
  local SBTargetDmg = GetDmg("STALKER", KSTarget)
  
  if R.ready and KillStealR and R.state and ComboSR ~= 1 and RTargetDmg >= KSTarget.health and ValidTarget(KSTarget, R.range) then
    CastSR(KSTarget)
  end
  
  if I.ready and KillStealI and ITargetDmg >= KSTarget.health and ValidTarget(KSTarget, I.range) then
    CastI(KSTarget)
  end
  
  if Items["Stalker"].ready and KillStealS and SBTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Items["Stalker"].range) then
    CastS(KSTarget)
  end
  
  if not (Q.ready or W.ready) then
    return
  end
  
  if W.ready and KillStealW and WTargetDmg >= KSTarget.health and ValidTarget(KSTarget, W.radius) then
    CastW(KSTarget)
  elseif Q.ready and KillStealQ and QTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Q.radius) then
    CastQ(KSTarget)
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
  
  if KSTarget == nil or not (W.ready or R.ready) then
    return
  end
  
  local AutoAutoW = Menu.Auto.AutoW
  local AutoWmin = Menu.Auto.Wmin
  local AutoAutoR = Menu.Auto.AutoR
  
  local ComboOn = Menu.Combo.On
  local FComboOn = Menu.FCombo.On
  local HarassOn = Menu.Harass.On
  local JStealOn = Menu.JSteal.On
  
  if FComboOn then
    return
  end
  
  if R.ready and R.state and AutoAutoR and ValidTarget(KSTarget, R.range) then
    CastR2(KSTarget, Auto)
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

  MoveToMouse()
  
  if E.ready and os.clock()-LastQ > 0.25 then
    CastE(mousePos)
    LastE = os.clock()
  elseif Q.ready and os.clock()-LastE > 0.25 then
    CastQ(mousePos)
    LastQ = os.clock()
  end
  
end

----------------------------------------------------------------------------------------------------

function AutoLevel()

  if Menu.Misc.ALOpt == 1 then
  
    if Q.level+W.level+E.level+R.level < player.level then
    
      local spell = {SPELL_1, SPELL_2, SPELL_3, SPELL_4}
      local level = {0, 0, 0, 0}
      
      for i = 1, player.level, 1 do
        level[AutoEQWQ[i]] = level[AutoEQWQ[i]]+1
      end
      
      for i, v in ipairs({Q.level, W.level, E.level, R.level}) do
      
        if v < level[i] then
          LevelSpell(spell[i])
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Orbwalk(State)

  if Menu.Flee.On then
    return
  end
  
  if CanAA and CanMove then
  
    if Target ~= nil and (State == Combo or State == FCombo or State == Harass) and ValidTarget(Target, TrueTargetRange) then
      OrbCastAA(Target)
      return
    elseif State == Farm then
    
      for i, minion in pairs(EnemyMinions.objects) do
      
        if minion == nil then
          return
        end
        
        local AddRange = GetDistance(minion.minBBox, minion)
        local TrueminionRange = TrueRange+AddRange
        
        local AAMinionDmg = GetDmg("AD", minion)
        
        if AAMinionDmg >= minion.health and ValidTarget(minion, TrueminionRange) then
          OrbCastAA(minion)
          return
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
          OrbCastAA(minion)
          return
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
          OrbCastAA(minion)
          return
        end
        
      end
      
    elseif State == JFarm then
    
      for i, junglemob in pairs(JungleMobs.objects) do
      
        if junglemob == nil then
          return
        end
        
        --if GetDistance(
        
        local AddRange = GetDistance(junglemob.minBBox, junglemob)
        local TruejunglemobRange = TrueRange+AddRange
        
        if ValidTarget(junglemob, TruejunglemobRange) then
          OrbCastAA(junglemob)
          return
        end
        
      end
    
    elseif State == LastHit then
    
      for i, minion in pairs(EnemyMinions.objects) do
      
        if minion == nil then
          return
        end
        
        local AddRange = GetDistance(minion.minBBox, minion)
        local TrueminionRange = TrueRange+AddRange
        
        local AAminionDmg = GetDmg("AD", minion)
        
        if AAminionDmg >= minion.health and ValidTarget(minion, TrueminionRange) then
          OrbCastAA(minion)
          return
        end
        
      end
      
    end
    
  end
  
  if CanMove then
    MoveToMouse()
  end
  
end

----------------------------------------------------------------------------------------------------

function OrbCastAA(enemy)
  CanMove = false
  CastAA(enemy)
  CanQ = false
  CanW = false
  CanE = false
  CanFR = false
  CanSR = false
  LastAA = os.clock()
end

----------------------------------------------------------------------------------------------------

function GetDmg(spell, enemy)

  if enemy == nil then
    return
  end

  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local RTotalDmg = 1.2*TotalDmg
  local AddDmg = myHero.addDamage
  local RAddDmg = AddDmg+0.2*TotalDmg
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
  elseif spell == "RAD" then
    PureDmg = TotalDmg+(20+math.floor(Level/3)*5)*RTotalDmg/100
  elseif spell == "Q" then
    PureDmg = 20*Q.level-10+(.05*Q.level+.35)*TotalDmg
  elseif spell == "RQ" then
    PureDmg = 20*Q.level-10+(.05*Q.level+.35)*RTotalDmg
  elseif spell == "W" then
    PureDmg = 30*W.level+20+AddDmg
  elseif spell == "RW" then
    PureDmg = 30*W.level+20+RAddDmg
  elseif spell == "R" then
    PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+TargetLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
  end
  
  local TrueDmg = PureDmg*(1-ArmorPercent)
  
  return TrueDmg
  
end

function RGetDmg(spell, enemy)

  if enemy == nil then
    return
  end
  
  local TotalDmg = myHero.totalDamage
  local AddDmg = myHero.addDamage
  local RAddDmg = AddDmg+0.2*TotalDmg
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
    
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  
  local ADTargetDmg = GetDmg("AD", enemy)
  local QTargetDmg = GetDmg("Q", enemy)
  local WTargetDmg = GetDmg("W", enemy)
  local RADTargetDmg = GetDmg("RAD", enemy)
  local RQTargetDmg = GetDmg("RQ", enemy)
  local RWTargetDmg = GetDmg("RW", enemy)
  
  local QREnemyHealth = enemy.health-QTargetDmg
  local WREnemyHealth = enemy.health-WTargetDmg
  local QWREnemyHealth = enemy.health-QTargetDmg-WTargetDmg
  local FCREnemyHealth = enemy.health-WTargetDmg-ADTargetDmg-QTargetDmg
  local RFCREnemyHealth = enemy.health-RWTargetDmg-RADTargetDmg-RQTargetDmg
  
  local QRTargetLossHealth = 1-(QREnemyHealth/enemy.maxHealth)
  local WRTargetLossHealth = 1-(WREnemyHealth/enemy.maxHealth)
  local QWRTargetLossHealth = 1-(QWREnemyHealth/enemy.maxHealth)
  local FCRTargetLossHealth = 1-(FCREnemyHealth/enemy.maxHealth)
  local RFCRTargetLossHealth = 1-(RFCREnemyHealth/enemy.maxHealth)
  
  if spell == "QR" then
    PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+QRTargetLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
  elseif spell == "WR" then
    PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+WRTargetLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
  elseif spell == "QWR" then
    PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+QWRTargetLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
  elseif spell == "FCR" then
    PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+FCRTargetLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
  elseif spell == "RFCR" then
    PureDmg = math.min((40*R.level+40+.6*RAddDmg)*(1+RFCRTargetLossHealth*(8/3)),120*R.level+120+1.8*RAddDmg)
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
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_MOVE", {sourceNetworkId = myHero.networkID, type = 7, x = enemy.x, y = enemy.z}):send()
  else
    myHero:Attack(enemy)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastQ(enemy)
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _Q, toX = enemy.x, toY = enemy.z, fromX = enemy.x, fromY = enemy.z}):send()
  else
    CastSpell(_Q, enemy.x, enemy.z)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastW()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _W}):send()
  else
    CastSpell(_W)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastE(Pos)
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E, toX = Pos.x, toY = Pos.z, fromX = Pos.x, fromY = Pos.z}):send()
  else
    CastSpell(_E, Pos.x, Pos.z)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastFR()

  if R.state then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet('S_CAST', {spellId = _R}):send()
  else
    CastSpell(_R)
  end
  
end

function CastSR(enemy)

  if not R.state then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet('S_CAST', {spellId = _R, toX = enemy.x, toY = enemy.z, fromX = enemy.x, fromY = enemy.z}):send()
  else
    CastSpell(_R, enemy.x, enemy.z)
  end
  
end

function CastR2(enemy, State)
  
  local AoECastPosition, MainTargetHitChance, NT = VP:GetConeAOECastPosition(enemy, R.delay, R.angle, R.range, R.speed, myHero, false)
  
  if State == Combo then
  
    if NT >= Menu.Combo.Rmin then
    
      if MainTargetHitChance >=2 then
        CastSR(AoECastPosition)
      end
      
    end
    
  elseif State == Auto then
  
    if NT >= Menu.Auto.Rmin then
    
      if MainTargetHitChance >=2 then
        CastSR(AoECastPosition)
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function CastI(enemy)
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Ignite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Ignite, enemy)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastS(enemy)
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Smite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Smite, enemy)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastF(Pos)
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Flash, toX = Pos.x, toY = Pos.z, fromX = Pos.x, fromY = Pos.z}):send()
  else
    CastSpell(Flash, Pos.x, Pos.z)
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
  
    if not BeingQ and spell.name:find("RivenBasicAttack" or "RivenBasicAttack2" or "RivenBasicAttack3") then
      AnimationTime = spell.animationTime
      WindUpTime = spell.windUpTime
      BeingAA = true
      CanAA = false
      LastAA = os.clock()
    end
    
    if spell.name:find("RivenTriCleave") then
      BeingQ = true
      
      if not Menu.Flee.On then
        DelayAction(function() CanTurn = true end, 0.2)
        CanMove = false
      end
      CanQ = false
      StartFullCombo = false
      StartFullCombo2 = false
      StartFullCombo3 = false
      AfterCombo = true
      LastQ = os.clock()
    end
    
    if spell.name:find("RivenMartyr") then
      BeingW = true
      CanW = false
      StartFullCombo = false
      StartFullCombo2 = true
      LastW = os.clock()
    end
    
    if spell.name:find("RivenFeint") then
      BeingE = true
      CanE = false
      LastE = os.clock()
    end
    
    if spell.name:find("RivenFengShuiEngine") then
      R.state = true
      CanFR = false
      StartFullCombo = true
      LastFR = os.clock()
    end
    
    if spell.name:find("rivenizunablade") then
      R.state = false
      CanSR = false
      StartFullCombo2 = false
      StartFullCombo3 = true
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
