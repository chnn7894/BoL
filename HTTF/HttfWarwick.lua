Version = "1.1"
AutoUpdate = true

if myHero.charName ~= "Warwick" then
  return
end

require 'SourceLib'

function ScriptMsg(msg)
  print("<font color=\"#00fa9a\"><b>HTTF Warwick:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

----------------------------------------------------------------------------------------------------

Host = "raw.github.com"

ServerPath = "/BolHTTF/BoL/master/Server.status".."?rand="..math.random(1,10000)
ServerData = GetWebResult(Host, ServerPath)

ScriptMsg("Server check...")

assert(load(ServerData))()

print("<font color=\"#00fa9a\"><b>HTTF Warwick:</b> </font><font color=\"#FFFFFF\">Server status: </font><font color=\"#ff0000\"><b>"..Server.."</b></font>")

if Server == "Off" then
  return
end

ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

ScriptPath = "/BolHTTF/BoL/master/HTTF/HttfWarwick.lua".."?rand="..math.random(1,10000)
UpdateURL = "https://"..Host..ScriptPath

VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HttfWarwick.version".."?rand="..math.random(1,10000)
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
  
  Variables()
  WarwickMenu()
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
  LastSkin = 0
  RebornLoaded, RevampedLoaded, MMALoaded, SxOrbLoaded, SOWLoaded = false, false, false, false, false
  Recall = false
  
  Q = {range = 400, ready}
  W = {range = 1200, ready}
  E = {range = 0, mspeed = 0, ready, state = true}
  R = {range = 700, ready}
  I = {range = 600, ready}
  
  MyminBBox = 56.38
  TrueRange = 125.5 + MyminBBox
  
  QrangeSqr = Q.range*Q.range
  RrangeSqr = R.range*R.range
  IrangeSqr = I.range*I.range
  
  AutoWQWE = {2, 1, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3} --W Q E
  AutoWQQE = {2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3} --Q W E
  AutoWQQE2 = {2, 1, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2} --Q E W
  AutoWQEQ = {2, 1, 3, 1, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3} --Q WEWE
  AutoQEQW = {1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2} --Q E W
  
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
  
  TS = TargetSelector(TARGET_LESS_CAST, R.range, DAMAGE_PHYSICAL, false)
  ETS = TargetSelector(TARGET_LESS_CAST, 4700, DAMAGE_PHYSICAL, false)
  
  EnemyMinions = minionManager(MINION_ENEMY, Q.range, player, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, Q.range, player, MINION_SORT_MAXHEALTH_DEC)
  
end

----------------------------------------------------------------------------------------------------

function WarwickMenu()

  Menu = scriptConfig("HTTF Warwick", "HTTF Warwick")
    
  Menu:addSubMenu("Combo Settings", "Combo")
  
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Info", "Use Q if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
      Menu.Combo:addParam("Q2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Info", "Use W if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
      Menu.Combo:addParam("W2", "Default value = 20", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		  Menu.Combo:addParam("Info", "Max Time to reach the Target if Use E", SCRIPT_PARAM_INFO, "")
      Menu.Combo:addParam("E2", "Default value = 5", SCRIPT_PARAM_SLICE, 5, 1, 10, 0)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R", "Use R Combo", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Rearly", "Use R early", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("DontR", "Do not use R if Killable with Q", SCRIPT_PARAM_ONOFF, true)
      
  Menu:addSubMenu("Clear Settings", "Clear")  
  
    Menu.Clear:addSubMenu("Lane Clear Settings", "Farm")
    
      Menu.Clear.Farm:addParam("On", "Lane Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
        Menu.Clear.Farm:addParam("Info", "Use Q if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
        Menu.Clear.Farm:addParam("Q2", "Default value = 70", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Info", "Use W if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
        Menu.Clear.Farm:addParam("W2", "Default value = 80", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
        
    Menu.Clear:addSubMenu("Jungle Clear Settings", "JFarm")
    
      Menu.Clear.JFarm:addParam("On", "Jungle Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Info", "Use Q if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
        Menu.Clear.JFarm:addParam("Q2", "Default value = 0", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Info", "Use W if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
        Menu.Clear.JFarm:addParam("W2", "Default value = 10", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
        
  Menu:addSubMenu("Harass Settings", "Harass")
  
    Menu.Harass:addParam("On", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Info", "Use Q if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
      Menu.Harass:addParam("Q2", "Default value = 10", SCRIPT_PARAM_SLICE, 10, 0, 100, 0)
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Info", "Use W if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
      Menu.Harass:addParam("W2", "Default value = 20", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
		  Menu.Harass:addParam("Info", "Max Time to reach the Target if Use E", SCRIPT_PARAM_INFO, "")
      Menu.Harass:addParam("E2", "Default value = 5", SCRIPT_PARAM_SLICE, 5, 1, 10, 0)
      
  Menu:addSubMenu("LastHit Settings", "LastHit")
  
    Menu.LastHit:addParam("On", "LastHit Key 1", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
    Menu.LastHit:addParam("On2", "LastHit Key 2", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
      Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.LastHit:addParam("Info", "Use Q if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
      Menu.LastHit:addParam("Q2", "Default value = 70", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
      
  Menu:addSubMenu("Jungle Steal Settings", "JSteal")
  
    Menu.JSteal:addParam("On", "Jungle Steal", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
      Menu.JSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.JSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
    --Menu.JSteal:addParam("S", "Use Smite", SCRIPT_PARAM_ONOFF, true)
    --Menu.JSteal:addParam("QS", "Use Q + Smite", SCRIPT_PARAM_ONOFF, true)
      
  Menu:addSubMenu("KillSteal Settings", "KillSteal")
  
    Menu.KillSteal:addParam("On", "KillSteal", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, false)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("I", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("AutoCast Settings", "Auto")
  
    Menu.Auto:addParam("On", "AutoCast", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoQ", "Auto Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Auto:addParam("Info", "Auto Q if Current Mana > Max mana * x%", SCRIPT_PARAM_INFO, "")
      Menu.Auto:addParam("Q2", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
      Menu.Auto:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Auto:addParam("AutoR", "Auto R", SCRIPT_PARAM_ONOFF, false)
      Menu.Auto:addParam("Info", "Auto R if Enemy Health percent < x%", SCRIPT_PARAM_INFO, "")
      Menu.Auto:addParam("R2", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
    
  Menu:addSubMenu("Flee Settings", "Flee")
  
    Menu.Flee:addParam("On", "Flee (Only Use KillSteal)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
      Menu.Flee:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Flee:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    
  Menu:addSubMenu("Misc Settings", "Misc")
  
    if VIP_USER then
    Menu.Misc:addParam("UsePacket", "Use Packet", SCRIPT_PARAM_ONOFF, true)
      Menu.Misc:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Misc:addParam("Skin", "Use Skin hack", SCRIPT_PARAM_ONOFF, false)
    Menu.Misc:addParam("SkinOpt", "Skin list : ", SCRIPT_PARAM_LIST, 8, { "1", "2", "3", "4", "5", "6", "7", "Classic"})  
      Menu.Misc:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    end
    Menu.Misc:addParam("AutoLevel", "Auto Level Spells", SCRIPT_PARAM_ONOFF, false)
    Menu.Misc:addParam("ALOpt", "Skill order : ", SCRIPT_PARAM_LIST, 1, { "R>W>Q>E (WQWE), Jungle", "R>Q>W>E (WQQE), Jungle", "R>Q>E>W (WQQE), Jungle", "R>Q>W=E (WQEQ), Jungle", "R>Q>E>W (QEQW), Top"})
   
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
    
  elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
    require 'SxOrbWalk'
    SxOrb = SxOrbWalk()
    HttfSxOrb = scriptConfig("HTTF Warwick - SxOrbalk", "Httf SxOrb")
		SxOrb:LoadToMenu(HttfSxOrb)
    SxOrbLoaded = true
    ScriptMsg("SxOrb Loaded ")
    
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
	ETarget = SpellETarget()
  Debug()
  
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
  
  if Menu.Flee.On then
    Flee()
  end
  
  if not (Menu.Combo.On and Menu.Combo.E) and not (Menu.Harass.On and Menu.Harass.E) and not (Menu.Flee.On and Menu.Flee.E) then
  
    if E.ready and E.state == true and Recall == false then
    
      if ETarget == nil then
        CastE()
      elseif (Target ~= nil and TargetHealthPercent > 50) or not ValidTarget(ETarget, E.range) then
        CastE()
      end
      
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
  
  if Menu.Auto.On then
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
  
  if GetSpellData(_E).level == 1 then
    E.mspeed = 0.2
	elseif GetSpellData(_E).level == 2 then
    E.mspeed = 0.25
	elseif GetSpellData(_E).level == 3 then
    E.mspeed = 0.3
	elseif GetSpellData(_E).level == 4 then
    E.mspeed = 0.35
	elseif GetSpellData(_E).level == 5 then
    E.mspeed = 0.4
	end
  
  EMoveSpeed = myHero.ms*(1+E.mspeed)
  
  EnemyMinions:update()
  JungleMobs:update()
  
  ManaPercent = (myHero.mana/myHero.maxMana)*100
  
  if Target ~= nil then
    TargetHealthPercent = (Target.health/Target.maxHealth)*100
  end
  
  local QL, WL, EL, RL = player:GetSpellData(_Q).level, player:GetSpellData(_W).level, player:GetSpellData(_E).level, player:GetSpellData(_R).level
    
  if QL + WL + EL + RL < player.level then
  
    if myHero:GetSpellData(_E).level == 1 then
      E.range = 1500
    elseif myHero:GetSpellData(_E).level == 2 then
      E.range = 2300
    elseif myHero:GetSpellData(_E).level == 3 then
      E.range = 3100
    elseif myHero:GetSpellData(_E).level == 4 then
      E.range = 3900
    elseif myHero:GetSpellData(_E).level == 5 then
      E.range = 4700
    end
  
  end
  
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
  
  if SxOrbLoaded then
    T = SxOrb:GetTarget()
  end
  
  if SOWLoaded then
    T = SOWVP:GetTarget()
  end
  
  if T and T.tpye == Player.type and ValidTarget(T, R.range) then
    return T
  end
  
  TS:update()
  
  if TS.target then
    return TS.target
  end
  
end

function SpellETarget()

  ETS:update()
  
  if ETS.target then
    return ETS.target
  end

end

----------------------------------------------------------------------------------------------------

function Debug()

  if E.state == true then
    Estate = "true"
	elseif E.state == false then
    Estate = "false"
  end
  
  if os.clock() - DebugClock > 2 then
    print("Debugging... E.state: "..Estate.." EMoveSpeed: "..EMoveSpeed.." E Range: "..E.range)
    DebugClock = os.clock()
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Combo()

  local ComboE = Menu.Combo.E
  
  if E.ready and ComboE and E.state == false and TargetHealthPercent <= 50 and ValidTarget(Target, R.range) then
    ComboCastE()
  end
  
  if GetDistanceSqr(Target) > RrangeSqr then
    return
  end
  
  local ComboQ = Menu.Combo.Q
  local ComboQ2 = Menu.Combo.Q2
  local ComboW = Menu.Combo.W
  local ComboW2 = Menu.Combo.W2
  local ComboR = Menu.Combo.R
  local ComboRearly = Menu.Combo.Rearly
  local DontR = Menu.Combo.DontR
  
  local QTargetDmg = getDmg("Q", Target, myHero)
  local RTargetDmg = getDmg("R", Target, myHero)*5
  print("QTargetDmg: "..QTargetDmg.." RTargetDmg: "..RTargetDmg)
  if R.ready and ComboR then
  
    if ValidTarget(Target, Q.range) then
    
      if Q.ready and ComboQ and ComboQ2 <= ManaPercent and DontR and QTargetDmg >= Target.health then
        CastQ(Target)
        return
      end
      
      if Q.ready and ComboQ and ComboQ2 <= ManaPercent and (QTargetDmg+RTargetDmg) >= Target.health then
        CastQ(Target)
        CastR(Target)
      elseif not (Q.ready and ComboQ) and RTargetDmg >= Target.health then
        CastR(Target) print("578")
        return
      end
      
    end
    
    if ValidTarget(Target, R.range) then
      
      if Q.ready and ComboQ and ComboRearly and ComboQ2 <= ManaPercent and (QTargetDmg+RTargetDmg) >= Target.health then
        CastR(Target)
        return
      end
    
      if RTargetDmg >= Target.health then
        CastR(Target)
      end
      
    end
    
  end
  
  if Q.ready and ComboQ and ComboQ2 <= ManaPercent and ValidTarget(Target, Q.range) then
    CastQ(Target)
  end
  
  if W.ready and ComboW and ComboW2 <= ManaPercent and ValidTarget(Target, TrueRange) then
    CastW()
  end
  
end

function ComboCastE()
  
  if EMoveSpeed  <= Target.ms then
    return
  end
  
  local ComboE2 = Menu.Combo.E2
	
  local TimeToReach = GetDistance(Target, myHero)/(EMoveSpeed-Target.ms)
  
  if TimeToReach <= ComboE2 then
    CastE()
  end
  
end

----------------------------------------------------------------------------------------------------

function Farm()

  if not Q.ready and not W.ready then
    return
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil or GetDistanceSqr(minion) > QrangeSqr then
      return
    end
  
    local FarmQ = Menu.Clear.Farm.Q
    local FarmQ2 = Menu.Clear.Farm.Q2
    local FarmW = Menu.Clear.Farm.W
    local FarmW2 = Menu.Clear.Farm.W2
    
    local AAMinionDmg = getDmg("AD", minion, myHero)
    local QMinionDmg = getDmg("Q", minion, myHero)
    
    if Q.ready and FarmQ and FarmQ2 <= ManaPercent and (QMinionDmg + AAMinionDmg <= minion.health or QMinionDmg >= minion.health) and ValidTarget(minion, Q.range) then
      CastQ(minion)
    end
    
    if W.ready and FarmW and FarmW2 <= ManaPercent and ValidTarget(minion, TrueRange) then
      CastW()
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function JFarm()

  if not Q.ready and not W.ready then
    return
  end
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob == nil or GetDistanceSqr(junglemob) > QrangeSqr then
      return
    end
    
    local JFarmQ = Menu.Clear.JFarm.Q
    local JFarmQ2 = Menu.Clear.JFarm.Q2
    local JFarmW = Menu.Clear.JFarm.W
    local JFarmW2 = Menu.Clear.JFarm.W2
  
    if Q.ready and JFarmQ and JFarmQ2 <= ManaPercent and ValidTarget(junglemob, Q.range) then
      CastQ(junglemob)
    end
    
    if W.ready and JFarmW and JFarmW2 <= ManaPercent and ValidTarget(junglemob, TrueRange) then
      CastW()
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function JSteal()

  if not Q.ready then
    return
  end
  
  for i, junglemob in pairs(JungleMobs.objects) do
  
    if junglemob == nil or GetDistanceSqr(junglemob) > QrangeSqr then
      return
    end
    
    local JStealQ = Menu.JSteal.Q
    local JStealS = Menu.JSteal.S
    local JStealSQ = Menu.JSteal.SQ
    
    local QjunglemobDmg = getDmg("Q", junglemob, myHero)
    
    if Q.ready and JStealQ and QjunglemobDmg >= junglemob.health and ValidTarget(junglemob, Q.range) then
      CastQ(junglemob)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function Harass()

  local HarassE = Menu.Harass.E
  
  if E.ready and HarassE and E.state == false and TargetHealthPercent <= 50 and ValidTarget(Target, R.range) then
    HarassCastE()
  end
  
  if GetDistanceSqr(Target) > QrangeSqr then
    return
  end
  
  local HarassQ = Menu.Harass.Q
  local HarassQ2 = Menu.Harass.Q2
  local HarassW = Menu.Harass.W
  local HarassW2 = Menu.Harass.W2
  
  if Q.ready and HarassQ and HarassQ2 <= ManaPercent and ValidTarget(Target, Q.range) then
    CastQ(Target)
  end
  
  if W.ready and HarassW and HarassW2 <= ManaPercent and ValidTarget(Target, TrueRange) then print("672")
    CastW()
  end
  
end

function HarassCastE()

  if EMoveSpeed <= Target.ms then
    return
  end
  
  local HarassE2 = Menu.Harass.E2
	
	local TimeToReach = GetDistance(Target, myHero)/(EMoveSpeed-Target.ms)
  
  if TimeToReach <= HarassE2 then
    CastE()
  end
  
end

----------------------------------------------------------------------------------------------------

function LastHit()

  if not Q.ready then
    return
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil or GetDistanceSqr(minion) > QrangeSqr then
      return
    end
    
    local LastHitQ = Menu.LastHit.Q
    local LastHitQ2 = Menu.LastHit.Q2
    
    local QminionDmg = getDmg("Q", minion, myHero)
    
    if Q.ready and LastHitQ and LastHitQ2 <= ManaPercent and QminionDmg >= minion.health and ValidTarget(minion, Q.range) then
      print(QminionDmg .. " " .. minion.health)
      CastQ(minion)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function KillSteal()

  if GetDistanceSqr(Target) > RrangeSqr then
    return
  end
  
  local KillStealQ = Menu.KillSteal.Q
  local KillStealR = Menu.KillSteal.R
  local KillStealI = Menu.KillSteal.I
  
  local QTargetDmg = getDmg("Q", Target, myHero)
  local RTargetDmg = getDmg("R", Target, myHero)*5
  local ITargetDmg = getDmg("IGNITE", Target, myHero)
  
  if I.ready and KillStealI and ITargetDmg >= Target.health and ValidTarget(Target, I.range) then
    CastI(Target)
  end
  
  if Q.ready and KillStealQ and QTargetDmg >= Target.health and ValidTarget(Target, Q.range) then
    CastQ(Target)
  end
  
  if R.ready and KillStealR and RTargetDmg >= Target.health and ValidTarget(Target, R.range) then
    CastR(Target) print("734")
  end
  
end

----------------------------------------------------------------------------------------------------

function Auto()

  local AutoAutoQ = Menu.Auto.AutoQ
  local AutoQ2 = Menu.Auto.Q2
  local AutoAutoR = Menu.Auto.AutoR
  local AutoR2 = Menu.Auto.R2
  
  local FleeOn = Menu.Flee.On
  
  if FleeOn or Recall == true then
    return
  end
  
  if Q.ready and AutoAutoQ and AutoQ2 <= ManaPercent and ValidTarget(Target, Q.range) then
    CastQ(Target)
  end
  
  if R.ready and AutoAutoR and AutoR2 >= TargetHealthPercent and ValidTarget(Target, R.range) then
    CastR(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function Flee()

  MoveToMouse()
  
	local FleeE = Menu.Flee.E
	
  if E.ready and FleeE and E.state == false then
    CastE()
  end
  
end

----------------------------------------------------------------------------------------------------

function Skin()

  local SkinOpt = Menu.Misc.SkinOpt 
  
  if SkinOpt ~= LastSkin then
    GenModelPacket("Warwick", SkinOpt)
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
  
    local QL, WL, EL, RL = player:GetSpellData(_Q).level, player:GetSpellData(_W).level, player:GetSpellData(_E).level, player:GetSpellData(_R).level
    
    if QL + WL + EL + RL < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoWQWE[i]] = level[AutoWQWE[i]] + 1
      end
      
      for i, v in ipairs({ QL, WL, EL, RL }) do
      
        if v < level[i] then
          LevelSpell(spell[i])
        end
        
      end
      
    end
    
  elseif Menu.Misc.ALOpt == 2 then
  
    local QL, WL, EL, RL = player:GetSpellData(_Q).level, player:GetSpellData(_W).level, player:GetSpellData(_E).level, player:GetSpellData(_R).level
    
    if QL + WL + EL + RL < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoWQQE[i]] = level[AutoWQQE[i]] + 1
      end
      
      for i, v in ipairs({ QL, WL, EL, RL }) do
      
        if v < level[i] then
        LevelSpell(spell[i])
        end
        
      end
      
    end
    
  elseif Menu.Misc.ALOpt == 3 then
  
    local QL, WL, EL, RL = player:GetSpellData(_Q).level, player:GetSpellData(_W).level, player:GetSpellData(_E).level, player:GetSpellData(_R).level
    
    if QL + WL + EL + RL < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoWQQE2[i]] = level[AutoWQQE2[i]] + 1
      end
      
      for i, v in ipairs({ QL, WL, EL, RL }) do
      
        if v < level[i] then
        LevelSpell(spell[i])
        end
        
      end
      
    end
    
  elseif Menu.Misc.ALOpt == 4 then
  
    local QL, WL, EL, RL = player:GetSpellData(_Q).level, player:GetSpellData(_W).level, player:GetSpellData(_E).level, player:GetSpellData(_R).level
    
    if QL + WL + EL + RL < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoWQEQ[i]] = level[AutoWQEQ[i]] + 1
      end
      
      for i, v in ipairs({ QL, WL, EL, RL }) do
      
        if v < level[i] then
        LevelSpell(spell[i])
        end
        
      end
      
    end
    
  elseif Menu.Misc.ALOpt == 5 then
  
    local QL, WL, EL, RL = player:GetSpellData(_Q).level, player:GetSpellData(_W).level, player:GetSpellData(_E).level, player:GetSpellData(_R).level
    
    if QL + WL + EL + RL < player.level then
    
      local spell = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
      local level = { 0, 0, 0, 0 }
      
      for i = 1, player.level, 1 do
        level[AutoQEQW[i]] = level[AutoQEQW[i]] + 1
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
      DrawCircle(Player.x, Player.y, Player.z, W.range, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.E then
      DrawCircle(Player.x, Player.y, Player.z, E.range, ARGB(0xFF,0xFF,0xFF,0xFF))
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
  
end

----------------------------------------------------------------------------------------------------

function CastR(enemy)

  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _R, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(_R, enemy)
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

function OnProcessSpell(object, spell)

  if object and spell.name == "BloodScent" then
  
    if E.state == true then
		  E.state = false
		elseif E.state == false then
		  E.state = true
		end
  
	end
  
  --[[if object == nil or object.name ~= myHero.name then
    return
  end
  
  print(spell.name)]]
  
end

function OnGainBuff(unit, buff)

  if unit.isMe then
  
    if buff.name == "recall" then
      Recall = true
    end
    
  end
  
end
 
function OnLoseBuff(unit, buff)

  if unit.isMe then
  
    if buff.name == "recall" then
      Recall = false
    end
    
  end
  
end
