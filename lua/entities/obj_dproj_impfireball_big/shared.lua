ENT.Type 			= "anim"
ENT.Base 			= "obj_cpt_base"
ENT.PrintName		= ""
ENT.Author			= "REXMaster"

ENT.Category = "D4TEST"
ENT.Spawnable = true

function ENT:Draw()
render.SetMaterial(Material("effects/doom/fireball"))
render.DrawSprite(self:GetPos(), 25, 25, Color( 255, 255, 255, 2550 ))
render.SetMaterial(Material("particle/particle_glow_04_additive"))
render.DrawSprite(self:GetPos(), 250, 250, Color( 255, 100, 5, 60 ))
end