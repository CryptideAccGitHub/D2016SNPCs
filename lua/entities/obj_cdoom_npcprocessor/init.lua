AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.MoveType = MOVETYPE_NONE

function ENT:Think()
	if DEMON_COUNT < 1 then
		_e = ents.GetAll()
		for k,v in ipairs(_e) do
		if v.ISD2016SPAWNER then v:Remove() end
		end
		if DEMON_COUNT ~= 0 then DEMON_COUNT = 0 end
		self:Remove()
	end
end

function ENT:Initialize()
	self:SetCollisionGroup(self.CollisionGroup)
	self:SetModel("models/error.mdl")
	self:SetNoDraw(true)
	self:DrawShadow(false)
end

