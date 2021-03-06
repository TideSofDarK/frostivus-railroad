-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

RegisterCustomAnimationScriptForModel("models/particle/snowball.vmdl", "animation/snowball.lua")
RegisterCustomAnimationScriptForModel("models/courier/greevil/greevil.vmdl", "animation/greevil.lua")

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)

  PrecacheResource("particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_blue.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_transform_green.vpcf", context)

  PrecacheResource("particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_base_attack.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_base_attack.vpcf", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  PrecacheModel("models/heroes/viper/viper.vmdl", context)
  --PrecacheModel("models/props_gameplay/treasure_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest001.vmdl", context)
  --PrecacheModel("models/props_debris/merchant_debris_chest002.vmdl", context)

  -- Sounds can precached here like anything else
  PrecacheResource("soundfile", "soundevents/custom_sound.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystal_maiden.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_doombringer.vsndevts", context)

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
  PrecacheUnitByNameSync("npc_dota_hero_winter_wyvern", context)
  PrecacheUnitByNameSync("npc_dota_hero_legion_commander", context)
  PrecacheUnitByNameSync("npc_dota_hero_abaddon", context)
  PrecacheUnitByNameSync("npc_dota_hero_tusk", context)
  PrecacheUnitByNameSync("npc_dota_hero_magnataur", context)
  PrecacheUnitByNameSync("npc_dota_hero_centaur", context)
  PrecacheUnitByNameSync("npc_dota_hero_wisp", context)
  PrecacheUnitByNameSync("npc_dota_hero_keeper_of_the_light", context)
  PrecacheUnitByNameSync("npc_dota_hero_treant", context)
  PrecacheUnitByNameSync("npc_dota_hero_invoker", context)
  PrecacheUnitByNameSync("npc_dota_hero_ursa", context)
PrecacheUnitByNameSync("npc_dota_hero_spectre", context)
PrecacheUnitByNameSync("npc_dota_hero_chen", context)
PrecacheUnitByNameSync("npc_dota_hero_omniknight", context) 
PrecacheUnitByNameSync("npc_dota_hero_dark_seer", context)
PrecacheUnitByNameSync("npc_dota_hero_dazzle", context) 
PrecacheUnitByNameSync("npc_dota_hero_dragon_knight", context)
PrecacheUnitByNameSync("npc_dota_hero_faceless_void", context)
PrecacheUnitByNameSync("npc_dota_hero_venomancer", context)
PrecacheUnitByNameSync("npc_dota_hero_beastmaster", context)
PrecacheUnitByNameSync("npc_dota_hero_lich", context) 
PrecacheUnitByNameSync("npc_dota_hero_bloodseeker", context)
PrecacheUnitByNameSync("npc_dota_hero_sand_king", context)  
PrecacheUnitByNameSync("npc_dota_hero_sven", context)
PrecacheUnitByNameSync("npc_dota_hero_crystal_maiden", context) 
PrecacheUnitByNameSync("npc_dota_hero_pudge", context)
PrecacheUnitByNameSync("npc_dota_hero_juggernaut", context)
PrecacheUnitByNameSync("npc_dota_hero_vengefulspirit", context)
PrecacheUnitByNameSync("npc_dota_hero_witch_doctor", context) 
PrecacheUnitByNameSync("npc_dota_hero_phantom_assassin", context)
PrecacheUnitByNameSync("npc_dota_hero_lion", context) 
PrecacheUnitByNameSync("npc_dota_hero_slardar", context)
PrecacheUnitByNameSync("npc_dota_hero_antimage", context)


  PrecacheUnitByNameSync("npc_black_greevil", context)
  PrecacheUnitByNameSync("npc_white_greevil", context)
  PrecacheUnitByNameSync("npc_orange_greevil", context)
  PrecacheUnitByNameSync("npc_yellow_greevil", context)
  PrecacheUnitByNameSync("npc_green_greevil", context)
  PrecacheUnitByNameSync("npc_purple_greevil", context)
  PrecacheUnitByNameSync("npc_fire_greevil", context)
  PrecacheUnitByNameSync("npc_ice_greevil", context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end