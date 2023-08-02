local ITEM = lia.meta.item

function ITEM:print(detail)
    if detail == true then
        print(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        print(Format("%s[%s]", self.uniqueID, self.id))
    end
end

function ITEM:printData()
    self:print(true)
    print("ITEM DATA:")

    for k, v in pairs(self.data) do
        print(Format("[%s] = %s", k, v))
    end
end

function ITEM:Print(detail)
    if detail == true then
        print(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        print(Format("%s[%s]", self.uniqueID, self.id))
    end
end

function ITEM:PrintData()
    self:Print(true)
    print("ITEM DATA:")

    for k, v in pairs(self.data) do
        print(Format("[%s] = %s", k, v))
    end
end
