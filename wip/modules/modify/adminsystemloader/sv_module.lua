local psaString = [[
/*------------------------------------------------------------

PUBLIC SERVICE ANNOUNCEMENT FOR LILIA SERVER OWNERS

There is a ENOURMOUS performance issue with ULX Admin mod.
Lilia Development Team found ULX is the main issue
that make the server freeze when player count is higher
than 20-30. The duration of freeze will be increased as you get
more players on your server.

If you're planning to open big server with ULX/ULib, we do
Development Team does not recommend your plan. Server Performance
Issues with ULX/Ulib on your server will be ignored and we're
going to consider that you're taking the risk of ULX/Ulib's
critical performance issue.

Lilia 1.2 only displays this message when you have ULX or
ULib on your server.

                               - Lilia Development Team

*/------------------------------------------------------------]]

function MODULE:OnLoaded()
    if not sam then
        -- admin stick no work :////////
        hook.Add("ModuleShouldLoad", "disableModules", function(id)
            if id == "adminstick" then return false end
        end)

        MsgC(Color(255, 0, 0), "AdminStick Couldn't Load Because SAM isn't Present! Please Tweak Such to fit your needs!")
    end

    if ulx or ULib then
        MsgC(Color(255, 0, 0), psaString .. "\n")
    end

    if serverguard then
        serverguard.module:Toggle("restrictions", false)
        MsgC(Color(255, 0, 0), "Loaded Serverguard Compatibility!")
    end
end