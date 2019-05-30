if !CPTBase then return end

sound.Add( {
	name = "mancubus_flamethrower_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = { 78, 82 },
	sound = "mancubus/flame_thrower_loop.ogg"
} )

AddCSLuaFile()
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT.ModelTable = {"models/monsters/mancubus/mancubus.mdl"}
ENT.Faction = "FACTION_DOOM2016"
ENT.StartHealth = 1500
ENT.ViewAngle = 180
ENT.Mass = 8000
ENT.CanBeRagdolled = false
ENT.MaxTurnSpeed = 10
ENT.BloodEffect = {"blood_impact_red_01"}
ENT.CanWander = false
ENT.CollisionBounds = Vector(40,40,100)

ENT.HasDeathRagdoll = true

ENT.NextPain = CurTime()
ENT.NextIdleSound = CurTime() + 5
ENT.CanBeAlerted = 0
ENT.MAttack = {}
ENT.MAttack.Normal = {}
ENT.MAttack.Normal.Dist = 200
ENT.MAttack.Normal.Damage = 35
ENT.MAttack.Normal.DamageDistance = 220
ENT.MAttack.Normal.DamageType = DMG_SLASH
ENT.MAttack.Purge = {}
ENT.MAttack.Purge.Dist = 300
ENT.MAttack.Purge.Damage = math.random(25,30)
ENT.MAttack.Purge.DamageDistance = 400
ENT.MAttack.Purge.DamageType = DMG_BLAST
ENT.MAttack.Flame = {}
ENT.MAttack.Flame.DamageType = DMG_BURN
ENT.RAttack = {}
ENT.RAttack.Dist = 3000
ENT.RAttack.Next = CurTime()
ENT.RAttack.Move = {}
ENT.RAttack.Move.NextChange = CurTime()
ENT.RAttack.Projectile = {}
ENT.RAttack.Projectile.Entity = "obj_proj_mancubusball"
ENT.RAttack.Projectile.Force = 2000

ENT.tbl_Animations = {
["Idle"] = {"idle"},
["Walk"] = {"walk_forward"},
["Run"] = {"walk_forward"}
}

ENT.tbl_Sounds = {}

ENT.s_CState = "idle"

function ENT:SetInit()
	self:SetHullType(HULL_LARGE)
	self:SetMovementType(MOVETYPE_STEP)
	self.UsesFlamethrower = false
	self.CanWander = false
	self:SetIdleAnimation("idle")
	timer.Simple(0,function() self:PlayActivity(self:SelectFromTable({"spawn_teleport1","spawn_teleport2"}))  end) 
	ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("leftweapon")) 
	ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rightweapon")) 
	
	if GetConVar("d2016_deco"):GetInt() > 0 then
		ParticleEffectAttach("mancubus_platesmoke",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("chestplate_center_att"))
	end
	
	if GetConVar("d2016_deco"):GetInt() == 2 then
		ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("leftweaponmortar"))
		ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rightweaponmortar"))
		self.leftweapon = ents.Create("env_sprite") 
		self.leftweapon:SetKeyValue("model","cptbase/sprites/glow01.spr") 
		self.leftweapon:SetKeyValue("rendermode","5") 
		self.leftweapon:SetKeyValue("rendercolor","255 80 0") 
		self.leftweapon:SetKeyValue("scale","0.4") 
		self.leftweapon:SetKeyValue("spawnflags","1") 
		self.leftweapon:SetParent(self) 
		self.leftweapon:Fire("SetParentAttachment","leftweapon",0) 
		self.leftweapon:Spawn() 
		self.leftweapon:Activate() 
		self:DeleteOnRemove(self.leftweapon) 
		
		self.leftweaponlight = ents.Create("light_dynamic")
		self.leftweaponlight:SetKeyValue("brightness", "1")
		self.leftweaponlight:SetKeyValue("distance", "150")
		self.leftweaponlight:SetLocalPos(self:GetPos())
		self.leftweaponlight:SetLocalAngles( self:GetAngles() )
		self.leftweaponlight:Fire("Color", "255 80 0")
		self.leftweaponlight:SetParent(self)
		self.leftweaponlight:Spawn()
		self.leftweaponlight:Activate()
		self.leftweaponlight:Fire("SetParentAttachment","leftweapon")
		self.leftweaponlight:Fire("TurnOn", "", 0)
		self:DeleteOnRemove(self.leftweaponlight)
			
		self.leftweaponmortar = ents.Create("env_sprite") 
		self.leftweaponmortar:SetKeyValue("model","cptbase/sprites/glow01.spr") 
		self.leftweaponmortar:SetKeyValue("rendermode","5") 
		self.leftweaponmortar:SetKeyValue("rendercolor","255 80 0") 
		self.leftweaponmortar:SetKeyValue("scale","0.4") 
		self.leftweaponmortar:SetKeyValue("spawnflags","1") 
		self.leftweaponmortar:SetParent(self) 
		self.leftweaponmortar:Fire("SetParentAttachment","leftweaponmortar",0) 
		self.leftweaponmortar:Spawn() 
		self.leftweaponmortar:Activate() 
		self:DeleteOnRemove(self.leftweaponmortar) 
		
		self.leftweaponmortarlight = ents.Create("light_dynamic")
		self.leftweaponmortarlight:SetKeyValue("brightness", "1")
		self.leftweaponmortarlight:SetKeyValue("distance", "150")
		self.leftweaponmortarlight:SetLocalPos(self:GetPos())
		self.leftweaponmortarlight:SetLocalAngles( self:GetAngles() )
		self.leftweaponmortarlight:Fire("Color", "255 80 0")
		self.leftweaponmortarlight:SetParent(self)
		self.leftweaponmortarlight:Spawn()
		self.leftweaponmortarlight:Activate()
		self.leftweaponmortarlight:Fire("SetParentAttachment","leftweaponmortar")
		self.leftweaponmortarlight:Fire("TurnOn", "", 0)
		self:DeleteOnRemove(self.leftweaponmortarlight)
		
		self.rightweapon = ents.Create("env_sprite") 
		self.rightweapon:SetKeyValue("model","cptbase/sprites/glow01.spr") 
		self.rightweapon:SetKeyValue("rendermode","5") 
		self.rightweapon:SetKeyValue("rendercolor","255 80 0") 
		self.rightweapon:SetKeyValue("scale","0.4") 
		self.rightweapon:SetKeyValue("spawnflags","1") 
		self.rightweapon:SetParent(self) 
		self.rightweapon:Fire("SetParentAttachment","rightweapon",0) 
		self.rightweapon:Spawn() 
		self.rightweapon:Activate() 
		self:DeleteOnRemove(self.rightweapon) 
		
		self.rightweaponlight = ents.Create("light_dynamic")
		self.rightweaponlight:SetKeyValue("brightness", "1")
		self.rightweaponlight:SetKeyValue("distance", "150")
		self.rightweaponlight:SetLocalPos(self:GetPos())
		self.rightweaponlight:SetLocalAngles( self:GetAngles() )
		self.rightweaponlight:Fire("Color", "255 80 0")
		self.rightweaponlight:SetParent(self)
		self.rightweaponlight:Spawn()
		self.rightweaponlight:Activate()
		self.rightweaponlight:Fire("SetParentAttachment","leftweapon")
		self.rightweaponlight:Fire("TurnOn", "", 0)
		self:DeleteOnRemove(self.rightweaponlight)
		
		self.rightweaponmortar = ents.Create("env_sprite") 
		self.rightweaponmortar:SetKeyValue("model","cptbase/sprites/glow01.spr") 
		self.rightweaponmortar:SetKeyValue("rendermode","5") 
		self.rightweaponmortar:SetKeyValue("rendercolor","255 80 0") 
		self.rightweaponmortar:SetKeyValue("scale","0.4") 
		self.rightweaponmortar:SetKeyValue("spawnflags","1") 
		self.rightweaponmortar:SetParent(self) 
		self.rightweaponmortar:Fire("SetParentAttachment","rightweaponmortar",0) 
		self.rightweaponmortar:Spawn() 
		self.rightweaponmortar:Activate() 
		self:DeleteOnRemove(self.rightweaponmortar) 
		
		self.rightweaponmortarlight = ents.Create("light_dynamic")
		self.rightweaponmortarlight:SetKeyValue("brightness", "1")
		self.rightweaponmortarlight:SetKeyValue("distance", "150")
		self.rightweaponmortarlight:SetLocalPos(self:GetPos())
		self.rightweaponmortarlight:SetLocalAngles( self:GetAngles() )
		self.rightweaponmortarlight:Fire("Color", "255 80 0")
		self.rightweaponmortarlight:SetParent(self)
		self.rightweaponmortarlight:Spawn()
		self.rightweaponmortarlight:Activate()
		self.rightweaponmortarlight:Fire("SetParentAttachment","rightweaponmortar")
		self.rightweaponmortarlight:Fire("TurnOn", "", 0)
		self:DeleteOnRemove(self.rightweaponmortarlight)
		
		self.chestplate = ents.Create("env_sprite") 
		self.chestplate:SetKeyValue("model","cptbase/sprites/glow01.spr") 
		self.chestplate:SetKeyValue("rendermode","5") 
		self.chestplate:SetKeyValue("rendercolor","255 80 0") 
		self.chestplate:SetKeyValue("scale","0.6") 
		self.chestplate:SetKeyValue("spawnflags","1") 
		self.chestplate:SetParent(self) 
		self.chestplate:Fire("SetParentAttachment","chestplate_center_att",0) 
		self.chestplate:Spawn() 
		self.chestplate:Activate() 
		self:DeleteOnRemove(self.chestplate) 
	end
end

function ENT:SetDefault()
	self:StopParticles()
	self.UsesFlamethrower = false
	self:StopSound("flame_thrower_loop")
	ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("leftweapon")) 
	ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rightweapon")) 
	if GetConVar("d2016_deco"):GetInt() > 0 then
		ParticleEffectAttach("mancubus_platesmoke",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("chestplate_center_att"))
	end
	if GetConVar("d2016_deco"):GetInt() == 2 then
		ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("leftweaponmortar"))
		ParticleEffectAttach("mancubus_cannonparticle",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rightweaponmortar"))
	end
end

function ENT:OnThink()
	if not self:GetEnemy() then self.tbl_Animations["Run"] = {"walk_forward"} end
		if self.NextIdleSound <= CurTime() then
			self.NextIdleSound = CurTime() + math.random(20,120)*0.1
			sound.Play("mancubus/mono_vo_mancubus_idle".. math.random(1,3) ..".ogg",self:GetPos())
		end
		
	if self.IsPossessed then
	if not (self:GetCurrentAnimation() == "melee_shootdown") then
	self:LookAtPosUseBone("spine",self:Possess_AimTarget(),30,50,18,0.4)
	self:LookAtPosUseBone("spine3",self:Possess_AimTarget(),20,50,18,0.4)
	end
	self:LookAtPosUseBone("head",self:Possess_AimTarget(),20,40,18,0.2)
	else
	if self:GetEnemy() ~= nil then
	if not (self:GetCurrentAnimation() == "melee_shootdown") then
	self:LookAtPosUseBone("spine",self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter(),30,50,18,0.4)
	self:LookAtPosUseBone("spine3",self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter(),20,50,18,0.4)
	end
	self:LookAtPosUseBone("head",self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter(),20,40,18,0.2)
	end
	end
	
	if self.UsesFlamethrower == true then
		self:Attack(self:GetPos()+self:OBBCenter(),90,400,5)
	end
end

function ENT:HandleSchedules(enemy,dist,nearest,disp,time)
	if self.IsPossessed then return end
	
	if dist < self.MAttack.Normal.Dist and (self:CheckAngleTo(enemy:GetPos()).y < 60 and self:CheckAngleTo(enemy:GetPos()).y > -60) and self:CanPerformProcess() == true then
		self:PlayActivity("melee_forward") 
		elseif dist < 400 and (self:CheckAngleTo(enemy:GetPos()).y < 60 and self:CheckAngleTo(enemy:GetPos()).y > -60) and self:CanPerformProcess() == true then
			local att = math.random(1,5)
			if att == 1 then
				sound.Play("mancubus/sfx_mancubus_overheat_purge".. math.random(1,3) ..".ogg",self:GetPos()) 
				self:ResetManipulateBoneAngles("spine",enemy:GetPos(),30,50,18,0.4) 
				self:ResetManipulateBoneAngles("spine3",enemy:GetPos(),20,50,18,0.4) 
				self:PlayActivity("melee_shootdown")
			elseif att == 5 then
				sound.Play("mancubus/mancubus_flamethrower_start.ogg",self:GetPos())
				self:PlayActivity("flamethrow_forward")
			end
	end
	
	if dist < self.RAttack.Dist and self:CanPerformProcess() == true and self:Visible(enemy) then
		if math.random(1,20) == 1 and self:GetCurrentAnimation() == "walk_forward" and dist > 200 then
			self.tbl_Animations["Run"] = {"walk_forward_shoot"}
		end
		
		if self:CheckAngleTo(enemy:GetPos()).y < 60 and self:CheckAngleTo(enemy:GetPos()).y > -60 and self.RAttack.Next < CurTime() and self:GetCurrentAnimation() ~= "walk_forward_shoot" then
			self:PlayActivity(self:SelectFromTable({"shoot","shoot_rapid"}))  self.RAttack.Next = CurTime() + (math.random(50,80)*0.1) 
		elseif self:CheckAngleTo(enemy:GetPos()).y < -90 then
			self:PlayActivity("turn_90_right")  self.RAttack.Next = CurTime() + (math.random(15,18)*0.1) 
		elseif self:CheckAngleTo(enemy:GetPos()).y > 90 then
			self:PlayActivity("turn_90_left")  self.RAttack.Next = CurTime() + (math.random(15,18)*0.1) 
		end
	end
	
	if self.s_CState ~= "idle" and self:GetEnemy() == nil then
		self.s_CState = "idle"
	end
	
	if self.s_CState == "idle" then
		if self:GetEnemy() ~= nil then
			self.CanWander = true
			self:PlayActivity("taunt")
			self.s_CState = "infight"
			return
		end
	elseif self.s_CState == "infight" then
	self:ChaseEnemy()
	end
	
end

function ENT:OnDamage_Pain(dmg,dmginfo,hitbox)
	local _Damage = dmg:GetDamage() 
	local _Pos = dmg:GetDamagePosition() 
	local _Type = dmg:GetDamageType() 
	if (math.random(1,10) == 1 or (_Damage > 20 and math.random(1,5) == 1) or (_Damage > 50 and math.random(1,3) == 1) or (_Damage > 250 and math.random(1,2) == 1) or (_Type == DMG_CRUSH or _Type == DMG_VEHICLE or _Type == DMG_BLAST or _Type == DMG_BLAST_SURFACE)) and self.NextPain < CurTime() then
		self.NextPain = CurTime() + math.random(70,125)*0.1
		self:SetDefault()
		self:PlayActivity(self:SelectFromTable({"pain_chest_forward","pain_head_forward"}))
	end
	return true
end

function ENT:HandleEvents(...)
	local event = select(1,...) 
	local arg1 = select(2,...) 
	if(event == "emit") then
		self:SetDefault()
		if(arg1 == "attack") then
			self:Attack(self:GetPos()+self:OBBCenter(),80,150,40)
		elseif(arg1 == "shockwave") then
			self:Attack(self:GetPos()+self:OBBCenter(),180,300,30)
			ParticleEffect("mancubus_shockwave",self:GetPos(),self:GetAngles(),self)
		elseif(arg1 == "step") then
			sound.Play("stalker/large_step"..math.random(1,2)..".mp3",self:GetPos())
		elseif(arg1 == "pain") then
			sound.Play("mancubus/mono_vo_mancubus_pain".. math.random(1,3) ..".ogg",self:GetPos())
		elseif(arg1 == "roar") then
			sound.Play("mancubus/mono_vo_mancubus_sight".. math.random(1,3) ..".ogg",self:GetPos())
		elseif(arg1 == "flames_start") then
			self:EmitSound("mancubus_flamethrower_loop")
			self:SetDefault()
			self.UsesFlamethrower = true
			ParticleEffectAttach("mancubus_flamethrower",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("leftweapon"))
			ParticleEffectAttach("mancubus_flamethrower",PATTACH_POINT_FOLLOW,self,self:LookupAttachment("rightweapon"))
		elseif(arg1 == "flames_end") then
			sound.Play("mancubus/mancubuus_flamethrower_stop.ogg",self:GetPos())
		elseif(arg1 == "shoot_left") then
			if self:GetEnemy() ~= nil then
				self:RangeAttack_Normal("leftweapon_att")
				self.tbl_Animations["Run"] = {"walk_forward"}
			else
				self.tbl_Animations["Run"] = {"walk_forward"}
				self:PlayActivity("cancel_shoot")
			end
		elseif(arg1 == "shoot_right") then
			if self:GetEnemy() ~= nil then
				self:RangeAttack_Normal("rightweapon_att")
			else
				self.tbl_Animations["Run"] = {"walk_forward"}
				self:PlayActivity("cancel_shoot")
			end
		end
	end
	return true
end

function ENT:RangeAttack_Normal(att)
	self:StopParticles()
	sound.Play("mancubus/ai_mancubus_weapon_rocket_fire".. math.random(1,3) ..".ogg",self:GetPos()) 
	local ball = ents.Create("obj_proj_mancubusball")
	ball:SetPos(self:GetAttachment(self:LookupAttachment(att)).Pos)
	ball:SetOwner(self)
	ball:Spawn()
	ball:Activate()
	local phys = ball:GetPhysicsObject()
	if IsValid(phys) then
		if self.IsPossessed then
			phys:SetVelocity((self:Possess_AimTarget() - ball:GetPos()):GetNormal() *1300 +VectorRand()*math.Rand(0,25))
		else
			phys:SetVelocity(((self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter()) -ball:GetPos() +self:GetEnemy():GetVelocity() *0.15):GetNormal() *1300 +VectorRand()*math.Rand(0,25))
		end
	end
end
