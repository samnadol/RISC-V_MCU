#include <stdint.h>
#include <stdbool.h>

typedef struct
{
    volatile uint8_t *base;
    uint8_t size;
} gpio_reg_t;

void gpio_toggle_pin(gpio_reg_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base) ^= (1 << pin);
}

void gpio_set_pin(gpio_reg_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base) |= 1 << pin;
}

void gpio_unset_pin(gpio_reg_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base) &= ~(1 << pin);
}

int main(void)
{
    gpio_reg_t gpioA;
    gpioA.base = (uint8_t *)0x10000000;
    gpioA.size = 8;

    volatile uint32_t buf[32];

    for (int i = 0; i < 8; i++)
    {
        gpio_set_pin(&gpioA, i);
        buf[i] = 0xFF00 + (i * 3);
    }

    gpio_toggle_pin(&gpioA, 3);
    gpio_unset_pin(&gpioA, 6);

    return 0;
}
