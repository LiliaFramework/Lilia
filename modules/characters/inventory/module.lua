MODULE.name = "Inventroy"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds a weight inventory type."
lia.config.add("invWeightUnit", "Inventory Weight Unit", "KG", nil, {
    desc = "Selects the unit of measurement for item weights in the inventory (e.g., kilograms, pounds).",
    category = "Inventory",
    type = "Table",
    options = {"KG", "LB", "G", "OZ"}
})

lia.config.add("invMaxWeight", "Inventory Max Weight", 150, nil, {
    desc = "Defines the maximum total weight that a player’s inventory can hold.",
    category = "Inventory",
    type = "Int",
    min = 50,
    max = 10000
})

lia.config.add("invType", "Inventory Type", "gridinv", nil, {
    desc = "Determines whether the inventory uses a grid-based or weight-based storage system.",
    category = "Inventory",
    type = "Table",
    options = {"gridinv", "weight"}
})

lia.config.add("invRatio", "Inventory Ratio", 2.0, nil, {
    desc = "Specifies the conversion ratio between item grid size and weight for weight-based inventory calculations.",
    category = "Inventory",
    type = "Float",
    min = 0.1,
    max = 10,
    decimals = 2
})

function MODULE:GetDefaultInventoryType()
    return lia.config.get("invType", "gridinv")
end