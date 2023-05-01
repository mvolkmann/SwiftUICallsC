#include "lauxlib.h" // for luaL_* functions
#include "lualib.h" // for luaL_openlibs
#include "lua-helpers.h"

void createLuaVM() {
    printf("createLuaVM entered\n");

    lua_State *L = luaL_newstate();

    // Make the standard library functions available in Lua code.
    // luaL_openlibs(L);
    luaL_openlibs(L);

    printf("createLuaVM exiting\n");
}
