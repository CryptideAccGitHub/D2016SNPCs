AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Variables
local deco = GetConVar("d2016_deco"):GetInt()
local model = GetConVar("d2016_models"):GetInt()
local self_model = nil

--Basic set-up
ENT.ModelTable = {"models/monsters/"}
ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 0
ENT.ViewAngle = 0
ENT.Faction = ""
ENT.AttackablePropNames = {"prop_physics","func_breakable","prop_physics_multiplayer","func_physbox"}
ENT.AllowPropDamage = false

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.Possessor_CanBePossessed = true

ENT.tbl_Animations = {
["Idle"] = {"idle"},
["Run"] = {"runforward"},
["Walk"] = {"walkforward"}
}
ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

--Custom set-up
ENT.ISD2016NPC = true
ENT.NextIdleSound = CurTime()+1

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self:SetIdleAnimation("idle")
	self:CustomEffects()
	self.CanWander = false
	DEMON_COUNT = DEMON_COUNT+1
end

--Schedule processing--------------------------------------------------------------------------------------------

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	self:ChaseEnemy()
	if self:CanPerformProcess() then
	end
end
	
function ENT:OnThink()
end

--Utility code--------------------------------------------------------------------------------------------

function ENT:HandleEvents(...)
	local event = select(1,...)
	local arg1 = select(2,...)
	local rand
	if (event == "emit") then
		self:StopParticles()
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
	if dmg:GetDamage() > 100 then
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
