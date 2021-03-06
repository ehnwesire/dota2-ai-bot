----------------------------------------------------------------------------------------------------
-- ability_item_usage_axe.lua
-- Author: KingleeBotSmiths 
-- Smith Trey Email: benjtrey@163.com
-- Smith Eric Email: looking4eric@outlook.com 
-- Smith Jerry Email: j1059244837@icloud.com 
----------------------------------------------------------------------------------------------------

castBCDesire = 0;
castBHDesire = 0;
castCBDesire = 0;
 
function AbilityUsageThink()
 
    local npcBot = GetBot();

	-- Check if the ability will stop our ongoing action
    if ( npcBot:IsUsingAbility() ) then return end;
	
    abilityBC = npcBot:GetAbilityByName( "axe_berserkers_call" ); 
    abilityBH = npcBot:GetAbilityByName( "axe_battle_hunger" );
    abilityCB = npcBot:GetAbilityByName( "axe_culling_blade" );

	--Consider using each ability
    castBCDesire = ConsiderBerserkersCall(); 
    castBHDesire, castBHTarget = ConsiderBattleHunger();
    castCBDesire, castCBTarget = ConsiderCullingBlade();
 
	if ( castCBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCB, castCBTarget );
        return;
    end
 
    if ( castBCDesire > 0 )
    then
        npcBot:Action_UseAbility( abilityBC );
        return;
    end
 
    if ( castBHDesire > 0 )
    then
		npcBot:Action_UseAbilityOnEntity( abilityBH, castBHTarcget );
        return;
    end

end
 
----------------------------------------------------------------------------------------------------
 
function CanCastCullingBladeOnTarget( npcTarget )
     return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
 

function CanCastBerserkersCallTarget( ) ----this is a no target skill... so what?
     return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end
--issue#1
--culling blade and berserkers_call is ignores magic immunes

function CanCastBattleHungerOnTarget( npcTarget )
     return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

----------------------------------------------------------------------------------------------------
 
function ConsiderCullingBlade()
 
    local npcBot = GetBot();
	 
    if ( not abilityCB:IsFullyCastable() )
    then
		return BOT_ACTION_DESIRE_NONE, 0;
    end;
	
	-- If we can use BerserkersCall, reject CullingBlade for a while
    if ( castBCDesire > 0 )
    then
		return BOT_ACTION_DESIRE_NONE, 0;
    end
 
    local nCastRange = abilityCB:GetCastRange();
    local nDamage = abilityCB:GetAbilityDamage(); 
	
    local npcTarget = npcBot:GetTarget();
    if ( npcTarget ~= nil and CanCastCullingBladeOnTarget( npcTarget ) ) --what does ~= mean? 
    then
		--get actual damage??? --this line of code is probably wronG.
        if ( npcTarget:GetActualDamage( nDamage, eDamageType ) > npcTarget:GetHealth() + 100 and UnitToUnitDistance( npcTarget, npcBot ) <= ( nCastRange ) )
           then
				print("Jeff Smith is working dawg!");
                return BOT_ACTION_DESIRE_HIGH, npcTarget;
				--because culling blade can kill targets immediately thus the deisre should be highest
           end
     end
	 
	return BOT_ACTION_DESIRE_NONE, 0; 	
	
end


----------------------------------------------------------------------------------------------------

function ConsiderBerserkersCall() 

local npcBot = GetBot();
 
    if ( not abilityBC:IsFullyCastable() ) then
        return BOT_ACTION_DESIRE_NONE;
    end;
 
 
     local nRadius = abilityBC:GetSpecialValueInt( "berserkers_call_aoe" );
     local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius + 200, true, BOT_MODE_NONE );
     for _,npcEnemy in pairs( tableNearbyEnemyHeroes ) --the line's code is hard to understand, in pairs
     do
           if ( npcEnemy:IsChanneling() )
           then
                return BOT_ACTION_DESIRE_HIGH; --cEnemy:GetLocation();
           end
     end

	--if the bot is pushing or defending a tower, and can get 2 or more heroes with the call, usse it
     if (  npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
           npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
           npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
           npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
           npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
           npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT )
     then
           local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), nRadius, 0, 0 );
 
           if ( locationAoE.count >= 4 )
           then
                return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		   --if we can get 4 or more heroes by the BC, the desire should be HIGH. 
		   --if the hero counr is 2 instead of 4 (less valuable), return MEDIUM.
		   else if (locationAoE.count >= 2 )
		   then
				return BOT_ACTION_DESIRE_MEDIUM; --locationAoE.targetloc;
           end
		   
		   
			end

	 -- if the team is targeting on an enemy hero by the current active code, try to get them
     if (  npcBot:GetActiveMode() == BOT_MODE_ROAM or
           npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
           npcBot:GetActiveMode() == BOT_MODE_GANK or
           npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
     then
           local npcTarget = npcBot:GetTarget();
 
           if ( npcTarget ~= nil )
           then
                if ( CanCastBerserkersCallOnTarget( npcTarget ) )
                then
					if ( GetUnitToUnitDistance ( npcTarget, npcBot ) < nRadius )
					then	
						return BOT_ACTION_DESIRE_HIGH; -- npcTarget:GetLocation();
					end
					--added our own code here: if the target is within BC's area of effect, use it with HIGH desire. 
				end
           end
     end
 
     return BOT_ACTION_DESIRE_NONE;
	 
	end
end
 --[[
 float GetUnitToUnitDistance( hUnit1, hUnit2 )
Returns the distance between two units.
]]--
----------------------------------------------------------------------------------------------------
 
function ConsiderBattleHunger() 
 
     local npcBot = GetBot();
	 local npcTarget = npcBot:GetTarget();
		
	 --just casual checkings of the states
     if ( not abilityBH:IsFullyCastable() ) then
           return BOT_ACTION_DESIRE_NONE, 0;
     end
 
     if ( castBCDesire > 0 )
     then
           return BOT_ACTION_DESIRE_NONE, 0;
end

local nDuration = abilityBH:GetDuration();
local nEstimatedDamageToTarget = abilityBH:GetEstimatedDamageToTarget( true, npcTarget, nDuration, DAMAGE_TYPE_MAGICAL  );
local nCastRange = abilityBH:GetCastRange();
local BHDamage = math.floor ( nEstimatedDamageToTarget );

	 --if we are roaming to gank someone, and 
     if (  npcBot:GetActiveMode() == BOT_MODE_ROAM or
           npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
           npcBot:GetActiveMode() == BOT_MODE_GANK )
     then
           if ( npcTarget ~= nil )
           then
                if ( CanCastBattleHungerOnTarget( npcTarget ) )
                then
                     return BOT_ACTION_DESIRE_LOW, npcTarget;
                end
				
				if ( npcTarget:GetHealth() < BHDamage + 100 )
				then
					return BOT_ACTION_DESIRE_HIGH, npcTarget; 
				end
				
				
           end
     end
		
		--if the enemy's health is more than 60%, and our mana is more than 80%, cast it on the enemy as
		--an inflict of damage
		--condition under farming mode, laning mode, defend ally, defending towers 
	 if (  npcBot:GetActiveMode() == BOT_MODE_FARM or
           npcBot:GetActiveMode() == BOT_MODE_LANING or
           npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		   npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT or
           npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
           npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP )
	then
		 if ( npcTarget:GetHealth() / npcTarget:GetMaxHealth() > 0.6 )
		 then
			if ( npcBot:GetMana() / npcBot:GetMaxMana() > 0.8)
			then
				return BOT_ACTION_DESIRE_MEDIUM, npcTarget; 
			end
		end
	 end	
		
     return BOT_ACTION_DESIRE_NONE, 0;
end
----------------------------------------------------------------------------------------------------
--LevelUpUrAbility!

	 local AbilityToUpgrade = {
"axe_counter_helix",
"axe_berserkers_call",
"axe_counter_helix",
"axe_berserkers_call",
"axe_counter_helix",
"axe_culling_blade", -- Lv6
"axe_counter_helix",
"axe_berserkers_call",
"axe_berserkers_call",
"special_bonus_strength_8",-- "special_bonus_attack_speed_40"
"axe_battle_hunger",
"axe_culling_blade", -- Lv12
"axe_battle_hunger",
"axe_battle_hunger",
"special_bonus_mp_regen_3",-- "special_bonus_movement_speed_40"
"axe_battle_hunger",
"axe_culling_blade", -- Lv18
"special_bonus_hp_regen_20",-- "special_bonus_unique_axe_3"      unique3 is attacking procs counter helix
"special_bonus_unique_axe_2"-- ""special_bonus_unique_axe""    unique 2 is +100 berserker call AoE   unique is +120 battle hunger DPS
};

function AbilityLevelUpThink() 

if ( #AbilityToUpgrade == 0 ) then
return;
end

local npcBot = GetBot();
  if (npcBot:GetAbilityPoints() > 0) then 
  local sNextAbility = npcBot:GetAbilityByName(AbilityToUpgrade[1])
    if (sNextAbility~=nil and sNextAbility:CanAbilityBeUpgraded() and sNextAbility:GetLevel() < sNextAbility:GetMaxLevel()) then
    npcBot:ActionImmediate_LevelAbility(AbilityToUpgrade[1])
	table.remove( AbilityToUpgrade, 1 )
    end	
  end
end