AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.MoveType = MOVETYPE_NONE
ENT.EntsToSpawn = {
{Name = "entity", AddPos = Vector(0,0,0), Timer = 1, Class = {"npc_d2016_imp"}}
}

function ENT:CustomEffects()
  ParticleEffect("monster_spawn_small",self:GetPos()+self:GetUp()*-35, self:GetAngles())
  sound.Play("monster_spawn"..math.random(1,2)..".ogg",self:GetPos())
end
