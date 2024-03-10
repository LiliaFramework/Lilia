file = {
	"docs/hooks",
	"lilia",
	exclude = {"lilia/libraries/thirdparty"}
}

dir = "docs/html"
project = "Lilia"
title = "Lilia Documentation"
no_space_before_args = true
style = "docs/css"
template = "docs/templates"
format = "markdown"
ignore = true
topics = "docs/manual"
use_markdown_titles = true
kind_names = {module = "Libraries", topic = "Manual"}
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
new_type("hooks", "Hooks", true)
new_type("panel", "Panels", true)
tparam_alias("char", "Character")
tparam_alias("inventory", "Inventory")
tparam_alias("item", "Item")
tparam_alias("date", "date")
tparam_alias("string", "string")
tparam_alias("bool", "boolean")
tparam_alias("func", "function")
tparam_alias("player", "Player")
tparam_alias("entity", "Entity")
tparam_alias("color", "color")
tparam_alias("tab", "table")
tparam_alias("material", "material")
tparam_alias("vector", "vector")
tparam_alias("angle", "angle")