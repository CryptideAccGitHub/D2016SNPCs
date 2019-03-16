AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.MoveType = MOVETYPE_NONE
ENT.EntsToSpawn = {
--{Name = "entity1", AddPos = Vector(0,0,0), Timer = 1, Class = {"npc_zombie"}, Parameters = {StartHealth = 100}}
}
ENT.SpawnedEnts = {}


function ENT:OnSpawn(key,data) end
function ENT:CustomEffects() end
function ENT:Think() end

function ENT:Initialize()
	self:SetCollisionGroup(self.CollisionGroup)
	self:SetModel("models/error.mdl")
	self:SetMoveType(self.MoveType)
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:Physics()
	self:CustomEffects()
  for k,v in ipairs(self.EntsToSpawn) do
		timer.Simple(v.Timer, function()
			if self:IsValid() then
				self:OnSpawn(k,v)
				self:SpawnEnt(k,v)
			end
		end)
	end
end

function ENT:SpawnEnt(key,data)
	local ent = data.Name
	local ent = ents.Create(self:SelectFromTable(data.Class))
	ent:SetPos(self:GetPos() + data.AddPos)
	ent:SetAngles(Angle(0,0,math.random(0,360)))
	ent:Spawn()
	ent:Activate()
	table.insert(self.SpawnedEnts,key,data)
end

function ENT:OnRemove()
	for k, v in ipairs(self.SpawnedEnts) do
		if v:IsValid() then
		v:Remove()
		end
	end
end
