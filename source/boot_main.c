#include "boot_gpio.h"
#include "boot_uart.h"

extern int startBootLoader ( void );
extern void boot_uart_send_string(const char*);
extern void boot_uart_init( void );
extern void boot_uart_send( unsigned int);

int boot_main()
{
    boot_uart_init();
    boot_uart_send_string("Bootloader init");
    boot_uart_send(0x0A);
    boot_uart_send(0x0D);
    startBootLoader();	
    return 0;
}
