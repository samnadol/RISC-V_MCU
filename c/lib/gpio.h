#pragma once

#include <stdint.h>

typedef struct
{
    volatile uint8_t *base;
    uint8_t size;
} gpio_peripheral_t;

#define GPIO_REG_PINS 0

void gpio_toggle_pin(gpio_peripheral_t *reg, uint8_t pin);
void gpio_set_pin(gpio_peripheral_t *reg, uint8_t pin);
void gpio_unset_pin(gpio_peripheral_t *reg, uint8_t pin);