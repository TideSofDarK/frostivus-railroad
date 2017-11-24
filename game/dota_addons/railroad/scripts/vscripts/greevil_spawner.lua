function Spawn( entityKeyValues )
	thisEntity:SetModel("models/development/invisiblebox.vmdl")
	thisEntity:SetOriginalModel("models/development/invisiblebox.vmdl")
	local greevils = {
		"npc_black_greevil", "npc_white_greevil", "npc_orange_greevil", "npc_yellow_greevil", "npc_green_greevil", "npc_purple_greevil", "npc_fire_greevil", "npc_ice_greevil"
	}

	local greevil_name = GetRandomElement(greevils)

	Timers:CreateTimer(function ()
		local time = math.ceil(GameRules:GetDOTATime(false, false))
		if time % 60.0 == 0 and time > 0 then
			if not IsValidEntity(greevil) or not greevil:IsAlive() then
				greevil = CreateUnitByName(greevil_name, thisEntity:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
				local angles = thisEntity:GetAngles()
				greevil:SetAngles(angles.x, angles.y, angles.z)
			end
		end
		return 1.0
	end)
end