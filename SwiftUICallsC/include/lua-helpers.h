#ifndef lua_helpers_h
#define lua_helpers_h

#include <stdio.h>
#include "lauxlib.h" // for lua_CFunction

void callFunction(int inputs, int outputs);
void createLuaVM(void);
void doFile(const char* filePath);
const char* doString(const char* filePath);
int getGlobalBoolean(const char *var);
double getGlobalDouble(const char *var);
int getGlobalInt(const char *var);
const char* getGlobalString(const char *var);
void getGlobalTable(const char *var);
int getIntTableValueForIndex(int index);
const char* getStringTableValueForStringKey(const char *key);
void pop(int n);
void printStack(void);
void printTable(void);
void pushBoolean(int b);
void pushFunction(const char *name);
void pushDouble(double n);
void pushInt(int n);
void pushString(const char *s);
void registerCFunction(const char* name, lua_CFunction fn);
void setTableKeyValue(const char* key, const char* value);

#endif
