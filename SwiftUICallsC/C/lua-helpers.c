#include <stdlib.h> // for exit function and EXIT_FAILURE
#include <string.h> // for strcpy
#include "lauxlib.h" // for luaL_* functions
#include "lualib.h" // for luaL_openlibs
#include "lua-helpers.h"

lua_State *L;

// This must be declared before its first use.
void error(const char *fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vfprintf(stderr, fmt, argp);
    va_end(argp);
    lua_close(L);
    exit(EXIT_FAILURE);
}

void callFunction(int inputs, int outputs) {
    // lua_pcall returns a status code.
    // The possible values are LUA_OK, LUA_ERRRUN (normal error),
    // LUA_ERRERR (error in error handler),
    // LUA_ERRMEM (memory allocation error), and
    // LUA_ERRGCMM (error in finalizer).
    // 2nd argument is the number of arguments being passed to the Lua function.
    // 3rd argument is the number of values being returned by Lua function.
    // 4th argument is stack index where error handling function is found
    // or 0 to not use one.
    if (lua_pcall(L, inputs, outputs, 0) != LUA_OK) {
        error("error at %s", lua_tostring(L, -1));
    }
    // After the call the function and all its arguments are popped from the stack
    // and the outputs are pushed onto the stack.
}

void doFile(const char* filePath) {
    printf("doFile: filePath = %s\n", filePath);
    int status = luaL_dofile(L, filePath);
    printf("doFile: status = %d\n", status);
    if (status) {
        const char *message = lua_tostring(L, -1);
        printf("doFile: message = %s\n", message);
    }
}

// If there is an error, a status message is returned.
// Otherwise nil is returned.
const char* doString(const char* code) {
    int status = luaL_dostring(L, code);
    return status ? lua_tostring(L, -1) : "";
}

int getGlobalBoolean(const char *var) {
    lua_getglobal(L, var); // pushes onto stack
    if (!lua_isboolean(L, -1)) {
        error("expected %s to be a boolean\n", var);
    }
    int result = lua_toboolean(L, -1);
    lua_pop(L, 1); // pops from stack
    return result;
}

double getGlobalDouble(const char *var) {
    lua_getglobal(L, var); // pushes onto stack
    // From the docs, "the term number in the API refers to doubles."
    if (!lua_isnumber(L, -1)) {
        error("expected %s to be a number\n", var);
    }

    double result = lua_tonumber(L, -1);
    lua_pop(L, 1); // pops from stack
    return result;
}

int getGlobalInt(const char *var) {
    lua_getglobal(L, var); // pushes onto stack
    if (!lua_isinteger(L, -1)) {
        error("expected %s to be an integer\n", var);
    }
    int result = (int) lua_tointeger(L, -1);
    lua_pop(L, 1); // pops from stack
    return result;
}

const char* getGlobalString(const char *var) {
    lua_getglobal(L, var); // pushes onto stack
    if (!lua_isstring(L, -1)) {
        error("expected %s to be a string\n", var);
    }
    const char *result = lua_tostring(L, -1);
    lua_pop(L, 1); // pops from stack
    return result;
}

void getGlobalTable(const char *var) {
    lua_getglobal(L, var);
    if (!lua_istable(L, -1)) {
        error("expected %s to be a table\n", var);
    }
    // This leaves the table on the stack.
}

void pushBoolean(int b) {
    lua_pushboolean(L, b);
}

void pushFunction(const char *name) {
    lua_getglobal(L, name);
}

void pushDouble(double n) {
    lua_pushnumber(L, n);
}

void pushInt(int n) {
    lua_pushnumber(L, n);
}

void pushString(const char *s) {
    lua_pushstring(L, s);
}

// This assumes that the table is already at the top of the stack.
// Other versions are needed for non-string keys and values.
void setTableKeyValue(const char* key, const char* value) {
    pushString(key);
    pushString(value);
    lua_settable(L, -3); // -3 refers to the Lua table
}

// This variable definition was copied from the Lua source file linit.c.
static const luaL_Reg loadedlibs[] = {
    // This loads the "basic" standard library into the global environment.
    // It includes functions like pairs, ipairs, print,
    // tonumber, tostring, setmetatable, and getmetatable
    {LUA_GNAME, luaopen_base},

    // {LUA_COLIBNAME, luaopen_coroutine},
    // {LUA_DBLIBNAME, luaopen_debug},
    {LUA_IOLIBNAME, luaopen_io},
    {LUA_MATHLIBNAME, luaopen_math},
    // {LUA_OSLIBNAME, luaopen_os},
    // {LUA_LOADLIBNAME, luaopen_package},
    {LUA_STRLIBNAME, luaopen_string},
    {LUA_TABLIBNAME, luaopen_table},
    // {LUA_UTF8LIBNAME, luaopen_utf8},
    {NULL, NULL}
};

// This function was copied from the Lua source file linit.c.
LUALIB_API void openlibs(lua_State *L) {
    const luaL_Reg *lib;
    for (lib = loadedlibs; lib->func; lib++) {
        luaL_requiref(L, lib->name, lib->func, 1);
        lua_pop(L, 1);  /* remove lib */
    }

    // Assuming the io library is loaded,
    // remove the ability to change the default output file.
    // It will remain set to stdout.
    getGlobalTable("io");
    setTableKeyValue("output", 0);

    // TODO: Can Lua send HTTP requests without custom C code from another library?
    //
    // You may wish to enable the os library, but disable these os functions:
    // - os.execute
    // - os.exit
    // - os.getenv
    // - os.remove
    // - os.rename
    // - os.rename
    // - os.rename
    // - os.rename
}

void createLuaVM() {
    printf("createLuaVM entered\n");

    L = luaL_newstate();

    // Make the standard library functions available in Lua code.
    luaL_openlibs(L);
    // openlibs(L);

    printf("createLuaVM exiting\n");
}

void pop(int n) {
    lua_pop(L, n);
}

const char* getStackString(int i) {
    int t = lua_type(L, i);
    switch (t) {
        case LUA_TSTRING:
            return lua_tostring(L, i);
        case LUA_TBOOLEAN:
            return lua_toboolean(L, i) ? "true" : "false";
        case LUA_TNUMBER: {
            static char text[20];
            sprintf(text, "%g", lua_tonumber(L, i));
            return text;
        }
        default: {
            static char text[20];
            sprintf(text, "some %s", lua_typename(L, t));
            return text;
        }
    }
}

void printStack(void) {
    int top = lua_gettop(L);
    if (top == 0) {
        printf("Lua stack is empty.\n");
        return;
    }

    printf("Lua stack contains:\n");
    int i;
    for (i = 1; i <= top; i++) {
        printf("  %d = %s\n", i, getStackString(i));
    }
}

// This assumes that the table is on the top of the stack.
void printTable(void) {
    printf("table contains:\n");
    lua_pushnil(L); // initial key
    //
    // lua_next removes the key on the top of the stack and
    // pushes the next key and value onto the stack.
    while (lua_next(L, -2) != 0) {
        // The next key is at index -2 and its value is at index -1.
        char key[100];
        strcpy(key, getStackString(-2));
        const char *value = getStackString(-1);
        printf("  %s = %s\n", key, value);

        // This removes the value and keeps the key for the next iteration.
        lua_pop(L, 1);
    }
}

void registerCFunction(const char* name, lua_CFunction fn) {
    lua_pushcfunction(L, fn);
    lua_setglobal(L, name);
}

// This assumes that a Lua table is at the top of the stack.
// This must be defined after the `pushString` function.
int getIntTableValueForIndex(int index) {
    pushInt(index);
    // The table should now be at -2 on the stack.
    lua_gettable(L, -2);
    int value = lua_tointeger(L, -1);
    pop(1); // pops the key from the stack
    return value;
}

// This assumes that a Lua table is at the top of the stack.
// This must be defined after the `pushString` function.
const char* getStringTableValueForStringKey(const char *key) {
    lua_getfield(L, -1, key);
    const char *value = lua_tostring(L, -1);
    pop(1); // pops the key from the stack
    return value;
}
