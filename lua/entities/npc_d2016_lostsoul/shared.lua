ENT.Base = "npc_cpt_base"
ENT.Type = "ai"
ENT.PrintName = ""
ENT.Author = "REXMaster"
ENT.Contact = "Me" 
ENT.Purpose = ""
ENT.Instructions = "Rip and tear"
ENT.Information	= ""  
ENT.Category = "DOOM (2016)"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (CLIENT) then
local Name = "Lost SOul"
local LangName = "npc_d2016_lostsoul"
language.Add(LangName, Name)
killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end
