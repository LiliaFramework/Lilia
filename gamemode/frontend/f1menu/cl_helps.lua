--------------------------------------------------------------------------------------------------------
hook.Add(
    "BuildHelpMenu",
    "liaBasicHelp",
    function(tabs)
        tabs["commands"] = function(node)
            local body = ""
            for k, v in SortedPairs(lia.command.list) do
                local allowed = false
                if v.adminOnly and not LocalPlayer():IsAdmin() or v.superAdminOnly and not LocalPlayer():IsSuperAdmin() then continue end
                if v.group then
                    if istable(v.group) then
                        for _, v1 in pairs(v.group) do
                            if LocalPlayer():IsUserGroup(v1) then
                                allowed = true
                                break
                            end
                        end
                    elseif LocalPlayer():IsUserGroup(v.group) then
                        return true
                    end
                else
                    allowed = true
                end

                if allowed then body = body .. "<h2>/" .. k .. "</h2><strong>Syntax:</strong> <em>" .. v.syntax .. "</em><br /><br />" end
            end
            return body
        end

        tabs["flags"] = function(node)
            local body = [[<table border="0" cellspacing="8px">]]
            for k, v in SortedPairs(lia.flag.list) do
                local icon
                if LocalPlayer():getChar():hasFlags(k) then
                    icon = [[<img src="asset:/garrysmod/materials/icon16/tick.png" />]]
                else
                    icon = [[<img src="asset:/garrysmod/materials/icon16/cross.png" />]]
                end

                body = body .. Format([[
                <tr>
                    <td>%s</td>
                    <td><b>%s</b></td>
                    <td>%s</td>
                </tr>
            ]], icon, k, v.desc)
            end
            return body .. "</table>"
        end

        tabs["modules"] = function(node)
            local body = ""
            for _, v in SortedPairsByMemberValue(lia.module.list, "name") do
                body = (body .. [[
                <p>
                    <span style="font-size: 22;"><b>%s</b><br /></span>
                    <span style="font-size: smaller;">
                    <b>%s</b>: %s<br />
                    <b>%s</b>: %s
            ]]):format(v.name or "Unknown", L"desc", v.desc or L"noDesc", L"author", lia.module.namecache[v.author] or v.author)
                if v.version then body = body .. "<br /><b>" .. L"version" .. "</b>: " .. v.version end
                body = body .. "</span></p>"
            end
            return body
        end
    end
)
--------------------------------------------------------------------------------------------------------