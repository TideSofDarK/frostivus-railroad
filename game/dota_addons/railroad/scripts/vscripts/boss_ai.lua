function Spawn( entityKeyValues )
	thisEntity:AddNewModifier(thisEntity, nil, "modifier_invulnerable", {})
	thisEntity:AddNewModifier(thisEntity, nil, "modifier_rooted", {})

	Timers:CreateTimer(function (  )
		if not thisEntity:IsAlive() then
			Timers:CreateTimer(2, function ( )
				if thisEntity:GetTeamNumber() == 2 then
					GameRules:SetGameWinner(3)
				else
					GameRules:SetGameWinner(2)
				end
			end)
			return nil
		end
		if not thisEntity:HasModifier("modifier_rooted") then
			if not thisEntity.spawned then
				local spawnAbility = thisEntity:GetAbilityByIndex(1)
				thisEntity:CastAbilityNoTarget(spawnAbility, -1)
				thisEntity.spawned = true

				return 1.5
			else
				-- AddFOWViewer(2, Railroad.BOSS_DIRE:GetAbsOrigin(), flRadius, flDuration, bObstructedVision)
				if thisEntity:GetTeamNumber() == 2 then
					thisEntity:MoveToTargetToAttack(Railroad.BOSS_DIRE)
				else
					thisEntity:MoveToTargetToAttack(Railroad.BOSS_RADIANT)
				end
			end
		end

		return 0.1
	end)
end