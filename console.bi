'
' console.bi
'

#define CONSOLE_PAGE &H0001
#define CONSOLE_OFFSET &H0000
#define CONSOLE_LIMIT &H07D0

#define CONSOLE_WIDTH 80
#define CONSOLE_HEIGHT 25

common shared console_mutex as any ptr

dim shared console_port as string
dim shared console_bps as string
dim shared console_parity as string
dim shared console_data_bits as string
dim shared console_stop_bits as string

dim shared console_file_number as integer

declare sub console_attach()
declare sub console_init_local()
declare sub console_reset_local()
declare function console_input(port_number as ushort) as ushort
declare sub console_output(port_number as ushort, value as ushort)
declare sub console_cycle_local(byval userdata as any ptr)

declare sub console_init_serial()
declare sub console_reset_serial()
declare sub console_cycle_serial(byval userdata as any ptr)
