concommand.Add("lia_selectwep", function(client, _, arguments) client:SelectWeapon(arguments[1] or ("lia_fists" or "lia_keys")) end)
