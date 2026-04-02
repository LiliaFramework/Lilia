ITEM.name = "@bagName"
ITEM.desc = "@bagDesc"
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "@storage"
ITEM.weight = -5
function ITEM:onRegistered()
    if isnumber(self.invWidth) and isnumber(self.invHeight) then self.weight = -1 * self.invWidth * self.invHeight end
end
