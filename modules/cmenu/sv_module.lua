----------------------------------------------------------------------------------------------
local netcalls = {"cmenu", "liaApproveSearch", "liaRequestSearch", "blindfold", "gag_player", "vehicle_usage", "cmenu_tying", "FF", "liaRequestID", "liaApproveID"}
----------------------------------------------------------------------------------------------
for k, v in pairs(netcalls) do
    util.AddNetworkString(v)
end
----------------------------------------------------------------------------------------------