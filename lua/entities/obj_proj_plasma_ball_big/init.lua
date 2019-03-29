AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/hunter/misc/sphere075x075.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.Damage = math.random(30,50)
ENT.NextParticleT = 0
ENT.MassAmount = 1

--[[ENT.NextSound = CurTime()

sound.Add( {
	name = "imp_fireball_idle",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "imp/fireball.ogg"
} )]]

function ENT:GetMassAmount()
	return self.MassAmount
end

function ENT:SetMassAmount(mass)
	self.MassAmount = mass
end

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(self:GetMassAmount())
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
	end
	self:SetNoDraw(true)
	self:DrawShadow(false)
end

function ENT:CustomEffects()
	ParticleEffectAttach("soldier_bigplasmaball", PATTACH_ABSORIGIN_FOLLOW, self, 0)

    if GetConVar("d2016_deco"):GetInt() > 0 then
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "2")
	self.StartLight1:SetKeyValue("distance", "150")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 50 50")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(self.StartLight1)
	end
	
end

function ENT:DeathEffects()
self:StopParticles()
ParticleEffect("soldier_bigplasmaball_explosion",self:GetPos(),self:GetAngles())
sound.Play("possessed_soldier/red plasma explo "..math.random(1,5)..".ogg", self:GetPos(), 80, 80, 0.8) 
self:Remove()
end

function ENT:OnTouch(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		self:DeathEffects()
		for _,v in ipairs(ents.FindInSphere(self:GetPos(),100)) do
			if v:IsNPC() or v:IsPlayer() then
				if v:GetClass() != "npc_turret_floor" then
					local dmg = DamageInfo()
					if v:IsPlayer() then
					dmg:SetDamage(self.Damage)
					elseif v:IsNPC() then
					dmg:SetDamage(self.Damage*3)
					end
					dmg:SetAttacker(self:GetEntityOwner())
					dmg:SetInflictor(self)
					dmg:SetDamagePosition(data.HitPos)
					dmg:SetDamageType(self.DamageType)
					v:TakeDamageInfo(dmg)
				elseif !v.bSelfDestruct then
					v:GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormal() *100)
					v:Fire("selfdestruct","",0)
					v.bSelfDestruct = true
				end
			end
		end
		self:Remove()
	end
end