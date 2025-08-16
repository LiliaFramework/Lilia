-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" };
   { name = "system", root = "/home/runner/work/Lilia/Lilia/.luarocks" };
}
lua_interpreter = "lua";
variables = {
   LUA_DIR = "/home/runner/work/Lilia/Lilia/.lua";
   LUA_BINDIR = "/home/runner/work/Lilia/Lilia/.lua/bin";
}
