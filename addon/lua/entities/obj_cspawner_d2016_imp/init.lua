AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.MoveType = MOVETYPE_NONE
ENT.EntsToSpawn = {
--{Name = "entity1", AddPos = Vector(0,0,0), Timer = 1, Class = {"npc_zombie"}, Parameters = {StartHealth = 100}}
}
ENT.SpawnedEnts = {}

function ENT:CustomEffects() end
