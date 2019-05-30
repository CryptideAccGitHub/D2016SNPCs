ENT.Base = "npc_d2016_gorenest_base"
ENT.Type = "ai"
ENT.PrintName = "Gore Nest (Medium)"
ENT.Author = "REXMaster"
ENT.Contact = "Me" 
ENT.Purpose = ""
ENT.Instructions = "Rip and tear"
ENT.Information	= ""  
ENT.Category = "DOOM (2016)"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (CLIENT) then
local Name = "Gore Nest (Medium)"
local LangName = "npc_d2016_gorenest_medium"
language.Add(LangName, Name)
killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
language.Add("#"..LangName, Name)
killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end
