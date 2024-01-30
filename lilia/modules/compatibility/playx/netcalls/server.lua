---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("MediaRequest", function(client, url)
    if not client:hasFlag("m") and not client:IsAdmin() then
        PlayX.SendError(client, "You do not have permission to use the player")
        return
    end

    local result, err = PlayX.OpenMedia("", url, 0, false, true, false)
    if not result then PlayX.SendError(client, err) end
end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
