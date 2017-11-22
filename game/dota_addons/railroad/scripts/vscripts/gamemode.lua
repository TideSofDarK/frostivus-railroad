-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')
-- This library allow for easily accessing KV files
require('libraries/keyvalues')

require('libraries/wearables')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')


-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "playground" then
  require("examples/playground")
end

LinkLuaModifier( "modifier_out_of_game", "libraries/modifiers/modifier_out_of_game.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_universal_buff", "libraries/modifiers/modifier_universal_buff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_command_restricted", "libraries/modifiers/modifier_command_restricted.lua", LUA_MODIFIER_MOTION_NONE )


--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  --hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_example_item", hero, hero)
  hero:AddItem(item)

  hero.buff_dummy = CreateUnitByName("npc_dummy_unit", Vector(25000, 25000, 25000), true, nil, hero, hero:GetTeam())

  for k,v in pairs(GameMode.BuffsKVs) do
   hero.buff_dummy:AddAbility(k)
   print(k)
  end

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds 
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  GameMode.EggsKVs = LoadKeyValues("scripts/kv/greevils.kv")
  GameMode.BuffsKVs = LoadKeyValues("scripts/npc/railroad/abilities/buffs.txt")

  for i=0,9 do
    local buff_array = {}
    buff_array.ability1 = 0
    buff_array.ability2 = 0
    buff_array.ability3 = 0
    buff_array.ability4 = 0
    buff_array.ability5 = 0
    buff_array.ability6 = 0

    buff_array.lifesteal = 0
    buff_array.spell_lifesteal = 0
    buff_array.hp_regen = 0
    buff_array.hp = 0
    buff_array.mp_regen = 0
    buff_array.manacost = 0
    buff_array.damage = 0
    buff_array.spell_amplify = 0
    buff_array.armour = 0
    buff_array.magic_res = 0
    buff_array.cdr = 0
    buff_array.as = 0
    CustomNetTables:SetTableValue("universal_buff", tostring(i), buff_array)
  end
  
  GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( GameMode, "DamageFilter" ), self )
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      local hero = cmdPlayer:GetAssignedHero()
      
      for i=0,hero:GetModifierCount() do
        print(hero:GetModifierNameByIndex(i), hero:GetModifierStackCount(hero:GetModifierNameByIndex(i), hero))
      end
    end
  end

  print( '*********************************************' )
end

function GameMode:DamageFilter( filter_table )
    local victim = EntIndexToHScript(filter_table["entindex_victim_const"])

    local attacker = filter_table["entindex_attacker_const"]
    if attacker then
      attacker = EntIndexToHScript(attacker)
    end
    
    local damage = filter_table["damage"]
    local damage_type = filter_table["damagetype_const"]

    if not attacker:IsRealHero() and string.match(attacker:GetUnitName(), "greevil_hero") then
      local spell_lifesteal = CustomNetTables:GetTableValue("universal_buff", tostring(attacker:GetPlayerOwnerID())).spell_lifesteal
      local lifesteal = CustomNetTables:GetTableValue("universal_buff", tostring(attacker:GetPlayerOwnerID())).lifesteal
      if damage_type == DAMAGE_TYPE_MAGICAL and spell_lifesteal > 0 then
        local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
        attacker:Heal((spell_lifesteal / 100) * damage, nil)
      elseif damage_type == DAMAGE_TYPE_PHYSICAL and lifesteal > 0 then
        local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
        attacker:Heal((lifesteal / 100) * damage, nil)
      end
    end

    return true
end