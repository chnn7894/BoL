--Test-- --Test-- --Test-- --Test-- --Test-- --Test-- --Test-- --Test-- --Test-- --Test--
Version = "1.1"
AutoUpdate = true

if myHero.charName ~= "Ryze" then
  return
end

require 'SourceLib'

function ScriptMsg(msg)
  print("<font color=\"#00fa9a\"><b>HTTF Ryze R:</b></font> <font color=\"#FFFFFF\">"..msg.."</font>")
end

----------------------------------------------------------------------------------------------------

Host = "raw.github.com"

ServerPath = "/BolHTTF/BoL/master/Server.status".."?rand="..math.random(1,10000)
ServerData = GetWebResult(Host, ServerPath)

ScriptMsg("Server check...")

assert(load(ServerData))()

print("<font color=\"#00fa9a\"><b>HTTF Ryze:</b> </font><font color=\"#FFFFFF\">Server status: </font><font color=\"#ff0000\"><b>"..Server.."</b></font>")

if Server == "Off" then
  return
end

ScriptFilePath = SCRIPT_PATH..GetCurrentEnv().FILE_NAME

ScriptPath = "/BolHTTF/BoL/master/HTTF/HttfRyze.lua".."?rand="..math.random(1,10000)
UpdateURL = "https://"..Host..ScriptPath

VersionPath = "/BolHTTF/BoL/master/HTTF/Version/HttfRyze.version".."?rand="..math.random(1,10000)
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
  RyzeMenu()
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Variables()

  Target = nil
  
  Player = GetMyHero()
  
  if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
    Ignite = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
    Ignite = SUMMONER_2
  end
  
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
  
  Q = {range = 625, level = 0, ready}
  W = {range = 600, level = 0, ready}
  E = {range = 600, level = 0, ready}
  R = {level = 0, ready}
  I = {range = 600, ready}
  
  MyminBBox = 39.876
  TrueRange = 550+MyminBBox
  TrueminionRange = TrueRange
  TruejunglemobRange = TrueRange
  TrueTargetRange = TrueRange
  TargetAddRange = 0
  
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
  
  TS = TargetSelector(TARGET_LESS_CAST, Q.range+100, DAMAGE_MAGIC, false)
  
  EnemyMinions = minionManager(MINION_ENEMY, Q.range+100, player, MINION_SORT_MAXHEALTH_DEC)
  JungleMobs = minionManager(MINION_JUNGLE, Q.range, player, MINION_SORT_MAXHEALTH_DEC)
  
end

----------------------------------------------------------------------------------------------------

function RyzeMenu()

  Menu = scriptConfig("HTTF Ryze", "HTTF Ryze")
    
  Menu:addSubMenu("Combo Settings", "Combo")
  
    Menu.Combo:addParam("On", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
      Menu.Combo:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Combo:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.Combo:addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
      
  Menu:addSubMenu("Clear Settings", "Clear")  
  
    Menu.Clear:addSubMenu("Lane Clear Settings", "Farm")
    
      Menu.Clear.Farm:addParam("On", "Lane Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.Farm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)
        Menu.Clear.Farm:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.Farm:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Info", "Use Spell if Current Mana Percent > x%", SCRIPT_PARAM_INFO, "")
      Menu.Clear.Farm:addParam("Mana", "Default value = 70", SCRIPT_PARAM_SLICE, 70, 0, 100, 0)
        
    Menu.Clear:addSubMenu("Jungle Clear Settings", "JFarm")
    
      Menu.Clear.JFarm:addParam("On", "Jungle Claer", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
        Menu.Clear.JFarm:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
        Menu.Clear.JFarm:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
      Menu.Clear.JFarm:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
        
  Menu:addSubMenu("Harass Settings", "Harass")
  
    Menu.Harass:addParam("On", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
      Menu.Harass:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
      Menu.Harass:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Info", "Use Spell if Current Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.Harass:addParam("Mana", "Default value = 30", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
      
  Menu:addSubMenu("LastHit Settings", "LastHit")
  
    Menu.LastHit:addParam("On", "LastHit Key 1", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
      Menu.LastHit:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, false)
      Menu.LastHit:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, false)
      Menu.LastHit:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, false)
      Menu.LastHit:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Info", "Use Spell if Current Mana Percent > x%", SCRIPT_PARAM_INFO, "")
    Menu.LastHit:addParam("Mana", "Default value = 80", SCRIPT_PARAM_SLICE, 80, 0, 100, 0)
    
  Menu:addSubMenu("KillSteal Settings", "KillSteal")
  
    Menu.KillSteal:addParam("On", "KillSteal", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank2", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("W", "Use W", SCRIPT_PARAM_ONOFF, true)
      Menu.KillSteal:addParam("Blank3", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("E", "Use E", SCRIPT_PARAM_ONOFF, true)
    if Ignite ~= nil then
      Menu.KillSteal:addParam("Blank4", "", SCRIPT_PARAM_INFO, "")
    Menu.KillSteal:addParam("I", "Use Ignite", SCRIPT_PARAM_ONOFF, true)
    end
    
  Menu:addSubMenu("Flee Settings", "Flee")
  
    Menu.Flee:addParam("On", "Flee", SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'))
    
  if VIP_USER then
  Menu:addSubMenu("Misc Settings", "Misc")
  
    Menu.Misc:addParam("UsePacket", "Use Packet", SCRIPT_PARAM_ONOFF, true)
      Menu.Misc:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
  end
    Menu.Misc:addParam("Orbwalk", "Use Orbwalk", SCRIPT_PARAM_ONOFF, true)
  
  Menu:addSubMenu("Draw Settings", "Draw")
  
    Menu.Draw:addParam("On", "Draw", SCRIPT_PARAM_ONOFF, true)
      Menu.Draw:addParam("Blank", "", SCRIPT_PARAM_INFO, "")
    Menu.Draw:addParam("AA", "Draw Attack range", SCRIPT_PARAM_ONOFF, false)
    Menu.Draw:addParam("Q", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("W", "Draw W range", SCRIPT_PARAM_ONOFF, true)
    Menu.Draw:addParam("E", "Draw E range", SCRIPT_PARAM_ONOFF, false)
    
  Menu:addTS(TS)
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function OnTick()

  if myHero.dead then
    return
  end
  
  Check()
  Target = MyTarget()
  
  if Menu.KillSteal.On then
    KillSteal()
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
  
  if Menu.Harass.On then
    Harass()
  end
  
  if Menu.LastHit.On then
    LastHit()
  end
  
  if Menu.Flee.On then
    Flee()
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Check()
  
  if not CanMove and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastAA > WindUpTime and os.clock()-LastQ > 0.25 and os.clock()-LastW > 0.2419 and os.clock()-LastE > 0.5 then
    CanMove = true
  end
  
  if not CanAA and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastAA > math.max(WindUpTime, AnimationTime) then
    CanAA = true
  end
  
  if not CanQ and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastQ > 3.5*(1+myHero.cdr) then
    CanQ = true
  end
  
  if not CanW and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastW > 14*(1+myHero.cdr) then
    CanW = true
  end
  
  if not CanE and not (BeingAA or BeingQ or BeingW or BeingE) and os.clock()-LastE > 14*(1+myHero.cdr) then
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
  end
  
  if BeingW and os.clock()-LastW > 0.2419 then
    BeingW = false
    CanMove = true
  end
  
  if BeingE and os.clock()-LastE > 0.25 then
    BeingE = false
    CanMove = true
  end
  
  Q.ready = myHero:CanUseSpell(_Q) == READY
  W.ready = myHero:CanUseSpell(_W) == READY
  E.ready = myHero:CanUseSpell(_E) == READY
  R.ready = myHero:CanUseSpell(_R) == READY
  I.ready = Ignite ~= nil and myHero:CanUseSpell(Ignite) == READY
  
  Q.level = player:GetSpellData(_Q).level
  W.level = player:GetSpellData(_W).level
  E.level = player:GetSpellData(_E).level
  
  EnemyMinions:update()
  JungleMobs:update()
  
  ManaPercent = (myHero.mana/myHero.maxMana)*100

  TrueRange = 550+GetDistance(myHero.minBBox, myHero)
  
  if Target ~=nil then
  
    local AddRange = GetDistance(Target.minBBox, Target)
    
    TrueTargetRange = TrueRange+AddRange
    TargetAddRange = AddRange
    
  end
  
end

----------------------------------------------------------------------------------------------------

function MyTarget()
  
  TS:update()
  
  if TS.target then
    return TS.target
  end
  
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function Combo()

  Orbwalk(Combo)
  
  if Target == nil or not (Q.ready or W.ready or E.ready) then
    return
  end
  
  local ComboQ = Menu.Combo.Q
  local ComboW = Menu.Combo.W
  local ComboE = Menu.Combo.E
  local ComboR = Menu.Combo.R
  
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  local ETargetDmg = GetDmg("E", Target)
  
  if R.ready and QTargetDmg+WTargetDmg+ETargetDmg >= Target.health and ValidTarget(Target, 600) then
    CastR()
  end
  
  if Q.ready and ComboQ and CanQ and ValidTarget(Target, Q.range) then
    CastQ(Target)
  end
  
  if W.ready and ComboW and CanW and ValidTarget(Target, W.range) then
    CastW(Target)
  end
  
  if E.ready and ComboE and CanE and ValidTarget(Target, E.range) then
    CastE(Target)
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
    local FarmMana = Menu.Clear.Farm.Mana
    
    local AAMinionDmg = GetDmg("AD", minion)
    local QMinionDmg = GetDmg("Q", minion)
    local WMinionDmg = GetDmg("W", minion)
    local EMinionDmg = GetDmg("E", minion)
    
    if ManaPercent < FarmMana then
      return
    end
    
    if Q.ready and FarmQ and CanQ and (QMinionDmg+AAMinionDmg <= minion.health or QMinionDmg >= minion.health) and ValidTarget(minion, Q.range) then
      CastQ(minion)
    end
    
    if W.ready and FarmW and CanW and (WMinionDmg+AAMinionDmg <= minion.health or WMinionDmg >= minion.health) and ValidTarget(minion, W.range) then
      CastW(minion)
    end
    
    if E.ready and FarmE and CanE and (EMinionDmg+AAMinionDmg <= minion.health or EMinionDmg >= minion.health) and ValidTarget(minion, W.range) then
      CastE(minion)
    end
    
  end
  
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
    
    if Q.ready and JFarmQ and CanQ and ValidTarget(junglemob, Q.range) then
      CastQ(junglemob)
    end
    
    if W.ready and JFarmW and CanW and ValidTarget(junglemob, W.range) then
      CastW(junglemob)
    end
    
    if E.ready and JFarmE and CanE and ValidTarget(junglemob, E.range) then
      CastE(junglemob)
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
  local HarassMana = Menu.Harass.Mana
    
  if ManaPercent < HarassMana then
    return
  end
  
  if Q.ready and HarassQ and CanQ and ValidTarget(Target, Q.range) then
    CastQ(Target)
  end
  
  if W.ready and HarassW and CanW and ValidTarget(Target, W.range) then
    CastW(Target)
  end
  
  if E.ready and HarassE and CanE and ValidTarget(Target, E.range) then
    CastE(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function LastHit()

  Orbwalk(LastHit)
  
  if not (Q.ready or W.ready or E.ready) then
    return
  end
  
  for i, minion in pairs(EnemyMinions.objects) do
  
    if minion == nil then
      return
    end
    
    local LastHitQ = Menu.LastHit.Q
    local LastHitW = Menu.LastHit.W
    local LastHitE = Menu.LastHit.E
    local LastHitMana = Menu.LastHit.Mana
    
    local QminionDmg = GetDmg("Q", minion)
    local WminionDmg = GetDmg("W", minion)
    local EminionDmg = GetDmg("E", minion)
    
    if ManaPercent < LastHitMana then
      return
    end
    
    if Q.ready and LastHitQ and QminionDmg >= minion.health and ValidTarget(minion, Q.range) then
      CastQ(minion)
    end
    
    if W.ready and LastHitW and WminionDmg >= minion.health and ValidTarget(minion, W.range) then
      CastW(minion)
    end
    
    if E.ready and LastHitE and EminionDmg >= minion.health and ValidTarget(minion, E.range) then
      CastE(minion)
    end
    
  end
  
end

----------------------------------------------------------------------------------------------------

function KillSteal()

  if Target == nil or not (Q.ready or W.ready or E.ready or I.ready) then
    return
  end
  
  local KillStealQ = Menu.KillSteal.Q
  local KillStealW = Menu.KillSteal.W
  local KillStealE = Menu.KillSteal.E
  local KillStealI = Menu.KillSteal.I
  
  local QTargetDmg = GetDmg("Q", Target)
  local WTargetDmg = GetDmg("W", Target)
  local ETargetDmg = GetDmg("E", Target)
  local ITargetDmg = GetDmg("IGNITE", Target)
  
  if I.ready and KillStealI and ITargetDmg >= Target.health and ValidTarget(Target, I.range) then
    CastI(Target)
  end
  
  if Q.ready and KillStealQ and QTargetDmg >= Target.health and ValidTarget(Target, Q.range) then
    CastQ(Target)
  end
  
  if W.ready and KillStealW and WTargetDmg >= Target.health and ValidTarget(Target, W.range) then
    CastW(Target)
  end
  
  if E.ready and KillStealE and ETargetDmg >= Target.health and ValidTarget(Target, E.range) then
    CastE(Target)
  end
  
end

----------------------------------------------------------------------------------------------------

function Flee()

  Orbwalk(Flee)

end

----------------------------------------------------------------------------------------------------

function Orbwalk(State)

  if not Menu.Misc.Orbwalk then
    return
  end

  if State == Flee then
    MoveToMouse()
    return
  end
  
  if CanAA and CanMove then
  
    if Target ~= nil and State == Combo and ValidTarget(Target, TrueTargetRange) then
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
        
        if ValidTarget(minion, TrueminionRange) then
				
				  if AAMinionDmg >= minion.health then
            CanMove = false
            CanQ = false
            CanW = false
            CanE = false
            CastAA(minion)
          elseif 2*AAMinionDmg <= minion.health then
            CanMove = false
            CanQ = false
            CanW = false
            CanE = false
            CastAA(minion)
					end
					
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
          CanMove = false
          CanQ = false
          CanW = false
          CanE = false
          CastAA(junglemob)
        end
        
      end
      
    elseif Target ~= nil and State == Harass and ValidTarget(Target, TrueTargetRange) then
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
          CanMove = false
          CanQ = false
          CanW = false
          CanE = false
          CastAA(minion)
        end
        
      end
      
    end
    
  end
    
  if CanMove then
    MoveToMouse()
  end
  
end

----------------------------------------------------------------------------------------------------

function GetDmg(spell, enemy)
  
  local Level = myHero.level
  local TotalDmg = myHero.totalDamage
  local AP = myHero.ap
  local MaxMana = myHero.maxMana
  local ArmorPen = myHero.armorPen
  local ArmorPenPercent = myHero.armorPenPercent
  local MagicPen = myHero.magicPen
  local MagicPenPercent = myHero.magicPenPercent
  
  local Armor = math.max(0, enemy.armor*ArmorPenPercent-ArmorPen)
  local ArmorPercent = Armor/(100+Armor)
  local MagicArmor = math.max(0, enemy.magicArmor*MagicPenPercent-MagicPen)
  local MagicArmorPercent = MagicArmor/(100+MagicArmor)
  
  if spell == "IGNITE" then
  
    local TrueDmg = 50+20*Level
    
    return TrueDmg
    
  elseif spell == "AD" then
    
    local TrueDmg = TotalDmg*(1-ArmorPercent)
    
    return TrueDmg
  
  elseif spell == "Q" then
    PureDmg = 20*Q.level+20+0.4*AP+0.065*MaxMana
  elseif spell == "W" then
    PureDmg = 35*W.level+25+0.6*AP+0.045*MaxMana
  elseif spell == "E" then
    PureDmg = 20*E.level+30+0.35*AP+0.01*MaxMana
  end
  
  local TrueDmg = PureDmg*(1-MagicArmorPercent)
  
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
    
    if Menu.Draw.Q and Q.ready then
      DrawCircle(Player.x, Player.y, Player.z, Q.range, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.W and W.ready then
      DrawCircle(Player.x, Player.y, Player.z, W.range, ARGB(0xFF,0xFF,0xFF,0xFF))
    end
    
    if Menu.Draw.E and E.ready then
      DrawCircle(Player.x, Player.y, Player.z, E.range, ARGB(0xFF,0xFF,0xFF,0xFF))
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
  
  LastAA = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastQ(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _Q, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(_Q, enemy)
  end
  
  LastQ = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastW(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _W, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(_W, enemy)
  end
  
  LastW = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastE(enemy)

  if enemy == nil then
    return
  end
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _E, targetNetworkId = enemy.networkID}):send()
  else
    CastSpell(_E, enemy)
  end
  
  LastE = os.clock()
  
end

----------------------------------------------------------------------------------------------------

function CastR()
  
  if VIP_USER and Menu.Misc.UsePacket then
    Packet("S_CAST", {spellId = _R}):send()
  else
    CastSpell(_R)
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
----------------------------------------------------------------------------------------------------

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
  
    if spell.name:find("RyzeBasicAttack" or "RyzeBasicAttack2") then
      LastAA = os.clock()
      BeingAA = true
      CanAA = false
      AnimationTime = spell.animationTime
      WindUpTime = spell.windUpTime+0.05
    end
    
    if spell.name:find("Overload") then
      LastQ = os.clock()
      LastW = LastW+1
      LastE = LastE+1
      BeingQ = true
      CanQ = false
    end
    
    if spell.name:find("RunePrison") then
      LastW = os.clock()
      LastQ = LastQ+1
      LastE = LastE+1
      BeingW = true
      CanW = false
    end
    
    if spell.name:find("SpellFlux") then
      LastE = os.clock()
      LastQ = LastQ+1
      LastW = LastW+1
      BeingE = true
      CanE = false
    end
    
    if spell.name:find("DesperatePower") then
      LastQ = LastQ+1
      LastW = LastW+1
      LastE = LastE+1
    end
    
  end
  
end
