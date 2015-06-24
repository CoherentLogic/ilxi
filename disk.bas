'
' disk.bas
'

#include "disk.bi"
#include "storage.bi"
#include "bus.bi"
#include "config.bi"
#include "message.bi"


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
            return installed_disk_count
        case (disk_io_base + 1)
            return installed_disks(channel).track_count
        case (disk_io_base + 2)
            return installed_disks(channel).sectors_per_track
    end select


end function

sub disk_output(port_number as ushort, value as ushort)

    select case port_number
        case (disk_io_base + 0)
            channel = value
        case (disk_io_base + 1)
            sect_buf_page = value
        case (disk_io_base + 2)
            sect_buf_offset = value
        case (disk_io_base + 3)
            track = value
        case (disk_io_base + 4)
            sector = value
        case (disk_io_base + 5)
            ' read
        case (disk_io_base + 6)
            ' write
    end select

end sub

sub disk_cycle(byval userdata as any ptr)

    do
        sleep 500

        if bus_get_stop_flag(5) = 1 then exit do
    loop

end sub