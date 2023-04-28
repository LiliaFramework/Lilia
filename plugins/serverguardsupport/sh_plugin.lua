PLUGIN.name = "ServerGuard Support"
PLUGIN.author = "Leonheart#7476/Sample Name"
PLUGIN.desc = "Proper ServerGuard support"
-- We don't want the code below to run when ServerGuard isn't installed
if not serverguard then return end
-- ServerGuard's restrictions plugin was created to limit toolgun possibilies, but using it with Lilia
-- prevents any admins from using any of the tools, which is obviousbly a bug. Lilia utilizes flag system to limit toolgun usage,
-- so simply disabling this ServerGuard plugin will solve the problem.
serverguard.plugin:Toggle("restrictions", false)