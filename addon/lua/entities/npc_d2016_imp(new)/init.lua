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
ENT.StartHealth = 120
ENT.ViewAngle = 180
ENT.Faction = "FACTION_DOOM2016"

ENT.BloodEffect = {"blood_impact_red_01"}

ENT.tbl_Animations = {}
ENT.tbl_Capabilities = {CAP_OPEN_DOORS}

function ENT:SetInit()
	self:SetHullType(HULL_MEDIUM)
	self:SetCState("Idle")
	self:SetMovementType(MOVETYPE_STEP)
	self:SetIdleAnimation("idle")
end


