AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Variables
local deco = GetConVar("d2016_deco"):GetInt()
local model = GetConVar("d2016_models"):GetInt()
local self_model = nil

--Model set-up
if (model == 0) or (model == nil) then
	self_model = {"models/monsters/imp/imp.mdl"}
elseif (model == 1) then
	self_model = {"models/monsters/imp/imp_quakecon.mdl"}
elseif (model == 2) then
	self_model = {"models/monsters/imp/imp_eternal.mdl"}
end

--Basic set-up
ENT.ModelTable = self_model
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 125
ENT.ViewAngle = 180
ENT.Faction = "FACTION_DOOM2016"

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.tbl_Animations = {}
ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

--Custom set-up
ENT.ISD2016NPC = true
ENT.NEXTCTASK = CurTime()+1
ENT.NEXTHEAVYATTACK = CurTime()+math.random(3,8)
ENT.NEXTCSTATE = ""
ENT.NEXTATTACK = CurTime() + 1
ENT.NEXTSPECIALMOVEMENT = CurTime() + math.random(5,8)
ENT.CSTATE = ""
ENT.CTARGET = self:GetPos()
ENT.NEXTCTARGET = CurTime()+1

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self:SetIdleAnimation("idle")
	self:CustomEffects()
	self.CSTATE("Idle_NoEnemy")
	self.CanWander = false
	DEMON_COUNT = DEMON_COUNT+1
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	if self:CanPerformProcess() then
		
		if self.CSTATE ~= "Idle_NoEnemy" and self.EnemyMemoryCount < 1 then
		self.CSTATE = "Idle_NoEnemy"
		end
		
		if dist < 150 and self:GetCurrentAnimation() == "idle" then
			self:PlayActivity("meleeforward0"..math.random(1,2))
		elseif dist < 160 and self:GetCurrentAnimation() == "run" then
			self:PlayActivityENTERAMOVEMENTMELEEACTIVITYFAGGOT --("meleeforward0"..math.random(1,2))
		end
		
		-- Just an idle
		
		if self.CSTATE == "Idle_NoEnemy" then
			if self:GetEnemy() != nil then
				self:PlayActivity({\PLACE-ACTIVITY-TABLE-HERE-MOTHERFUCKER\})
				self.CanWander = true
				self.CSTATE = "InFight_Running"
			end
			
		-- It runs to enemy/around enemy.
			
		elseif self.CSTATE == "InFight_Running" then
			if self.NEXTCSTATE <= CurTime() and dist > 600 and dist < 1200  then
				self.CSTATE = "InFight"
				self.NEXTCSTATE = CurTime()+math.Rand(5,15)
			elseif dist < 300 then
				if self:IsFrightened() then self:RunAway() else self:ChaseEnemy() end
				self.NEXTCSTATE = CurTime()+math.Rand(3,5)
			end
			
			if self.NEXTSPECMOVEMENT <= CurTime() and self:FindInCone(enemy,90) then
				self.PlayActivity(ROLLFORWARD)
				self.NEXTSPECMOVEMENT = CurTime() + math.random(5,8)
			elseif self.NEXTSPECMOVEMENT <= CurTime() then
				self.PlayActivity(ROLLFORWARD2)
				self.NEXTSPECMOVEMENT = CurTime() + math.random(5,8)
			end
			
			if self:FindInCone(enemy,90) and dist > 300 then
			self:PlayActivity(ENTERARANGEATTACKACTIVITYFAGGOT)		
			end
			
			if dist > 700 then
				self:ChaseEnemy()
			else
				if self.NEXTCTARGET <= self:CurTime() then
					/INSERT-MOVE-CODE-HERE-FAGGOT/
				end
			end
		
		-- It stands and throws its shit.	
		elseif self.CSTATE == "InFight"
			
			if self.NEXTATTACK <= CurTime() then
				if self.NEXTHEAVYATTACK <= CurTime() then
					if IMP_COUNT > 1 then
						local _e = ents.GetAll()
						for k,v in ipairs(_e) then
							if v.ISD2016NPC and v:GetClass() == "npc_d2016_imp" then
								v.NEXTHEAVYATTACK = CurTime()+math.random(5,12)
							end
						end
						self:PlayActivity(THATSHITTYSPECIAL)
					end
				else
					self:PlayActivity(ENTERARANGEATTACKACTIVITYFAGGOT)
				end
			end
		
			if self.NEXTSPECMOVEMENT <= CurTime() and self:FindInCone(enemy,90) then
				self.PlayActivity(JUMPLEFTRIGHT)
				self.NEXTSPECMOVEMENT = CurTime() + math.random(5,8)
			end
			
			if (self.NEXTCSTATE <= CurTime()) or (dist > 1200)  then
				self.CSTATE = "InFight_Running"
				self.NEXTCSTATE = CurTime()+math.Rand(5,15)
			elseif (self.NEXTCSTATE <= CurTime()) and (dist < 300) then
				if self:Health <= 120 then self:RunAway() else self:ChaseEnemy() end
				self.NEXTCSTATE = CurTime()+math.Rand(3,5)
			end
		end
	end
end
	
function ENT:OnThink()
end

--Utility code--------------------------------------------------------------------------------------------

function ENT:OnRemove()
	DEMON_COUNT = DEMON_COUNT-1
end

function ENT:RunAway()
self:PlayActivity(PUTHEREYOURSHITTYACTIVITY)
/PUTSOMESHITTYMOVINGCODEHERE/
end

function ENT:IsFrightened()
if (self:GetEnemy():Health()=>300) or ((DEMON_COUNT <= 5) and (DEMON_MEDIUM_EXIST == false) and (DEMON_HEAVY_EXIST == false)) or self:Health()<=110
return true
end
end

function ENT:CustomEffects()
	if deco == 0 then
		return
	elseif deco == 1 then
		return
	elseif deco == 2 then
		return
	end
end

function ENT:OnDeath(dmg,dmginfo,hitbox)
	DEMON_COUNT = DEMON_COUNT-1
	if dmg:GetDamage() => 100 then
		self.HasDeathRagdoll = false
		for i=1,math.random(4,6) do
			local gib = ents.Create("obj_d2016_gib")
			gib:SetPos(self:GetPos() +self:OBBCenter())
			gib:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			gib:SetOwner(self)
			gib:Spawn()
			gib:Activate()
			local phys = spit:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100)) *2 +self:GetUp() * 200 + dmg:GetDamageForce())
			end
		end
	end
end
