file = {
    "docs/hooks",
    "lilia",
    exclude = {"lilia/gamemode/core/libraries/thirdparty"}
}

dir = "docs/html"
project = "Lilia"
title = "Lilia Documentation"
no_space_before_args = true
style = "docs/css"
template = "docs/templates"
format = "markdown"
ignore = true
use_markdown_titles = true
topics = {"docs/information", "docs/store", "docs/structures",}
merge = true
sort = true
sort_modules = true
simple_args_string = true -- we show optionals/defaults outside of the display name
strip_metamethod_prefix = true -- remove the name of the table when displaying metamethod names
no_viewed_topic_at_top = true -- don't put the currently viewed topic at the top
use_new_templates = true -- new templating system
pretty_urls = true -- avoid showing .html in urls
pretty_topic_names = true -- strips extension from manual filenames, this does not check filename collisions
kind_names = {
    module = "Libraries",
}

custom_tags = {
    {
        "realm",
        hidden = true
    },
    {
        "internal",
        hidden = true
    },
    {
        "group",
        hidden = true
    },
}

custom_display_name_handler = function(item, default_handler)
    if item.type == "function" and item.module then
        if item.module.type == "hooks" then
            if item.module.mod_name == "Class" then
                return "CLASS:" .. default_handler(item)
            elseif item.module.mod_name == "Faction" then
                return "FACTION:" .. default_handler(item)
            end
            return "MODULE:" .. default_handler(item)
        elseif item.module.kind == "character meta" then
            return "characterMeta:" .. default_handler(item)
        elseif item.module.kind == "entity meta" then
            return "entityMeta:" .. default_handler(item)
        elseif item.module.kind == "item meta" then
            return "itemMeta:" .. default_handler(item)
        elseif item.module.kind == "player meta" then
            return "playerMeta:" .. default_handler(item)
        elseif item.module.kind == "inventory meta" then
            return "inventoryMeta:" .. default_handler(item)
           elseif item.module.kind == "tool meta" then
            return "ToolGunMeta:" .. default_handler(item)
        end
    end
    return default_handler(item)
end

new_type("factions", "Factions", true)
new_type("classes", "Classes", true)
new_type("library", "Libraries", true)
new_type("hooks", "Hooks", true)
new_type("charactermeta", "Character Meta", true)
new_type("entitymeta", "Entity Meta", true)
new_type("itemmeta", "Item Meta", true)
new_type("playermeta", "Player Meta", true)
new_type("inventorymeta", "Inventory Meta", true)
new_type("toolmeta", "Tool Meta", true)
new_type("configuration", "Configurations", true)
new_type("structures", "Structures", true)
new_type("information", "Information", true)
new_type("modules", "Modules", true)
new_type("store", "Store", true)
tparam_alias("inventory", "Inventory")
tparam_alias("item", "Item")
tparam_alias("date", "Date")
tparam_alias("panel", "Panel")
tparam_alias("string", "String")
tparam_alias("bool", "Boolean")
tparam_alias("func", "Function")
tparam_alias("client", "Player")
tparam_alias("entity", "Entity")
tparam_alias("character", "Character")
tparam_alias("color", "Color")
tparam_alias("tab", "Table")
tparam_alias("material", "Material")
tparam_alias("vector", "Vector")
tparam_alias("angle", "Angle")
tparam_alias("int", "Integer")
tparam_alias("float", "Float")