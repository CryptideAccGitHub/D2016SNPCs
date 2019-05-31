AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.ModelTable = {"models/monsters/lostsoul/lostsoul.mdl"}
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 50
ENT.ViewAngle = 180
ENT.Faction = "FACTION_DOOM2016"
ENT.AllowPropDamage = true
ENT.HasDeathRagdoll = false

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.Possessor_CanBePossessed = true

ENT.tbl_Animations = {
["Run"] = {"idle_open"},
["Walk"] = {"idle"}
}
ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

--Custom set-up
ENT.ISD2016NPC = true
ENT.NextIdleSound = CurTime()+1
ENT.s_CState = "idle"

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetFlySpeed(100)
	self:SetMovementType(MOVETYPE_FLY,true)
	self:SetIdleAnimation("idle")
	self:SetCollisionBounds(Vector(25,25,25),Vector(-25,-25,-30))
	DEMON_COUNT = DEMON_COUNT+1
	
	self:SetNoDraw(true)
	self.IsEssential = true
	self:SetModelScale(math.random(95,105)*0.01)
	
	ParticleEffect("d_monster_spawn_small_01",self:GetPos()+self:GetUp()*-35, self:GetAngles())
	sound.Play("doom2016/sfx_spawn_0"..math.random(1,2)..".ogg",self:GetPos())
	timer.Simple(1, function() if self:IsValid(self) then self:EmitSound("doom2016/lostsoul/soul_sight.ogg") self:PlayActivity("spawn_teleport"..math.random(1,4)) self.IsEssential = false self:SetNoDraw(false) ParticleEffectAttach("lostsoul_fireblu",PATTACH_ABSORIGIN_FOLLOW,self,self:LookupAttachment("origin")) end end)
	
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "3")
	self.StartLight1:SetKeyValue("distance", "220")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 100 0")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("SetParentAttachment","origin")
	self.StartLight1:Fire("TurnOff", "", 0)
	self:DeleteOnRemove(self.StartLight1)
	
end

--Schedule processing--------------------------------------------------------------------------------------------
function ENT:HandleSchedules_Fly(enemy,dist,nearest,disp)
	if self.IsPossessed == true or not self:CanPerformProcess() or self:GetNoDraw() == true then return end
		
		if self.s_CState == "idle" then
			--Alert code
			if self:GetEnemy() ~= nil then
				self.s_CState = "infight"
				self:EmitSound("doom2016/lostsoul/soul_sight.ogg")
				self.StartLight1:Fire("TurnOn", "", 0)
				self:StopParticles()
				ParticleEffectAttach("lostsoul_fire",PATTACH_ABSORIGIN_FOLLOW,self,self:LookupAttachment("origin"))
				timer.Simple(math.Rand(0,5),function() if self:IsValid() and IsValid(enemy) and not self.IsPossessed then
					self:PlayActivity("charge_into")
					self:EmitSound("doom2016/lostsoul/soul_att.ogg")
					self:SetIdleAnimation("idle_open")
					self.s_CState = "attack"
					self:SetFlySpeed(300)
					return
					end
				end)
			end
			
			self:HandleFlying(enemy,dist,nearest)
		elseif self.s_CState == "infight" then
			self:HandleFlying(enemy,dist,nearest)
		elseif self.s_CState == "attack" then
			self:HandleFlying(enemy,dist,nearest)
			if self:Visible(self:GetEnemy()) then
				local target
				if target == nil then target = ((self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()) -self:GetPos() + self:GetEnemy():GetVelocity() *0.35):GetNormal() *250 end
				self:SetVelocity(target)
			end
			if nearest < 50 then self:dCDamage((self:GetAttachment(self:LookupAttachment("origin"))).Pos, 20 , 80, 180, DMG_BLAST) self:OnDeath(nil) end
		end
	
		self:HandleFlying(enemy,dist,nearest)
	if self.IsStartingUp == true then
		self.IsStartingUp = false
		self:SetLocalVelocity(Vector(0,0,0))
	end
end
	
function ENT:OnThink()
	if self.IsPossessed then
		if self.s_CState == "attack" then
			target = (self:Possess_AimTarget() - self:GetPos()):GetNormal() * 350
			self:SetVelocity(target)
		end
		self:dCLook("origin", self:Possess_AimTarget(),90,90,18,1)
	else
		if self:GetEnemy() == nil and self:GetNoDraw() == false and self.s_CState == "attack" then
			self.s_CState = "idle"
			self:StopParticles()
			ParticleEffectAttach("lostsoul_fireblu",PATTACH_ABSORIGIN_FOLLOW,self,self:LookupAttachment("origin"))
			self:SetFlySpeed(100)
			self.StartLight1:Fire("TurnOff", "", 0)
		end
	end
end

function ENT:Possess_OnPossessed(possessor)
	possessor:ChatPrint(
[[
Lost soul controls:
 - LMB - charge attack
]]
	)
end

function ENT:Possess_Primary()
	self:PlayActivity("charge_into")
	self:StopParticles()
	ParticleEffectAttach("lostsoul_fire",PATTACH_ABSORIGIN_FOLLOW,self,self:LookupAttachment("origin"))
	self:EmitSound("doom2016/lostsoul/soul_att.ogg")
	self:SetIdleAnimation("idle_open")
	self.s_CState = "attack"
	self:SetFlySpeed(300)
	return
end

function ENT:Touch()
	if self.s_CState == "attack" then
		self:OnDeath()
	end
end

function ENT:OnRemove()
DEMON_COUNT = DEMON_COUNT-1
end

function ENT:OnDeath(dmg,dmginfo,hitbox)
	if dmg == nil then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		util.Effect( "Explosion",	effectdata )
		if self.IsPossessed then
			util.BlastDamage(self, self.Possessor, self:GetPos(), 100, 100)
		end
		self:Remove()
	else
		self:dSpawnLostSoulGib(dmg)
	end
end
