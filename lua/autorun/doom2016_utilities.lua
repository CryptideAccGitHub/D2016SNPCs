local ENTm = FindMetaTable("Entity")

-- Default CPTBase DoDamage function with additional parameters

function ENTm:Attack(pos,angle,dist,dmg,dmgtype,force,viewPunch,OnHit)
	local pos = pos or self:GetPos() +self:OBBCenter() +self:GetForward() *20
	local angle = angle or 75
	local dmgtype = dmgtype or DMG_SLASH
	local posSelf = self:GetPos()
	local center = posSelf +self:OBBCenter()
	local didhit
	local tblhit = {}
	local tblprops = {}
	local hitpos = Vector(0,0,0)
	for _,ent in ipairs(ents.FindInSphere(pos,dist)) do
		if ent:IsValid() && self:Visible(ent) then
			if self.AllowPropDamage then
				if table.HasValue(self.tbl_AttackablePropNames,ent:GetClass()) then
					table.insert(tblprops,ent)
				end
				self:AttackProps(tblprops,dmg,dmgtype,force,OnHit)
			end
			if ((ent:IsNPC() && ent != self && ent:GetModel() != self:GetModel()) || (ent:IsPlayer() && ent:Alive())) && (self:GetForward():Dot(((ent:GetPos() +ent:OBBCenter()) -pos):GetNormalized()) > math.cos(math.rad(angle))) then
				if self.CheckDispositionOnAttackEntity && self:Disposition(ent) == D_LI then return end
				if self:CustomChecksBeforeDamage(ent) then
					if force then
						local forward,right,up = self:GetForward(),self:GetRight(),self:GetUp()
						force = forward *force.x +right *force.y +up *force.z
					end
					didhit = true
					local dmgpos = ent:NearestPoint(center)
					local dmginfo = DamageInfo()
					if self.HasMutated == true && (self.MutationType == "damage" or self.MutationType == "both") then
						dmg = math.Round(dmg *1.65)
					end
					if dmgtype != DMG_FROST then
						local finaldmg = AdaptCPTBaseDamage(dmg)
						dmginfo:SetDamage(finaldmg)
						dmginfo:SetAttacker(self)
						dmginfo:SetInflictor(self)
						dmginfo:SetDamageType(dmgtype)
						dmginfo:SetDamagePosition(dmgpos)
						hitpos = dmgpos
						if force then
							dmginfo:SetDamageForce(force)
						end
						if(OnHit) then
							OnHit(ent,dmginfo)
						end
						table.insert(tblhit,ent)
						if self.CanRagdollEnemies then
							if math.random(1,self.RagdollEnemyChance) == 1 then
								self:RagdollEnemy(dist,self.RagdollEnemyVelocity,tblhit)
							end
						end
						ent:TakeDamageInfo(dmginfo)
						if ent:GetClass() == "npc_turret_floor" then
							ent:Fire("selfdestruct","",0)
							ent:GetPhysicsObject():ApplyForceCenter(self:GetForward() *10000)
						end
					else
						util.DoFrostDamage(dmg,ent,self)
					end
				end
			end
		end
	end
	if didhit == true then
		self:OnHitEntity(tblhit,hitpos)
	else
		self:OnMissEntity()
	end
	self:OnDoDamage(didhit,tblhit,hitpos)
	table.Empty(tblhit)
end

-- It checks angle to position

function ENTm:CheckAngleTo(pos)
	local selfpos = self:GetPos() +self:OBBCenter()
	local selfang = self:GetAngles()
	local targetang = (pos - selfpos):Angle()
	local _x = math.AngleDifference(targetang.x,selfang.x)
	local _y = math.AngleDifference(targetang.y,selfang.y)
	local _return = {["x"] = _x,["y"] = _y}
	return _return
end

--Because idk how to make poseparameters

function ENTm:LookAtPosUseBone(bone, pos, limitx, limity, speed, mul)
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
	self:ManipulateBoneAngles(_bone,Angle(returnx,returny,0) )
	end
end
