
local ver = "0.02"

if GetObjectName(GetMyHero()) ~= "Diana" then return end

require('MixLib')
require("DamageLib")
require("OpenPredict")


function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/Diana/master/Diana.lua', SCRIPT_PATH .. 'Diana.lua', function() PrintChat('<font color = "#00FFFF">Diana Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No new Diana updates found!')
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/Diana/master/Diana.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0

local DianaMenu = Menu("Diana", "Diana")

DianaMenu:SubMenu("Combo", "Combo")

DianaMenu.Combo:Boolean("Q", "Use Q in combo", true)
DianaMenu.Combo:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
DianaMenu.Combo:Boolean("W", "Use W in combo", true)
DianaMenu.Combo:Boolean("E", "Use E in combo", false)
DianaMenu.Combo:Boolean("R", "Use R in combo", false)
DianaMenu.Combo:Slider("RX", "X Enemies to Cast R",3,1,5,1)
DianaMenu.Combo:Boolean("Gunblade", "Use Gunblade", true)
DianaMenu.Combo:Boolean("Randuins", "Use Randuins", true)


DianaMenu:SubMenu("AutoMode", "AutoMode")
DianaMenu.AutoMode:Boolean("Level", "Auto level spells", false)
DianaMenu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
DianaMenu.AutoMode:Boolean("Q", "Auto Q", false)
DianaMenu.AutoMode:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
DianaMenu.AutoMode:Boolean("W", "Auto W", false)
DianaMenu.AutoMode:Boolean("E", "Auto E", false)
DianaMenu.AutoMode:Boolean("R", "Auto R", false)



DianaMenu:SubMenu("AutoFarm", "AutoFarm")
DianaMenu.AutoFarm:Boolean("Q", "Auto Q", false)
DianaMenu.AutoFarm:Boolean("W", "Auto W", false)
DianaMenu.AutoFarm:Boolean("E", "Auto E Always", false)




DianaMenu:SubMenu("LaneClear", "LaneClear")
DianaMenu.LaneClear:Boolean("Q", "Use Q", true)
DianaMenu.LaneClear:Boolean("W", "Use W", true)
DianaMenu.LaneClear:Boolean("E", "Use E", true)


DianaMenu:SubMenu("Harass", "Harass")
DianaMenu.Harass:Boolean("Q", "Use Q", true)
DianaMenu.Harass:Boolean("W", "Use W", true)

DianaMenu:SubMenu("KillSteal", "KillSteal")
DianaMenu.KillSteal:Boolean("Q", "KS w Q", true)
DianaMenu.KillSteal:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
DianaMenu.KillSteal:Boolean("W", "KS w W", true)
DianaMenu.KillSteal:Boolean("E", "KS w E", true)



DianaMenu:SubMenu("AutoIgnite", "AutoIgnite")
DianaMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

DianaMenu:SubMenu("Drawings", "Drawings")
DianaMenu.Drawings:Boolean("DQ", "Draw Q Range", true)

DianaMenu:SubMenu("SkinChanger", "SkinChanger")
DianaMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
DianaMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 4, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	      local target = GetCurrentTarget()
        
        local Gunblade = GetItemSlot(myHero, 3146)       
        local Cutlass = GetItemSlot(myHero, 3144)
        local Randuins = GetItemSlot(myHero, 3143)
        local DianaQ = { delay = 0.250, speed = 1700, width = 55, range = 900 }
        
	--AUTO LEVEL UP
	if DianaMenu.AutoMode.Level:Value() then

			spellorder = {_E, _W, _Q, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end



        
        --Harass
          if Mix:Mode() == "Harass" then
            if DianaMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 1000) then		
                                      CastSkillShot(_Q, target)
                                
            end

            if DianaMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 200) then
				       CastTargetSpell(target, _W)
            end     
          end





	--COMBO
	  if Mix:Mode() == "Combo" then
        

            if DianaMenu.Combo.Randuins:Value() and Randuins > 0 and Ready(Randuins) and ValidTarget(target, 500) then
			           CastSpell(Randuins)
            end

            if DianaMenu.Combo.Gunblade:Value() and Gunblade > 0 and Ready(Gunblade) and ValidTarget(target, 615) then
			           CastTargetSpell(target, Gunblade)
            end
			
	    if DianaMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 900) then
                 local QPred = GetPrediction(target,DianaQ)
                 if QPred.hitChance > (DianaMenu.Combo.Qpred:Value() * 0.1) then
                           CastSkillShot(_Q, QPred.castPos)
                 end
            end	


                   
            if DianaMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 450) then
			             CastSpell(_E)
	          end

		    
                  
            if DianaMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 200) then                                  
                               CastSpell(_W)
                       end
            

             if DianaMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 825) and GotBuff(target,"dianamoonlight") and (EnemiesAround(myHeroPos(), 825) >= DianaMenu.Combo.RX:Value()) then
                             CastTargetSpell(target,_R)
                   end
        
            end
			
	    			
          





         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end





    --KillSteal

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 900) and DianaMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
                       local QPred = GetPrediction(target,DianaQ)
                       if QPred.hitChance > (DianaMenu.KillSteal.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q, QPred.castPos)
                       end
            end

                
		         if IsReady(_W) and ValidTarget(enemy, 200) and DianaMenu.KillSteal.W:Value() and GetHP(enemy) < getdmg("W",enemy) then                 
                                  CastSpell(_W)
                    end
             
			
			
		         if IsReady(_E) and ValidTarget(enemy, 450) and DianaMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then
		                      CastSpell(_E)
  
                end

              
            
              end




    
      --Laneclear	
      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if DianaMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 900) then
	        	CastSkillShot(_Q, closeminion)
                end

                if DianaMenu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 200) then
	        	CastSpell(_W)
	        end

                if DianaMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 450) then
	        	CastSpell(_E)
	        end

               
          end
      end




      --Auto on minions
          for _, minion in pairs(minionManager.objects) do
      			
      			   	
              if DianaMenu.AutoFarm.Q:Value() and Ready(_Q) and ValidTarget(minion, 900) and GetCurrentHP(minion) < CalcDamage(myHero,minion,QDmg,Q) then
                  CastSkillShot(_Q, minion)
              end

              if DianaMenu.AutoFarm.W:Value() and Ready(_W) and ValidTarget(minion, 200) and GetCurrentHP(minion) < CalcDamage(myHero,minion,WDmg,W) then
                  CastSpell(_W)
              end

              if DianaMenu.AutoFarm.E:Value() and Ready(_E) and ValidTarget(minion, 450) and GetCurrentHP(minion) < CalcDamage(myHero,minion,EDmg,E) then
                  CastSpell(_E)
              end
		
	      		
			
          end


      


      
      --AutoMode
      
        if DianaMenu.AutoMode.Q:Value() and ValidTarget(target, 900) then        
               local QPred = GetPrediction(target,DianaQ)
               if QPred.hitChance > (DianaMenu.AutoMode.Qpred:Value() * 0.1) then
                         CastSkillShot(_Q, QPred.castPos)
               end
       end

        
        if DianaMenu.AutoMode.W:Value() and ValidTarget(target, 200) then                     
                         CastSpell(_W)
               end
        
    
        if DianaMenu.AutoMode.E:Value() then        
	           if Ready(_E) and ValidTarget(target, 615) then
		                CastSpell(_E)
	           end
        end
        
                
	--AUTO GHOST
	if DianaMenu.AutoMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)




OnDraw(function (myHero)
        
         if DianaMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 900, 0, 150, GoS.Black)
	end

end)



local function SkinChanger()
	if DianaMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Diana</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')
