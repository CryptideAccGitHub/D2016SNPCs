AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/hunter/misc/sphere075x075.mdl"

ENT.Damage = math.random(45,65)
ENT.GravityEnabled = false

--[[ENT.NextSound = CurTime()

sound.Add( {
	name = "imp_fireball_idle",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "imp/fireball.ogg"
} )]]

function ENT:Physics()
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(self.GravityEnabled)
		phys:EnableDrag(false)
	end
	--self:SetNoDraw(false)
	self:DrawShadow(false)
end

function ENT:CustomEffects()
	ParticleEffectAttach("d_fireball_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "2")
	self.StartLight1:SetKeyValue("distance", "150")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 100 50")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(self.StartLight1)
	
	self.glow = ents.Create("env_sprite")
	self.glow:SetKeyValue("model","cptbase/sprites/glow01.spr")
	self.glow:SetKeyValue("rendermode","5")
	self.glow:SetKeyValue("rendercolor","255 80 0")
	self.glow:SetKeyValue("scale","500")
	self.glow:SetKeyValue("spawnflags","1")
	self.glow:SetParent(self)
	self.glow:Spawn()
	self.glow:Activate()
	self:DeleteOnRemove(self.glow)
end

function ENT:DeathEffects(data)
self:StopParticles()
ParticleEffect("d_explosion_01",data.HitPos +data.HitNormal,self:GetAngles())
self:EmitSound("doom2016/imp/imp_fireball_impact_0"..math.random(1,4)..".ogg")
util.Decal("Scorch",data.HitPos +data.HitNormal, data.HitPos -data.HitNormal)
self:Remove()
end

function ENT:PhysicsCollide(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		self:DeathEffects(data)
		for _,v in ipairs(ents.FindInSphere(self:GetPos(),50)) do
			if v:IsNPC() or v:IsPlayer() then
				if v:GetClass() != "npc_turret_floor" then
					if self:GetHitEntity().Faction == "FACTION_DOOM2016" then return end
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