if !CPTBase then print("INSTALL A CPTBASE, FAGGOT") return end
AddCSLuaFile('doom2016_autorun_base.lua')
AddCSLuaFile('doom2016_utilities.lua')
include('doom2016_utilities.lua')
CPTBase.RegisterMod("DOOM (2016) SNPCs Redux - Part 1","0.2")

D2016_BASEMOUNTED = true

DEMON_COUNT = 0
DEMON_MEDIUM_EXIST = false
DEMON_HEAVY_EXIST = false
BOSS_EXIST = false
PROCESSOR_EXIST = false

CreateConVar("d2016_gibfadingtime", "10", FCVAR_NONE)
CreateConVar("d2016_fastzombies", "0", FCVAR_NONE)
CreateConVar("d2016_bonelooking", "1", FCVAR_NONE)
CreateConVar("d2016_turnanimations", "1", FCVAR_NONE)


local Category = "DOOM (2016)"

CPTBase.AddParticleSystem("particles/d2016_vfx.pcf",{"d_monster_spawn_small_01","d_monster_spawn_medium_01"})
CPTBase.AddParticleSystem("particles/d2016_blood.pcf",{"d_bloodsplat","d_bloodtrail"})
	
CPTBase.AddNPC("Hellknight","npc_d2016_hellknight", Category); CPTBase.AddParticleSystem("particles/d2016_vfx.pcf",{"hellknight_wave_outfire"})
CPTBase.AddNPC("Lost Soul","npc_d2016_lostsoul", Category); CPTBase.AddParticleSystem("particles/d2016_vfx.pcf",{"lostsoul_fire","lostsoul_fireblu"})
CPTBase.AddNPC("Imp","npc_d2016_imp", Category); CPTBase.AddParticleSystem("particles/d2016_vfx.pcf",{"d_fireball_trail","d_explosion_01","d_bigfireball_charge"})
CPTBase.AddNPC("Possessed Scientist","npc_d2016_zombie_scientist", Category);
CPTBase.AddNPC("Possessed Worker","npc_d2016_zombie_worker", Category);
CPTBase.AddNPC("Unwilling","npc_d2016_zombie_hell", Category);

if D2016_PACK2MOUNTED then
--CPTBase.AddNPC("Hellrazer","obj_d2016_hellrazer_spawner", Category)
--CPTBase.AddNPC("Cyber-Mancubus","obj_d2016_cybermancubus_spawner", Category)
--CPTBase.AddNPC("Pinky","obj_d2016_pinky_spawner", Category)
--CPTBase.AddNPC("Cacodemon","obj_d2016_cacodemon_spawner", Category)
--CPTBase.AddNPC("Spectre","obj_d2016_spectre_spawner", Category)
--CPTBase.AddNPC("Summoner","obj_d2016_summoner_spawner", Category)
--CPTBase.AddNPC("Revenant","obj_d2016_revenant_spawner", Category)
--CPTBase.AddNPC("Baron of Hell","obj_d2016_baronofhell_spawner", Category)
end
if D2016_MPMOUNTED then
--CPTBase.AddNPC("Prowler","obj_d2016_prowler_spawner", Category)
--CPTBase.AddNPC("Harvester","obj_d2016_harvester_spawner", Category)
end
if D2016_BOSSMOUNTED then
--CPTBase.AddNPC("Cyberdemon","npc_d2016_cyberdemon", Category)
--CPTBase.AddNPC("Spider Mastermind","npc_d2016_mastermind", Category)
--CPTBase.AddNPC("Hell guard (Main)","npc_d2016_hellguard", Category)
--CPTBase.AddNPC("Hell guard (Staff)","npc_d2016_hellguard_s", Category)
--CPTBase.AddNPC("Hell guard (Hammer)","npc_d2016_hellguard_h", Category)

--CPTBase.AddNPC("Hell guards (BOSS)","obj_d2016_hellguard_fight", Category)
end

CPTBase.AddNPC("Gore Nest (Easy)","npc_d2016_gorenest_easy", "DOOM (2016) Gore Nests")
CPTBase.AddNPC("Gore Nest (Medium)","npc_d2016_gorenest_medium", "DOOM (2016) Gore Nests")

sound.Add(
{
name = "D2016.DemonScream",
channel = CHAN_STATIC,
volume = 1,
soundlevel = 0,
sound = {"demonic_scream_1.ogg","demonic_scream_2.ogg","demonic_scream_3.ogg"}
} )
