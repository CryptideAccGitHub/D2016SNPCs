AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = "models/hunter/misc/sphere025x025.mdl"

ENT.Damage = math.random(5,8)
ENT.GravityEnabled = true

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
	--self:DrawShadow(false)
end

function ENT:CustomEffects()
	--ParticleEffectAttach("d_fireball_trail", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	util.SpriteTrail( self, 0, Color( 255, 0, 0 ), false, 15, 0, 0.1, 5, "trails/plasma" )
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

function ENT:DeathEffects(data)
self:StopParticles()
ParticleEffect("d_plasmexplo_01",data.HitPos +data.HitNormal,self:GetAngles())
self:EmitSound("doom2016/possessed_soldier/PLSDETH"..math.random(1,3)..".wav")
util.Decal("FadingScorch",data.HitPos +data.HitNormal, data.HitPos -data.HitNormal)
self:Remove()
end

function ENT:PhysicsCollide(data,phys)
	if self.IsDead == false then
		self.IsDead = true
		self:DeathEffects(data)
		for _,v in ipairs(ents.FindInSphere(self:GetPos(),30)) do
			if v:IsNPC() or v:IsPlayer() then
				if v:GetClass() != "npc_turret_floor" then
					if v.Faction == "FACTION_DOOM2016" then return end
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