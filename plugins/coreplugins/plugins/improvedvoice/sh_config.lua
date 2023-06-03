PLUGIN.WhitelistedProps = {"models/props_c17/fence01a.mdl", "models/props_c17/fence01b.mdl", "models/props_c17/fence02a.mdl", "models/props_c17/fence02b.mdl", "models/props_c17/fence03a.mdl", "models/props_c17/fence04a.mdl", "models/props_c17/gate_door01a.mdl", "models/props_c17/gate_door02a.mdl", "models/props_building_details/Storefront_Template001a_Bars.mdl", "models/props_wasteland/exterior_fence001a.mdl", "models/props_wasteland/exterior_fence001b.mdl", "models/props_wasteland/exterior_fence002a.mdl", "models/props_wasteland/exterior_fence002b.mdl", "models/props_wasteland/exterior_fence002c.mdl", "models/props_wasteland/exterior_fence002d.mdl", "models/props_wasteland/exterior_fence002e.mdl", "models/props_wasteland/exterior_fence003a.mdl", "models/props_wasteland/exterior_fence003b.mdl", "models/props_wasteland/interior_fence001a.mdl", "models/props_wasteland/interior_fence001b.mdl", "models/props_wasteland/interior_fence001c.mdl", "models/props_wasteland/interior_fence001d.mdl", "models/props_wasteland/interior_fence001e.mdl", "models/props_wasteland/interior_fence001g.mdl", "models/props_wasteland/interior_fence002a.mdl", "models/props_wasteland/interior_fence002b.mdl", "models/props_wasteland/interior_fence002c.mdl", "models/props_wasteland/interior_fence002d.mdl", "models/props_wasteland/interior_fence002e.mdl", "models/props_wasteland/interior_fence002f.mdl", "models/props_wasteland/interior_fence003a.mdl", "models/props_wasteland/interior_fence003b.mdl", "models/props_wasteland/interior_fence003d.mdl", "models/props_wasteland/interior_fence003e.mdl", "models/props_wasteland/interior_fence003f.mdl", "models/props_wasteland/interior_fence004a.mdl", "models/props_wasteland/interior_fence004b.mdl", "models/props_wasteland/prison_archgate001.mdl", "models/props_wasteland/prison_archgate002a.mdl", "models/props_wasteland/prison_archgate002b.mdl", "models/props_wasteland/prison_archgate002c.mdl", "models/props_wasteland/prison_archwindow001.mdl", "models/props_wasteland/prison_celldoor001a.mdl", "models/props_wasteland/prison_celldoor001b.mdl", "models/props_wasteland/prison_cellwindow002a.mdl", "models/props_wasteland/prison_gate001c.mdl", "models/props_wasteland/prison_gate001b.mdl", "models/props_wasteland/prison_gate001a.mdl", "models/props_wasteland/prison_slidingdoor001a.mdl", "models/props_wasteland/kitchen_shelf001a.mdl", "models/props_wasteland/kitchen_shelf002a.mdl", "models/props_interiors/elevatorshaft_door01a.mdl", "models/props_interiors/radiator01a.mdl", "models/props_interiors/pot01a.mdl", "models/props_interiors/pot02a.mdl", "models/props_interiors/furniture_lamp01a.mdl", "models/props_interiors/furniture_desk01a.mdl", "models/props_interiors/furniture_couch02a.mdl", "models/props_interiors/furniture_couch01a.mdl"}

lia.config.add("3DVoiceEnabled", false, "Enable 3D Voice System?", nil, {
    category = "3DVoice"
})

lia.config.add("3DVoiceRadius", 325, "Maximum Distance a player can be heard from.", nil, {
    data = {
        min = 50,
        max = 500
    },
    category = "3DVoice"
})

lia.config.add("3DVoiceRefreshRate", 2, "Amount of seconds between checks to if the players voice should be heard. > 3 or 4 may be too much, < 2 can cause lag.", nil, {
    form = "Float",
    data = {
        min = 0.5,
        max = 10
    },
    category = "3DVoice"
})

lia.config.add("3DVoiceDebugMode", false, "Enable 3D Voice System Debug", nil, {
    category = "3DVoice"
})