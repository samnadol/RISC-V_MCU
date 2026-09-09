#include "uart.h"

void uart_tx(uart_peripheral_t *uart, uint8_t data)
{
    *(uart->base + UART_BUF_TX) = data;
    while (!(*(uart->base + UART_REG_STATUS) & UART_STATUS_IDLE)) {}
}