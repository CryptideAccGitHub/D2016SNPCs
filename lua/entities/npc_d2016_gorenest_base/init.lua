AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Variables
local deco = GetConVar("d2016_deco"):GetInt()
local self_model = nil

--Basic set-up
ENT.ModelTable = {"models/monsters/gore_nest.mdl"}

ENT.EntsToSpawnAtSpawn = {
--{Name = "entity1", AddPos = Vector(0,0,0), Timer = 1, Class = {"npc_zombie"}, Parameters = {StartHealth = 100}}
}

ENT.EntsToSpawnOnDeath = {
--{Name = "entity1", AddPos = Vector(0,0,0), Timer = 1, Class = {"npc_zombie"}, Parameters = {StartHealth = 100}}
}

ENT.CollisionBounds = Vector(0,0,0)
ENT.StartHealth = 500
ENT.Faction = "FACTION_NONE"
ENT.BloodEffect = {"blood_impact_red_01"}
ENT.Possessor_CanBePossessed = false
ENT.HasDeathRagdoll = false
ENT.CanMove = false

ENT.ISD2016NPC = true
ENT.ISGoreNest = true

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetIdleAnimation("idle")
	self:CustomEffects()
	
	 for k,v in ipairs(self.EntsToSpawnAtSpawn) do
		timer.Simple(v.Timer, function()
			if self:IsValid() then
				self:OnSpawn(k,v)
				self:SpawnEnt(k,v)
			end
		end)
	end
end

function ENT:OnSpawn(key,data) end

function ENT:SpawnEnt(key,data)
	local ent = data.Name
	local ent = ents.Create(self:SelectFromTable(data.Class))
	ent:SetPos(self:GetPos() + data.AddPos)
	ent:SetAngles(Angle(0,math.random(0,360)))
	ent:Spawn()
	ent:Activate()
	self:DeleteOnRemove(ent)
	table.insert(self.SpawnedEnts,key,ent)
end

function ENT:CustomEffects()
end

function ENT:OnRemove()
end

function ENT:DoDeath(dmg,dmginfo,hitbox)
		self:EmitSound("D2016.DemonScream")
		for i=1,math.random(20,40) do
			local gib = ents.Create("obj_doom_cgore")
			gib:SetPos(self:GetPos()+self:OBBCenter() + VectorRand()*20)
			gib:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			gib:SetOwner(self)
			gib:Spawn()
			gib:Activate()
			local phys = gib:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200)) +self:GetUp() * 200 + dmg:GetDamageForce()/10)
			end
		end
		
		timer.Simple(3,function()
		for k,v in ipairs(self.EntsToSpawnOnDeath) do
			timer.Simple(v.Timer, function()
				if self:IsValid() then
					self:OnSpawn(k,v)
					self:SpawnEnt(k,v)
				end
			end)
		end
		self:Remove()
		end)
end
