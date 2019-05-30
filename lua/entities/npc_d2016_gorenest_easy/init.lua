AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.EntsToSpawnAtSpawn = {
{Name = "entity1", AddPos = Vector(-100,0,0), Timer = 0, Class = {"npc_d2016_zombie_scientist"}, Parameters = {}},
{Name = "entity2", AddPos = Vector(100,0,0), Timer = 0, Class = {"npc_d2016_zombie_scientist"}, Parameters = {}},
{Name = "entity3", AddPos = Vector(0,100,0), Timer = 0, Class = {"npc_d2016_zombie_worker"}, Parameters = {}},
{Name = "entity4", AddPos = Vector(-100,100,0), Timer = 0, Class = {"npc_d2016_zombie_scientist"}, Parameters = {}},
{Name = "entity5", AddPos = Vector(-100,-100,0), Timer = 0, Class = {"npc_d2016_zombie_worker"}, Parameters = {}}
}
ENT.EntsToSpawn = {
{Name = "entity6", AddPos = Vector(-100,0,0), Timer = 3, Class = {"obj_cspawner_d2016_imp"}, Parameters = {}},
{Name = "entity7", AddPos = Vector(100,0,0), Timer = 3, Class = {"obj_cspawner_d2016_imp"}, Parameters = {}},
{Name = "entity8", AddPos = Vector(0,100,0), Timer = 3, Class = {"obj_cspawner_d2016_imp"}, Parameters = {}},
{Name = "entity9", AddPos = Vector(-100,100,0), Timer = 3, Class = {"obj_cspawner_d2016_imp"}, Parameters = {}},
{Name = "entity10", AddPos = Vector(-100,-100,0), Timer = 3, Class = {"obj_cspawner_d2016_imp"}, Parameters = {}}
}

ENT.StartHealth = 250