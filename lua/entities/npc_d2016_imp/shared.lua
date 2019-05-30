ENT.Base = "npc_cpt_base"
ENT.Type = "ai"
ENT.PrintName = "Imp"
ENT.Author = "REXMaster"
ENT.Contact = "Me" 
ENT.Purpose = "Imp SNPC from DOOM (2016)"
ENT.Instructions = "Rip and tear"
ENT.Information	= "Small enemy, easily killable and not dangerous."  
ENT.Category = "DOOM (2016)"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (CLIENT) then
local Name = "Imp"
local LangName = "npc_d2016_imp"
language.Add(LangName, Name)
killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end