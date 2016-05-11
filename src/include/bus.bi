'
' bus.bi
'

#define BUS_SIZE 256
#define IOPORT_COUNT 65536

type dev_entry

    dev_tag as string * 255

    io_base as ushort  
    io_port_count as ushort

    dev_init as sub()
    dev_reset as sub()
    dev_cycle as sub(byval userdata as any ptr)

    dev_input as function(port_number as ushort) as ushort
    dev_output as sub(port_number as ushort, value as ushort) 
        
    dev_thread as any ptr
    dev_thread_started as ubyte = 0
    dev_thread_stop_flag as ubyte = 0

end type

dim shared bus(0 to BUS_SIZE - 1) as dev_entry
dim shared io_ports(0 to IOPORT_COUNT - 1) as short

dim shared devices() as ubyte
dim shared dev_count as ubyte = 0

dim shared bus_started as ubyte = 0

declare sub bus_clear()
declare sub bus_init()
declare sub bus_start()
declare sub bus_stop()
declare sub bus_sig_stop(device_number as ushort)
declare function bus_get_stop_flag(device_number as ushort) as ubyte

declare sub bus_attach(device_number as ushort, dev as dev_entry)
declare sub bus_output(port_number as ushort, value as ushort)
declare function bus_input(port_number as ushort) as ushort