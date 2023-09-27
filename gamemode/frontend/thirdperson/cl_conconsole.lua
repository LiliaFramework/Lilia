--------------------------------------------------------------------------------------------------------
concommand.Add(
    "lia_tp_toggle",
    function()
        local setTP = GetConVar("lia_tp_enabled"):GetInt() == 0 and 1 or 0
        GetConVar("lia_tp_enabled"):SetInt(setTP)
    end
)
--------------------------------------------------------------------------------------------------------