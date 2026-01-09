local uploads = WireLib.RegisterPlayerTable()
local upload_ents = WireLib.RegisterPlayerTable()
net.Receive("wire_expression2_upload", function(len, ply)
    local toent = Entity(net.ReadUInt(16))
    local numpackets = net.ReadUInt(16)
    if not IsValid(toent) or toent:GetClass() ~= "gmod_wire_expression2" then
        if uploads[ply] then
            uploads[ply] = nil
            upload_ents[ply] = nil
            WireLib.AddNotify(ply, "Invalid Expression chip specified. Upload aborted.", NOTIFY_ERROR, 7, NOTIFYSOUND_DRIP3)
        end
        return
    end

    if not (ply:IsDonator() or ply:IsAdmin()) then
        WireLib.AddNotify(ply, "You are not allowed to upload to the target Expression chip. Upload aborted.", NOTIFY_ERROR, 7, NOTIFYSOUND_DRIP3)
        return
    end

    if upload_ents[ply] ~= toent then uploads[ply] = nil end
    upload_ents[ply] = toent
    if not uploads[ply] then uploads[ply] = {} end
    uploads[ply][#uploads[ply] + 1] = net.ReadData(net.ReadUInt(32))
    if numpackets <= #uploads[ply] then
        local datastr = E2Lib.decode(table.concat(uploads[ply]))
        uploads[ply] = nil
        local ok, ret = pcall(WireLib.von.deserialize, datastr)
        if not ok then
            WireLib.AddNotify(ply, "Expression 2 upload failed! Error message:\n" .. ret, NOTIFY_ERROR, 7, NOTIFYSOUND_DRIP3)
            print("Expression 2 upload failed! Error message:\n" .. ret)
            return
        end

        local code = ret[1]
        local includes = {}
        for k, v in pairs(ret[2]) do
            includes[k] = v
        end

        local filepath = ret[3]
        if ply ~= toent.player and toent.player:GetInfoNum("wire_expression2_friendwrite", 0) ~= 1 then code = "@disabled for security reasons. Remove this line (Ctrl+Shift+L) and left-click the chip to enable. 'wire_expression2_friendwrite 1' disables security.\n" .. code end
        toent:Setup(code, includes, nil, nil, filepath)
    end
end)
