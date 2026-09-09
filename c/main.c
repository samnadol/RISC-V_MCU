#include <stdint.h>
#include <stdbool.h>

typedef struct
{
    volatile uint8_t *base;
    uint8_t size;
} gpio_reg_t;

#define GPIO_PIN_REG 0

typedef struct
{
    volatile uint8_t *base;
} uart_peripheral_t;

#define UART_TXB 0 // tx buffer
#define UART_RXB 1 // rx buffer
#define UART_STATUS 2 // peripheral status register

#define UART_STATUS_TXD (1<<0) // tx done signal
#define UART_STATUS_RXD (1<<1) // rx done signal
#define UART_STATUS_TXS (1<<2) // tx start flag


void gpio_toggle_pin(gpio_reg_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base + GPIO_PIN_REG) ^= (1 << pin);
}

void gpio_set_pin(gpio_reg_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base + GPIO_PIN_REG) |= 1 << pin;
}

void gpio_unset_pin(gpio_reg_t *reg, uint8_t pin)
{
    if (pin > reg->size)
        return;
    *(reg->base + GPIO_PIN_REG) &= ~(1 << pin);
}

void uart_tx(uart_peripheral_t *uart, uint8_t data)
{
    *(uart->base + UART_TXB) = data;
    *(uart->base + UART_STATUS) |= UART_STATUS_TXS;

    while (*(uart->base + UART_STATUS) & UART_STATUS_TXD) {}
}

int main(void)
{
    gpio_reg_t gpioA;
    gpioA.base = (uint8_t *)0x10000000;
    gpioA.size = 8;

    for (int i = 0; i < gpioA.size; i++)
    {
        gpio_set_pin(&gpioA, i);
    }
    gpio_toggle_pin(&gpioA, 3);
    gpio_unset_pin(&gpioA, 6);

    uart_peripheral_t uartA;
    uartA.base = (uint8_t *)0x20000000;

    uart_tx(&uartA, 0b10110100);

    return 0;
}
