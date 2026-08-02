#include <stdint.h>

// .data — has a nonzero initializer, so this shows up as real content in dmem.hex
volatile uint32_t seed = 0xDEADBEEF;

// .bss — zero-initialized, so it takes up space in dmem's address range
// but contributes no actual bytes to dmem.hex (nothing to load — it's already 0)
volatile uint8_t buffer[256];

int main(void) {
    seed ^= 0x12345678;

    for (int i = 0; i < 256; i++) {
        buffer[i] = i * i;
    }

    while (1) {}
    return 0;
}