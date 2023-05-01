#ifndef lua_helpers_h
#define lua_helpers_h

#include <stdio.h>

void createLuaVM();

void doFile(const char* filePath);

int getGlobalInt(const char *var);

#endif
