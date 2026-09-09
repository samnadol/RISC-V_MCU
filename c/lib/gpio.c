#include "gpio.h"

void gpio_toggle_pin(gpio_peripheral_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base + GPIO_REG_PINS) ^= (1 << pin);
}

void gpio_set_pin(gpio_peripheral_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base + GPIO_REG_PINS) |= 1 << pin;
}

void gpio_unset_pin(gpio_peripheral_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base + GPIO_REG_PINS) &= ~(1 << pin);
}