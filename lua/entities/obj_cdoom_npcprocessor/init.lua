AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.MoveType = MOVETYPE_NONE

function ENT:Think()
	if DEMON_COUNT < 1 then
		_e = ents.GetAll()
		for k,v in ipairs(_e) do
		if v.ISD2016SPAWNER and v.SpawnedEnt then v:Remove() end
		end
		if DEMON_COUNT ~= 0 then DEMON_COUNT = 0 end
	end
end

function ENT:Initialize()
	self:SetCollisionGroup(self.CollisionGroup)
	PROCESSOR_EXIST = true
	self:SetModel("models/error.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
end

