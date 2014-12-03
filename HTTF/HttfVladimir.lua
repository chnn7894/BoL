Version = "1.13"
AutoUpdate = true

if myHero.charName ~= "Vladimir" then
  return
end

if VIP_USER then
  require 'Prodiction'
end

require 'SourceLib'
require 'VPrediction'

function ScriptMsg(msg)
  print("<font color=\"#00fa9a\"><b>HTTF Vladimir:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

----------------------------------------------------------------------------------------------------

Host = "raw.github.com"

ServerPath = "/BolHTTF/BoL/master/Server.status".."?rand="..math.random(1,10000)
ServerData = GetWebResult(Host, ServerPath)

ScriptMsg("Server check...")

assert(load(ServerData))()

print("<font color=\"#00fa9a\"><b>HTTF Vladimir:</b> </font><font color=\"#FFFFFF\">Server status: </font><font color=\"#ff0000\"><b>"..Server.."</b></font>")

if Server == "Off" then
  return
end

ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

ScriptPath = "/BolHTTF/BoL/master/HTTF/HttfVladimir.lua".."?rand="..math.random(1,10000)
UpdateURL = "https://"..Host..ScriptPath

VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HttfVladimir.version".."?rand="..math.random(1,10000)
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
        ScriptMsg("You've got the latest version: v"..VersionData)
      end
      
    end
    
  else
    ScriptMsg("Error downloading version info.")
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnLoad()

  Donator = false
  
  if VIP_USER then
  
    if Prodiction.IsDonator() then
      Donator = true
    else
      Donator = false
    end
    
  end
  
  Variables()
  VladimirMenu()
  DelayAction(Orbwalk, 1)
  
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
  
  DebugClock = os.clock()
  LastE = os.clock()
  LastSkin = 0
  RebornLoaded, RevampedLoaded, MMALoaded, SOWLoaded = false, false, false, false
  Recall = false
  
  Q = {delay = 0.5, range = 600, speed = 1400, ready, Off = 0}
  W = {delay = 0.5, radius = 350, speed = 1600, ready, Off = 0}
  E = {delay = 0.5, radius = 0, range = 620, speed = 1100, ready, Off = 0, stack = 0}
  R = {delay = 0, radius = 325, range = 625, speed = math.huge, ready, Off = 0}
  I = {range = 600, ready}
  Z = {range = 1000, ready}
  
  MyminBBox = 56.92
  TrueRange = myHero.range + MyminBBox
  
  MaxRrange = R.range + R.radius
  
  QrangeSqr = Q.range*Q.range
  ErangeSqr = E.range*E.range
  RradiusSqr = R.radius*R.radius
  RrangeSqr = R.range*R.range
  MaxRrangeSqr = (R.range+R.radius)*(R.range+R.radius)
  IrangeSqr = I.range*I.range
  
  AutoQEWQ = {1, 3, 2, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2}
  AutoQWEQ = {1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2}
  
  S5SR = false
  TT = false
  
  if GetGame().map.index == 15 then -- S5 Summoner's Rift, summonerRift
    S5SR = true
  elseif GetGame().map.index == 4 then -- A, B 
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
  QWETS = TargetSelector(TARGET_LESS_CAST, E.range, DAMAGE_MAGIC, false)
  RTS = TargetSelector(TARGET_LESS_CAST, MaxRrange, DAMAGE_MAGIC, false)
  
  EnemyMinions = minionManager(MINION_ENEMY, E.range, player, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, E.range, player, MINION_SORT_MAXHEALTH_DEC)
  
  if VIP_USER then
    PacketHandler:HookOutgoingPacket(Packet.headers.S_CAST, BlockR)
  end
  
end

function BlockR(unit)

  if Menu.Misc.BlockR then
  
    if Packet(unit):get('spellId') == _R then
    
      if HitRCount() == 0 then
        unit:Block()
      end
      
    end
    
  end
  
end

function HitRCount()

  local enemies = {}
  
  for _, enemy in ipairs(EnemyHeroes) do
  
    local Position = VP:GetPredictedPos(enemy, R.delay, R.speed, myHero, false)
    
    if ValidTarget(enemy) and _GetDistanceSqr(Position, mousePos) < RradiusSqr then
      table.insert(enemies, enemy)
    end
    
  end
  
  return #enemies, enemies
  
end

----------------------------------------------------------------------------------------------------

function VladimirMenu()

  Menu = scriptConfig("HTTF Vladimir", "")
  
  Menu:addSubMenu("Predict Settings", "Predict")
  
    Menu.Predict:addParam("PdOpt", "Predict Settings : (Require reload)", SCRIPT_PARAM_LIST, 2, { "Prodiction (Only Donator)", "VPrediction"})
    
  Menu:addSubMenu("Combo Settings", "Combo")
  
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Info", "Use W if W damage > loss health * x%", SCRIPT_PARAM_INFO, "")
      Menu.Combo:addParam("W2", "Default value = 100", SCRIPT_PARAM_SLICE, 100, 0, 200, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      if Donator and Menu.Predict.PdOpt == 1 then
      Menu.Combo:addParam("Emin", "Use E Min Count (Prodiction)", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
      Menu.Combo:addParam("Ehit", "Use E Hitchance (Prodiction)", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
      else
      Menu.Combo:addParam("Emin", "Use E Min Count", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
      end
      Menu.Combo:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.Combo:addParam("E2", "Default value = 10", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R", "Use R Combo", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Info2", "Use R if Full Combo Damage * x% > Target Health", SCRIPT_PARAM_INFO, "")
      Menu.Combo:addParam("R2", "Default value = 90", SCRIPT_PARAM_SLICE, 90, 60, 120, 0)
      Menu.Combo:addParam("Rearly", "Use R early", SCRIPT_PARAM_ONOFF, false)
      Menu.Combo:addParam("DontR", "Do not use R if Killable with Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("AutoR", "Auto R on Combo", SCRIPT_PARAM_ONOFF, true)
      if Donator and Menu.Predict.PdOpt == 1 then
      Menu.Combo:addParam("Rmin", "Auto R Min Count (Prodiction)", SCRIPT_PARAM_SLICE, 3, 2, 5, 0)
      Menu.Combo:addParam("Rhit", "Auto R Hitchance (Prodiction)", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
      else
      Menu.Combo:addParam("Rmin", "Auto R Min Count", SCRIPT_PARAM_SLICE, 3, 2, 5, 0)
      end
      
  Menu:addSubMenu("Clear Settings", "Clear")  
  
    Menu.Clear:addSubMenu("Lane Clear Settings", "Farm")
    
      Menu.Clear.Farm:addParam("On", "Lane Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
        Menu.Clear.Farm:addParam("E2", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
        Menu.Clear.Farm:addParam("Emin", "Use E Min Count", SCRIPT_PARAM_SLICE, 4, 1, 15, 0)
        
    Menu.Clear:addSubMenu("Jungle Clear Settings", "JFarm")
    
      Menu.Clear.JFarm:addParam("On", "Jungle Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
        Menu.Clear.JFarm:addParam("E2", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
        Menu.Clear.JFarm:addParam("Emin", "Use E Min Count", SCRIPT_PARAM_SLICE, 1, 1, 4, 0)
        
  Menu:addSubMenu("Harass Settings", "Harass")
  
    Menu.Harass:addParam("On", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.Harass:addParam("E2", "Default value = 10", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
      if Donator and Menu.Predict.PdOpt == 1 then
      Menu.Harass:addParam("Emin", "Use E Min Count (Prodiction)", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
      Menu.Harass:addParam("Ehit", "Use E Hitchance (Prodiction)", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
      else
      Menu.Harass:addParam("Emin", "Use E Min Count", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
      end
      
  Menu:addSubMenu("LastHit Settings", "LastHit")
  
    Menu.LastHit:addParam("On", "LastHit Key 1", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.LastHit:addParam("On2", "LastHit Key 2", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    Menu.LastHit:addParam("EQ", "Use EQ", SCRIPT_PARAM_ONOFF, false)
      Menu.LastHit:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.LastHit:addParam("E2", "Default value = 70", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
      
  Menu:addSubMenu("Jungle Steal Settings", "JSteal")
  
    Menu.JSteal:addParam("On", "Jungle Steal", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)
    Menu.JSteal:addParam("EQ", "Use EQ", SCRIPT_PARAM_ONOFF, false)
      Menu.JSteal:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.JSteal:addParam("E2", "Default value = 5", SCRIPT_PARAM_SLICE, 5, 0, 100, 0)
      
  Menu:addSubMenu("KillSteal Settings", "KillSteal")
  
    Menu.KillSteal:addParam("On", "KillSteal", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Menu.KillSteal:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      if Donator and Menu.Predict.PdOpt == 1 then
      Menu.KillSteal:addParam("Ehit", "Use E Hitchance (Prodiction)", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
      end
      Menu.KillSteal:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.KillSteal:addParam("E2", "Default value = 5", SCRIPT_PARAM_SLICE, 5, 0, 100, 0)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, false)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("I", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("AutoCast Settings", "Auto")
  
    Menu.Auto:addParam("On", "AutoCast", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoE", "Auto E", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Info", "Auto E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.Auto:addParam("E2", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
      if Donator and Menu.Predict.PdOpt == 1 then
      Menu.Auto:addParam("Emin", "Auto E Min Count (Prodiction)", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
      Menu.Auto:addParam("Ehit", "Auto E Hitchance (Prodiction)", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
      else
      Menu.Auto:addParam("Emin", "Auto E Min Count", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
      end
      
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("StackE", "Stack E (When not Combo, Harass)", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey('T'))
      Menu.Auto:addParam("Info", "Use E if Current Health > Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.Auto:addParam("SE2", "Default value = 40", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoR", "Auto R", SCRIPT_PARAM_ONOFF, true)
      if Donator and Menu.Predict.PdOpt == 1 then
      Menu.Auto:addParam("Rmin", "Auto R Min Count (Prodiction)", SCRIPT_PARAM_SLICE, 4, 2, 5, 0)
      Menu.Auto:addParam("Rhit", "Auto R Hitchance (Prodiction)", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
      else
      Menu.Auto:addParam("Rmin", "Auto R Min Count", SCRIPT_PARAM_SLICE, 4, 2, 5, 0)
      end
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoZ", "Auto Zhonya", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Info", "Auto Zhonya if Current Health < Max health * x%", SCRIPT_PARAM_INFO, "")
      Menu.Auto:addParam("Z", "Default value = 15", SCRIPT_PARAM_SLICE, 15, 0, 100, 0)
      Menu.Auto:addParam("Zmin", "Auto Zhonya Min Count", SCRIPT_PARAM_SLICE, 0, 0, 5, 0)
    
  Menu:addSubMenu("Flee Settings", "Flee")
  
    Menu.Flee:addParam("On", "Flee (Only Use KillSteal & Auto R)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
      Menu.Flee:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Flee:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("Misc Settings", "Misc")
  
    if VIP_USER then
    Menu.Misc:addParam("UsePacket", "Use Packet", SCRIPT_PARAM_ONOFF, false)
      Menu.Misc:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Misc:addParam("Skin", "Use Skin hack", SCRIPT_PARAM_ONOFF, false)
    Menu.Misc:addParam("SkinOpt", "Skin list : ", SCRIPT_PARAM_LIST, 7, { "Count Vladimir", "Marquis Vladimir", "Nosferatu Vladimir", "Vandal Vladimir", "Blood Lord Vladimir", "Soulstealer Vladmir", "Classic"})  
      Menu.Misc:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    end
    Menu.Misc:addParam("AutoLevel", "Auto Level Spells", SCRIPT_PARAM_ONOFF, true)
    Menu.Misc:addParam("ALOpt", "Skill order : ", SCRIPT_PARAM_LIST, 1, { "R>Q>E>W (QEWQ)", "R>Q>E>W (QWEQ)"})
      Menu.Misc:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    if VIP_USER then
    Menu.Misc:addParam("BlockR", "Block R if hitcount = 0", SCRIPT_PARAM_ONOFF, true)
    end
      
  Menu:addSubMenu("Draw Settings", "Draw")
  
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("R", "Draw R range", SCRIPT_PARAM_ONOFF, false)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("On2", "Use PermaShow", SCRIPT_PARAM_ONOFF, false)
    
    if Menu.Draw.On2 then
    
      Menu.Combo:permaShow("On")
      Menu.Clear.Farm:permaShow("On")
      Menu.Clear.JFarm:permaShow("On")
      Menu.Harass:permaShow("On")
      Menu.LastHit:permaShow("On")
      Menu.LastHit:permaShow("On2")
      Menu.JSteal:permaShow("On")
      Menu.Flee:permaShow("On")
      
    end
    
end

----------------------------------------------------------------------------------------------------

function Orbwalk()

  if _G.AutoCarry then
  
    if _G.AutoCarry.Helper then
      RebornLoaded = true
      ScriptMsg("Found SAC: Reborn.")
    else
      RevampedLoaded = true
      ScriptMsg("Found SAC: Revamped.")
    end
    
  elseif _G.Reborn_Loaded then
    DelayAction(Orbwalk, 1) 
    
  elseif _G.MMA_Loaded then
    MMALoaded = true
    ScriptMsg("Found MMA.")
    
  elseif FileExist(LIB_PATH .. "SOW.lua") then
    require 'SOW'
    SOWVP = SOW(VP)
    Menu:addSubMenu("Orbwalk Settings (SOW)", "Orbwalk")
      Menu.Orbwalk:addParam("Info", "SOW settings", SCRIPT_PARAM_INFO, "")
      Menu.Orbwalk:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      SOWVP:LoadToMenu(Menu.Orbwalk)
    SOWLoaded = true
    ScriptMsg("SOW Loaded.")
    
  else
    ScriptMsg("Orbwalk not founded. Using AllClass TS.")
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnTick()

  if myHero.dead then
    return
  end
  
  Check()
  Target = OrbTarget()
  --Debug()
  
  if Menu.Clear.Farm.On then
    Farm()
  end
  
  if Menu.Clear.JFarm.On then
    JFarm()
  end
  
  if Menu.JSteal.On then
    JSteal()
  end
  
  if Menu.LastHit.On or Menu.LastHit.On2 then
    LastHit()
  end
  
  if Menu.Auto.StackE and Recall == false and not Menu.Flee.On then
    StackE()
  end
  
  if Menu.Flee.On then
    Flee()
  end
  
  if Pool and Menu.Combo.On then
  
    if Target ~= nil then
    
      if GetDistance(Target, mousePos) <= 450 then
        MoveToPos(2*Target.x - mousePos.x, 2*Target.z - mousePos.z)
      else
        MoveToMouse()
      end
      
    else
      MoveToMouse()
    end
    
  end
  
  if VIP_USER and Menu.Misc.Skin then
    Skin()
  end
  
  if Menu.Misc.AutoLevel then
    AutoLevel()
  end
  
  if Target == nil then
    return
  end
  
  if Menu.KillSteal.On then
    KillSteal()
  end
  
  if Menu.Auto.On and Recall == false then
    Auto()
  end
  
  if Menu.Combo.On then
    Combo()
  end
  
  if Menu.Harass.On then
    Harass()
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Check()

  Q.ready = (myHero:CanUseSpell(_Q) == READY)
  W.ready = (myHero:CanUseSpell(_W) == READY)
  E.ready = (myHero:CanUseSpell(_E) == READY)
  R.ready = (myHero:CanUseSpell(_R) == READY)
  I.ready = (Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY)
  
  ZSlot = GetInventorySlotItem(3157)
  Z.ready = (ZSlot ~= nil and myHero:CanUseSpell(ZSlot) == READY)
	
  EnemyMinions:update()
  JungleMobs:update()
  
  if os.clock() - LastE > 10.1 then
    E.stack = 0
  end
  
  HealthPercent = (myHero.health/myHero.maxHealth)*100
  
end

----------------------------------------------------------------------------------------------------

function OrbTarget()

  local T
  
  if RebornLoaded then
    T = _G.AutoCarry.Crosshair.Attack_Crosshair.target
  end
  
  if RevampedLoaded then
    T = _G.AutoCarry.Orbwalker.target
  end
  
  if MMALoaded then
    T = _G.MMA_Target
  end
  
  if SOWLoaded then
    T = SOWVP:GetTarget()
  end
  
  if T and T.tpye == Player.type and ValidTarget(T, MaxRrange) then
    return T
  end
  
  QWETS:update()
  RTS:update()
  
  if QWETS.target then
    return QWETS.target
  end
  
  if RTS.target then
    return RTS.target
  end
  
end

----------------------------------------------------------------------------------------------------

function Debug()

  if os.clock() - DebugClock > 10 then
    print("Debugging...")
    DebugClock = os.clock()
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Combo()
  
  if GetDistanceSqr(Target) > MaxRrangeSqr then
    return
  end
  
  local ComboQ = Menu.Combo.Q
  local ComboE = Menu.Combo.E
  local ComboE2 = Menu.Combo.E2
  local ComboW = Menu.Combo.W
  local ComboW2 = Menu.Combo.W2
  local ComboR = Menu.Combo.R
  local ComboR2 = Menu.Combo.R2
  local ComboRearly = Menu.Combo.Rearly
  local DontR = Menu.Combo.DontR
  local ComboAutoR = Menu.Combo.AutoR
  
  local QTargetDmg = getDmg("Q", Target, myHero)
  local WTargetDmg = getDmg("W", Target, myHero)
  local ETargetDmg = (getDmg("E", Target, myHero) + E.stack*getDmg("E", Target, myHero, 2))
  local RTargetDmg = getDmg("R", Target, myHero)
  
  if R.ready and ComboAutoR then
  
    if ValidTarget(Target, MaxRrange) then
      CastR2(Target, Combo)
    end
    
  end
  
  if R.ready and ComboR then
  
    if ValidTarget(Target, R.range) then
    
      if not Q.ready and not E.ready and RTargetDmg*ComboR2 >= Target.health*100 then
        CastR(Target)
      end
      
    end
    
    if ValidTarget(Target, Q.range) then
    
      if Q.ready and DontR and QTargetDmg >= Target.health then
        return
      end
      
      if R.ready and ComboRearly and (QTargetDmg+ETargetDmg+RTargetDmg)*ComboR2 >= Target.health*100 then
        CastR(Target)
        return
      end
      
      if Q.ready and ComboQ and E.ready and ComboE and (QTargetDmg+ETargetDmg+RTargetDmg)*ComboR2 >= Target.health*100 then
        CastE()
        CastQ(Target)
        CastR(Target)
      elseif Q.ready and ComboQ and (not E.ready or not ComboE) and (QTargetDmg+RTargetDmg)*ComboR2 >= Target.health*100 then
        CastQ(Target)
        CastR(Target)
      elseif (not Q.ready or not ComboQ) and E.ready and ComboE and (ETargetDmg+RTargetDmg)*ComboR2 >= Target.health*100 then
        CastE()
        CastR(Target)
      end
      
    end
    
  end
  
  if E.ready and ComboE then
  
    if ComboE2 <= HealthPercent then
    
      if ValidTarget(Target, E.range) then
        CastE2(Target, Combo)
      end
      
    end
    
  end
  
  if Q.ready and ComboQ then
  
    if ValidTarget(Target, Q.range) then
      CastQ(Target)
    end
    
  end
  
  if W.ready and ComboW then
  
    if (not Q.ready or not ComboQ) and (not E.ready or not ComboE) then 
    
      if WTargetDmg*1000 >= myHero.health*2*ComboW2 then
      
        if ValidTarget(Target, W.radius) then
          CastW()
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Farm()

  if not Q.ready and not E.ready then
    return
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil or GetDistanceSqr(minion) > QrangeSqr then
      return
    end
    
    local FarmQ = Menu.Clear.Farm.Q
    local FarmE = Menu.Clear.Farm.E
    local FarmE2 = Menu.Clear.Farm.E2
    local FarmEmin = Menu.Clear.Farm.Emin
    
    local AAMinionDmg = getDmg("AD", minion, myHero)
    local QMinionDmg = getDmg("Q", minion, myHero)
    local EMinionDmg = getDmg("E", minion, myHero) + E.stack*getDmg("E", minion, myHero, 2)
    
    if E.ready and FarmE then
    
      if FarmE2 <= HealthPercent and FarmEmin <= MinionCount(minion, E.range) then
      
        if EMinionDmg + AAMinionDmg <= minion.health or EMinionDmg >= minion.health then
        
          if ValidTarget(minion, E.range) then
            CastE()
          end
          
        end
        
      end
      
    end
    
    if Q.ready and FarmQ then
    
      if QMinionDmg + AAMinionDmg <= minion.health or QMinionDmg >= minion.health then
      
        if ValidTarget(minion, Q.range) then
          CastQ(minion)
        end
        
      end
      
    end
    
  end
  
end

function MinionCount(Point, Range)

  local count = 0
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion ~= nil and GetDistance(Point, minion) <= Range then
      count = count + 1
    end
    
  end
  
  return count
  
end

----------------------------------------------------------------------------------------------------

function JFarm()

  if not Q.ready and not E.ready then
    return
  end
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob == nil or GetDistanceSqr(junglemob) > QrangeSqr then
      return
    end
  
    local JFarmQ = Menu.Clear.JFarm.Q
    local JFarmE = Menu.Clear.JFarm.E
    local JFarmE2 = Menu.Clear.JFarm.E2
    local JFarmEmin = Menu.Clear.JFarm.Emin
  
    if E.ready and JFarmE then
    
      if JFarmE2 <= HealthPercent and JFarmEmin <= JungleMobCount(junglemob, E.range) then
      
        if ValidTarget(junglemob, E.range) then
          CastE()
        end
        
      end
      
    end
    
    if Q.ready and JFarmQ then
    
      if ValidTarget(junglemob, Q.range) then
        CastQ(junglemob)
      end
      
    end
    
  end
  
end

function JungleMobCount(Point, Range)

  local count = 0
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob ~= nil and GetDistance(Point, junglemob) <= Range then
      count = count + 1
    end
    
  end
  
  return count
  
end

----------------------------------------------------------------------------------------------------

function JSteal()

  if not Q.ready and not E.ready then
    return
  end
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob == nil or GetDistanceSqr(junglemob) > ErangeSqr then
      return
    end
    
    local JStealQ = Menu.JSteal.Q
    local JStealE = Menu.JSteal.E
    local JStealEQ = Menu.JSteal.EQ
    local JStealE2 = Menu.JSteal.E2
    
    local AAjunglemobDmg = getDmg("AD", junglemob, myHero)
    local QjunglemobDmg = getDmg("Q", junglemob, myHero)
    local EjunglemobDmg = getDmg("E", junglemob, myHero) + E.stack*getDmg("E", junglemob, myHero, 2)
    
    if Q.ready and JStealQ and E.ready and JStealE and JStealEQ then
    
      if QjunglemobDmg + EjunglemobDmg >= junglemob.health and EjunglemobDmg < junglemob.health then
      
        if JStealE2 <= HealthPercent then
        
          if ValidTarget(junglemob, Q.range) then
            CastE()
            CastQ(junglemob)
          end
          
        end
        
      end
      
    elseif Q.ready and JStealQ then
    
      if QjunglemobDmg >= junglemob.health then
      
        if ValidTarget(junglemob, Q.range) then
          CastQ(junglemob)
        end
        
      end
      
    elseif E.ready and JStealE then
    
      if EjunglemobDmg >= junglemob.health then
      
        if JStealE2 <= HealthPercent then
        
          if ValidTarget(junglemob, E.range) then
            CastE()
          end
          
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Harass()

  if GetDistanceSqr(Target) > ErangeSqr then
    return
  end
  
  local HarassQ = Menu.Harass.Q
  local HarassE = Menu.Harass.E
  local HarassE2 = Menu.Harass.E2
  
  if E.ready and HarassE then
  
    if HarassE2 <= HealthPercent then
    
      if ValidTarget(Target, E.range) then
        CastE2(Target, Harass)
      end
    
    end
    
  end
  
  if Q.ready and HarassQ then
  
    if ValidTarget(Target, Q.range) then
      CastQ(Target)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function LastHit()

  if not Q.ready and not E.ready then
    return
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil or GetDistanceSqr(minion) > ErangeSqr then
      return
    end
    
    local LastHitQ = Menu.LastHit.Q
    local LastHitE = Menu.LastHit.E
    local LastHitEQ = Menu.LastHit.EQ
    local LastHitE2 = Menu.LastHit.E2
    
    local AAminionDmg = getDmg("AD", minion, myHero)
    local QminionDmg = getDmg("Q", minion, myHero)
    local EminionDmg = getDmg("E", minion, myHero) + E.stack*getDmg("E", minion, myHero, 2)
    
    if Q.ready and LastHitQ and E.ready and LastHitE and LastHitEQ then
    
      if QminionDmg + EminionDmg >= minion.health and EminionDmg < minion.health then
      
        if LastHitE2 <= HealthPercent then
        
          if ValidTarget(minion, Q.range) then
            CastE()
            CastQ(minion)
          end
          
        end
        
      end
      
    end
    
    if Q.ready and LastHitQ then
    
      if QminionDmg >= minion.health then
      
        if ValidTarget(minion, Q.range) then
          CastQ(minion)
        end
        
      end
      
    elseif E.ready and LastHitE then
    
      if EminionDmg >= minion.health then
      
        if LastHitE2 <= HealthPercent then
        
          if ValidTarget(minion, E.range) then
            CastE()
          end
          
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function KillSteal()

  if GetDistanceSqr(Target) > RrangeSqr then
    return
  end
  
  local KillStealQ = Menu.KillSteal.Q
  local KillStealW = Menu.KillSteal.W
  local KillStealE = Menu.KillSteal.E
  local KillStealE2 = Menu.KillSteal.E2
  local KillStealR = Menu.KillSteal.R
  local KillStealI = Menu.KillSteal.I
  
  local QTargetDmg = getDmg("Q", Target, myHero)
  local WTargetDmg = getDmg("W", Target, myHero)
  local ETargetDmg = (getDmg("E", Target, myHero) + E.stack*getDmg("E", Target, myHero, 2))
  local RTargetDmg = getDmg("R", Target, myHero)
  local ITargetDmg = getDmg("IGNITE", Target, myHero)
  
  if I.ready and KillStealI then
  
    if ITargetDmg >= Target.health then
    
      if ValidTarget(Target, I.range) then
        CastI(Target)
      end
      
    end
    
  end
  
  if E.ready and KillStealE then
  
    if KillStealE2 <= HealthPercent and ETargetDmg >= Target.health then
    
      if ValidTarget(Target, E.range) then
        CastE1(Target, KillSteal)
      end
      
    end
    
  end
  
  if Q.ready and KillStealQ then
  
    if QTargetDmg >= Target.health then
    
      if ValidTarget(Target, Q.range) then
        CastQ(Target)
      end
      
    end
    
  end
  
  if W.ready and KillStealW then
  
    if (not Q.ready or not KillStealQ) and (not E.ready or not KillStealE) then
    
      if WTargetDmg >= Target.health then
      
        if ValidTarget(Target, W.radius) then
          CastW()
        end
        
      end
      
    end
    
  end
  
  if R.ready and KillStealR then
  
    if RTargetDmg >= Target.health then
    
      if ValidTarget(Target, R.range) then
        CastR(Target)
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Auto()

  local AutoAutoZ = Menu.Auto.AutoZ
  local AutoZ = Menu.Auto.Z
  local AutoZmin = Menu.Auto.Zmin
  
  if Z.ready and AutoAutoZ then
  
    if AutoZ > HealthPercent and AutoZmin <= EnemyCount(Z.range) then
      CastZ()
    end
    
  end
  
  if E.ready and not Menu.Flee.On then
  
    if not Menu.Combo.On and not Menu.Harass.On and Menu.Auto.StackE then
    
      if Menu.Auto.SE2 <= HealthPercent then
        StackE()
      end
      
    end
    
    if Menu.Auto.AutoE then
    
      if Menu.Auto.E2 <= HealthPercent then
      
        if ValidTarget(Target, E.range) then
          CastE2(Target, Auto)
        end
        
      end
      
    end
    
  end
  
  if R.ready and Menu.Auto.AutoR then
    CastR2(Target, Auto)
  end
  
end

function EnemyCount(Range)

  local enemies = {}
  
  for _, enemy in ipairs(EnemyHeroes) do
    
    if ValidTarget(enemy, Range) then
      table.insert(enemies, enemy)
    end
    
  end
  
  return #enemies, enemies
  
end

function CastZ()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = ZSlot}):send()
  else
    CastSpell(ZSlot)
  end
  
end

----------------------------------------------------------------------------------------------------

function StackE()

  if os.clock() - LastE > 9.9 then
    CastE()
  end
  
end

----------------------------------------------------------------------------------------------------

function Flee()

  MoveToMouse()
  
  if W.ready and Menu.Flee.W then
    CastW()
  end
  
end

----------------------------------------------------------------------------------------------------

function Skin()

  local SkinOpt = Menu.Misc.SkinOpt 
  
  if SkinOpt ~= LastSkin then
    GenModelPacket("Vladimir", SkinOpt)
    LastSkin = Menu.Misc.SkinOpt
  end
  
end

function GenModelPacket(Champion, SkinId)

  p = CLoLPacket(0x97)
  p:EncodeF(myHero.networkID)
  p.pos = 1
  t1 = p:Decode1()
  t2 = p:Decode1()
  t3 = p:Decode1()
  t4 = p:Decode1()
  p:Encode1(t1)
  p:Encode1(t2)
  p:Encode1(t3)
  p:Encode1(bit32.band(t4,0xB))
  p:Encode1(1)
  p:Encode4(SkinId)
  
  for i = 1, #Champion do
    p:Encode1(string.byte(Champion:sub(i,i)))
  end
  
  for i = #Champion + 1, 64 do
    p:Encode1(0)
  end
  
  p:Hide()
  RecvPacket(p)
  
end

----------------------------------------------------------------------------------------------------

function AutoLevel()

  if Menu.Misc.ALOpt == 1 then
  
    local QL, WL, EL, RL = player:GetSpellData(_Q).level + Q.Off, player:GetSpellData(_W).level + W.Off, player:GetSpellData(_E).level + E.Off, player:GetSpellData(_R).level + R.Off
    
    if QL + WL + EL + RL < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoQEWQ[i]] = level[AutoQEWQ[i]] + 1
      end
      
      for i, v in ipairs({ QL, WL, EL, RL }) do
      
        if v < level[i] then
          LevelSpell(spell[i])
        end
        
      end
      
    end
    
  elseif Menu.Misc.ALOpt == 2 then
  
    local QL, WL, EL, RL = player:GetSpellData(_Q).level + Q.Off, player:GetSpellData(_W).level + W.Off, player:GetSpellData(_E).level + E.Off, player:GetSpellData(_R).level + R.Off
    
    if QL + WL + EL + RL < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoQWEQ[i]] = level[AutoQWEQ[i]] + 1
      end
      
      for i, v in ipairs({ QL, WL, EL, RL }) do
      
        if v < level[i] then
        LevelSpell(spell[i])
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnDraw()

  if Menu.Draw.On then
  
    if Menu.Draw.AA then
      DrawCircle(Player.x, Player.y, Player.z, TrueRange, ARGB(0xFF,0,0xFF,0))
    end
    
    if Menu.Draw.Q then
      DrawCircle(Player.x, Player.y, Player.z, Q.range, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.W then
      DrawCircle(Player.x, Player.y, Player.z, W.radius, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.E then
      DrawCircle(Player.x, Player.y, Player.z, E.range - 10, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.R then
      DrawCircle(Player.x, Player.y, Player.z, R.range, ARGB(0xFF,0xFF,0,0))
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function CastQ(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _Q, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(_Q, enemy)
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

function CastE()

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E}):send()
  else
    CastSpell(_E)
  end
  
  LastE = os.clock()
  
end

function CastE1(enemy, State)

  if Menu.Predict.PdOpt == 1 then
  
    local Pos, Info = Prodiction.GetCircularAOEPrediction(enemy, E.range, E.speed, E.delay, E.radius)
    
    if State == KillSteal then
    
      if Pos and Info.hitchance >= Menu.KillSteal.Ehit then
        CastE()
      end
      
    end
    
  elseif Menu.Predict.PdOpt == 2 then
  
    local AoECastPosition, MainTargetHitChance, NT = VP:GetCircularAOECastPosition(enemy, E.delay, E.radius, E.range, E.speed, myHero, false)
    
    if NT >= 1 then
    
      if MainTargetHitChance >= 2 then
        CastE()
      end
      
    end
    
  end
  
end

function CastE2(enemy, State)

  if Menu.Predict.PdOpt == 1 then
  
    if Donator then
    
      if State == Combo then
      
        local Boolean, Pos, Info = Prodiction.GetMinCountCircularAOEPrediction(Menu.Combo.Emin, E.range, E.speed, E.delay, E.radius)
        
        if Boolean and Pos and Info.hitchance >= Menu.Combo.Ehit then
          CastE()
        end
        
      elseif State == Harass then
      
        local Boolean, Pos, Info = Prodiction.GetMinCountCircularAOEPrediction(Menu.Harass.Emin, E.range, E.speed, E.delay, E.radius)
        
        if Boolean and Pos and Info.hitchance >= Menu.Harass.Ehit then
          CastE()
        end
        
      elseif State == Auto then
      
        local Boolean, Pos, Info = Prodiction.GetMinCountCircularAOEPrediction(Menu.Auto.Emin, E.range, E.speed, E.delay, E.radius)
        
        if Boolean and Pos and Info.hitchance >= Menu.Auto.Ehit then
          CastE()
        end
        
      end
      
    else
      print("Prodiction Cast E using min count is only for donator.")
    end
    
  elseif Menu.Predict.PdOpt == 2 then
  
    local AoECastPosition, MainTargetHitChance, NT = VP:GetCircularAOECastPosition(enemy, E.delay, E.radius, E.range, E.speed, myHero, false)
    
    if State == Combo then
    
      if NT >= Menu.Combo.Emin then
      
        if MainTargetHitChance >= 2 then
          CastE()        
        end
        
      end
      
    elseif State == Harass then
    
      if NT >= Menu.Harass.Emin then
      
        if MainTargetHitChance >= 2 then
          CastE()        
        end
        
      end
      
    elseif State == Auto then
    
      if NT >= Menu.Auto.Emin then
      
        if MainTargetHitChance >= 2 then
          CastE()        
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function CastR(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet('S_CAST', {spellId = _R, toX = enemy.x, toY = enemy.z, fromX = enemy.x, fromY = enemy.z}):send(true)
  else
    CastSpell(_R, enemy.x, enemy.z)
  end
  
end

function CastR2(enemy, State)

  if Menu.Predict.PdOpt == 1 then
  
    if Donator then
    
      if State == Combo then
      
        local Boolean, Pos, Info = Prodiction.GetMinCountCircularAOEPrediction(Menu.Combo.Rmin, R.range, R.speed, R.delay, R.radius)
        
        if Boolean and Pos and Info.hitchance >= Menu.Combo.Rhit then
          CastR(Pos)
        end
        
      elseif State == Auto then
      
        local Boolean, Pos, Info = Prodiction.GetMinCountCircularAOEPrediction(Menu.Auto.Rmin, R.range, R.speed, R.delay, R.radius)
        
        if Boolean and Pos and Info.hitchance >= Menu.Auto.Rhit then
          CastR(Pos)
        end
        
      end
      
    else
      print("Prodiction Cast E using min count is only for donator.")
    end
    
  elseif Menu.Predict.PdOpt == 2 then
  
    local AoECastPosition, MainTargetHitChance, NT = VP:GetCircularAOECastPosition(enemy, R.delay, R.radius, R.range, R.speed, myHero, false)
    
    if State == Combo then
    
      if NT >= Menu.Combo.Rmin then
      
        if MainTargetHitChance >= 2 then
          CastR(AoECastPosition)
        end
        
      end
      
    elseif State == Auto then
    
      if NT >= Menu.Auto.Rmin then
      
        if MainTargetHitChance >= 2 then
          CastR(AoECastPosition)
        end
        
      end
      
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function CastI(enemy)

  if Ignite == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = Ignite, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(Ignite, enemy)
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function MoveToPos(x, z)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_MOVE", {x, z}):send()
  else
    myHero:MoveTo(x, z)
  end
  
end

function MoveToMouse()

  if GetDistance(mousePos) then
    MousePos = myHero + (Vector(mousePos) - myHero):normalized()*300
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_MOVE", {MousePos.x, MousePos.z}):send()
  else
    myHero:MoveTo(MousePos.x, MousePos.z)
  end
  
end

----------------------------------------------------------------------------------------------------

function OnProcessSpell(owner,spell)

  if owner.isMe and spell.name == "VladimirTidesofBlood" then
  
    LastE = os.clock()
    
    if E.stack < 4 then
      E.stack = E.stack + 1
    end
    
  end
  
end

function OnGainBuff(unit, buff)

  if unit.isMe then
  
    if buff.name == "recall" then
      Recall = true
    end
    
    if buff.name == "vladimirsanguinepool" then
      Pool = true
    end
    
  end
  
end
 
function OnLoseBuff(unit, buff)

  if unit.isMe then
  
    if buff.name == "recall" then
      Recall = false
    end
    
    if buff.name == "vladimirsanguinepool" then
      Pool = false
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function OnSendPacket(p)

  if Target == nil then
    return
  end
  
  if E.ready and Menu.Combo.On then
  
    if Menu.Combo.E2 <= HealthPercent then
      BlockAA(p)
    end
    
  end
  
end

function BlockAA(p)

  local info = {header, NetworkID, type, x, y}
  
  info.header = p.header
  p.pos = 1
  info.networkID = p:DecodeF()
  info.type = p:Decode1()
  
  if info.header == Packet.headers.S_MOVE and info.type == 3 then
    p:Block()
  end
  
end
