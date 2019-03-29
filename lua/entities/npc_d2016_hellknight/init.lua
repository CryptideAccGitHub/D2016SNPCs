AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.ModelTable = {"models/monsters/hellknight/hellknight.mdl"}
ENT.CollisionBounds = Vector(50,50,80)
ENT.TurnSpeed = 20
ENT.StartHealth = 1000
ENT.ViewAngle = 180
ENT.Faction = "FACTION_DOOM2016"
ENT.AllowPropDamage = false

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.Possessor_CanBePossessed = true

ENT.tbl_Animations = {
["Idle"] = {"idle"},
["Walk"] = {"walk"},
["Run"] = {"charge"}
}

ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

--Custom set-up
ENT.ISD2016NPC = true
ENT.NextIdleSound = CurTime()+1

ENT.s_Cstate = "idle"

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self:SetIdleAnimation("idle")
	self:CustomEffects()
	self.CanWander = false
	DEMON_COUNT = DEMON_COUNT+1
	timer.Simple(0,function()
		self:PlayActivity("spawn_teleport"..math.random(1,3))
	end)
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	self:ChaseEnemy()
	if self:CanPerformProcess() then
		if dist < 150 and self:CanPerformProcess() and self:FindInCone(enemy,70) then 
			self:PlayActivity(self:SelectFromTable({"meleeforward_close","meleeforward_close5","meleeforward_close6","meleeforward_close7"}))
		elseif dist < 250 and self:CanPerformProcess() and self:FindInCone(enemy,50) then 
			self:PlayActivity(self:SelectFromTable({"meleeforward5_1","meleeforward3_1","meleeforward4_med"}))
		elseif dist > 250 and dist < 400 and self:GetCurrentAnimation() == "charge" and self:FindInCone(enemy,10) and math.random(1,5) == 1 then
			self:PlayActivity(self:SelectFromTable({"charge_leapattack","charge_leapattack_5"}))
		end
		
		if self:CheckAngleTo(enemy:GetPos()).y > 50 and self:GetCurrentAnimation() == "idle" then
			self:PlayActivity("turn90left")
			return
		elseif self:CheckAngleTo(enemy:GetPos()).y < -50 and self:GetCurrentAnimation() == "idle" then
			self:PlayActivity("turn90right")
			return
		end
		
		if self.s_Cstate == "idle" then
			--Alert code
			if self:GetEnemy() != nil then
				self.CanWander = true
				--self:PlayActivity(self:SelectFromTable({"rage_taunt","rage_taunt_2","rage_taunt_3","rage_taunt_4"}));
				self.s_Cstate = "infight"
				return
			end
		elseif self.s_Cstate == "infight" then
			self:ChaseEnemy()
		end
	end
end
	
function ENT:OnThink()
	local target
	if self.IsPossessed then
		target = self:Possess_AimTarget()
	else
		if self:GetEnemy() ~= nil then
			target = self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()
			else
			target = self:GetPos()+self:OBBCenter()+self:GetForward()*20
		end
	end
	self:LookAtPosUseBone("spine3",target,40,60,18,0.5)
	self:LookAtPosUseBone("head",target,40,40,18,0.5)
	
	if self.NextIdleSound <= CurTime() then
		self.NextIdleSound = CurTime() + math.random(30,150)*0.1
		sound.Play("hellknight/HKnightIdle.wav",self:GetPos())
	end
end

--Utility code--------------------------------------------------------------------------------------------

function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	local rand
	if (event == "emit") then
		self:StopParticles()
		if(arg1 == "step") then
			sound.Play("stalker/large_step"..math.random(1,2)..".mp3",self:GetPos())
		elseif (arg1 == "melee") then
			sound.Play("hellknight/hellknight_melee_"..math.random(1,3)..".wav",self:GetPos())
			self:Attack((self:GetAttachment(self:LookupAttachment("origin"))).Pos+self:OBBCenter(),70,130,40)
		elseif (arg1 == "leap") then
			sound.Play("hellknight/hellknight_melee_"..math.random(1,3)..".wav",self:GetPos())
			self:Attack((self:GetAttachment(self:LookupAttachment("origin"))).Pos+self:OBBCenter(),120,180,60)
		elseif(arg1 == "roar") then
			sound.Play("hellknight/sight"..math.random(1,2)..".ogg",self:GetPos())
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
	if dmg:GetDamage() > 200 then
		self.HasDeathRagdoll = false
		for i=1,math.random(15,20) do
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
