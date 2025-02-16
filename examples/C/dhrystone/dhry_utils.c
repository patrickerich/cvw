#include <sys/times.h>
#include "dhry.h"

void *malloc(size_t size) {
    // Simple bump allocator using static memory
    static char memory[16384];
    static size_t next = 0;
    void *result = &memory[next];
    next += (size + 7) & ~7; // 8-byte align
    return result;
}

clock_t times(struct tms *buffer) {
    unsigned long cycles;
    asm volatile ("rdcycle %0" : "=r" (cycles));
    if (buffer) {
        buffer->tms_utime = cycles;
        buffer->tms_stime = 0;
        buffer->tms_cutime = 0;
        buffer->tms_cstime = 0;
    }
    return cycles;
}

int scanf(const char *format, ...) {
    // Return 1000000 runs for benchmarking
    va_list args;
    va_start(args, format);
    int *n = va_arg(args, int*);
    // *n = 1000000;
    *n = 1000;
    // *n = 100;
    va_end(args);
    return 1;
}
