ENT.Table = {
name = 
model = "models/error.mdl",
}

--Custom setting up
function ENT:CustomOnInitialize() return end

function ENT:Initialize()
self:SetModel(self.Table["model"])
self.Table["model"] = "var"
self:CustomOnInitialize()
end
