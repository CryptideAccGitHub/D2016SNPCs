AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.ModelTable = {"models/monsters/possessed/zombie.mdl"}
ENT.StartHealth = 100

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self:SetIdleAnimation("idle")
	self:SetBodygroup(0,1)
	self.CanWander = false
	DEMON_COUNT = DEMON_COUNT+1
	
	self.GibDamage = 100
	self.GoreChance = 2
	self.GibScale = 1
	
	self:SetNoDraw(true)
	self.IsEssential = true
	self:SetModelScale(math.random(95,105)*0.01)
	
	ParticleEffect("d_monster_spawn_small_01",self:GetPos()+self:GetUp()*-35, self:GetAngles())
	sound.Play("doom2016/sfx_spawn_0"..math.random(1,2)..".ogg",self:GetPos())
	timer.Simple(1, function() if self:IsValid(self) then self:PlayActivity("spawn_teleport") self.IsEssential = false self:SetNoDraw(false) end end)
end
