
function lia.flag.onSpawn(client)
    if client:getChar() then
        local flags = client:getChar():getFlags()
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info and info.callback then
                info.callback(client, true)
            end
        end
    end
end
