'
' console.bi
'

'
' I/O PORT USAGE
'
' OUT
'
'   IOBASE   +  0:  1 = Enable Cursor; 0 = Disable Cursor
'               1:  Set cycle sleep value (ms)
'               2:  Set horizontal offset
'               3:  Set vertical offset
'               4:  Fill video buffer
'
' IN
'
'   IOBASE   +  0:  Read cursor enable value
'               1:  Read refresh sleep value (ms)
'               2:  Read horizontal offset
'               3:  Read vertical offset
'		4:  Read one character from console
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

dim shared horizontal_offset as ushort = 0
dim shared vertical_offset as ushort = 0
dim shared sleep_duration as ushort = 50
dim shared cursor_enabled as ushort = 1

dim shared console_file_number as integer

dim shared console_io_base as ushort

dim shared console_refresh as sub()

declare sub console_attach()
declare sub console_init_local()
declare sub console_reset_local()
declare function console_input(port_number as ushort) as ushort
declare sub console_output(port_number as ushort, value as ushort)
declare sub console_cycle_local(byval userdata as any ptr)

declare sub console_init_serial()
declare sub console_reset_serial()
declare sub console_cycle_serial(byval userdata as any ptr)
declare sub console_refresh_local()
declare sub console_refresh_serial()