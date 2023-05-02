#ifndef lua_helpers_h
#define lua_helpers_h

#include <stdio.h>

void createLuaVM(void);

void doFile(const char* filePath);

const char* doString(const char* filePath);

int getGlobalBoolean(const char *var);
double getGlobalDouble(const char *var);
int getGlobalInt(const char *var);
const char* getGlobalString(const char *var);

#endif
