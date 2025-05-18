#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

#define FFI_PLUGIN_EXPORT

FFI_PLUGIN_EXPORT int validateFeed(const char* feed_url);
FFI_PLUGIN_EXPORT char* parseFeeds(const char* feed_urls);