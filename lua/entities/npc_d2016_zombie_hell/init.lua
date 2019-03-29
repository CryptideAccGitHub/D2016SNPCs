AddCSLuaFile('init.lua') -- for testing purposes
AddCSLuaFile('shared.lua')
include('shared.lua')

--Basic set-up
ENT.StartHealth = 80

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetMovementType(MOVETYPE_STEP)
	self:SetBodygroup(0,1)
	self.s_CState = "idle"
	self.CanWander = false
	DEMON_COUNT = DEMON_COUNT+1
	timer.Simple(0,function()
	self:PlayActivity("spawn_teleport")
	end)
end

function ENT:Remove()
DEMON_COUNT = DEMON_COUNT-1
end