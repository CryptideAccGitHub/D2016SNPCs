ENT.Type 			= "anim"
ENT.Base 			= "obj_cpt_base"
ENT.PrintName		= "plasma_ball"
ENT.Author			= "REXMaster"

ENT.Category = "D4TEST"
ENT.Spawnable = true

function ENT:Draw()
render.SetMaterial(Material("effects/doom/plasma_ball"))
render.DrawSprite(self:GetPos(), 10, 10, Color( 255, 50, 50, 2550 ))
render.SetMaterial(Material("particle/particle_glow_04_additive"))
render.DrawSprite(self:GetPos(), 50, 50, Color( 255, 5, 5, 20 ))
end