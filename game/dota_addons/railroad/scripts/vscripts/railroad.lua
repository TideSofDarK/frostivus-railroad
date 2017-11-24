if Railroad == nil then
    _G.Railroad = class({})
end

function Railroad:Init()
    CustomGameEventManager:RegisterListener( "frostivus_upgrade", Dynamic_Wrap(Railroad, 'OnUpgrade'))

    Railroad.BOSS_RADIANT = Entities:FindByName(nil, "npc_ice_queen")
    Railroad.BOSS_DIRE = Entities:FindByName(nil, "npc_ice_king")

    Railroad.RICH_GREEVIL_WAYPOINTS_1 = {}
    for i=1,7 do
    	table.insert(Railroad.RICH_GREEVIL_WAYPOINTS_1, Entities:FindByName(nil, "rich_greevil_waypoint1_"..tostring(i)):GetAbsOrigin())
    end
    Railroad.RICH_GREEVIL_WAYPOINTS_2 = {}
    for i=1,7 do
    	table.insert(Railroad.RICH_GREEVIL_WAYPOINTS_2, Entities:FindByName(nil, "rich_greevil_waypoint2_"..tostring(i)):GetAbsOrigin())
    end
end

function Railroad:OnUpgrade(keys)
	local pid = keys.PlayerID
	local ability_id = keys.id

	local hero = PlayerResource:GetPlayer(pid):GetAssignedHero()

	local old_data = CustomNetTables:GetTableValue("players", tostring(hero:GetPlayerOwnerID()))

	local candies = old_data.candies

	local ab = hero.buff_dummy:FindAbilityByName(tostring(string.gsub(ability_id, "Cell", "buff_")))
	if ab then
		if ab:GetLevel() >= ab:GetMaxLevel() then return end
		local cost = ab:GetLevelSpecialValueFor("cost", ab:GetLevel())
		if old_data.candies >= cost then
			old_data.candies = old_data.candies - cost

			CustomNetTables:SetTableValue("players", tostring(hero:GetPlayerOwnerID()), old_data)

			ab:SetLevel(ab:GetLevel() + 1)

			local buff_dummy = hero.buff_dummy
			if buff_dummy then
				local buff_array = CustomNetTables:GetTableValue("universal_buff", tostring(pid))
				local key = tostring(string.gsub(string.lower(ab:GetName()), "buff_", ""))
				buff_array[key] = ab:GetAbilitySpecial(key)
				CustomNetTables:SetTableValue("universal_buff", tostring(pid), buff_array)
			end

			if hero.greevil then
				for i=0,5 do
					local ab = hero.greevil:GetAbilityByIndex(i)
					ab:SetLevel(CustomNetTables:GetTableValue("universal_buff", tostring(pid))["ability"..tostring(i+1)])
					ab:SetHidden(false)
				end
			end
		end
	end
end

function Railroad:GiveCandiesToTeam(team, candies, particle)
	for playerID = 0, DOTA_MAX_PLAYERS do
      	if PlayerResource:IsValidPlayerID(playerID) then
        	if not PlayerResource:IsBroadcaster(playerID) then
        		if PlayerResource:GetTeam(playerID) == team then
			      	local hero = GameMode.assignedPlayerHeroes[playerID] 
			      	if IsValidEntity(hero) == true then
			        	local old_data = CustomNetTables:GetTableValue("players", tostring(playerID))

			        	old_data.candies = old_data.candies + candies

			        	CustomNetTables:SetTableValue("players", tostring(playerID), old_data)

			        	if particle then PopupParticle(candies, Vector(200,60,55), 1.0, hero, POPUP_SYMBOL_PRE_PLUS) end
			      	end
        		end
        	end
      	end
    end
end

function Railroad:SpawnRichGreevil()
	local points

	if math.random(0,1) == 0 then
		points = Railroad.RICH_GREEVIL_WAYPOINTS_1
	else
		points = Railroad.RICH_GREEVIL_WAYPOINTS_2
	end

	if IsValidEntity(Railroad.rich_greevil) then
		Railroad.rich_greevil:RemoveSelf()
	end
	Railroad.rich_greevil = CreateUnitByName("npc_rich_greevil", points[1], true, nil, nil, DOTA_TEAM_NEUTRALS)

	local point = 1
	Timers:CreateTimer(function()
		if not IsValidEntity(Railroad.rich_greevil) then
			return
		end
		if Railroad.rich_greevil:IsIdle() then
			point = point + 1
			if point > 7 then
				point = 1
			end
			Railroad.rich_greevil:MoveToPosition(points[point])
		else
			
		end
		return 0.1
	end)
end

function OnRichGreevilAttacked( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability:IsCooldownReady() then
		local new_item = CreateItem("item_rich_candy", caster, caster)
		local container = CreateItemOnPositionForLaunch(caster:GetAbsOrigin(), new_item):GetContainedItem():LaunchLoot(false, 120, 1.0, GetGroundPosition(Vector(math.random(-100, 100), math.random(-100, 100), 0) + caster:GetAbsOrigin(), caster))
		new_item:GetContainer():SetRenderColor(math.random(25, 250), math.random(25, 250), math.random(25, 250))
		new_item:EmitSound("ui.inv_drop_highvalue")
		ability:StartCooldown(1)

		local p = ParticleManager:CreateParticle("particles/hw_fx/hw_rosh_death_candy.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(p)
	end
end

function OnRichGreevilDead( keys )
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker

	local pos = caster:GetAbsOrigin()

	Timers:CreateTimer(4.5, function (  )
		local p = ParticleManager:CreateParticle("particles/rich_greevil_death.vpcf", PATTACH_CUSTOMORIGIN, attacker)
		ParticleManager:SetParticleControl(p, 0, pos)
		ParticleManager:SetParticleControl(p, 3, pos)
		ParticleManager:ReleaseParticleIndex(p)
	end)
end

function PickupRichCandy( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:EmitSound("DOTA_Item.Hand_Of_Midas")

	Railroad:GiveCandiesToTeam(caster:GetTeamNumber(), ability:GetAbilitySpecial("candies"), true)
end

WAGON_SPEED = 6

Railroad.wagon = nil
Railroad.wagon_path = nil

function BuildPath()
	local path = Entities:FindAllByName("wagon_path_*")
	local swap = 0

	Railroad.wagon_path = {}
	local skip = false

	for i=1,#path do
		local p = Entities:FindByName(nil, "wagon_path_"..tostring(i))
		-- local p1 = path[i]:GetAbsOrigin()
		-- local p2 = path[i+1]

		-- if p2 then
		-- 	p2 = path[i+1]:GetAbsOrigin()
		-- else
		-- 	p2 = p1
		-- end

		-- local direction = path[i-1]
		-- if direction then
		-- 	direction = direction:GetAbsOrigin()
		-- end

		table.insert(Railroad.wagon_path, p:GetAbsOrigin())	

		-- if Distance(p1, p2) > 200 then
		-- 	-- DebugDrawLine(p1 + Vector(0,0,50), p2 + Vector(0,0,50), 255, 0, 255, false, 5.0)
		-- 	table.insert(Railroad.wagon_path, p1)	
		-- else
		-- 	-- table.insert(self.wagon_path, p1)	

		-- 	local p3 = Vector(p1.x, ((p1.y + p2.y) / 2))
		-- 	local p4 = Vector(((p1.x + p2.x) / 2), p2.y)

		-- 	local curve = BezierCurve:ComputeBezier({p1,p3,p4,p2},30) 

		-- 	if swap % 2 == 0 then
		-- 		p3.x = p2.x
		-- 		p4.y = p1.y
		-- 		curve = BezierCurve:ComputeBezier({p2,p3,p4,p1},30) 

		-- 		for x=#curve,1,-1 do
		-- 			table.insert(Railroad.wagon_path, curve[x])
		-- 		end
		-- 	else
		-- 		for x=1,#curve-1 do
		-- 			table.insert(Railroad.wagon_path, curve[x])
		-- 		end
		-- 	end

		-- 	swap = swap + 1
		-- end
	end
end

function InitWagon( keys )
	local caster = keys.caster
	local ability = keys.ability

	BuildPath()

	Railroad.wagon = caster

	-- if Railroad.wagon.area then
	-- 	ParticleManager:DestroyParticle(Railroad.wagon.area, true)
	-- end

	-- Railroad.wagon:SetForwardVector(UnitLookAtPoint(wagon, self.wagon_path[2] ))

	-- Railroad.wagon:SetAbsOrigin(Railroad.wagon_path[1])

	Railroad.wagon.path = Railroad.wagon_path
	Railroad.wagon.path_point = 3

	Railroad.wagon.path_length = GetPathLength( Railroad.wagon_path )
	Railroad.wagon.path_traveled = 0
end

function Wagon( keys )
	local caster = keys.caster
	local ability = keys.ability

	if not IsValidEntity(ability) then return end

	if caster:IsNull() then return end

	if not Railroad.wagon_path then
		InitWagon( keys )
	end

	local percentage = caster.path_traveled / caster.path_length

	-- if percentage >= 50 and Director.scenario.stage < Mines.STAGE_BOSS then
	-- 	Director.scenario:NextStage()
	-- 	return
	-- end

	-- if not Director.scenario:CanMoveWagon() then
	-- 	return
	-- end

	if not caster.area then
		caster.area = ParticleManager:CreateParticle("particles/wagon_area.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(caster.area, 0, caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin(),false)
		ParticleManager:SetParticleControl(caster.area, 2, Vector(128,0,0))
	end
	local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,GetSpecial(ability, "radius"),DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	local teams = {}
	for k,v in pairs(units) do
		if v:GetUnitName() == "npc_wagon" then
			table.remove(units, k)
		else
			teams[v:GetTeam()] = true
			if v:GetUnitName() == "npc_snowball" or teams[2] and teams[3] then
				units = {}
				break
			end
		end
	end
	for k,v in pairs(units) do
		if v:IsRealHero() then
			ParticleManager:SetParticleControl(caster.area, 2, Vector(0,128,0))

			-- CustomNetTables:SetTableValue( "scenario", "wagon", {percentage = percentage} )
			local team = v:GetTeamNumber()

			if team == 3 then
				team = 2
			else
				team = 3
			end

			local team_modifier = 1
			if team == 3 then team_modifier = -1 end

			local movement

			movement = Timers:CreateTimer(0.0, function ()
				local position = caster:GetAbsOrigin()
				 
				local distance_traveled = 0
				local distance_to_travel = WAGON_SPEED
				 
				local new_position = position
				 
				while distance_traveled < distance_to_travel do
				    -- if #caster.path < caster.path_point + team_modifier then
				    --     break
				    -- end

				    local function Destroy()
				    	local p = ParticleManager:CreateParticle("particles/frostivus_gameplay/fireworks.vpcf", PATTACH_CUSTOMORIGIN, caster)
				    	ParticleManager:SetParticleControl(p, 3, caster:GetAbsOrigin() + Vector(0,0,300))
				    	ParticleManager:SetParticleControlOrientation(p, 3, Vector(0, 1, 0), Vector(1, 0, 0), Vector(0,1,0))

						caster:FindAbilityByName("railroad_wagon"):RemoveSelf()

						ParticleManager:DestroyParticle(caster.area, false)
				    	
				    	Timers:CreateTimer(5.0, function ()
				    		caster:SetModel("models/development/invisiblebox.vmdl")
				    		caster:EmitSound("Hero_Techies.Suicide")
				    		local p = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				    		ParticleManager:SetParticleControl(p, 3, caster:GetAbsOrigin())
				    		Timers:CreateTimer(4.0, function (  )
				    			caster:RemoveSelf()
				    		end)
				    		Railroad.wagon = nil
				    	end)

				    	Timers:RemoveTimer(movement)
				    end
					
				    local next_point

				    if team == 3 then
					    if not caster.path[caster.path_point] then
					    	Railroad:GiveCandiesToTeam(2, 1200, true)

					    	Notifications:TopToTeam(3, {text="Enemy has captured the wagon and received 1200 candies", duration=2, class="NotificationMessage"})
					    	Notifications:TopToTeam(2, {text="You've captured the wagon and received 1200 candies!", duration=3, class="NotificationMessage"})
					    
					    	EmitAnnouncerSoundForTeam("bucket.lost_wagon", 3)
					    	EmitAnnouncerSoundForTeam("bucket.capture", 2)

					    	Destroy()
					    	return 0.0
					    end

					    next_point = GetGroundPosition(caster.path[caster.path_point],caster)
				    else
					    if not caster.path[caster.path_point + team_modifier] then
					    	Railroad:GiveCandiesToTeam(3, 1200, true)

					    	Notifications:TopToTeam(2, {text="Enemy has captured the wagon and received 1200 candies", duration=2, class="NotificationMessage"})
					    	Notifications:TopToTeam(3, {text="You've captured the wagon and received 1200 candies!", duration=3, class="NotificationMessage"})
					    
					    	EmitAnnouncerSoundForTeam("bucket.lost_wagon", 2)
					    	EmitAnnouncerSoundForTeam("bucket.capture", 3)

					    	Destroy()
					    	return 0.0
					    end

					    next_point = GetGroundPosition(caster.path[caster.path_point + team_modifier],caster)
				    end

				    if not caster.moved_last_frame then
				    	StartSoundEvent("bucket.wagon_loop", caster)
				    	caster.moved_last_frame = true
				    end

				    local ignore_z = (team == 3 and caster.path[caster.path_point].z == caster.path[caster.path_point + 1].z) or (team == 2 and caster.path[caster.path_point + team_modifier].z == caster.path[caster.path_point].z)
				    local look_at_target = UnitLookAtPoint( caster, next_point, true, ignore_z )
				    look_at_target.z = look_at_target.z * team_modifier
				    caster:SetForwardVector(LerpVectors(caster:GetForwardVector(), look_at_target, 0.03 * 10))

				    local direction_to_next_point = (next_point - new_position):Normalized()
				    local distance_to_next_point  = (new_position - next_point):Length2D()
				    local distance_left_to_travel = distance_to_travel - distance_traveled
				   
				    local step_distance = math.min(distance_left_to_travel, distance_to_next_point)
				   
				    if step_distance == 0 then
				        break
				    end
				   
				    new_position = (step_distance * direction_to_next_point) + new_position

				    if step_distance == distance_to_next_point then
				        caster.path_point = caster.path_point + team_modifier
				    end
				   
				    distance_traveled = distance_traveled + step_distance
				    caster.path_traveled = caster.path_traveled + step_distance
				end
				 
				new_position.z = GetGroundHeight(new_position,caster)
				 
				caster:SetAbsOrigin(new_position)
				 
				return 0.03
			end)

			Timers:CreateTimer(0.47, function (  )
				Timers:RemoveTimer(movement)
			end)
		end
	end

	if #units == 0 then
		caster.moved_last_frame = false
		StopSoundEvent("bucket.wagon_loop", caster)
		ParticleManager:SetParticleControl(caster.area, 2, Vector(128,0,0))
	end
end

function SpawnBall(keys)
	local caster = keys.caster
	local ability = keys.ability

	-- local offset = 100

	-- local ball = CreateUnitByName("npc_snowball", caster:GetAbsOrigin() + Vector(0,0,offset), false, caster, caster, 3)

	local rangeParticle = ParticleManager:CreateParticle("particles/bucket_range.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(rangeParticle, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(rangeParticle, 3, Vector(450, 1, 1))
	ParticleManager:SetParticleControl(rangeParticle, 4, Vector(55, 255, 55))
	-- ParticleManager:ReleaseParticleIndex(rangeParticle)
end

function OnSnowballAttacked( keys )
	local ball = keys.caster
	local ability = keys.ability

	local offset = 100

	ball.initial = ball:GetAbsOrigin()
	local target = GetGroundPosition(ball:GetAbsOrigin() + Vector(0, -700, 0), ball) + Vector(0, 0, offset)

	if ball:GetTeamNumber() == 2 then
		target = GetGroundPosition(ball:GetAbsOrigin() + Vector(0, 700, 0), ball) + Vector(0, 0, offset)
	end

	Physics:Unit(ball)

	ball:SetPhysicsFriction (0.05,0.05)

	ball:SetBounceMultiplier(1.2)
	ball:SetNavCollisionType (PHYSICS_NAV_NOTHING)

	local direction = target - ball.initial
	direction = direction:Normalized()

	ball:AddPhysicsVelocity((direction * 1000) + Vector(0,0,1500))
	ball:SetPhysicsAcceleration(Vector(0,0,-1400))

	ball.collider = ball:AddColliderFromProfile("blocker")
  	ball.collider.radius = 128
  	-- collider.draw = {color = Vector(200,200,200), alpha = 5}

  	ball.collider.test = function(self, collider, collided)
    	return IsPhysicsUnit(collided) or (collided.IsRealHero and collided:IsRealHero()) or (collided.GetUnitName and collided:GetUnitName() == "npc_wagon")
  	end
  	ball.collider.postaction = function(self, collider, collided)
    	print("post: " .. collided:GetName() .. " -- " .. VectorDistance(collider:GetAbsOrigin(), collided:GetAbsOrigin()))
  	end

	StartSoundEvent("Hero_Tusk.Snowball.Loop", ball)

	if ball:GetTeamNumber() == 3 then
		ball:SetTeam(2)
	else
		ball:SetTeam(3)
	end

	local i = 0
	ball:OnPhysicsFrame(function(unit)
		local distance = (target - unit:GetAbsOrigin()):Length()
		i = i + 9
		ball:SetAngles(0, i, i)
		if ball:GetAbsOrigin().z <= target.z then
			ball:SetPhysicsAcceleration(Vector(0,0,0))
			ball:SetPhysicsVelocity(Vector(0,0,0))
			ball:OnPhysicsFrame(nil)
			StopSoundEvent("Hero_Tusk.Snowball.Loop", ball)
			EmitSoundOn("Hero_Tusk.Snowball.ProjectileHit", ball)

			ball:RemoveModifierByName("modifier_invulnerable")
			ball:RemoveModifierByName("modifier_snowball_onattacked")
		end
	end)
end

function OnSnowballDead( keys )
	local ball = keys.caster
	local ability = keys.ability

	ball:RemoveCollider()
	ball:StopPhysicsSimulation()

	Timers:CreateTimer(5 * 60, function (  )
		local ball = CreateUnitByName("npc_snowball", ball.initial, false, caster, caster, ball:GetTeamNumber())

		if ball:GetTeamNumber() == 3 then
			ball:SetTeam(2)
		else
			ball:SetTeam(3)
		end
	end)
end

function OnBucketSpawned( keys )
	local caster = keys.caster
	local ability = keys.ability

	local function CreateParticle(team)
		local rangeParticle = ParticleManager:CreateParticleForTeam("particles/bucket_range.vpcf", PATTACH_ABSORIGIN, caster, team)
		ParticleManager:SetParticleControlEnt(rangeParticle, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(rangeParticle, 3, Vector(ability:GetAbilitySpecial("radius"), 1, 1))
		ParticleManager:SetParticleControl(rangeParticle, 4, Vector(255, 255, 255))
		return rangeParticle
	end

	Timers:CreateTimer(5.0, function (  )
		caster.particles = {CreateParticle(2), CreateParticle(3)}
		caster.progress = 0
	end)
end

function OnBucketThink( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end

	if caster.particles then
		local radius = ability:GetAbilitySpecial("radius")

		local units = FindUnitsInRadius( caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false )
		local teams = {}
		for _,v in pairs(units) do
			teams[v:GetTeamNumber()] = true
		end
		if teams[2] and teams[3] then

		elseif teams[2] then
			local new_value = math.min(caster.progress + 0.2, 1.0)
			if caster.progress ~= new_value then
				caster.once = false
			end
			caster.progress = new_value
		elseif teams[3] then
			local new_value = math.max(caster.progress - 0.2, -1.0)
			if caster.progress ~= new_value then
				caster.once = false
			end
			caster.progress = new_value
		end

		local color = math.ceil(math.abs(caster.progress) * 255)
		local color_b = 255 - color

		if caster.progress >= 0 then
			ParticleManager:SetParticleControl(caster.particles[1], 4, Vector(color_b, 255, color_b))
			ParticleManager:SetParticleControl(caster.particles[2], 4, Vector(255, color_b, color_b))
		else
			ParticleManager:SetParticleControl(caster.particles[1], 4, Vector(255, color_b, color_b))
			ParticleManager:SetParticleControl(caster.particles[2], 4, Vector(color_b, 255, color_b))
		end

		if caster.progress == 1.0 then
			if not caster.once then
				EmitAnnouncerSoundForTeam("bucket.capture", 2)
				caster.once = true
				Notifications:TopToTeam(2, {text="You've captured the bucket!", duration=3, class="NotificationMessage"})
			end

			for i=0,4 do
				local pID = PlayerResource:GetNthPlayerIDOnTeam(2, i)
				local hero = GameMode.assignedPlayerHeroes[pID]

				if hero then
					PlayerResource:ModifyGold(pID, 3, true, 0)
					hero:AddExperience(3, 0, false, true)
				end
			end
			Railroad:GiveCandiesToTeam(2, ability:GetAbilitySpecial("candies"))
			PopupParticle(ability:GetAbilitySpecial("candies"), Vector(200,60,55), 1.0, caster, POPUP_SYMBOL_PRE_PLUS)
			PopupParticle(3, Vector(200,200,55), 1.0, caster, POPUP_SYMBOL_PRE_PLUS)
			PopupParticle(3, Vector(200,200,200), 1.0, caster, POPUP_SYMBOL_PRE_PLUS)
			AddFOWViewer(2, caster:GetAbsOrigin(), 400, 2.0, false)
			ParticleManager:CreateParticle("particles/bucket_impact.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			caster:SetTeam(2)
		elseif caster.progress == -1.0 then
			if not caster.once then
				EmitAnnouncerSoundForTeam("bucket.capture", 3)
				caster.once = true
				Notifications:TopToTeam(3, {text="You've captured the bucket!", duration=3, class="NotificationMessage"})
			end

			for i=0,4 do
				local pID = PlayerResource:GetNthPlayerIDOnTeam(3, i)
				local hero = GameMode.assignedPlayerHeroes[pID]

				if hero then
					PlayerResource:ModifyGold(pID, 3, true, 0)
					hero:AddExperience(3, 0, false, true)
				end
			end
			Railroad:GiveCandiesToTeam(3, ability:GetAbilitySpecial("candies"))
			PopupParticle(ability:GetAbilitySpecial("candies"), Vector(200,60,55), 1.0, caster, POPUP_SYMBOL_PRE_PLUS)
			PopupParticle(3, Vector(200,200,55), 1.0, caster, POPUP_SYMBOL_PRE_PLUS)
			PopupParticle(3, Vector(200,200,200), 1.0, caster, POPUP_SYMBOL_PRE_PLUS)
			AddFOWViewer(3, caster:GetAbsOrigin(), 400, 2.0, false)
			ParticleManager:CreateParticle("particles/bucket_impact.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			caster:SetTeam(3)
		end
	end
end

function EatEgg( keys )
	local caster = keys.caster
	local ability = keys.ability

	local kv = GameMode.EggsKVs[ability:GetName()]

	caster:AddNewModifier(caster, ability, "modifier_invulnerable", {})
	caster:AddNewModifier(caster, ability, "modifier_command_restricted", {})

	local particle = ParticleManager:CreateParticle("particles/units/unit_greevil/greevil_transformation.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	caster:EmitSound("Item.GreevilWhistle")

	Timers:CreateTimer(1.5, function (  )
		caster:RemoveModifierByName("modifier_invulnerable")
		caster:RemoveModifierByName("modifier_command_restricted")
		caster:AddNewModifier(caster, ability, "modifier_out_of_game", {})
		caster:AddNoDraw()

		local unit = CreateUnitByName(kv.Unit, caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		caster.greevil = unit
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

		unit:AddNewModifier(caster, ability, "modifier_universal_buff", {})

		local i = 1
		for i=1,6 do
			local ab = unit:AddAbility(kv.Abilities[tostring(i)])
			ab:SetLevel(CustomNetTables:GetTableValue("universal_buff", tostring(caster:GetPlayerOwnerID()))["ability"..tostring(i)])
			ab:SetHidden(false)
		end

		PlayerResource:NewSelection(caster:GetPlayerOwnerID(), unit:GetEntityIndex())
		caster:SetSelectionOverride(unit)

		unit:AddNewModifier(caster, ability, "modifier_kill", {duration = 90})
		Timers:CreateTimer(function()
			if IsValidEntity(unit) then
				if unit:GetHealth() <= 0 then
					-- StartAnimation(unit, {duration=1.5, activity=ACT_DOTA_DISABLED, rate=1.0, translate="level_1"})
					unit:StartGesture(ACT_DOTA_DISABLED)
					local particle = ParticleManager:CreateParticle("particles/units/unit_greevil/greevil_transformation.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)

					caster:EmitSound("Item.GreevilWhistle.Return")

					Timers:CreateTimer(1.5, function (  )
						PlayerResource:SetDefaultSelectionEntity(caster:GetPlayerOwnerID(), caster)
						caster:SetSelectionOverride(-1)
						caster:SetAbsOrigin(unit:GetAbsOrigin())
						caster:RemoveModifierByName("modifier_out_of_game")
						caster:RemoveNoDraw()

						unit:RemoveSelf()
						caster.greevil = nil
					end)
				else
					return 0.03
				end
			end
		end)
	end)
end

function SpawnDragons( keys )
	local caster = keys.caster
	local ability = keys.ability

	local pos1 = caster:GetAbsOrigin() + Vector(-256, 256, 0)
	local pos2 = caster:GetAbsOrigin() + Vector(-256, -256, 0)

	local fire = CreateUnitByName("npc_fire_dragon", pos1, true, nil, nil, caster:GetTeamNumber())
	fire:SetMaterialGroup("1")
	ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_ABSORIGIN_FOLLOW, fire)

	local toxic = CreateUnitByName("npc_toxic_dragon", pos2, true, nil, nil, caster:GetTeamNumber())
	ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", PATTACH_ABSORIGIN_FOLLOW, toxic)

	caster:EmitSound("Hero_DragonKnight.DragonTail.Cast.Kindred")

	Timers:CreateTimer(function (  )
		fire:MoveToTargetToAttack(Railroad.BOSS_DIRE)
		toxic:MoveToTargetToAttack(Railroad.BOSS_DIRE)
		return 1.0
	end)
end

function SpawnDragon( keys )
	local caster = keys.caster
	local ability = keys.ability

	local ice = CreateUnitByName("npc_ice_dragon", caster:GetAbsOrigin() + Vector(256, 0, 0), true, nil, nil, caster:GetTeamNumber())
	ice:SetMaterialGroup("2")

	ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf", PATTACH_ABSORIGIN_FOLLOW, ice)

	caster:EmitSound("Hero_DragonKnight.DragonTail.Cast.Kindred")

	Timers:CreateTimer(function (  )
		ice:MoveToTargetToAttack(Railroad.BOSS_RADIANT)
		return 1.0
	end)
end