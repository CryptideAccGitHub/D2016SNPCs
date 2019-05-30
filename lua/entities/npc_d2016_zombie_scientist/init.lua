AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.ModelTable = {"models/monsters/possessed/zombie.mdl"}
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 80
ENT.ViewAngle = 180
ENT.Faction = "FACTION_DOOM2016"
ENT.AllowPropDamage = false

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.Possessor_CanBePossessed = true

ENT.tbl_Animations = {
["Run"] = {"walk_forward_a","walk_forward_b","walk_forward_c","walk_forward_d","walk_forward_e","walk_forward_f","walk_forward_g"},
["Walk"] = {"walk_forward_a","walk_forward_b","walk_forward_c","walk_forward_d","walk_forward_e","walk_forward_f","walk_forward_g"},
}
ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

ENT.GoreBones = {"head","spine3","leftleg","leftupleg","rightleg","rightupleg","leftarm","leftforearm","rightarm","rightforearm"}

--Custom set-up
ENT.ISD2016NPC = true

ENT.t_NextIdleSound = CurTime()+3
ENT.s_CState = "idle"
ENT.i_SleepType = 0

function ENT:SetInit()
	self.GibDamage = 100
	self.GoreChance = 2
	self.GibScale = 1
	
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self.s_CState = "idle"
	self.CanWander = false
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	self:ChaseEnemy()
	if self:CanPerformProcess() and self:GetNoDraw() == false then
		
			if self:dCAngleTo(enemy:GetPos()).y > 50 and math.random(1,3) == 1 then
					self:PlayActivity("turn_90_left")
					return
			elseif self:dCAngleTo(enemy:GetPos()).y < -50 and math.random(1,3) == 1 then
					self:PlayActivity("turn_90_right")
					return
			elseif self:dCAngleTo(enemy:GetPos()).y < -90 and math.random(1,3) == 1 then
				self:PlayActivity("turn_157_left")
				return
			elseif self:dCAngleTo(enemy:GetPos()).y > 90 and math.random(1,3) == 1 then
				self:PlayActivity("turn_157_right")
				return
			end
		
		if dist < 150 and self:FindInCone(enemy,90) and math.random(1,3) == 1 then
			if self:IsMoving() then
				sound.Play("doom2016/possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
				self:PlayActivity(self:SelectFromTable({"melee_special_uacsecurity_moving","melee_special_moving"}))
			else
				sound.Play("doom2016/possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
				self:PlayActivity(self:SelectFromTable({"melee_special_uacsecurity_moving","melee_special"}))
			end
		elseif dist < 100 and self:FindInCone(enemy,90) and not self:IsMoving() then
			sound.Play("doom2016/possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
			self:PlayActivity(self:SelectFromTable({"melee_lunge_short_left_arm","melee_lunge_short_right_arm"}))
			return
		elseif dist < 150 and self:FindInCone(enemy,60) and self:IsMoving() then
			sound.Play("doom2016/possessed/unwillingattack"..math.random(1,3)..".ogg",self:GetPos())
			self:PlayActivity(self:SelectFromTable({"melee_moving_fwd_lunge_right_arm","melee_moving_fwd_lunge_left_arm"}))
			return
		end
	
		if self.s_CState ~= "idle" and self.EnemyMemoryCount < 1 then
		self.s_CState = "idle"
		end
	
		if self.s_CState == "idle" then
			if self:GetEnemy() != nil and self:GetNoDraw() == false then
				self.CanWander = true
				sound.Play("doom2016/possessed/unwillingsight"..math.random(1,3)..".ogg",self:GetPos())
				self.s_CState = "infight"
				return
			end
		elseif self.s_CState == "infight" then
		end
	end
end
	
function ENT:OnThink()
	if GetConVar("d2016_fastzombies"):GetBool() or self.IsPossessed then
		self.tbl_Animations["Run"] = {"charge_forward_v1","charge_forward_v2","charge_forward_v3","charge_forward_v4","charge_forward_v5"}
	else
		self.tbl_Animations["Run"] = {"walk_forward_a","walk_forward_b","walk_forward_c","walk_forward_d","walk_forward_e","walk_forward_f","walk_forward_g"}
	end
if CurTime() > self.t_NextIdleSound then
		if math.random(1,6) == 1 then
			sound.Play("doom2016/possessed/unwillingidle"..math.random(1,3)..".ogg",self:GetPos())
			self.t_NextIdleSound = CurTime() + math.random(5,8)
		end 
end
end 

function ENT:OnDamage_Pain(dmg,dmginfo,hitbox)
	if math.random(1,2) == 1 && CurTime() > self.NextPainSoundT then
		sound.Play("doom2016/possessed/unwillingpain"..math.random(1,3)..".ogg",self:GetPos())
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
		self:dCDamage(self:GetPos()+self:OBBCenter(),25,100,90)
		elseif (arg1 == "leap") then
		self:dCDamage(self:GetPos()+self:OBBCenter(),45,100,90)
		end
	end
	return true
end

function ENT:OnRemove()
end

function ENT:OnDeath(dmg,dmginfo,hitbox)
	if dmg:GetDamage() >= self.GibDamage then
		self:dGib(dmg)
	else
		self:EmitSound("doom2016/possessed/unwillingdeath"..math.random(1,3)..".ogg")
	end
end