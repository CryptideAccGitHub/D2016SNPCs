AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.ModelTable = {"models/monsters/possessed/possessed_soldier.mdl"} -- Model
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 250
ENT.ViewAngle = 180 -- You can`t sneak past them
ENT.Faction = "FACTION_DOOM2016"
ENT.AllowPropDamage = false

ENT.HasDeathRagdoll = true

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.Possessor_CanBePossessed = true

ENT.OverrideRunAnim = false

ENT.tbl_Animations = {
["Idle"] = {"idle"},
["Run"] = {"run_forward"},
["Walk"] = {"strafewalk_forward"}
}

ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

--Custom set-upw
ENT.ISD2016NPC = true
ENT.NEXTHEAVYATTACK = CurTime()+math.Rand(3,5)
ENT.CSTATE = "Idle_NoEnemy"
ENT.CTARGET = Vector(-200,0,0)

ENT.t_NextTarget = CurTime()
ENT.t_NextShot = CurTime()
ENT.t_NextAttack = CurTime() + math.Rand(3,8)
ENT.t_NextHeavyAttack = CurTime() + math.Rand(3,8)
ENT.t_NextIdleSound = CurTime()+1
ENT.t_NextState = CurTime() + math.Rand(5,8)
ENT.b_IsShooting = false
ENT.i_ShootNumber = 0

function ENT:SetInit()
	self:SetHullType(HULL_HUMAN)
	self:SetMovementType(MOVETYPE_STEP)
	self:SetIdleAnimation("idle")
	self.CanWander = false
	DEMON_COUNT = DEMON_COUNT+1
	
	timer.Simple(0.05,function()
	sound.Play("possessed_soldier/PossessedSight"..math.random(1,4)..".ogg",self:GetPos())
	self:PlayActivity("hellspawn_v"..math.random(1,5))
	end)
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	if self.t_NextShot < CurTime() and self:FindInCone(enemy,70) then
		if (self.i_ShootNumber > 0 and (self:GetCurrentAnimation() == "idle" or self:GetCurrentAnimation() == "walkforward")) or self.b_IsShooting == true then
			self:RangeAttack_Normal()
		end
	else
		self.i_ShootNumber = 0
	end
	
	self:SetIdleAnimation("idle")

	if self:CanPerformProcess() then
			-- Turning code
			if self:CheckAngleTo(enemy:GetPos()).y > 50 and self:GetCurrentAnimation() == "idle" then
				self:PlayActivity("turn_90_left")
				return
			elseif self:CheckAngleTo(enemy:GetPos()).y < -50 and self:GetCurrentAnimation() == "idle" then
				self:PlayActivity("turn_90_right")
				return
			elseif self:CheckAngleTo(enemy:GetPos()).y < -90 and self:GetCurrentAnimation() == "idle" then
				self:PlayActivity("turn_157_right")
				return
			elseif self:CheckAngleTo(enemy:GetPos()).y > 90 and self:GetCurrentAnimation() == "idle" then
				self:PlayActivity("turn_157_left")
				return
			elseif math.random(1,80) == 1 and self:FindInCone(enemy,70) and self.i_ShootNumber < 1 and self:GetCurrentAnimation() == "idle" then
				-- It just does a taunt
				self:PlayActivity("glance_front_v"..math.random(1,3))
				sound.Play("possessed_soldier/PossessedSight"..math.random(1,4)..".ogg",self:GetPos())
			end
	
		if dist < 120 and self:FindInCone(enemy,70) then
			sound.Play("possessed_soldier/PossessedAttackYell"..math.random(1,5)..".ogg",self:GetPos())
			self:PlayActivity("melee_forward_v"..math.random(1,2))
			return
		elseif dist < 180 and self:FindInCone(enemy,50) and math.random(1,2) == 1 then
			sound.Play("possessed_soldier/PossessedAttackYell"..math.random(1,5)..".ogg",self:GetPos())
			self:PlayActivity("melee_from_run")
			return
		elseif (dist > 300 and dist < 800) and self:FindInCone(enemy,70) and self.t_NextAttack < CurTime() then

			if self:GetCurrentAnimation() == "run_forward" and self:Visible(self:GetEnemy()) then
				if math.random(1,3) == 3 then
					self.t_NextAttack = CurTime() + math.Rand(6,9)
					self:PlayActivity("shoot_from_run"..math.random(1,5))
					return
				end
			elseif (self:GetCurrentAnimation() == "strafewalk_forward" or self:GetCurrentAnimation() == "idle") and self:Visible(self:GetEnemy()) then
				if math.random(1,3) == 3 then
					self.t_NextAttack = CurTime() + math.Rand(6,9)
					self:PlayActivity("plasma_charge_attack_v"..math.random(1,3))
					return
				end
		end

		end
		
		if ((self:GetCurrentAnimation() == "idle" or self:GetCurrentAnimation() == "strafewalk_forward")) and self:FindInCone(enemy,70) and dist > 200 and dist < 800 and self.t_NextAttack < CurTime() then
			self.i_ShootNumber = math.random(3,9)
			self.t_NextAttack = CurTime() + math.Rand(6,9)
			return
		end
		
		if self.CSTATE ~= "Idle_NoEnemy" and self.EnemyMemoryCount < 1 then
			self.CSTATE = "Idle_NoEnemy"
		end
		
		if self.CSTATE == "Idle_NoEnemy" then
			if self:GetEnemy() != nil then
				self.CanWander = true
				self:PlayActivity("combat_taunt_"..math.random(1,6))
				sound.Play("possessed_soldier/PossessedSight"..math.random(1,4)..".ogg",self:GetPos())
				self.CSTATE = self:SelectFromTable({"InFight_Rush","InFight"})
				return
			end
		
		elseif self.CSTATE == "InFight_Rush" then
			self.tbl_Animations["Run"] = {"run_forward"}
			self:ChaseEnemy()
			if (self.t_NextState < CurTime() and dist < 500) or (dist < 200 and math.random(1,2)==1) then
				self.t_NextState = CurTime() + math.Rand(5,8)
				self.CSTATE = "InFight"
			end
		
		elseif self.CSTATE == "InFight_Chase" then
			self.tbl_Animations["Run"] = {"strafejog_forward"}
			self:ChaseEnemy(true)
			if (self.t_NextState < CurTime() and dist > 500) or (dist > 700 and math.random(1,2)==1) then
				self.t_NextState = CurTime() + math.Rand(5,8)
				self.CSTATE = "InFight_Rush"
			elseif ((self.t_NextState < CurTime() and dist < 400) or (dist < 400 and math.random(1,2)==1)) and self:Visible(self:GetEnemy()) then
				self.t_NextState = CurTime() + math.Rand(5,8)
				self.CSTATE = "InFight"
			end
			
		elseif self.CSTATE == "InFight" then
			self.tbl_Animations["Run"] = {"strafewalk_forward"}
			if dist > 500 and math.random(1,10) == 1 then 
				self:ChaseEnemy(true)
			else
				if self.t_NextTarget < CurTime() then
					self.CTARGET = self:GetPos()+self:GetForward()*math.random(50,60) + self:GetRight()*math.random(-1,1)*math.random(50,80)
					self.t_NextTarget = CurTime()+math.Rand(4,7)
					self:ChaseEnemy(true, self.CTARGET)
					return
				end
			end
			
			if (self.t_NextState < CurTime() and dist > 500) or (dist > 700 and math.random(1,3)==1) then
				self.t_NextState = CurTime() + math.Rand(5,8)
				self.CSTATE = "InFight_Rush"
			elseif ((self.t_NextState < CurTime() and dist > 400) or (dist > 400 and math.random(1,3)==1)) or not self:Visible(self:GetEnemy()) then
				self.t_NextState = CurTime() + math.Rand(5,8)
				self.CSTATE = "InFight_Chase"
			end
		end
		
	end
end
	
function ENT:OnThink()
if self.IsPossessed then
	if  self.t_NextShot < CurTime() and self.i_ShootNumber > 0 or self.b_IsShooting == true then
		self:RangeAttack_Normal()
	end
	if self:GetCurrentAnimation() == "idle" then
		self.b_IsShooting = false
	end
self:LookAtPosUseBone("spine3",self:Possess_AimTarget(),90,60,18,0.5)
self:LookAtPosUseBone("head",self:Possess_AimTarget(),90,70,18,0.5)
else
if self:GetEnemy() ~= nil then
self:LookAtPosUseBone("spine3",self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter(),70,60,18,0.5)
self:LookAtPosUseBone("head",self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter(),80,90,18,0.5)
end
end

if CurTime() > self.t_NextIdleSound then
if math.random(1,5) == 1 then 
sound.Play("possessed_soldier/PossessedIdle"..math.random(1,2)..".ogg",self:GetPos()) 
self.t_NextIdleSound = CurTime() + math.Rand(3,8)
end
end

end

--Utility code--------------------------------------------------------------------------------------------

function ENT:Possess_OnPossessed(possessor)
possessor:ChatPrint(
[[
Possessed soldier controls:
LMB - melee attack.
RMB - ranged attack.
Reload - special attack.
]]
)
end

function ENT:Possess_Primary()
	self:TASKFUNC_FACEPOSITION(self:Possess_AimTarget())
	if self:CanPerformProcess() then
		sound.Play("possessed_soldier/PossessedAttackYell"..math.random(1,5)..".ogg",self:GetPos())
		self:PlayActivity("melee_forward_v"..math.random(1,2))
	end
end


function ENT:Possess_Secondary()
	if self:CanPerformProcess() then
		if self:GetCurrentAnimation() == "run_forward" then
			self:PlayActivity("shoot_from_run"..math.random(1,3))
		else
			self.i_ShootNumber = math.random(1,2)
		end
	end	
end

function ENT:Possess_Reload()
	self:TASKFUNC_FACEPOSITION(self:Possess_AimTarget())
	if self.t_NextHeavyAttack < CurTime() then
			self.t_NextHeavyAttack = CurTime() + math.Rand(6,9)
			self:PlayActivity("plasma_charge_attack_v"..math.random(1,3))
			return
	end
end

function ENT:RangeAttack_Normal()
	self:StopParticles()
	self.i_NextShot = CurTime()+math.random(25,45) * 0.01
	self.i_ShootNumber = self.i_ShootNumber - 1
	sound.Play(self:SelectFromTable({"possessed_soldier/REDPLSM1.ogg","possessed_soldier/REDPLSM2.ogg"}),self:GetPos())
	local plasmaball = ents.Create("obj_proj_plasma_ball")
	plasmaball:SetPos(self:GetAttachment(self:LookupAttachment("weapon")).Pos)
	ParticleEffectAttach("soldier_plasmamuzzle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("weapon"))
	plasmaball:SetOwner(self)
	plasmaball:Spawn()
	plasmaball:Activate()
	local phys = plasmaball:GetPhysicsObject()
	if IsValid(phys) then
		if self.IsPossessed then
			phys:SetVelocity((self:Possess_AimTarget() - plasmaball:GetPos()):GetNormal() *800 +VectorRand()*math.Rand(0,25))
		else
			phys:SetVelocity(((self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()) -plasmaball:GetPos() +self:GetEnemy():GetVelocity() *0.15):GetNormal() *800 +VectorRand()*math.Rand(0,25))
		end
	end
end

function ENT:RangeAttack_Heavy()
	self:StopParticles()
	sound.Play(self:SelectFromTable({"possessed_soldier/REDPLASF.ogg"}),self:GetPos())
	local plasmaball = ents.Create("obj_proj_plasma_ball_big")
	plasmaball:SetPos(self:GetAttachment(self:LookupAttachment("weapon")).Pos)
	ParticleEffectAttach("soldier_plasmamuzzle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("weapon"))
	plasmaball:SetOwner(self)
	plasmaball:Spawn()
	plasmaball:Activate()
	local phys = plasmaball:GetPhysicsObject()
	if IsValid(phys) then
		if self.IsPossessed then
			phys:SetVelocity((self:Possess_AimTarget() - plasmaball:GetPos()):GetNormal() *1200 +VectorRand()*math.Rand(0,25))
		else
			phys:SetVelocity(((self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()) -plasmaball:GetPos() +self:GetEnemy():GetVelocity() *0.15):GetNormal() *1200 +VectorRand()*math.Rand(0,25))
		end	
	end
end



function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	local rand
	if (event == "emit") then
		self:StopParticles()
		if (arg1 == "melee") then
			self:Attack(self:GetPos()+self:OBBCenter(),70,100,25)
		elseif (arg1 == "shoot_start") then
			self.b_IsShooting = true
		elseif (arg1 == "shoot_end") then
			self.b_IsShooting = false
		elseif (arg1 == "glow_start") then
			sound.Play(self:SelectFromTable({"possessed_soldier/REDPLASC.ogg"}),self:GetPos())
			ParticleEffectAttach("soldier_plasmaglow",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("weapon"))
		elseif (arg1 == "plasma_shoot") then
			self:RangeAttack_Heavy()
		end
	end
	return true
end

function ENT:CustomEffects()
	if deco ~= 0 then
	end
end

function ENT:OnRemove()
DEMON_COUNT = DEMON_COUNT-1
end

function ENT:OnDeath(dmg,dmginfo,hitbox)
	if dmg:GetDamage() >= 120 then
		self.HasDeathRagdoll = false
		for i=1,math.random(6,8) do
			local gib = ents.Create("obj_doom_cgore")
			gib:SetPos(self:GetPos()+self:OBBCenter() + VectorRand()*20)
			gib:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			gib:SetOwner(self)
			gib:Spawn()
			gib:Activate()
			local phys = gib:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-80,80),math.Rand(-80,80),math.Rand(-80,80)) +self:GetUp() * 200 + dmg:GetDamageForce()/30)
			end
		end
	end
end
