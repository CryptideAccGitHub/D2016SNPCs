AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/hunter/misc/sphere025x025.mdl"
ENT.PhysicsType = SOLID_VPHYSICS
ENT.SolidType = SOLID_CUSTOM
ENT.CollisionGroup = COLLISION_GROUP_PROJECTILE
ENT.MoveCollide = COLLISION_GROUP_PROJECTILE
ENT.MoveType = MOVETYPE_VPHYSICS
ENT.Damage = math.random(5,8)
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

ENT.tbl_SoundDeath = {"imp/imp_fireball_impact_01.ogg","imp/imp_fireball_impact_02.ogg","imp/imp_fireball_impact_03.ogg","imp/imp_fireball_impact_04.ogg"}

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
	ParticleEffectAttach("soldier_plasmaball", PATTACH_ABSORIGIN_FOLLOW, self, 0)
    if GetConVar("d2016_deco"):GetInt() == 2 then
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "2")
	self.StartLight1:SetKeyValue("distance", "50")
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
--ParticleEffect("imp_fireballexplosion",self:GetPos(),self:GetAngles())
--sound.Play(self:SelectFromTable(self.tbl_SoundDeath), self:GetPos(), 80, 80, 0.8) 
self:Remove()
end

function ENT:OnTouch(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		self:SetHitEntity(data.HitEntity)
		self:DeathEffects()
		if self:GetHitEntity():IsPlayer() or self:GetHitEntity():IsNPC() and not self:GetHitEntity().Faction == "FACTION_DOOM2016" then
			if self:GetHitEntity():GetClass() != "npc_turret_floor" then
				local dmg = DamageInfo()
				if self:GetHitEntity():IsPlayer() then
				dmg:SetDamage(self.Damage)
				elseif self:GetHitEntity():IsNPC() then
				dmg:SetDamage(self.Damage*3)
				end
				dmg:SetAttacker(self:GetEntityOwner())
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(data.HitPos)
				dmg:SetDamageType(self.DamageType)
				self:GetHitEntity():TakeDamageInfo(dmg)
			elseif !self:GetHitEntity().bSelfDestruct then
				self:GetHitEntity():GetPhysicsObject():ApplyForceCenter(self:GetVelocity():GetNormal() *100)
				self:GetHitEntity():Fire("selfdestruct","",0)
				self:GetHitEntity().bSelfDestruct = true
			end
		end
		self:Remove()
	end
end