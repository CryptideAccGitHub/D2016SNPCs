AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Variables
local deco = GetConVar("d2016_deco"):GetInt()

--Basic set-up
ENT.ModelTable = {"models/monsters/imp/imp.mdl"} -- Model
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 125
ENT.ViewAngle = 180 -- You can`t sneak ppast them
ENT.Faction = "FACTION_DOOM2016"
ENT.AllowPropDamage = false

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.Possessor_CanBePossessed = true
ENT.Possessor_UseBoneCamera = true

ENT.LeavesBlood = true
ENT.AutomaticallySetsUpDecals = true
ENT.BloodDecal = {"Blood"}

ENT.tbl_Animations = {
["Idle"] = {"idle"},
["Run"] = {"runforward"},
["Walk"] = {"walkforward"}
}
ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

--Custom set-up
ENT.ISD2016NPC = true
ENT.NEXTHEAVYATTACK = CurTime()+math.Rand(3,5)
ENT.NEXTCSTATE = CurTime() + math.Rand(3,8)
ENT.NEXTATTACK = CurTime() + math.Rand(3,8)
ENT.NEXTSPECIALMOVEMENT = CurTime() + math.Rand(6,18)
ENT.CSTATE = "Idle_NoEnemy"
ENT.CTARGET = Vector(-200,0,0)
ENT.NEXTCTARGET = CurTime()
ENT.NextIdleSound = CurTime()+1

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self:SetIdleAnimation("idle")
	self:CustomEffects()
	self.CanWander = false
	DEMON_COUNT = DEMON_COUNT+1
	-- Spawn animation
	timer.Simple(0.05,function()
	self:PlayActivity("spawn_teleport"..math.random(1,5))
	end)
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	--self:ChaseEnemy()
	if self:CanPerformProcess() then
	
		--[[self:SetIdleAnimation("idle") -- Required due to bug]]
				
		if self:CheckAngleTo(enemy:GetPos()).y > 60 and self:GetCurrentAnimation() == "idle" then
			self:PlayActivity("turn90left")
		elseif self:CheckAngleTo(enemy:GetPos()).y < -60 and self:GetCurrentAnimation() == "idle" then
			self:PlayActivity("turn90right")
		end
		
		
		if self.CSTATE ~= "Idle_NoEnemy" and self.EnemyMemoryCount < 1 then
		self.CSTATE = "Idle_NoEnemy"
		end
		
		if dist < 120 and self:FindInCone(enemy,90) then
			self:PlayActivity("meleeforward0"..math.random(1,2))
			return
		elseif dist < 170 and self:FindInCone(enemy,50) and math.random(1,2) == 1 then
			self:PlayActivity("meleemoving0"..math.random(1,3))
			return
		end
		
		-- Just an idle
		
		if self.CSTATE == "Idle_NoEnemy" then
			--Alert code
			if self:GetEnemy() != nil then
				self.CanWander = true
				self.CSTATE = "InFight"
				return
			end
			
		-- It runs to enemy/around enemy.
			
		elseif self.CSTATE == "InFight_Running" then
			if self.NEXTCSTATE < CurTime() and dist > 300 and dist < 800 and self:GetCurrentAnimation() == "runforward" and self:Visible(self:GetEnemy()) then
				self.CTARGET = self:GetPos()
				local enemypos = self:GetEnemy():GetPos()
				if self:CheckAngleTo(enemypos).y < 45 and self:CheckAngleTo(enemypos).y > -45 then
						self:PlayActivity("runforward_throw_to_idle")
				elseif self:CheckAngleTo(enemypos).y > 135 or self:CheckAngleTo(enemypos).y < -135 then
						self:PlayActivity(self:SelectFromTable({"runforward_throw_turn_157_left_to_idle","runforward_throw_turn_157_right_to_idle"}))
				elseif self:CheckAngleTo(enemypos).y > 45 and self:CheckAngleTo(enemypos).y < 90 then
						self:PlayActivity("runforward_throw_turn_left_to_idle")
				elseif self:CheckAngleTo(enemypos).y < -45 and self:CheckAngleTo(enemypos).y > -90 then
						self:PlayActivity("runforward_throw_turn_right_to_idle")
				end
				self.CSTATE = "InFight"
				self.NEXTCSTATE = CurTime()+math.Rand(3,8)
				return
			elseif dist < 300 and self:CanPerformProcess() then
				self:RunAway()
				self.NEXTCSTATE = CurTime()+math.Rand(2,4)
				return
			end
			
			if self.NEXTSPECIALMOVEMENT < CurTime() and self:FindInCone(enemy,90) and self:GetCurrentAnimation() == "runforward" then
				self:PlayActivity(self:SelectFromTable({"diveforward_forward1","diveforward_forward2"}))
				self.NEXTSPECIALMOVEMENT = CurTime() + math.Rand(6,12)
				return
			elseif self.NEXTSPECIALMOVEMENT < CurTime() and self:GetCurrentAnimation() == "runforward" then
				self:PlayActivity(self:SelectFromTable({"diveforward_right1","diveforward_right2","diveforward_left1","diveforward_left2"}))
				self.NEXTSPECIALMOVEMENT = CurTime() + math.Rand(6,12)
				return
			end
			
			if self:FindInCone(enemy,90) and dist > 200 and dist < 800 and CurTime() > self.NEXTATTACK and self:Visible(self:GetEnemy()) then
				self:PlayActivity("runforward_throwforward")	
				self.NEXTATTACK = CurTime() + math.Rand(3,5)
				return
			end
			
			if dist > 800 or not self:Visible(self:GetEnemy()) then
				self:ChaseEnemy()
				return
			elseif dist < 800 and self:Visible(self:GetEnemy()) then
				if self.NEXTCTARGET < CurTime() then
					dir = VectorRand()
					_x = dir.x
					_y = dir.y
					self.CTARGET = (self:GetEnemy():GetPos()+Vector(dir.x*500,dir.y*500,0))
					self.NEXTCTARGET = CurTime()+math.Rand(4,7)
					self:SetLastPosition(self.CTARGET)
					self:SetArrivalActivity(ACT_IDLE)
					self:TASKFUNC_RUNLASTPOSITION()
					return
				end
			end
		
		-- It stands and throws its shit.	
		elseif self.CSTATE == "InFight" then
			if (self.NEXTCSTATE < CurTime()) or (dist > 600) then
				self.CSTATE = "InFight_Running"
				self.NEXTCSTATE = CurTime()+math.Rand(3,8)
				return
			end
			
			if (dist < 300) then
				self:RunAway()
				self.NEXTCSTATE = CurTime()+math.Rand(4,5)
				return
			end
			
			if self.NEXTATTACK < CurTime() and self:FindInCone(enemy,90) and dist < 800 and self:CanPerformProcess() and self:Visible(self:GetEnemy()) then
				if self.NEXTHEAVYATTACK < CurTime() then
					self:PlayActivity(self:SelectFromTable({"throw_fastball","throw_fastball2"}))
					return
				end
			elseif self.NEXTATTACK < CurTime() and self:FindInCone(enemy,90) and dist < 800 and self:CanPerformProcess() then
				self:PlayActivity(self:SelectFromTable({"throw","throw2","throw3","step_left_throw","step_right_throw"}))
				return 
			elseif self.NEXTATTACK < CurTime() and dist > 800 then
				self.CSTATE = "InFight_Running"
				self.NEXTCSTATE = CurTime()+math.Rand(3,8)
			end
		
			if self.NEXTSPECIALMOVEMENT < CurTime() and self:FindInCone(enemy,90) and self:CanPerformProcess() then
				self:PlayActivity(self:SelectFromTable({"step_left","step_right"}))
				self.NEXTSPECIALMOVEMENT = CurTime() + math.random(5,8)
				return
			end
		end
	end
end
	
function ENT:OnThink()
if self.IsPossessed then
self:LookAtPosUseBone("spine",self:Possess_AimTarget(),70,60,18,0.5)
self:LookAtPosUseBone("head",self:Possess_AimTarget(),80,90,18,0.5)
else
if self:GetEnemy() ~= nil then
self:LookAtPosUseBone("spine",self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter(),70,60,18,0.5)
self:LookAtPosUseBone("head",self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter(),80,90,18,0.5)
end
end

if CurTime() > self.NextIdleSound then
	if self:GetEnemy() == nil then 
		if math.random(1,6) == 1 then
			sound.Play("imp/imp_idle"..math.random(1,4)..".ogg",self:GetPos())
			self.NextIdleSound = CurTime() + math.random(1,8)
		end 
	else 
		if math.random(1,3) == 1 then
			sound.Play("imp/imp_distant_short_0"..math.random(1,3)..".ogg",self:GetPos()) 
			self.NextIdleSound = CurTime() + math.random(1,8)
		end 
	end
end
end

--Utility code--------------------------------------------------------------------------------------------

function ENT:Possess_Primary()
	if self:CanPerformProcess() then
		if self:GetCurrentAnimation() ~= "runforward" then
			self:PlayActivity("meleeforward0"..math.random(1,2))
		else
			self:PlayActivity("meleemoving0"..math.random(1,3))
		end
	end
end


function ENT:Possess_Secondary()
	if self:CanPerformProcess() then
		if self:GetCurrentAnimation() ~= "runforward" then
			--self:PlayActivity(self:SelectFromTable({"throw","throw2","throw3"}))
			self:PlayActivity(self:SelectFromTable({"throw3"}))
		else
			self:PlayActivity("runforward_throwforward")	
		end
	end	
end

function ENT:Possess_Jump()
	if self.NEXTSPECIALMOVEMENT < CurTime() and self:GetCurrentAnimation() == "runforward" then
		self:PlayActivity(self:SelectFromTable({"diveforward_forward1","diveforward_forward2"}))
		self.NEXTSPECIALMOVEMENT = CurTime() + math.Rand(3,4)
	end
end

function ENT:RunAway()
if self.CSTATE == "InFight" then
self:PlayActivity(self:SelectFromTable({"step_back","step_back_left","step_back_right","step_back_left_throw","step_back_right_throw"}))
end
self.CTARGET = (self:GetEnemy():GetPos() - self:GetPos()):GetNormal() * 300
self:SetLastPosition(self.CTARGET)
self.CSTATE = "InFight_Running"
self:SetArrivalActivity(ACT_IDLE)
timer.Simple(1,function() if self:IsValid() then self:TASKFUNC_RUNLASTPOSITION() end end)
end

function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	local rand
	if (event == "emit") then
		self:StopParticles()
		self.StartLight1:Fire("TurnOff", "", 0)
		self.StartLight2:Fire("TurnOff", "", 0)
		if (arg1 == "melee") then
			self:Attack(self:GetPos()+self:OBBCenter(),70,100,20)
		elseif(arg1 == "right_fireball") then
			self.StartLight1:Fire("TurnOn", "", 0)
			ParticleEffectAttach("imp_fireball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("righthand"))
		elseif(arg1 == "left_fireball") then
			self.StartLight2:Fire("TurnOn", "", 0)
			ParticleEffectAttach("imp_fireball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("lefthand"))
		elseif (arg1 == "range_left")  then
			sound.Play(self:SelectFromTable({"imp/fx_imp_fireball_launch_01.ogg","imp/fx_imp_fireball_launch_02.ogg","imp/fx_imp_fireball_launch_03.ogg"}),self:GetPos())
			self:RangeAttack_Normal("lefthand")
		elseif (arg1 == "range_right")  then
			sound.Play(self:SelectFromTable({"imp/fx_imp_fireball_launch_01.ogg","imp/fx_imp_fireball_launch_02.ogg","imp/fx_imp_fireball_launch_03.ogg"}),self:GetPos())
			self:RangeAttack_Normal("righthand")
		elseif (arg1 == "range_left_powered")  then
			self:RangeAttack_Powered("lefthand")
		elseif (arg1 == "range_right_powered")  then
			self:RangeAttack_Powered("righthand")
		elseif (arg1 == "right_bigfireball")  then
			sound.Play(self:SelectFromTable({"imp/imp_charge1.ogg"}),self:GetPos())
			ParticleEffectAttach("imp_bigball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("righthand"))
		elseif (arg1 == "left_bigfireball")  then
			sound.Play(self:SelectFromTable({"imp/imp_charge1.ogg"}),self:GetPos())
			ParticleEffectAttach("imp_bigball",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("lefthand"))
		elseif (arg1 == "roar")  then
			sound.Play(self:SelectFromTable({"imp/imp_sight1.ogg","imp/imp_sight2.ogg","imp/imp_sight3.ogg","imp/imp_sight4.ogg"}),self:GetPos())
		end
	end
	return true
end

function ENT:RangeAttack_Normal(att)
	self:StopParticles()
	self.NEXTATTACK = CurTime()+math.Rand(3,8)
	local fireball = ents.Create("obj_proj_impball")
	fireball:SetPos(self:GetAttachment(self:LookupAttachment(att)).Pos)
	fireball:SetOwner(self)
	fireball:Spawn()
	fireball:Activate()
	local phys = fireball:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(self:SetUpRangeAttackTarget()*1.5 +self:GetUp() * 150 + VectorRand()*math.Rand(1,40))
	end
end

function ENT:RangeAttack_Powered(att)
	self:StopParticles()
	self.NEXTHEAVYATTACK = CurTime()+math.Rand(7,15)
	local fireball = ents.Create("obj_proj_impball")
	fireball:SetPos(self:GetAttachment(self:LookupAttachment(att)).Pos)
	fireball:SetOwner(self)
	fireball:Spawn()
	fireball:Activate()
	local phys = fireball:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(self:SetUpRangeAttackTarget()*1.5 + VectorRand()*math.Rand(1,40))
	end
end

function ENT:IsFrightened()
if (self:GetEnemy():Health()>300) or ((DEMON_COUNT < 5) and (DEMON_MEDIUM_EXIST == false) and (DEMON_HEAVY_EXIST == false)) or (self:Health()<110) then
return true
end
end

function ENT:CustomEffects()
	if deco ~= 0 then
	self.eyel = ents.Create("env_sprite")
	self.eyel:SetKeyValue("model","cptbase/sprites/glow01.spr")
	self.eyel:SetKeyValue("rendermode","5")
	self.eyel:SetKeyValue("rendercolor","255 80 0")
	self.eyel:SetKeyValue("scale","0.06")
	self.eyel:SetKeyValue("spawnflags","1")
	self.eyel:SetParent(self)
	self.eyel:Fire("SetParentAttachment","lefteye",0)
	self.eyel:Spawn()
	self.eyel:Activate()
	self:DeleteOnRemove(self.eyel)
	
	self.eyer = ents.Create("env_sprite")
	self.eyer:SetKeyValue("model","cptbase/sprites/glow01.spr")
	self.eyer:SetKeyValue("rendermode","5")
	self.eyer:SetKeyValue("rendercolor","255 80 0")
	self.eyer:SetKeyValue("scale","0.06")
	self.eyer:SetKeyValue("spawnflags","1")
	self.eyer:SetParent(self)
	self.eyer:Fire("SetParentAttachment","righteye",0)
	self.eyer:Spawn()
	self.eyer:Activate()
	self:DeleteOnRemove(self.eyer)
	
	end
	
	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "3")
	self.StartLight1:SetKeyValue("distance", "220")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 100 0")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("SetParentAttachment","righthand")
	self.StartLight1:Fire("TurnOff", "", 0)
	self:DeleteOnRemove(self.StartLight1)
	
	self.StartLight2 = ents.Create("light_dynamic")
	self.StartLight2:SetKeyValue("brightness", "3")
	self.StartLight2:SetKeyValue("distance", "220")
	self.StartLight2:SetLocalPos(self:GetPos())
	self.StartLight2:SetLocalAngles( self:GetAngles() )
	self.StartLight2:Fire("Color", "255 100 0")
	self.StartLight2:SetParent(self)
	self.StartLight2:Spawn()
	self.StartLight2:Activate()
	self.StartLight2:Fire("SetParentAttachment","lefthand")
	self.StartLight2:Fire("TurnOff", "", 0)
	self:DeleteOnRemove(self.StartLight2)
end

function ENT:OnRemove()
DEMON_COUNT = DEMON_COUNT-1
end

function ENT:OnDeath(dmg,dmginfo,hitbox)
	if dmg:GetDamage() > 100 then
		self.HasDeathRagdoll = false
		for i=1,math.random(4,6) do
			local gib = ents.Create("obj_doom_cgore")
			gib:SetPos(self:GetPos()+self:OBBCenter() + VectorRand()*20)
			gib:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			gib:SetOwner(self)
			gib:Spawn()
			ParticleEffect("blood_impact_red_big",self:GetPos()+self:OBBCenter(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
			gib:Activate()
			local phys = gib:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-80,80),math.Rand(-80,80),math.Rand(-80,80)) +self:GetUp() * 200 + dmg:GetDamageForce()/20)
			end
		end
	end
end
