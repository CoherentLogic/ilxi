'
' bus.bas
'
' multithreaded XIBUS subsystem
'

#include "bus.bi"
#include "cpu.bi"
#include "storage.bi"
#include "error.bi"
#include "message.bi"
#include "console.bi"

sub bus_clear()

    dim i as integer

    for i = 0 to IOPORT_COUNT - 1
        '
        ' -1 indicates that I/O port i is available
        '
        io_ports(i) = -1 
    next i

    redim devices(1) as ubyte
    dev_count = 0

end sub

sub bus_init()
    
    dim i as integer

    for i = 1 to dev_count
        message_print "bus_init():  initializing device " & devices(i)

        bus(devices(i)).dev_thread_started = 0
        bus(devices(i)).dev_thread_stop_flag = 0
        bus(devices(i)).dev_init()        
    next i

end sub

sub bus_start()
    
    dim i as integer

    for i = 1 to dev_count
        message_print "bus_start():  starting device " & devices(i)

        bus(devices(i)).dev_thread = threadcreate(bus(devices(i)).dev_cycle, @devices(i))
        bus(devices(i)).dev_thread_started = 1
    next i

end sub

sub bus_stop()
    
    dim i as integer

    for i = 1 to dev_count
        if bus(devices(i)).dev_thread_started = 1 then
            bus(devices(i)).dev_thread_stop_flag = 1

            message_print "bus_stop():  stopping device " & devices(i)           

            threadwait bus(devices(i)).dev_thread
            bus(devices(i)).dev_thread_started = 0
            bus(devices(i)).dev_thread_stop_flag = 0

        end if
    next i

end sub

sub bus_sig_stop(device_number as ushort)
    bus(device_number).dev_thread_stop_flag = 1
end sub

function bus_get_stop_flag(device_number as ushort) as ubyte
    return bus(device_number).dev_thread_stop_flag
end function

sub bus_attach(device_number as ushort, dev as dev_entry)
    dim port as ushort

    '
    ' try to assign I/O ports to this device
    '
    for port = dev.io_base to dev.io_base + (dev.io_port_count - 1)

        if io_ports(port) >= 0 then

            mutexlock console_mutex

            print "bus_attach():  port "; port; 
            print " requested by device "; device_number; 
            print " already bound to device "; io_ports(port)
           
            print "bus_attach():  failed for device "; device_number

            mutexunlock console_mutex
            
            exit sub
        else
            message_print "bus_attach():  allocating port " & port & " to device " & device_number
            io_ports(port) = device_number
        end if

    next port

    '
    ' port assignment successful; attach the device.
    '
    bus(device_number) = dev

    dev_count += 1
    redim preserve devices(dev_count) as ubyte
    devices(dev_count) = device_number

end sub

function bus_input(port_number as ushort) as ushort

    dim dev as dev_entry

    if io_ports(port_number) >= 0 then
        dev = bus(io_ports(port_number))

        return dev.dev_input(port_number)
    else
        machine_error ERR_INVALID_IOPORT, 10
    end if
    
end function

sub bus_output(port_number as ushort, value as ushort)

    dim dev as dev_entry

    if io_ports(port_number) >= 0 then
        dev = bus(io_ports(port_number))

        dev.dev_output(port_number, value)
    else
        machine_error ERR_INVALID_IOPORT, 10
    end if

end sub