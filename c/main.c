#include <stdint.h>
#include <stdbool.h>

#include "lib/gpio.h"
#include "lib/uart.h"

int main(void)
{
    gpio_peripheral_t gpioA;
    gpioA.base = (uint8_t *)0x10000000;
    gpioA.size = 8;

    uart_peripheral_t uartA;
    uartA.base = (uint8_t *)0x20000000;

    for (int i = 0; i < gpioA.size; i++)
    {
        gpio_set_pin(&gpioA, i);
        uart_tx(&uartA, i);
    }

    char* uart_string = "Hello, World!";
    char *ptr = uart_string;
    do
    {
        uart_tx(&uartA, *ptr);
    } while (*ptr++);

    return 0;
}
