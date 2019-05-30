AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_DEBRIS
ENT.MoveCollide = 3
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.CanFade = true
ENT.Damage = 10
ENT.DamageType = DMG_SLASH
ENT.RemoveOnHitEntity = false

ENT.tbl_Sounds = {}

ENT.IdleSoundLevel = 75

function ENT:Initialize()
	self:SetMoveCollide(self.MoveCollide)
	self:SetCollisionGroup(self.CollisionGroup)
	self:SetModel("models/monsters/gibs/generic_gibs"..math.random(1,6)..".mdl")
	self:PhysicsInit(self.PhysicsType)
	self:SetMoveType(self.MoveType)
	self:SetSolid(self.SolidType)
	self:SetNoDraw(false)
	self:DrawShadow(true)
	self:Physics()
	ParticleEffectAttach("d_bloodtrail",PATTACH_ABSORIGIN_FOLLOW,self,0)
	if self.CanFade == true then
		self.RemoveTime = CurTime() + GetConVar("d2016_gibfadingtime"):GetInt()
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

function ENT:OnTouch(data,phys)
self:StopParticles()
if math.random(1,5) == 1 then
self:EmitSound("d4t/sfx_gore_small.ogg")
util.Decal("Blood",self:GetPos(),self:GetPos()+self:GetVelocity())
ParticleEffect("blood_impact_red_01",self:GetPos(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
end
--ParticleEffect("blood_impact_red_01",self:GetPos(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
--ParticleEffect("blood_impact_red_01",self:GetPos(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
end