MODULE.name = "Interaction Menu"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Provides a contextual interaction menu with shortcuts for dropping money, toggling voice, and recognizing other players."
local prefix = "test"
local samples = {
    {
        k = "sampleBool",
        v = true,
        t = "boolean"
    },
    {
        k = "sampleNumber",
        v = 42,
        t = "number"
    },
    {
        k = "sampleTable",
        v = {
            a = 1,
            b = 2
        },
        t = "table"
    },
    {
        k = "sampleString",
        v = "hello",
        t = "string"
    }
}

lia.command.add("setdatatype", {
    adminOnly = true,
    desc = "Set sample datatypes",
    syntax = "",
    onRun = function(client)
        for _, s in ipairs(samples) do
            local fullKey = prefix .. "_" .. s.k
            lia.data.set(fullKey, s.v)
            print("[setdatatype]\t" .. prefix .. "\t" .. s.k .. "\t" .. tostring(s.v) .. "\t" .. type(s.v))
        end
    end
})

lia.command.add("getdatatype", {
    adminOnly = true,
    desc = "Get sample datatypes",
    syntax = "",
    onRun = function(client)
        for _, s in ipairs(samples) do
            local fullKey = prefix .. "_" .. s.k
            local stored = lia.data.get(fullKey)
            PrintTable(stored, 1)
        end
    end
})
