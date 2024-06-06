file = {
	"docs/hooks",
	"lilia",
	exclude = {"lilia/gamemode/libraries/thirdparty"}
}

module_file = {
	Character = "lilia/gamemode/libraries/meta/character.lua",
	Entity = "lilia/gamemode/libraries/meta/entity.lua",
	Inventory = "lilia/gamemode/libraries/meta/inventory.lua",
	Item = "lilia/gamemode/libraries/meta/item.lua",
	Player = "lilia/gamemode/libraries/meta/player.lua"
}

dir = "docs/html"
project = "Lilia"
title = "Lilia Documentation"
no_space_before_args = true
style = "docs/css"
template = "docs/templates"
format = "markdown"
ignore = true
topics = {
    "docs/manual",
    "docs/structures",
    "docs/store" 
}
use_markdown_titles = true
kind_names = {module = "Core - Libraries", topic = "Information"}
merge = true
sort = true
sort_modules = true

simple_args_string = true -- we show optionals/defaults outside of the display name
strip_metamethod_prefix = true -- remove the name of the table when displaying metamethod names
no_viewed_topic_at_top = true -- don't put the currently viewed topic at the top
use_new_templates = true -- new templating system
pretty_urls = true -- avoid showing .html in urls
pretty_topic_names = true -- strips extension from manual filenames, this does not check filename collisions

custom_tags = {
	{"realm", hidden = true},
	{"internal", hidden = true}
}

new_type("configurationmodule", "Config - Module", true)
new_type("configurationgeneral", "Config - General", true)
new_type("hooksgeneral", "Hooks - General", true)
new_type("hooksmodule", "Hooks - Module", true)
new_type("panels", "UI - Panels", true)
new_type("structures", "Structures", true)
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