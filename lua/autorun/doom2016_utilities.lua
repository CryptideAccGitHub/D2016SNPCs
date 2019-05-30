local ENTm = FindMetaTable("Entity")

function ENTm:dCDamage(pos,damage,dist,angle,dmgtype)
	local _pos = pos or self:GetPos() +self:OBBCenter() +self:GetForward() *20
	local _dmg = damage or 20
	local _dist = dist or 100
	local _angle = angle or 90
	local _dmgtype = dmgtype or DMG_SLASH
	local diff = math.Round(GetConVar("cpt_aidifficulty"):GetInt())
	local didhit = false
	local alreadydidhit = false
	if diff == 0 then diff = 1 end
	for _,v in ipairs(ents.FindInSphere(_pos,_dist)) do
		if !IsValid(v) or v == self or v.Faction == "FACTION_DOOM2016" then return end
		if self:FindInCone(v,_angle) then
			if v:GetClass() != "npc_turret_floor" then
				local dmg = DamageInfo()
				if v:IsPlayer() then
					v:ViewPunch(Angle(math.random(-1,1)*damage,math.random(-1,1)*damage,math.random(-1,1)*damage))
					dmg:SetDamage(_dmg*(diff/2))
				elseif v:IsNPC() then
					dmg:SetDamage(_dmg*(diff/2)*3)
				end
				dmg:SetAttacker(self)
				dmg:SetInflictor(self)
				dmg:SetDamagePosition(v:NearestPoint(self:GetPos()+self:OBBCenter()))
				dmg:SetDamageType(_dmgtype)
				v:TakeDamageInfo(dmg)
			else
				ent:Fire("selfdestruct","",0)
				ent:GetPhysicsObject():ApplyForceCenter(self:GetForward()*1000)
			end
		didhit = true
		end
		if alreadydidhit == false then
			if didhit == true and self.CurrentHitSound ~= nil then
				alreadydidhit = true
				self:EmitSound(self.CurrentHitSound)
			elseif didhit == false and self.CurrentMissSound ~= nil then
				alreadydidhit = true
				self:EmitSound(self.CurrentMissSound)
			end
		end
	end
end

function ENTm:dCCheck(dist,dest)
	local tracedata = {}
	tracedata.start = self:GetPos()+self:OBBCenter()
	tracedata.endpos = self:GetPos()+self:OBBCenter()+(dest*dist)
	tracedata.filter = {self}
	local tr = util.TraceLine(tracedata)
	if tr.Hit then
		return false
	else
		return true
	end
end

function ENTm:dCAngleTo(pos)
	local targetang = (pos - self:GetPos() +self:OBBCenter()):Angle()
	local _return = {["x"] = math.AngleDifference(targetang.x,self:GetAngles().x),["y"] = math.AngleDifference(targetang.y,self:GetAngles().y)}
	return _return
end

function ENTm:dCResetBoneAngles(bone)
local _bone = self:LookupBone(bone)
self:ManipulateBoneAngles(_bone,Angle(-self:GetManipulateBoneAngles(_bone).x,-self:GetManipulateBoneAngles(_bone).y,0) )
end

function ENTm:dCLook(bone, pos, limitx, limity, speed, mul)
	local mul = mul or 1
	local _bone = self:LookupBone(bone)
	local selfpos = self:GetPos() +self:OBBCenter()
	local selfang = self:GetAngles()
	local targetang = (pos - selfpos):Angle()
	local x = math.AngleDifference(targetang.x,selfang.x)*mul
	local y = math.AngleDifference(targetang.y,selfang.y)*mul
	local returnx = Lerp(0.5,self:GetManipulateBoneAngles(_bone).x,math.Approach(self:GetManipulateBoneAngles(_bone).x,x,speed))
	local returny = Lerp(0.5,self:GetManipulateBoneAngles(_bone).y,math.Approach(self:GetManipulateBoneAngles(_bone).y,y,speed))
	
	if (x > -limitx and x < limitx) and (y > -limity and y < limity) then
		if self:GetManipulateBoneAngles(_bone).x == returnx and self:GetManipulateBoneAngles(_bone).y == returny then return end
		self:ManipulateBoneAngles(_bone,Angle(returnx,returny,0) )
	end
end

function ENTm:dGib(dmg)
	for _,v in ipairs(self.GoreBones) do
		if math.random(1,self.GoreChance) == 1 then
			self.gib = ents.Create("obj_doom_cgore")
			self.gib:SetPos(self:GetBonePosition(self:LookupBone(v)))
			self.gib:SetOwner(self)
			self.gib:Spawn()
			self.gib:SetModelScale(self.GibScale)
			--ParticleEffect("blood_impact_red_big",self:GetPos()+self:OBBCenter(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
			self.gib:Activate()
			local phys = self.gib:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-80,80),math.Rand(-80,80),math.Rand(-80,80)) +self:GetUp() * 200 + dmg:GetDamageForce():GetNormalized()*math.random(290,390))
			end
		end
	end
	self.HasDeathRagdoll = false
	self:Remove()
end

function ENTm:dSpawnLostSoulGib(dmg)
	self.gib = ents.Create("obj_doom_lostsoulgib")
	self.gib:SetPos(self:GetPos())
	self.gib:SetAngles(self:GetAngles())
	self.gib:SetOwner(self)
	self.gib:Spawn()
	--ParticleEffect("blood_impact_red_big",self:GetPos()+self:OBBCenter(),Angle(math.random(0,360),math.random(0,360),math.random(0,360)),false)
	self.gib:Activate()
	local phys = self.gib:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(Vector(math.Rand(-80,80),math.Rand(-80,80),math.Rand(-80,80)) +self:GetUp() * 50 + dmg:GetDamageForce():GetNormalized()*math.random(590,690))
		phys:AddAngleVelocity(Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)))
	end
	self.HasDeathRagdoll = false
	self:Remove()
end