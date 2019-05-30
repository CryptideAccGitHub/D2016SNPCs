ENT.Base = "npc_cpt_base"
ENT.Type = "ai"
ENT.PrintName = "Possessed Soldier"
ENT.Author = "REXMaster"
ENT.Contact = "Me"
ENT.Purpose = "To die."
ENT.Instructions = "Rip and tear"
ENT.Information	= "Low-difficulty enemy, that can cause some problems."  
ENT.Category = "DOOM (2016)"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (CLIENT) then
local Name = "Possessed Soldier"
local LangName = "npc_d2016_soldier"
language.Add(LangName, Name)
killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end