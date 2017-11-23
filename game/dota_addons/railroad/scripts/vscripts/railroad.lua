if Railroad == nil then
    _G.Railroad = class({})

    CustomGameEventManager:RegisterListener( "frostivus_upgrade", Dynamic_Wrap(Railroad, 'OnUpgrade'))
end

function Railroad:OnUpgrade(keys)
	local pid = keys.PlayerID
	local ability_id = keys.id

	local hero = PlayerResource:GetPlayer(pid):GetAssignedHero()

	local old_data = CustomNetTables:GetTableValue("players", tostring(hero:GetPlayerOwnerID()))

	local candies = old_data.candies

	local ab = hero.buff_dummy:FindAbilityByName(tostring(string.gsub(ability_id, "Cell", "buff_")))
	if ab then
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

WAGON_SPEED = 14

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
		teams[v:GetTeam()] = true
		if v:GetUnitName() == "npc_snowball" or teams[2] and teams[3] then
			units = {}
			break
		end
	end
	for k,v in pairs(units) do
		if v:IsRealHero() then
			ParticleManager:SetParticleControl(caster.area, 2, Vector(0,128,0))

			-- CustomNetTables:SetTableValue( "scenario", "wagon", {percentage = percentage} )
			local team = v:GetTeamNumber()
			local team_modifier = 1
			if team == 3 then team_modifier = -1 end

			local movement = Timers:CreateTimer(0.0, function ()
				local position = caster:GetAbsOrigin()
				 
				local distance_traveled = 0
				local distance_to_travel = WAGON_SPEED
				 
				local new_position = position
				 
				while distance_traveled < distance_to_travel do
				    if #caster.path < caster.path_point + team_modifier then
				        break
				    end
					
				    local next_point

				    if team == 3 then
				    	next_point = GetGroundPosition(caster.path[caster.path_point],caster)	
				    else
				    	next_point = GetGroundPosition(caster.path[caster.path_point + team_modifier],caster)	
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

	Physics:Unit(ball)

	ball:SetPhysicsFriction (0.05,0.05)

	ball:SetBounceMultiplier(1.2)
	ball:SetNavCollisionType (PHYSICS_NAV_NOTHING)

	local direction = target - ball.initial
	direction = direction:Normalized()

	ball:AddPhysicsVelocity((direction * 750) + Vector(0,0,1500))
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

			if ball:GetTeamNumber() == 3 then
				ball:SetTeam(2)
			else
				ball:SetTeam(3)
			end

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

	if caster.particles then

		local radius = ability:GetAbilitySpecial("radius")

		local units = FindUnitsInRadius( caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
		local teams = {}
		for _,v in pairs(units) do
			teams[v:GetTeamNumber()] = true
		end
		if teams[2] and teams[3] then

		elseif teams[2] then
			caster.progress = math.min(caster.progress + 0.2, 1.0)
		elseif teams[3] then
			caster.progress = math.max(caster.progress - 0.2, -1.0)
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

		local unit = CreateUnitByName(kv.Unit, caster:GetAbsOrigin(), false, nil, caster, caster:GetTeamNumber())
		caster.greevil = unit
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)

		unit:AddNewModifier(caster, ability, "modifier_universal_buff", {})

		local i = 1
		for k,v in pairs(kv.Abilities) do
			local ab = unit:AddAbility(v)
			ab:SetLevel(CustomNetTables:GetTableValue("universal_buff", tostring(caster:GetPlayerOwnerID()))["ability"..tostring(i)])
			ab:SetHidden(false)
			i = i + 1
		end

		PlayerResource:NewSelection(caster:GetPlayerOwnerID(), unit:GetEntityIndex())
		caster:SetSelectionOverride(unit)

		unit:AddNewModifier(caster, ability, "modifier_kill", {duration = 20})
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