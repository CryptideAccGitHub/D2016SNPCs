AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.ModelTable = {"models/monsters/hellknight/hellknight.mdl"}
ENT.CollisionBounds = Vector(50,50,80)
ENT.TurnSpeed = 20
ENT.StartHealth = 1200
ENT.ViewAngle = 180
ENT.Faction = "FACTION_DOOM2016"
ENT.AllowPropDamage = false

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.CurrentHitSound = "doom2016/meleehitclaws"..math.random(1,2)..".ogg"

ENT.Possessor_CanBePossessed = true

ENT.tbl_Animations = {
["Idle"] = {"idle"},
["Walk"] = {"walkforward"},
["Run"] = {"charge"}
}

ENT.tbl_Capabilities = {CAP_OPEN_DOORS}
ENT.GoreBones = {"head","spine3","leftleg","leftupleg","rightleg","rightupleg","leftarm","leftforearm","rightarm","rightforearm"}

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
	self.GibDamage = 200
	self.GoreChance = 1
	self.GibScale = 1.8
	self:SetNoDraw(true)
	self.IsEssential = true
	self:SetModelScale(math.random(95,105)*0.01)
	
	ParticleEffect("d_monster_spawn_medium_01",self:GetPos()+self:GetUp()*-35, self:GetAngles())
	sound.Play("doom2016/sfx_spawn_0"..math.random(1,2)..".ogg",self:GetPos())
	timer.Simple(1, function() if self:IsValid(self) then self:PlayActivity("spawn_teleport"..math.random(1,5)) self.IsEssential = false self:SetNoDraw(false) end end)
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	if self:CanPerformProcess() and self:GetNoDraw() == false then
	
		self:ChaseEnemy()
		
		if dist < 150 and self:CanPerformProcess() and self:FindInCone(enemy,80) then 
			self:PlayActivity(self:SelectFromTable({"meleeforward_close","meleeforward_close5","meleeforward_close6","meleeforward_close7"}))
		elseif dist < 250 and self:CanPerformProcess() and self:FindInCone(enemy,40) then 
			self:PlayActivity(self:SelectFromTable({"meleeforward5_1","meleeforward3_1","meleeforward4_med"}))
		elseif dist > 250 and dist < 450 and self:GetCurrentAnimation() == "charge" and self:FindInCone(enemy,20) and math.random(1,5) == 1 then
			self:PlayActivity(self:SelectFromTable({"charge_leapattack","charge_leapattack_5"}))
				timer.Simple(0.4, function() if self:IsValid() and (self:GetCurrentAnimation() == "charge_leapattack" or self:GetCurrentAnimation() == "charge_leapattack_5") and not self:IsFalling() then
					self:SetVelocity(self:GetUp()*300 + self:GetForward()*math.Clamp(dist*5,1000,3000))
					end
				end)
				timer.Simple(0.8, function() if self:IsValid() and (self:GetCurrentAnimation() == "charge_leapattack" or self:GetCurrentAnimation() == "charge_leapattack_5") then
					self:SetVelocity(self:GetUp()*-300)
					end
				end)
		end
		
		if self:dCAngleTo(enemy:GetPos()).y > 70 and self:GetCurrentAnimation() == "idle" and math.random(1,3) == 1 then
			self:PlayActivity("turn90left")
			return
		elseif self:dCAngleTo(enemy:GetPos()).y < -70 and self:GetCurrentAnimation() == "idle" and math.random(1,3) == 1 then
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
	self:dCLook("spine3",target,40,60,18,0.5)
	self:dCLook("head",target,40,40,18,0.5)
	
	if self.NextIdleSound <= CurTime() and self:GetNoDraw() == false then
		self.NextIdleSound = CurTime() + math.random(30,150)*0.1
		sound.Play("doom2016/hellknight/HKnightIdle.wav",self:GetPos())
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
			sound.Play("doom2016/hellknight/hellknight_melee_"..math.random(1,3)..".wav",self:GetPos())
			self:dCDamage((self:GetAttachment(self:LookupAttachment("origin"))).Pos+self:OBBCenter(),35,110,90)
		elseif (arg1 == "leap") and not self:IsFalling(30) then
			ParticleEffect("hellknight_wave_outfire",self:GetAttachment(self:LookupAttachment("origin")).Pos+self:GetForward()*60, self:GetAngles())
			sound.Play("doom2016/hellknight/hkpound"..math.random(1,5)..".ogg",self:GetPos())
			self:dCDamage((self:GetAttachment(self:LookupAttachment("origin"))).Pos+self:OBBCenter(),40,200,180,DMG_BLAST)
		elseif(arg1 == "roar") then
			sound.Play("doom2016/hellknight/sight"..math.random(1,2)..".ogg",self:GetPos())
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
	if dmg:GetDamage() >= self.GibDamage then
		self:dGib(dmg)
	else
		self:EmitSound("doom2016/hellknight/hellknight_death"..math.random(1,3)..".wav")
	end
end