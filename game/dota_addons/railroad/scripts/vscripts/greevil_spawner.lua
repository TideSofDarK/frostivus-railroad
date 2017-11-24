function Spawn( entityKeyValues )
	local greevils = {
		"npc_black_greevil", "npc_white_greevil", "npc_orange_greevil", "npc_yellow_greevil", "npc_green_greevil", "npc_purple_greevil", "npc_fire_greevil", "npc_ice_greevil"
	}

	local greevil = GetRandomElement(greevils)

	greevil = CreateUnitByName("greevil", thisEntity:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
end