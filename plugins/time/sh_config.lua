lia.config.add("TimeOnScreenEnabled", false, "Enable Time On Screen?", nil, {
    category = "Time"
})

lia.config.add("SchemaYear", 2023, "Year that should appear on the HUD.", nil, {
    data = {
        min = 1,
        max = 5000
    },
    category = "Time"
})