#include <stddef.h>

#include "boot_gpio.h"
#include "boot_uart.h"

// UART BUSY TRANSMITTING
#define BOOT_UART_BUSY_TX (1 << 3)

//Rx FIFO empty
#define BOOT_RX_FIFO_EMPTY (1 << 4)

// Tx FIFO full
#define BOOT_TX_FIFO_FULL (1 << 5)

// Rx FIFO full
#define BOOT_RX_FIFO_FULL (1 << 6)

// Tx FIFO empty
#define BOOT_TX_FIFO_EMPTY (1<< 7)

// Wait for space in the Tx FIFO
void boot_wait_for_tx_slot()
{
    // Spin while the Tx FIFO is full
    while (((volatile uint32_t)boot_uart[BOOT_UART0_FR]) & BOOT_TX_FIFO_FULL)
	{
		// NOOP
	}
}

// Wait until the UART is not busy
void boot_wait_for_uart_idle()
{
    //Spin while the UART is busy transmitting
    while (((volatile uint32_t)boot_uart[BOOT_UART0_FR]) & BOOT_UART_BUSY_TX)
	{
		//NOOP
	}
}

// Wait for space in the Rx FIFO 
void boot_wait_for_rx_slot()
{
    // Spin while the Rx FIFO is full
    while (((volatile uint32_t)boot_uart[BOOT_UART0_FR]) & BOOT_RX_FIFO_FULL)
	{
		//NOOP
	}
}

// Wait for the Rx FIFO to receive something
void boot_wait_for_rx_has_char()
{
    // Spin while the Rx FIFO is empty
    while (((volatile uint32_t)boot_uart[BOOT_UART0_FR]) & BOOT_RX_FIFO_EMPTY)
	{
		//NOOP
	}
}

// Not this thing again... you know what it's for...
extern void boot_delay(volatile uint32_t count)
{
    while (count)
    {
        count--;
    }
}


// Initalizes the uart port.
// Puts GPIO pins XX and YY to alternative selection 5.
extern void boot_uart_init()
{
    // First things first, we need to set the UART pins to use
    // alternate function 0.  Page 236 of the shows
    // that GPIO 14 is TXD, GPIO 15 is RXD, and they must be set
    // to use alternate function 0 in select register 1.
    // The bits must be set to 100 for GPIO 15 and 14.
    boot_gpio[BOOT_GPFSEL1] |= 0x24000;

    // According to the BCM2835 manual page 185, we
    // need to do the following to enable UART.
    // 1. Disable the UART.
    // 2. Wait for end-of-transmisstion or reception
    //    of the current character.
    // 3. Flush the transmit queue by setting the FEN
    //    bit to 0 in the line control register (UART_LCRH).
    //    This is bit 4, the enable FIFOs bit.
    // 4. Set the Baud Rate
    // 5. Reprogram the control register, UART_CR
    // 6. Enable the UART.

    // 1. Disable the UART.  Easiest way to do that is
    // to zeroize the control register.
    boot_uart[BOOT_UART0_CR] = 0;

    // 2. Wait for end-of-transmission
    boot_wait_for_uart_idle();

    // 3. Set FEN bit to 0 of UART-LCRH, which flushes the Tx Queue.
    boot_uart[BOOT_UART0_LCRH] |= (0 << 4);

    boot_gpio[BOOT_GPPUD] = 0;
    boot_delay(150);
    boot_gpio[BOOT_GPPUDCLK0] = (1<<14)|(1<<15);
    boot_delay(150);
    boot_gpio[BOOT_GPPUDCLK0] = 0; // Writing zero apparently makes it take affect.

    // Clear Pending Interrupts
    boot_uart[BOOT_UART0_ICR] = 0x7FF;

    boot_uart[BOOT_UART0_IBRD] = 26;
    boot_uart[BOOT_UART0_FBRD] = 1;
	
    //Enable FIFOs and set word length by shifting in '1's
    boot_uart[BOOT_UART0_LCRH] |= (1 << 4)| (1 << 5) | (1 << 6);

    // Mask all interrupts
    boot_uart[BOOT_UART0_IMSC] |= (
        (1 << 1) | (1 << 4) | (1 << 5) | (1 << 6) |
        (1 << 7) | (1 << 8) | (1 << 9) | (1 << 10)
    );

    // 5.  Reprogram the UART control register.

    // Enable Receive, Enable Tx, Enable UART.
    boot_uart[BOOT_UART0_CR] |= (1 << 9)|(1 << 8) | (1 << 0);
}

/// Gets a single character from the UART port.
extern unsigned int boot_uart_recv()
{
	// Waits for the rx port to have a char
    boot_wait_for_rx_has_char();

	// Do not remove!!! The RPi UART is a bit... lazy... 
    boot_delay(150);
	
	// Read the data register.
    // Only care about the least significant 8 bits, so mask off others.
    return (unsigned int)(boot_uart[BOOT_UART0_DR] & 0xFF);
}

/// Writes a single character to the uart port.
extern void boot_uart_send(unsigned int c)
{
	// Wait make for TX slot to send data
	boot_wait_for_tx_slot();
	
	
	// Do not remove!!! The RPi UART is a bit... lazy... 
        boot_delay(150);
	
	// <<Write the character to the data register here.>>
	boot_uart[BOOT_UART0_DR] = ((boot_uart[BOOT_UART0_DR] | 0xFF) & (c & 0xFF));
	
}


/// Sends an entire null-terminated string
/// to the UART port.  The function will keep sending characters
/// until it reaches a null-character and then it stops.
extern void boot_uart_send_string(const char* str)
{
    char currentChar = str[0];
    for (size_t i = 0; currentChar != '\0'; ++i)
    {
        // << SET CURRENT CHARACTER >>
	   currentChar = str[i];	   

        // Depending on which console is being used, this may
        // or may not be needed.  On linux, we've discovered we can't
        // send null characters or the formatting is all wrong.
        if(currentChar!= '\0')
        {
            boot_uart_send(currentChar);
        }
    }
    // << INSERT POLLING FUNCTION CALL HERE>>
    boot_wait_for_uart_idle();
}