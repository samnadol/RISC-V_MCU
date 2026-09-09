#pragma once

#include <stdint.h>

typedef struct
{
    volatile uint8_t *base;
} uart_peripheral_t;

#define UART_REG_STATUS 0 // peripheral status register
#define UART_BUF_TX     1 // tx buffer
#define UART_BUF_RX     2 // rx buffer

#define UART_STATUS_IDLE (1<<0) // peripheral idle

void uart_tx(uart_peripheral_t *uart, uint8_t data);