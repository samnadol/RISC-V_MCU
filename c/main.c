#include <stdint.h>

volatile uint32_t seed = 0xDEADBEEF;
volatile uint32_t buffer[16];
int main(void) {
    seed ^= 0x12345678;
    for (int i = 0; i < 16; i++) {
        buffer[i] = seed + i;
    }
    return 0;
}