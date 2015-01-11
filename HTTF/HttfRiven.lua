Version = "3.16"
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
  
  DelayAction(function() AnimationTime = 1/(0.625*myHero.attackSpeed) end, 20)
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
  CanSR = true
  FCDamage = {}
  LastAA = 0
  LastP = 0
  LastQ = 0
  LastQ2 = 0
  LastW = 0
  LastE = 0
  LastDraw = 0
  Recall = false
  
  P = {stack = 0}
  Q = {radius = 300, range = 225, level = 0, ready, state = 0}
  W = {radius = 250, level = 0, ready}
  E = {range = 250, level = 0, ready}
  R = {delay = 0, angle = 45, range = 900, speed = 1200, level = 0, ready, state = false}
  I = {range = 600, ready}
  S = {range = 760, ready}
  F = {range = 400, ready}
  
  AutoEQWQ = {3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3}
  AutoQEWQ = {1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3}
  
  Items =
  {
  ["Tiamat"] = {id=3077, range = 150, maxrange = 300, slot = nil, ready},
  ["Hydra"] = {id=3074, range = 150, maxrange = 300, slot = nil, ready},
  ["Youmuu"] = {id=3142, slot = nil, ready},
  ["BC"] = {id=3144, range = 450, slot = nil, ready},
  ["BRK"] = {id=3153, range = 450, slot = nil, ready},
  ["Stalker"] = {id=3706, slot = nil, ready},
  ["StalkerW"] = {id=3707, slot = nil},
  ["StalkerM"] = {id=3708, slot = nil},
  ["StalkerJ"] = {id=3709, slot = nil},
  ["StalkerD"] = {id=3710, slot = nil}
  }
  
  MyFirstminBBox = 39.44
  TrueRange = 125.5+MyFirstminBBox
  TrueTargetRange = TrueRange+100
  
  TargetAddRange = 0
  KSTargetAddRange = 0
  
  TrueMinionRange = TrueRange+100
  TrueJunglemobRange = TrueRange+100
  
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
  TS = TargetSelector(TARGET_NEAR_MOUSE, R.range, DAMAGE_PHYSICAL, true)
  KSTS = TargetSelector(TARGET_LESS_CAST, R.range, DAMAGE_PHYSICAL, false)
  
  AllyMinions = minionManager(MINION_ALLY, Q.range+E.range+TrueTargetRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  EnemyMinions = minionManager(MINION_ENEMY, Q.range+E.range+TrueMinionRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, Q.range+E.range+TrueJunglemobRange, myHero, MINION_SORT_MAXHEALTH_DEC)
  
end

----------------------------------------------------------------------------------------------------

function RivenMenu()

  Menu = scriptConfig("HTTF Riven", "HTTF Riven")
  
  Menu:addSubMenu("Combo Settings", "Combo")
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("QS", "Use Q to Stick to Target", SCRIPT_PARAM_ONOFF, false)
      Menu.Combo:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("E2", "Use E if Health Percent > x%", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Combo:addParam("EAA", "Don't use E if enemy is in AA range", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R", "Use R Combo", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("FR", "Use Active R (FR)", SCRIPT_PARAM_LIST, 4, { "None", "Killable", "Max Damage or Killable", "Full Combo"})
      Menu.Combo:addParam("SR", "Use Cast R (SR)", SCRIPT_PARAM_LIST, 2, { "None", "Killable", "Max Damage or Killable"})
      Menu.Combo:addParam("Rearly", "Use Second R early", SCRIPT_PARAM_ONOFF, false)
      Menu.Combo:addParam("DontR", "Don't use SR if Killable with Q or W", SCRIPT_PARAM_ONOFF, false)
      Menu.Combo:addParam("Blank5", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("AutoR", "Use Cast R by Min Count", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Rmin", "Cast R Min Count", SCRIPT_PARAM_SLICE, 4, 2, 5, 0)
      Menu.Combo:addParam("Blank6", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Item", "Use Items", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("BRK1", "Use BRK if Target HP < x%", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
      Menu.Combo:addParam("BRK2", "Use BRK if my own HP < x%", SCRIPT_PARAM_SLICE, 15, 0, 100, 0)
      
  Menu:addSubMenu("Full Combo Settings", "FCombo")
    Menu.FCombo:addParam("On", "Full Combo (ER F W>AA>Item>RQ)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('T'))
      Menu.FCombo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.FCombo:addParam("F", "Use Flash", SCRIPT_PARAM_ONOFF, true)
    
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
    Menu.LastHit:addParam("On", "LastHit", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
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
      Menu.KillSteal:addParam("Blank6", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("BRK", "Use Blade of the Ruined King", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("AutoCast Settings", "Auto")
  
    Menu.Auto:addParam("On", "AutoCast", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("StackQ", "Auto Stack Q ", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoW", "Auto W by Min Count", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Wmin", "W Min Count", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
      Menu.Auto:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoR", "Auto Cast R by Min Count", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Rmin", "Cast R Min Count", SCRIPT_PARAM_SLICE, 5, 1, 5, 0)
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
    Menu.Misc:addParam("ALOpt", "Skill order : ", SCRIPT_PARAM_LIST, 2, {"R>Q>W>E (EQWQ)", "R>Q>W>E (QEWQ)"})
    
  Menu:addSubMenu("Draw Settings", "Draw")
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("Target", "Draw Target", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("R", "Draw R range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("S", "Draw Smite range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("FCD", "Draw Full Combo damage", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addTS(TS)
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnTick()
  
  if myHero.dead then
    return
  end
  
  Checks()
  Targets()
  
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

function Checks()

  if BeingAA and os.clock()-LastAA >= WindUpTime+0.003 then
    BeingAA = false
    CanMove = true
    CanQ = true
    CanW = true
    CanE = true
    CanSR = true
  end
  
  if BeingQ and os.clock()-LastQ >= 0.25+0.149 then
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
  
  if not CanMove and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastAA >= WindUpTime+0.003 then
    CanMove = true
  end
  
  if not CanAA and not (BeingQ or BeingW or BeingE) and os.clock()-LastAA >= AnimationTime+0.003 then
    CanAA = true
  end
  
  --[[if not CanQ and not (BeingAA or BeingW or BeingE) and os.clock()-FirstQ >= 13*(1-myHero.cdr) then
    CanQ = true
  end]]
  
  if not CanW and not (BeingAA or BeingQ or BeingE) and W.ready then
    CanW = true
  end
  
  if not CanE and not (BeingAA or BeingQ or BeingW) and E.ready then
    CanE = true
  end
  
  if not CanSR and not BeingAA and R.state and R.ready then
    CanSR = true
  end
  
  if P.stack ~= 0 and os.clock()-LastP >= 5 then
    P.stack = 0
  end
  
  if Q.state ~= 0 and os.clock()-LastQ >= 4 then
    Q.state = 0
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
  Items["Youmuu"].ready = Items["Youmuu"].slot and myHero:CanUseSpell(Items["Youmuu"].slot) == READY
  Items["BC"].ready = Items["BC"].slot and myHero:CanUseSpell(Items["BC"].slot) == READY
  Items["BRK"].ready = Items["BRK"].slot and myHero:CanUseSpell(Items["BRK"].slot) == READY
  Items["Stalker"].ready = Smite ~= nil and (Items["Stalker"].slot or Items["StalkerW"].slot or Items["StalkerM"].slot or Items["StalkerJ"].slot or Items["StalkerD"].slot) and myHero:CanUseSpell(Smite) == READY
  
  AllyMinions:update()
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
  
  MyminBBox = GetDistance(myHero.minBBox)/2
  TrueRange = myHero.range+MyminBBox
  TargetHealthPercent = 100
  KSTargetHealthPercent = 100
  
  if Target ~=nil then
  
    local AddRange = GetDistance(Target.minBBox, Target)/2
    
    TargetAddRange = AddRange
    TrueTargetRange = TrueRange+AddRange
    TargetHealthPercent = (Target.health/Target.maxHealth)*100
  end
  
  if KSTarget ~= nil then
  
    local AddRange = GetDistance(KSTarget.minBBox, KSTarget)/2
    
    KSTargetAddRange = AddRange
    KSTargetHealthPercent = (KSTarget.health/KSTarget.maxHealth)*100
  end
  
  Q.level = myHero:GetSpellData(_Q).level
  W.level = myHero:GetSpellData(_W).level
  E.level = myHero:GetSpellData(_E).level
  R.level = myHero:GetSpellData(_R).level
  
  _ENV.DrawKillable()
  
end

function _ENV.DrawKillable()

  if Menu.Draw.FCD and os.clock()-LastDraw >= 0.1 then
  
    for i, enemy in ipairs(EnemyHeroes) do
    
      if ValidTarget(enemy, 1500) then
        FCDamage[enemy.hash] = GetFCDmg(enemy)
      end
      
      LastDraw = os.clock()
      
    end
    
  end
  
end

function _ENV.GetFCDmg(enemy)
  
  local PADTargetDmg = GetDmg("PAD", enemy)
  local QTargetDmg = GetDmg("Q", enemy)
  local WTargetDmg = GetDmg("W", enemy)
  local FCRTargetDmg = RGetDmg("FCR", enemy)
  
  local RADTargetDmg = GetDmg("RAD", enemy)
  local RQTargetDmg = GetDmg("RQ", enemy)
  local RWTargetDmg = GetDmg("RW", enemy)
  local RFCRTargetDmg = RGetDmg("RFCR", enemy)
  
  local TotalDmg = 0
  
  if not (R.ready or R.state) then
    TotalDmg = WTargetDmg+PADTargetDmg+QTargetDmg*(3-Q.state)+FCRTargetDmg
  else
    TotalDmg = RWTargetDmg+RADTargetDmg+RQTargetDmg*(3-Q.state)+RFCRTargetDmg
  end
  
  return TotalDmg
  
end

----------------------------------------------------------------------------------------------------

function Targets()

  TS:update()
  KSTS:update()
  Target = TS.target
  KSTarget = KSTS.target
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Combo()

  Orbwalk(Combo)
  
  if KSTarget == nil then
    return
  end
  
  local ComboItem = Menu.Combo.Item
  local ComboBRK1 = Menu.Combo.BRK1
  local ComboBRK2 = Menu.Combo.BRK2
  local ComboQ = Menu.Combo.Q
  local ComboQS = Menu.Combo.QS
  local ComboW = Menu.Combo.W
  local ComboE = Menu.Combo.E
  local ComboE2 = Menu.Combo.E2
  local ComboEAA = Menu.Combo.EAA
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
  local RRKSTargetDmg = GetDmg("RR", KSTarget)
  local SBKSTargetDmg = GetDmg("STALKER", KSTarget)
  local BCKSTargetDmg = GetDmg("BC", KSTarget)
  local BRKKSTargetDmg = GetDmg("BRK", KSTarget)
  
  if Items["Stalker"].ready and ComboItem and SBKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, S.range) then
    CastS(KSTarget)
  end
  
  if Items["BC"].ready and ComboItem and BCKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Items["BC"].range) then
    CastBC(KSTarget)
  elseif Items["BRK"].ready and ComboItem and BRKKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Items["BRK"].range) then
    CastBRK(KSTarget)
  end
  
  if R.state and ComboAutoR and ValidTarget(KSTarget, R.range) then
    CastR2(KSTarget, Combo)
  end
  
  if R.ready and not R.state and ComboR and ComboFR ~= 1 then
  
    if ValidTarget(KSTarget, R.range) then
    
      if ComboFR == 2 and RRKSTargetDmg >= KSTarget.health then
        CastFR()
      elseif ComboFR == 3 and (RRKSTargetDmg >= KSTarget.health or 25 >= KSTargetHealthPercent) then
        CastFR()
      elseif ComboFR == 4 and GetFCDmg(KSTarget) >= KSTarget.health then
      
        if ValidTarget(KSTarget, TrueTargetRange) then
          CastFR()
        elseif not (Q.ready and ComboQ) and E.ready and ComboE and ValidTarget(KSTarget, E.range+TrueTargetRange-50) then
          CastFR()
        elseif Q.ready and ComboQ and E.ready and ComboE and ValidTarget(KSTarget, Q.radius+E.range-50) then
          CastFR()
        end
        
      end
      
    end
    
  elseif R.state and ComboR and ComboSR ~= 1 then
  
    if ValidTarget(KSTarget, R.range) then
    
      if ComboSR == 2 and RKSTargetDmg >= KSTarget.health then
        CastSR(KSTarget)
      elseif ComboSR == 3 and (RKSTargetDmg >= KSTarget.health or 25 >= KSTargetHealthPercent) then
        CastSR(KSTarget)
      end
      
    end
    
    if ValidTarget(Target, Q.radius) then
    
      if Q.ready and ComboQ and W.ready and ComboW and ComboRearly and RTargetDmg+QTargetDmg+WTargetDmg >= Target.health then
        CastSR(Target)
        DelayAction(function() CastQ(Target) end, 0.25)
        DelayAction(function() CastW() end, 0.5)
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
  
  if CanTurn and ValidTarget(Target, TrueTargetRange) then
    CancelPos = myHero+(Vector(Target)-myHero):normalized()*-300
    MoveToPos(CancelPos)
    CanTurn = false
  end
  
  if Items["Tiamat"].ready and ComboItem and not BeingAA and ValidTarget(Target, Items["Tiamat"].range+TargetAddRange) then
    CastT()
  elseif Items["Hydra"].ready and ComboItem and not BeingAA and ValidTarget(Target, Items["Hydra"].range+TargetAddRange) then
    CastH()
  end
  
  if Items["Youmuu"].ready and ComboItem and ValidTarget(Target, TrueTargetRange) then
    CastY()
  end
  
  if Items["BC"].ready and ComboItem and (ComboBRK1 >= TargetHealthPercent or ComboBRK2 >= HealthPercent) and ValidTarget(Target, Items["BC"].range) then
    CastBC(Target)
  elseif Items["BRK"].ready and ComboItem and (ComboBRK1 >= TargetHealthPercent or ComboBRK2 >= HealthPercent) and ValidTarget(Target, Items["BRK"].range) then
    CastBRK(Target)
  end
  
  if not (Q.ready or W.ready or E.ready) then
    return
  end
  
  if E.ready and ComboE and ComboE2 <= HealthPercent and CanE then
  
    if not ComboEAA and not ValidTarget(Target, E.range-TrueTargetRange+50) and ValidTarget(Target, E.range+TrueTargetRange-50) then
      CastE(Target)
    elseif ComboEAA and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, E.range+TrueTargetRange-50) then
      CastE(Target)
    elseif Q.ready and ComboQ and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, Q.radius+E.range-50) then
      CastE(Target)
    end
    
  end
  
  if W.ready and ComboW and CanW and os.clock()-LastE >= 0.25 and ValidTarget(Target, W.radius) then
    CastW()
  end
  
  if Q.ready and ComboQ and CanQ and os.clock()-LastE >= 0.25 and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  elseif Q.ready and ComboQ and os.clock()-LastE >= 0.25 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  elseif Q.ready and ComboQ and ComboQS and os.clock()-LastE >= 0.25 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, (3-Q.state)*Q.range) then
    CastQ(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function FCombo()

  Orbwalk(FCombo)
  
  if Target == nil then
    return
  end
    
  local PADTargetDmg = GetDmg("PAD", Target)
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  local FCRTargetDmg = RGetDmg("FCR", Target)
  local RADTargetDmg = GetDmg("RAD", Target)
  local RQTargetDmg = GetDmg("RQ", Target)
  local RWTargetDmg = GetDmg("RW", Target)
  local RFCRTargetDmg = RGetDmg("RFCR", Target)
  
  local SBTargetDmg = GetDmg("STALKER", Target)
  
  local FComboF = Menu.FCombo.F
  
  if Items["Stalker"].ready and SBTargetDmg >= Target.health and ValidTarget(Target, S.range) then
    CastS(Target)
  end
  
  if Q.ready and W.ready and E.ready and R.ready then
  
    AfterCombo = false
    
    if not R.state then
    
      if FComboF and F.ready and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, E.range+F.range+W.radius-50) then
        CastE(Target)
        DelayAction(function() CastFR() end, 0.2)
        DelayAction(function() CastF(Target) end, 0.25)
      elseif not (FComboF and F.ready) and ValidTarget(Target, E.range+TrueTargetRange-50) then
        CastE(Target)
        DelayAction(function() CastFR() end, 0.25)
      end
      
    elseif R.state then
    
      if FComboF and F.ready and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, E.range+F.range+W.radius-50) then
        CastE(Target)
        DelayAction(function() CastF(Target) end, 0.25)
      elseif not (FComboF and F.ready) and ValidTarget(Target, E.range+TrueTargetRange-50) then
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
    
    if Items["Youmuu"].ready and ValidTarget(Target, TrueTargetRange) then
      CastY()
    end
    
    if Items["BC"].ready and ValidTarget(Target, Items["BC"].range) then
      CastBC(Target)
  elseif Items["BRK"].ready and ValidTarget(Target, Items["BRK"].range) then
      CastBRK(Target)
    end
    
    if StartFullCombo2 and R.state and CanSR then
      CastSR(Target)
    end
    
    if StartFullCombo3 then
      CastQ(Target)
    end
    
  elseif AfterCombo then
  
    if CanTurn and ValidTarget(Target, TrueTargetRange) then
      CancelPos = myHero+(Vector(Target)-myHero):normalized()*-300
      MoveToPos(CancelPos)
      CanTurn = false
    end
    
    if Items["Tiamat"].ready and not BeingAA and ValidTarget(Target, Items["Tiamat"].range+TargetAddRange) then
      CastT()
    elseif Items["Hydra"].ready and not BeingAA and ValidTarget(Target, Items["Hydra"].range+TargetAddRange) then
      CastH()
    end
    
    if Items["Youmuu"].ready and ValidTarget(Target, TrueTargetRange) then
      CastY()
    end
    
    if not (Q.ready or W.ready or E.ready) then
      return
    end
    
    if E.ready and CanE then
    
      if not ValidTarget(Target, E.range-TrueTargetRange+50) and ValidTarget(Target, E.range+TrueTargetRange-50) then
        CastE(Target)
      elseif Q.ready and not ValidTarget(Target, E.range+TrueTargetRange-50) and ValidTarget(Target, Q.radius+E.range-50) then
        CastE(Target)
      end
      
    end
    
    if W.ready and CanW and os.clock()-LastE >= 0.25 and ValidTarget(Target, W.radius) then
      CastW()
    end
    
    if Q.ready and CanQ and os.clock()-LastE >= 0.25 and ValidTarget(Target, Q.radius) then
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
    
    local AddRange = GetDistance(minion.minBBox, minion)/2
    local TrueMinionRange = TrueRange+AddRange
    
    local FarmQ = Menu.Clear.Farm.Q
    local FarmW = Menu.Clear.Farm.W
    local FarmE = Menu.Clear.Farm.E
    local FarmTH = Menu.Clear.Farm.TH
    local FarmTHmin = Menu.Clear.Farm.THmin
    
    local AAMinionDmg = GetDmg("AD", minion)
    local QMinionDmg = GetDmg("Q", minion)
    local WMinionDmg = GetDmg("W", minion)

    if CanTurn and ValidTarget(minion, TrueMinionRange) then
      CancelPos = myHero+(Vector(minion)-myHero):normalized()*-300
      MoveToPos(CancelPos)
      CanTurn = false
    end
    
    if Items["Tiamat"].ready and FarmTH and not BeingAA and os.clock()-LastE >= 0.5 and FarmTHmin <= EnemyMinionCount(Items["Tiamat"].maxrange+AddRange) then
      CastT()
    elseif Items["Hydra"].ready and FarmTH and not BeingAA and os.clock()-LastE >= 0.5 and FarmTHmin <= EnemyMinionCount(Items["Hydra"].maxrange+AddRange) then
      CastH()
    end
    
    if not (Q.ready or W.ready or E.ready) then
      return
    end
    
    if E.ready and FarmE and CanE then
    
      if Q.ready and FarmQ and ValidTarget(minion, Q.radius+E.range+AddRange-50) then
        CastE(minion)
      elseif ValidTarget(minion, E.range+TrueMinionRange-50) then
        CastE(minion)
      end
      
    end
    
    if W.ready and FarmW and CanW and (WMinionDmg+AAMinionDmg <= minion.health or WMinionDmg >= minion.health) and os.clock()-LastE >= 0.25 and ValidTarget(minion, W.radius) then
      CastW()
    end
    
    if Q.ready and FarmQ and CanQ and (QMinionDmg+AAMinionDmg <= minion.health or QMinionDmg >= minion.health) and ValidTarget(minion, Q.radius) then
      CastQ(minion)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function EnemyMinionCount(range)

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
    
    local AddRange = GetDistance(junglemob.minBBox, junglemob)/2
    local TrueJunglemobRange = TrueRange+AddRange
    
    local JFarmQ = Menu.Clear.JFarm.Q
    local JFarmW = Menu.Clear.JFarm.W
    local JFarmE = Menu.Clear.JFarm.E
    local JFarmTH = Menu.Clear.JFarm.TH
    local JFarmTHmin = Menu.Clear.JFarm.THmin
    
    if CanTurn and ValidTarget(junglemob, TrueJunglemobRange) then
      CancelPos = myHero+(Vector(junglemob)-myHero):normalized()*-300
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
      elseif ValidTarget(junglemob, E.range+TrueJunglemobRange-50) then
        CastE(junglemob)
      end
      
    end
    
    if W.ready and JFarmW and CanW and os.clock()-LastE >= 0.5 and ValidTarget(junglemob, W.radius) then
      CastW()
    end
    
    if Q.ready and JFarmQ and CanQ and ValidTarget(junglemob, Q.radius) then
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
      end
      
      if Q.ready and JStealQ and Q.state <=1 and QjunglemobDmg >= junglemob.health then
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
  
  if CanTurn and ValidTarget(Target, TrueTargetRange) then
    CancelPos = myHero+(Vector(Target)-myHero):normalized()*-300
    MoveToPos(CancelPos)
    CanTurn = false
  end
  
  if Items["Tiamat"].ready and HarassItem and not BeingAA and ValidTarget(Target, Items["Tiamat"].range+TargetAddRange) then
    CastT()
  elseif Items["Hydra"].ready and HarassItem and not BeingAA and ValidTarget(Target, Items["Hydra"].range+TargetAddRange) then
    CastH()
  end
  
  if Items["Youmuu"].ready and HarassItem and ValidTarget(Target, TrueTargetRange) then
    CastY()
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
  
  if W.ready and HarassW and CanW and os.clock()-LastE >= 0.25 and ValidTarget(Target, W.radius) then
    CastW()
  elseif Q.ready and HarassQ and CanQ and os.clock()-LastE >= 0.25 and ValidTarget(Target, Q.radius) then
    CastQ(Target)
  elseif Q.ready and HarassQ and os.clock()-LastE >= 0.25 and not ValidTarget(Target, TrueTargetRange) and ValidTarget(Target, Q.radius) then
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
  local KillStealBRK = Menu.KillSteal.BRK
  
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  local RKSTargetDmg = GetDmg("R", KSTarget)
  local IKSTargetDmg = GetDmg("IGNITE", KSTarget)
  local SBKSTargetDmg = GetDmg("STALKER", KSTarget)
  local BCKSTargetDmg = GetDmg("BC", KSTarget)
  local BRKKSTargetDmg = GetDmg("BRK", KSTarget)
  
  if R.state and KillStealR and RKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, R.range) then
    CastSR(KSTarget)
  end
  
  if I.ready and KillStealI and IKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, I.range) then
    CastI(KSTarget)
  end
  
  if Items["Stalker"].ready and KillStealS and SBKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, S.range) then
    CastS(KSTarget)
  end
  
  if Items["BC"].ready and KillStealBRK and BCKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Items["BC"].range) then
    CastBC(KSTarget)
  elseif Items["BRK"].ready and KillStealBRK and BRKKSTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Items["BRK"].range) then
    CastBRK(KSTarget)
  end
  
  if not (Q.ready or W.ready) then
    return
  end
  
  if W.ready and KillStealW and WTargetDmg >= KSTarget.health and ValidTarget(KSTarget, W.radius) then
    CastW(KSTarget)
  end
  
  if Q.ready and KillStealQ and QTargetDmg >= KSTarget.health and ValidTarget(KSTarget, Q.radius) then
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
  
  local AutoStackQ = Menu.Auto.StackQ
  
  local FleeOn = Menu.Flee.On
  
  if Q.ready and Q.state >= 1 and AutoStackQ and not FleeOn and os.clock()-LastQ2 > 3.7 then
    CastQ(mousePos)
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
  
  if R.state and AutoAutoR and ValidTarget(KSTarget, R.range) then
    CastR2(KSTarget, Auto)
  end
  
  if W.ready and AutoAutoW and not (ComboOn or HarassOn) and AutoWmin <= AutoEnemyCount(W.radius) then
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
  
  if E.ready and os.clock()-LastQ >= 0.25 then
    CastE(mousePos)
  end
  
  if Q.ready and os.clock()-LastE >= 0.25 then
    CastQ(mousePos)
  end
  
end

----------------------------------------------------------------------------------------------------

function AutoLevel()

  if Menu.Misc.ALOpt == 1 then
  
    if Q.level+W.level+E.level+R.level < myHero.level then
    
      local spell = {SPELL_1, SPELL_2, SPELL_3, SPELL_4}
      local level = {0, 0, 0, 0}
      
      for i = 1, myHero.level, 1 do
        level[AutoEQWQ[i]] = level[AutoEQWQ[i]]+1
      end
      
      for i, v in ipairs({Q.level, W.level, E.level, R.level}) do
      
        if v < level[i] then
          LevelSpell(spell[i])
        end
        
      end
      
    end
    
  elseif Menu.Misc.ALOpt == 2 then
  
    if Q.level+W.level+E.level+R.level < myHero.level then
    
      local spell = {SPELL_1, SPELL_2, SPELL_3, SPELL_4}
      local level = {0, 0, 0, 0}
      
      for i = 1, myHero.level, 1 do
        level[AutoQEWQ[i]] = level[AutoQEWQ[i]]+1
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
    
      if AllyMinionCount(R.range) == 0 then
      
        for i, minion in pairs(EnemyMinions.objects) do
        
          if minion == nil then
            return
          end
          
          local AddRange = GetDistance(minion.minBBox, minion)/2
          local TrueMinionRange = TrueRange+AddRange
          
          local AAMinionDmg = GetDmg("AD", minion)
          
          if ValidTarget(minion, TrueMinionRange) then
            OrbCastAA(minion)
            return
          end
          
        end
        
      elseif AllyMinionCount(R.range) >= 1 then
        
        for i, minion in pairs(EnemyMinions.objects) do
        
          if minion == nil then
            return
          end
          
          local AddRange = GetDistance(minion.minBBox, minion)/2
          local TrueMinionRange = TrueRange+AddRange
          
          local AAMinionDmg = GetDmg("AD", minion)
          
          if AAMinionDmg >= minion.health and ValidTarget(minion, TrueMinionRange) then
            OrbCastAA(minion)
            return
          end
          
        end
        
        for i, minion in pairs(EnemyMinions.objects) do
        
          if minion == nil then
            return
          end
          
          local AddRange = GetDistance(minion.minBBox, minion)/2
          local TrueMinionRange = TrueRange+AddRange
          
          local AAMinionDmg = GetDmg("AD", minion)
          
          if minion.health >= AAMinionDmg+40*AllyMinionCount(R.range)--[[2*AAMinionDmg]] and ValidTarget(minion, TrueMinionRange) then
            OrbCastAA(minion)
            return
          end
          
        end
        
      end
      
    elseif State == JFarm then
    
      for i, junglemob in pairs(JungleMobs.objects) do
      
        if junglemob == nil then
          return
        end
        
        --if GetDistance(
        
        local AddRange = GetDistance(junglemob.minBBox, junglemob)/2
        local TrueJunglemobRange = TrueRange+AddRange
        
        if ValidTarget(junglemob, TrueJunglemobRange) then
          OrbCastAA(junglemob)
          return
        end
        
      end
    
    elseif State == LastHit then
    
      for i, minion in pairs(EnemyMinions.objects) do
      
        if minion == nil then
          return
        end
        
        local AddRange = GetDistance(minion.minBBox, minion)/2
        local TrueMinionRange = TrueRange+AddRange
        
        local AAminionDmg = GetDmg("AD", minion)
        
        if AAminionDmg >= minion.health and ValidTarget(minion, TrueMinionRange) then
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

function AllyMinionCount(range)

  local count = 0
  
  for i, allyminion in pairs(AllyMinions.objects) do
  
    if allyminion ~= nil and GetDistance(allyminion) <= range then
      count = count + 1
    end
    
  end
  
  return count
  
end

----------------------------------------------------------------------------------------------------

function OrbCastAA(enemy)
  CanMove = false
  CastAA(enemy)
  CanQ = false
  CanW = false
  CanE = false
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
  local MagicPen = myHero.magicPen
  local MagicPenPercent = myHero.magicPenPercent
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local MagicArmor = math.max(0, enemy.magicArmor*MagicPenPercent-MagicPen)
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)
  local EnemyLossHealth = 1-(enemy.health/enemy.maxHealth)
  
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
  
  elseif spell == "BC" then
    local TrueDmg = 100*(1-MagicArmorPercent)
    
    return TrueDmg
    
  elseif spell == "BRK" then
    PureDmg = math.max(100, 0.1*enemy.maxHealth)
  elseif spell == "AD" then
    PureDmg = TotalDmg
  elseif spell == "PAD" then
    PureDmg = TotalDmg+(20+math.floor(Level/3)*5)*TotalDmg/100
  elseif spell == "RAD" then
    PureDmg = TotalDmg+(20+math.floor(Level/3)*5)*RTotalDmg/100
  elseif spell == "Q" then
  
    if Q.ready then
      PureDmg = 20*Q.level-10+(.05*Q.level+.35)*TotalDmg
    else
      PureDmg = 0
    end
    
  elseif spell == "RQ" then
  
    if Q.ready then
      PureDmg = 20*Q.level-10+(.05*Q.level+.35)*RTotalDmg
    else
      PureDmg = 0
    end
    
  elseif spell == "W" then
  
    if W.ready then
      PureDmg = 30*W.level+20+AddDmg
    else
      PureDmg = 0
    end
    
  elseif spell == "RW" then
  
    if W.ready then
      PureDmg = 30*W.level+20+RAddDmg
    else
      PureDmg = 0
    end
    
  elseif spell == "R" then
  
    if R.ready then
      PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+EnemyLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
    else
      PureDmg = 0
    end
    
  elseif spell == "RR" then
  
    if R.ready then
      PureDmg = math.min((40*R.level+40+.6*RAddDmg)*(1+EnemyLossHealth*(8/3)),120*R.level+120+1.8*RAddDmg)
    else
      PureDmg = 0
    end
    
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
  
  local PADTargetDmg = GetDmg("PAD", enemy)
  local QTargetDmg = GetDmg("Q", enemy)
  local WTargetDmg = GetDmg("W", enemy)
  local RADTargetDmg = GetDmg("RAD", enemy)
  local RQTargetDmg = GetDmg("RQ", enemy)
  local RWTargetDmg = GetDmg("RW", enemy)
  
  local QREnemyHealth = enemy.health-QTargetDmg
  local WREnemyHealth = enemy.health-WTargetDmg
  local QWREnemyHealth = enemy.health-QTargetDmg-WTargetDmg
  local FCREnemyHealth = enemy.health-WTargetDmg-PADTargetDmg-QTargetDmg
  local RFCREnemyHealth = enemy.health-RWTargetDmg-RADTargetDmg-RQTargetDmg
  
  local QREnemyLossHealth = 1-(QREnemyHealth/enemy.maxHealth)
  local WREnemyLossHealth = 1-(WREnemyHealth/enemy.maxHealth)
  local QWREnemyLossHealth = 1-(QWREnemyHealth/enemy.maxHealth)
  local FCREnemyLossHealth = 1-(FCREnemyHealth/enemy.maxHealth)
  local RFCREnemyLossHealth = 1-(RFCREnemyHealth/enemy.maxHealth)
  
  if spell == "QR" then
  
    if R.ready then
      PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+QREnemyLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
    elseif not R.ready then
      PureDmg = 0
    end
    
  elseif spell == "WR" then
  
    if R.ready then
      PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+WREnemyLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
    elseif not R.ready then
      PureDmg = 0
    end
    
  elseif spell == "QWR" then
  
    if R.ready then
      PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+QWREnemyLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
    elseif not R.ready then
      PureDmg = 0
    end
    
  elseif spell == "FCR" then
  
    if R.ready then
      PureDmg = math.min((40*R.level+40+.6*AddDmg)*(1+FCREnemyLossHealth*(8/3)),120*R.level+120+1.8*AddDmg)
    elseif not R.ready then
      PureDmg = 0
    end
    
  elseif spell == "RFCR" then
  
    if R.ready then
      PureDmg = math.min((40*R.level+40+.6*RAddDmg)*(1+RFCREnemyLossHealth*(8/3)),120*R.level+120+1.8*RAddDmg)
    elseif not R.ready then
      PureDmg = 0
    end
    
  end
  
  local TrueDmg = PureDmg*(1-ArmorPercent)
  
  return TrueDmg

end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnDraw()

  if myHero.dead or not Menu.Draw.On then
    return
  end
  
  if Menu.Draw.Target and Target ~= nil then
  
    for i = 0, 1 do
      DrawCircle(Target.x, Target.y, Target.z, TargetAddRange+i, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
    end
    
  end
  
  if Menu.Draw.AA then
    DrawCircle(myHero.x, myHero.y, myHero.z, TrueRange, ARGB(0xFF, 0, 0xFF, 0))
  end
  
  if Menu.Draw.Q then
    DrawCircle(myHero.x, myHero.y, myHero.z, Q.range, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.W and W.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, W.radius, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.E and E.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, E.range, ARGB(0xFF, 0xFF, 0xFF, 0xFF))
  end
  
  if Menu.Draw.R and R.ready then
    DrawCircle(myHero.x, myHero.y, myHero.z, R.range, ARGB(0xFF, 0xFF, 0, 0))
  end
  
  if Menu.Draw.S and S.ready and ((Menu.Auto.On and Menu.Auto.AutoS) or (Menu.JSteal.On and Menu.JSteal.S)) then
    DrawCircle(myHero.x, myHero.y, myHero.z, S.range, ARGB(0xFF, 0xFF, 0x14, 0x93))
  end
  
  if _ENV.Menu.Draw.FCD then
  
    for i, enemy in _ENV.ipairs(_ENV.EnemyHeroes) do
    
      if _ENV.ValidTarget(enemy, 1500) then
        _ENV.DrawFCD(enemy)
      end
      
    end
    
  end
  
end

function _ENV.DrawFCD(enemy)

  local SPos, EPos = _ENV.HPos(enemy)
  local FCDmg = FCDamage[enemy.hash] or 0
  
  if SPos then
  
    local Width = EPos.x-SPos.x
    local Pos = SPos.x+_ENV.math.max(0, (enemy.health-FCDmg)/enemy.maxHealth)*Width
    _ENV.DrawText("|", 13, Pos, EPos.y, _ENV.ARGB(255, 0, 255, 0))
    
    _ENV.DrawText("HP : ".._ENV.math.max(0, math.floor(enemy.health-FCDmg)), 15, SPos.x, SPos.y+20, (_ENV.ARGB(255, 0, 255, 0)))
    
  end
  
end

function _ENV.HPos(enemy)
  local Pos = GetUnitHPBarPos(enemy)
  local PosOffset = GetUnitHPBarOffset(enemy)
  
  local POffset = Point(enemy.barData.PercentageOffset.x, enemy.barData.PercentageOffset.y)
  
  local PosOffsetX = 169
  local PosOffsetY = 47
  local PosOffsetX2 = 16
  local PosOffsetY2 = 18
  
  Pos.x = Pos.x+(PosOffset.x-0.5+POffset.x)*PosOffsetX+PosOffsetX2
  Pos.y = Pos.y+(PosOffset.y-0.5+POffset.y)*PosOffsetY+PosOffsetY2
  
  local SPos = Point(Pos.x, Pos.y)
  local EPos = Point(Pos.x + 103, Pos.y)
  
  return Point(SPos.x, SPos.y), Point(EPos.x, EPos.y)
  
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

  if not Menu.Flee.On then
    DelayAction(function() CanTurn = true end, 0.1)
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
  
end

----------------------------------------------------------------------------------------------------

function CastE(Pos)
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E, toX = Pos.x, toY = Pos.z, fromX = Pos.x, fromY = Pos.z}):send()
  else
    CastSpell(_E, Pos.x, Pos.z)
  end
  
  LastE = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastFR()
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet('S_CAST', {spellId = _R}):send()
  else
    CastSpell(_R)
  end
  
end

function CastSR(enemy)

  if enemy == nil then
    return
  end
  
  CanQ = false
  CanW = false
  CanE = false
  
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

function CastY()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["Youmuu"].slot}):send()
  else
    CastSpell(Items["Youmuu"].slot)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastBC(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["BC"].slot, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Items["BC"].slot, enemy)
  end
  
end

----------------------------------------------------------------------------------------------------

function CastBRK(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Items["BRK"].slot, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Items["BRK"].slot, enemy)
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
----------------------------------------------------------------------------------------------------

function OnGainBuff(unit, buff)

  if unit.isMe then
  
    if buff.name == "RivenFengShuiEngine" then
      LastP = os.clock()
      
      if P.stack <= 2 then
        P.stack = P.stack + 1
      end
      
      R.state = true
      StartFullCombo = true
    end
    
    if buff.name == "recall" then
      Recall = true
    end
    
  end
  
end

function OnLoseBuff(unit, buff)

  if unit.isMe then
    
    if buff.name == "RivenFengShuiEngine" then
      R.state = false
    end
    
    if buff.name == "rivenwindslashready" then
      LastP = os.clock()
      
      if P.stack <= 2 then
        P.stack = P.stack + 1
      end
      
      CanSR = false
      StartFullCombo2 = false
      StartFullCombo3 = true
    end
    
    if buff.name == "recall" then
      Recall = false
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function OnProcessSpell(object, spell)

  if object.isMe then
  
    if spell.name:find("recall") then
      LastRC = os.clock()
      Recall = true
    end
    
    if not BeingQ and spell.name:find("RivenBasicAttack") then
      LastAA = os.clock()
      LastP = os.clock()
      
      if P.stack >= 1 then
        P.stack = P.stack - 1
      end
      
      AnimationTime = spell.animationTime
      WindUpTime = spell.windUpTime
      BeingAA = true
      CanAA = false
    end
    
    if spell.name:find("RivenTriCleave") then
      LastQ = os.clock()
      LastP = os.clock()
      
      if P.stack <= 2 then
        P.stack = P.stack + 1
      end
      
      if Q.state <= 1 then
        LastQ2 = os.clock()
        Q.state = Q.state + 1
      elseif Q.state == 2 then
        Q.state = 0
      end
      
      BeingQ = true
      CanMove = false
      CanQ = false
      StartFullCombo = false
      StartFullCombo2 = false
      StartFullCombo3 = false
      AfterCombo = true
    end
    
    if spell.name:find("RivenMartyr") then
      LastW = os.clock()
      LastP = os.clock()
      
      if P.stack <= 2 then
        P.stack = P.stack + 1
      end
      
      BeingW = true
      CanW = false
      StartFullCombo = false
      StartFullCombo2 = true
    end
    
    if spell.name:find("RivenFeint") then
      LastE = os.clock()
      LastP = os.clock()
      
      if P.stack <= 2 then
        P.stack = P.stack + 1
      end
      
      BeingE = true
      CanE = false
    end
    
  end
  
end
