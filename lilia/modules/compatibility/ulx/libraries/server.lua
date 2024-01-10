
function ULXCompatibility:InitializedModules()
    MsgC(Color(255, 0, 0), "WE DO NOT RECOMMEND THE USE OF ULX AS IT MAY CREATE PERFOMANCE ISSUES!" .. "\n")
end


hook.Remove("PlayerSay", "ULXMeCheck")

