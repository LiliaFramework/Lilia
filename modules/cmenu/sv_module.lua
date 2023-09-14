----------------------------------------------------------------------------------------------
local netcalls = {"cmenu", "liaApproveSearch", "liaRequestSearch", "blindfold", "gag_player", "vehicle_usage", "cmenu_tying", "Dragging::Update", "FF", "moneyprompt", "liaRequestID", "liaApproveID"}
----------------------------------------------------------------------------------------------
for k, v in pairs(netcalls) do
    util.AddNetworkString(v)
end
----------------------------------------------------------------------------------------------