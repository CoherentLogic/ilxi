#define CONSOLE_PAGE &H0001
#define CONSOLE_OFFSET &H0000
#define CONSOLE_LIMIT &H07D0

#define CONSOLE_WIDTH 80
#define CONSOLE_HEIGHT 25

declare sub console_attach()
declare sub console_init()
declare sub console_reset()
declare function console_input(port_number as ushort) as ushort
declare sub console_output(port_number as ushort, value as ushort)
declare sub console_cycle(byval userdata as any ptr)