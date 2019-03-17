AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.ISD2016SPAWNER = true
ENT.EntsToSpawn = {
{Name = "entity", AddPos = Vector(0,0,0), Timer = 1, Class = {"npc_d2016_soldier"}}
}

function ENT:CustomEffects()
self.StartLight1 = ents.Create("light_dynamic")
self.StartLight1:SetKeyValue("brightness", "3")
self.StartLight1:SetKeyValue("distance", "180")
self.StartLight1:Fire("Color", "255 5 0")
self.StartLight1:SetLocalPos(self:GetPos())
self.StartLight1:SetLocalAngles( self:GetAngles() )
self.StartLight1:SetParent(self)
self.StartLight1:Spawn()
self.StartLight1:Activate()
self.StartLight1:Fire("TurnOn", "", 0)
self:DeleteOnRemove(self.StartLight1)
timer.Simple(1.3,function()
if self:IsValid() then
self.SpawnedEnt = true
self.StartLight1:Fire("TurnOff", "", 0)
self.StartLight1:Remove()
end
end)
ParticleEffect("monster_spawn_small",self:GetPos()+self:GetUp()*-35, self:GetAngles())
sound.Play("sfx_spawn_0"..math.random(1,2)..".ogg",self:GetPos())
end