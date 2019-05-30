ENT.Base = "npc_cpt_base"
ENT.PrintName = "Mancubus"
ENT.Author = "REXMaster"
ENT.Contact = "me" 
ENT.Purpose = ""
ENT.Instructions = "Rip and tear"
ENT.Category = "DOOM (2016)"

if (CLIENT) then
local Name = "Mancubus"
local LangName = "npc_d2016_mancubus"
language.Add(LangName, Name)
killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end