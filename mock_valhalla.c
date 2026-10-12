#include <stdint.h>

const char* valhalla_route(const char* request_json) {
    // Return a mock Valhalla JSON response
    return "{\"trip\": {\"status\": \"success\", \"summary\": {\"time\": 1200, \"length\": 15.5}}}";
}

void valhalla_free_string(const char* str) {
    // In the real Valhalla, this frees the memory of the returned string.
    // For our mock static string, we do nothing.
}
