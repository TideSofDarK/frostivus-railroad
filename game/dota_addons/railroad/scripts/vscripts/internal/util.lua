function GetSpecial( ability, name )
  return ability:GetLevelSpecialValueFor(name,ability:GetLevel()-1)
end

function GetRandomElement(list, checker, return_key)
  local new_table = {}

  for k,v in pairs(list) do
    if (checker and checker(v) == false) then

    else
      new_table[k] = v
    end
  end

  local count = GetTableLength(new_table)
  local seed = math.random(1, count)
  local i = 1
  
  for k,v in pairs(new_table) do
    if i == seed then
      if return_key then
        return k
      end
      return v
    end
    i = i + 1
  end
end

function GetPathLength( path )
  local length = 0
  for i=1,#path do
    if not path[i+1] then
      return length
    else
      length = length + (path[i] - path[i+1]):Length2D()
    end
  end
end

function UnitLookAtPoint( unit, point, only_z, ignore_z )
  local dir = (point - unit:GetAbsOrigin()):Normalized()
  if only_z then
    dir.x = unit:GetForwardVector().x
    dir.y = unit:GetForwardVector().y
  end
  if ignore_z then
    dir.z = 0
  end
  if dir == Vector(0,0,0) then return unit:GetForwardVector() end
  return dir
end

function DoToUnitsInRadius( caster, position, radius, target_team, target_type, target_flags, action )
  local units = FindUnitsInRadius(caster:GetTeamNumber(),position,nil,radius,target_team or DOTA_UNIT_TARGET_TEAM_ENEMY, target_type or DOTA_UNIT_TARGET_ALL, target_flags or DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

  for k,v in pairs(units) do
    action(v)
  end

  return units
end

function GetTableLength( t )
  if not t then return 0 end
  local length = 0

  for k,v in pairs(t) do
    if v then
      length = length + 1
    end
  end

  return length
end

function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end

POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8


function PopupParticle(number, color, duration, caster, preSymbol, postSymbol)
  if number < 1 then
    return false
  end
  local pfxPath = string.format("particles/msg_fx/msg_gold.vpcf", pfx)

  local pidx

  -- if caster:GetPlayerOwner() == nil then
  --   pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster)
  -- else
  --   pidx = ParticleManager:CreateParticleForPlayer(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetPlayerOwner())
  -- end
  pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, caster)

  local color = color
  local lifetime = duration
  local digits = #tostring(number) + 1

  local digits = 0
  if number ~= nil then
      digits = #tostring(number)
  end
  if preSymbol ~= nil then
      digits = digits + 1
  end
  if postSymbol ~= nil then
      digits = digits + 1
  end

  ParticleManager:SetParticleControl(pidx, 1, Vector( preSymbol, number, postSymbol ) )
  ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
  ParticleManager:SetParticleControl(pidx, 3, color)
end