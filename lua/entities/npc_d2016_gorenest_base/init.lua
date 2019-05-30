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
ENT.EntsToSpawn = {
--{Name = "entity1", AddPos = Vector(0,0,0), Timer = 1, Class = {"npc_zombie"}, Parameters = {StartHealth = 100}}
}

ENT.CollisionBounds = Vector(50,50,90)
ENT.StartHealth = 500
ENT.Faction = "FACTION_NONE"
ENT.BloodEffect = {"blood_impact_red_01"}
ENT.Possessor_CanBePossessed = false
ENT.HasDeathRagdoll = false
ENT.CanMove = false

ENT.ISD2016NPC = true
ENT.ISGoreNest = true

ENT.SpawnedEnts = {}

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
	table.insert(self.SpawnedEnts,key,ent)
end

function ENT:CustomEffects()
if GetConVar("d2016_deco"):GetInt() > 0 then
self.StartLight1 = ents.Create("light_dynamic")
self.StartLight1:SetKeyValue("brightness", "1")
self.StartLight1:SetKeyValue("distance", "2000")
self.StartLight1:Fire("Color", "255 5 5")
self.StartLight1:SetLocalPos(self:GetPos())
self.StartLight1:SetLocalAngles(self:GetAngles())
self.StartLight1:SetParent(self)
self.StartLight1:Spawn()
self.StartLight1:Activate()
self.StartLight1:Fire("SetParentAttachment","portal",0)
self.StartLight1:Fire("TurnOn", "", 0)
self:DeleteOnRemove(self.StartLight1)
end
self.portal = ents.Create("prop_dynamic")
self.portal:SetPos((self:GetAttachment(self:LookupAttachment("portal"))).Pos)
self.portal:SetOwner(self)
self.portal:SetMaterial("models/shadertest/shader4")
self.portal:SetModel("models/hunter/misc/sphere075x075.mdl")
self.portal:SetModelScale(0.75)
self.portal:SetRenderMode(RENDERMODE_TRANSALPHA)
self.portal:SetColor(255,10,10,5)
self.portal:Spawn()
self.portal:SetParent(self)
self:DeleteOnRemove(self.portal)
	
ParticleEffectAttach("hell_portal",PATTACH_ABSORIGIN_FOLLOW,portal,0)
end

function ENT:DoDeath(dmg,dmginfo,hitbox)
	if self.Dead then return end
	self.Dead = true
		self:EmitSound("D2016.DemonScream")
		for i=1,math.random(10,20) do
			local gib = ents.Create("obj_doom_cgore")
			gib:SetPos(self:GetPos()+self:OBBCenter() + VectorRand()*20)
			gib:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
			gib:SetOwner(self)
			gib:Spawn()
			gib:Activate()
			local phys = gib:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200)) +self:GetUp() * 200)
			end
		end
		
		if GetConVar("d2016_deco"):GetInt() > 0 then self.StartLight1:Remove() end
		self.portal:Remove()
		self:StopParticles()
		self:SetNoDraw(true)
		timer.Simple(5, function() if self:IsValid() then self:Remove() end end)
		
		for k,v in ipairs(self.EntsToSpawn) do
			timer.Simple(v.Timer, function()
				if self:IsValid() then
					self:OnSpawn(k,v)
					self:SpawnEnt(k,v)
				end
			end)
		end
end
