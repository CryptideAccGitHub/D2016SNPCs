AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_DEBRIS
ENT.MoveCollide = 3
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.CanFade = true
ENT.FadeTime = 4
ENT.Damage = 10
ENT.DamageType = DMG_SLASH
ENT.RemoveOnHitEntity = false

ENT.tbl_Sounds = {}

ENT.IdleSoundLevel = 75

function ENT:Initialize()
	self:SetMoveCollide(self.MoveCollide)
	self:SetCollisionGroup(self.CollisionGroup)
	self:SetMaterial("models/flesh")
	self:SetModel("models/gibs/strider_gib4.mdl")
	self:PhysicsInit(self.PhysicsType)
	self:SetMoveType(self.MoveType)
	self:SetSolid(self.SolidType)
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:SetModelScale(math.random(75,125)*0.01)
	self:Physics()
	ParticleEffect("blood_impact_red_01",self:GetPos(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
	if self.CanFade == true then
		self.RemoveTime = CurTime() +self.FadeTime
	end
	self.IsDead = false
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

function ENT:OnTouch(data,phys) ParticleEffect("blood_impact_red_01",self:GetPos(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)  end