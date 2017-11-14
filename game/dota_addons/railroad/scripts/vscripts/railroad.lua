if Railroad == nil then
    _G.Railroad = class({})
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
	
	local units = DoToUnitsInRadius( caster, caster:GetAbsOrigin(), GetSpecial(ability, "radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, function ( v )
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
	end )

	if #units == 0 then
		ParticleManager:SetParticleControl(caster.area, 2, Vector(128,0,0))
	end
end