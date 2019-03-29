AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.ModelTable = {"models/monsters/possessed/zombie.mdl"}
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 70
ENT.ViewAngle = 180
ENT.Faction = "FACTION_DOOM2016"
ENT.AllowPropDamage = false

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.Possessor_CanBePossessed = true

ENT.tbl_Animations = {
--["Idle"] = {"sleep1"},
["Run"] = {"walk_forward_a","walk_forward_b","walk_forward_c","walk_forward_d","walk_forward_e","walk_forward_f","walk_forward_g"},
["Walk"] = {"walk_forward_a","walk_forward_b","walk_forward_c","walk_forward_d","walk_forward_e","walk_forward_f","walk_forward_g"},
}
ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

--Custom set-up
ENT.ISD2016NPC = true

ENT.t_NextIdleSound = CurTime()+1
ENT.s_CState = "idle"
ENT.i_SleepType = 0

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self.s_CState = "idle"
	self.CanWander = false
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	self:ChaseEnemy()
	if self:CanPerformProcess() then
	
		if self:CheckAngleTo(enemy:GetPos()).y > 50 then
			if math.random(1,3) == 1 then
				self:PlayActivity("turn_90_left")
				return
			end
		elseif self:CheckAngleTo(enemy:GetPos()).y < -50 then
			if math.random(1,3) == 1 then
				self:PlayActivity("turn_90_right")
				return
			end
		elseif self:CheckAngleTo(enemy:GetPos()).y < -90 then
			if math.random(1,3) == 1 then
				self:PlayActivity("turn_157_left")
				return
			end
		elseif self:CheckAngleTo(enemy:GetPos()).y > 90 then
			if math.random(1,3) == 1 then
				self:PlayActivity("turn_157_right")
				return
			end
		end
		
		if dist < 150 and self:FindInCone(enemy,70) and math.random(1,3) == 1 then
			if self:IsMoving() then
				sound.Play("possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
				self:PlayActivity(self:SelectFromTable({"melee_special_moving","melee_special_uacsecurity_moving"}))
			else
				sound.Play("possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
				self:PlayActivity(self:SelectFromTable({"melee_special","melee_special_uacsecurity"}))
			end
		elseif dist < 100 and self:FindInCone(enemy,70) and not self:IsMoving() then
			sound.Play("possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
			self:PlayActivity(self:SelectFromTable({"melee_lunge_short_left_arm","melee_lunge_short_right_arm"}))
			return
		elseif dist < 150 and self:FindInCone(enemy,60) and self:IsMoving() then
			sound.Play("possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
			self:PlayActivity(self:SelectFromTable({"melee_moving_fwd_lunge_left_arm","melee_moving_fwd_lunge_right_arm"}))
			return
		end
	
		if self.CSTATE ~= "idle" and self.EnemyMemoryCount < 1 then
		self.CSTATE = "idle"
		end
	
		if self.s_CState == "idle" then
			if self:GetEnemy() != nil then
				self.CanWander = true
				sound.Play("possessed/unwillingsight"..math.random(1,3)..".ogg",self:GetPos())
				self.s_CState = "infight"
				return
			end
		elseif self.s_CState == "infight" then
		end
	end
end
	
function ENT:OnThink()
if CurTime() > self.t_NextIdleSound then
		if math.random(1,6) == 1 then
			sound.Play("possessed/unwillingidle"..math.random(1,3)..".ogg",self:GetPos())
			self.t_NextIdleSound = CurTime() + math.random(5,8)
		end 
end
end 

function ENT:OnDamage_Pain(dmg,dmginfo,hitbox)
	if math.random(1,2) == 1 && CurTime() > self.NextPainSoundT then
		sound.Play("possessed/unwillingpain"..math.random(1,3)..".ogg",self:GetPos())
		self.NextPainSoundT = CurTime() + math.random(2,3)
		if math.random(1,2) then
			if self:IsMoving() then
				self:PlayActivity("pain_move")
			else
				self:PlayActivity("pain_stand")
			end
		end
	end
end

--Utility code--------------------------------------------------------------------------------------------

function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	local rand
	if (event == "emit") then
		if (arg1 == "melee") then
		self:Attack(self:GetPos()+self:OBBCenter(),70,100,20)
		elseif (arg1 == "leap") then
		self:Attack(self:GetPos()+self:OBBCenter(),70,100,35)
		end
	end
	return true
end

function ENT:OnRemove()
end

function ENT:OnDeath(dmg,dmginfo,hitbox)
	if dmg:GetDamage() > 0 then
		self.HasDeathRagdoll = false
		for i=1,math.random(4,6) do
			local gib = ents.Create("obj_doom_cgore")
			gib:SetPos(self:GetPos()+self:OBBCenter() + VectorRand()*20)
			gib:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			gib:SetOwner(self)
			gib:Spawn()
			gib:Activate()
			local phys = gib:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-50,50),math.Rand(-50,50),math.Rand(-50,50)) +self:GetUp() * 200 + dmg:GetDamageForce()/10)
			end
		end
	end
end
