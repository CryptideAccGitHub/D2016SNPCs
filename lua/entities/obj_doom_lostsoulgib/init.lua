AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_DEBRIS
ENT.MoveCollide = 3
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.RemoveOnHitEntity = false

function ENT:Initialize()
	self:SetMoveCollide(self.MoveCollide)
	self:SetCollisionGroup(self.CollisionGroup)
	self:SetModel("models/monsters/lostsoul/lostsoul.mdl")
	self:PhysicsInit(self.PhysicsType)
	self:SetMoveType(self.MoveType)
	self:SetSolid(self.SolidType)
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:Physics()
	ParticleEffectAttach("lostsoul_fire",PATTACH_ABSORIGIN_FOLLOW,self,self:LookupAttachment("origin"))
	self.IsDead = false
	self.HasDeathRagdoll = false
	timer.Simple(0.8, function() if self:IsValid() then self:OnTouch() end end)
end

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(10)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(true)
		phys:EnableDrag(false)
	end
end

function ENT:OnTouch(data,phys)
	self:StopParticles()
	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	util.Effect( "Explosion",	effectdata )
	self:Remove()
end