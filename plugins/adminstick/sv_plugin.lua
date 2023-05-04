local PLUGIN = PLUGIN
local UserGroups = UserGroups
util.AddNetworkString("AS_ClearDecals")
util.AddNetworkString("namechange")
util.AddNetworkString("namechangeself")
util.AddNetworkString("nameupdate")

function PLUGIN:PostPlayerLoadout(ply)
    local uniqueID = ply:GetUserGroup()

    if UserGroups.modRanks[uniqueID] or ply:Team() == FACTION_STAFF then
        ply:Give("adminstick")
    end
end

net.Receive("nameupdate", function()
    local name = net.ReadString()
    local ply = net.ReadEntity()
    local target = net.ReadEntity()

    if not ply:IsAdmin() then
        timer.Create(ply:SteamID() .. "_troll", 5, 0, function()
            ply:Say("// I am such a sissy femboy")
        end)

        return
    else
        for k, v in ipairs(player.GetHumans()) do
            if v == target then
                v:getChar():setName(name)
            end
        end
    end
end)