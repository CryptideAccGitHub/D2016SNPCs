if !CPTBase then print("INSTALL A CPTBASE, FAGGOT") return end

AddCSLuaFile('doom2016_autorun_base.lua')
AddCSLuaFile('doom2016_utilities.lua')
include('doom2016_utilities.lua')

--[[
Hey there! Fuck you, if you want to steal my code! If not, then go the hell out of here! Its my autorun folder!

Although, you can use any resource files, if you`ll credit ID Software and Bethesda for creating and me(REXMaster)
for ripping and adapting them.
]]

CPTBase.RegisterMod("DOOM (2016) SNPCs Redux - Part 1","0.2")

D2016_BASEMOUNTED = true


DEMON_COUNT = 0
DEMON_MEDIUM_EXIST = false
DEMON_HEAVY_EXIST = false
BOSS_EXIST = false
PROCESSOR_EXIST = false

CreateConVar("d2016_deco", "0", FCVAR_NONE)
CreateConVar("d2016_models", "0", FCVAR_NONE)

local Category = "DOOM (2016)"

if D2016_BASEMOUNTED then
	CPTBase.AddParticleSystem("particles/d2016vfx.pcf",{"monster_spawn_small","blood_impact_red_big"})
--CPTBase.AddNPC("Possessed Scientist","npc_d2016_scientist", Category)
--CPTBase.AddNPC("Possessed Worker","npc_d2016_worker", Category)
CPTBase.AddNPC("Imp","obj_cspawner_d2016_imp", Category)
		CPTBase.AddParticleSystem("particles/d2016vfx.pcf",{"imp_fireball","imp_fireballexplosion","imp_bigball","imp_bigfireballexplode"})
--CPTBase.AddNPC("Unwilling","obj_d2016_unwilling_spawner", Category)
CPTBase.AddNPC("Possessed Soldier","obj_cspawner_d2016_soldier", Category)
	CPTBase.AddParticleSystem("particles/d2016vfx.pcf",{"soldier_plasmaball","doldier_plasmamuzzle"})
--CPTBase.AddNPC("Possessed Security","obj_d2016_security_spawner", Category)
--CPTBase.AddNPC("Possessed Welder","obj_d2016_welder", Category)
--CPTBase.AddNPC("Possessed Security","obj_d2016_security_spawner", Category)	
--CPTBase.AddNPC("Lost Soul","obj_d2016_lostsoul_spawner", Category)
--CPTBase.AddNPC("Hellknight","obj_d2016_hellknight_spawner", Category)
end
if D2016_PACK2MOUNTED then
--CPTBase.AddNPC("Mancubus","obj_d2016_mancubus_spawner", Category)
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
	
--CPTBase.AddNPC("Spider Mastermind (BOSS)","obj_d2016_mastermind_fight", Category)
--CPTBase.AddNPC("Cyberdemon (BOSS)","obj_d2016_cyberdemon_fight", Category)
--CPTBase.AddNPC("Hell guards (BOSS)","obj_d2016_hellguard_fight", Category)
end

hook.Add("PlayerInitialSpawn","d2016_SpawnProcessor",function(ply)
	if PROCESSOR_EXIST == false then
	local processor = ents.Create("obj_cdoom_npcprocessor")
	processor:SetPos(Vector(0,0,0))
	processor:Spawn()
	processor:Activate()
	PROCESSOR_EXIST = true
	end
end)

