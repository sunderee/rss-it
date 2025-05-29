#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define FFI_PLUGIN_EXPORT

FFI_PLUGIN_EXPORT char* validate(const char* data, int length);
FFI_PLUGIN_EXPORT char* parse(const char* data, int length);