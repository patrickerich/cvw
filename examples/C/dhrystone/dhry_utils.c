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
    unsigned long insns;
    asm volatile ("rdcycle %0" : "=r" (cycles));
    asm volatile ("rdinstret %0" : "=r" (insns));
    if (buffer) {
        buffer->tms_utime = cycles;
        buffer->tms_stime = insns;
        buffer->tms_cutime = 0;
        buffer->tms_cstime = 0;
    }
    return cycles;
}

// Helper function to print floating point number with 3 decimal places
void print_float3(float val) {
    int whole = (int)val;
    int frac = (int)((val - whole) * 1000);
    if (frac < 0) frac = -frac;
    printf("%d.%03d", whole, frac);
}

// Helper function to print floating point number with 1 decimal place
void print_float1(float val) {
    int whole = (int)val;
    int frac = (int)((val - whole) * 10);
    if (frac < 0) frac = -frac;
    printf("%d.%d", whole, frac);
}

int scanf(const char *format, ...) {
    // Return 10000 runs for benchmarking
    va_list args;
    va_start(args, format);
    int *n = va_arg(args, int*);
    *n = 10000;
    va_end(args);
    return 1;
}
