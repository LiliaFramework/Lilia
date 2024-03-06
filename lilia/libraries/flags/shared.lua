
lia.flag = lia.flag or {}

lia.flag.list = lia.flag.list or {}

function lia.flag.add(flag, desc, callback)
    lia.flag.list[flag] = {
        desc = desc,
        callback = callback
    }
end

