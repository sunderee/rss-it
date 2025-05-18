#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define FFI_PLUGIN_EXPORT

FFI_PLUGIN_EXPORT bool validateFeedURL(const char* feed_url);
// FFI_PLUGIN_EXPORT char* parseFeeds(const char* feed_urls);