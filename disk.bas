'
' disk.bas
'

#include "disk.bi"
#include "storage.bi"
#include "bus.bi"
#include "config.bi"
#include "message.bi"

'
' OUT
'
'   IOBASE   +  0:  Set channel 
'               1:  Set sector memory buffer page
'               2:  Set sector memory buffer offset
'               3:  Set disk track for current channel
'               4:  Set disk sector for current channel
'               5:  Read current track/sector into sector memory buffer
'               6:  Write current sector memory buffer to current track/sector
'
' IN
'
'   IOBASE   +  0:  Get installed channel count
'               1:  Get track count for current channel
'               2:  Get sectors-per-track count for current channel
'

sub disk_attach()

    dim disk_device as dev_entry

    with disk_device
        .dev_tag = "disk"
        .io_base = 240
        .io_port_count = 10
        .dev_init = @disk_init
        .dev_reset = @disk_reset
        .dev_cycle = @disk_cycle
        .dev_input = @disk_input
        .dev_output = @disk_output
    end with

    bus_attach 5, disk_device

end sub

sub disk_init()

end sub

sub disk_reset()

end sub

function disk_input(port_number as ushort) as ushort

    select case port_number
        case (disk_io_base + 0)

        case (disk_io_base + 1)

        case (disk_io_base + 2)

        case (disk_io_base + 3)

        case (disk_io_base + 4)

        case (disk_io_base + 5)

        case (disk_io_base + 6)
    
    end select


end function

sub disk_output(port_number as ushort, value as ushort)

    select case port_number
        case (disk_io_base + 0)

        case (disk_io_base + 1)

        case (disk_io_base + 2)

        case (disk_io_base + 3)

        case (disk_io_base + 4)

        case (disk_io_base + 5)

        case (disk_io_base + 6)
    
    end select

end sub

sub disk_cycle(byval userdata as any ptr)

    do
        sleep 500

        if bus_get_stop_flag(5) = 1 then exit do
    loop

end sub