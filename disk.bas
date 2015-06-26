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

    disk_io_base = disk_device.io_base
    
    bus_attach 5, disk_device

end sub

sub disk_init()       

    dim i as integer    
    dim disk_header as disk_header_t

    if installed_disk_count > 0 then
        for i = 0 to installed_disk_count - 1
            close #installed_disks(i).file_number
        next i
    end if

    installed_disk_count = val(config_get("disk", "count"))

    redim installed_disks(installed_disk_count) as installed_disk_t        

    for i = 0 to installed_disk_count - 1
        

        installed_disks(i).host_file = config_get("disk", trim(str(i)))
        installed_disks(i).file_number = freefile()

        open installed_disks(i).host_file for binary as #installed_disks(i).file_number
        get #installed_disks(i).file_number, , disk_header

        with installed_disks(i)
            .track_count = disk_header.track_count
            .sectors_per_track = disk_header.sectors_per_track
        end with


        disk_build_seek_table i

        message_print "disk_init():  channel " & trim(str(i)) & ": " & disk_header.track_count & " tracks, " & disk_header.sectors_per_track & " sectors/track (host file " & installed_disks(i).host_file & ")"

    next i

    for i = 0 to installed_disk_count - 1
        disk_seek i, 0
    next i
    
end sub

sub disk_build_seek_table(new_channel as ushort)

    dim f_num as integer
    dim f_header as disk_header_t
    dim f_track as disk_track_t
    dim i as integer
    dim f_pos as integer
    dim t_cnt as ushort

    f_num = installed_disks(new_channel).file_number
    t_cnt = installed_disks(new_channel).track_count

    seek #f_num, 1
    get #f_num, , f_header

    redim preserve disk_seek_table(installed_disk_count, t_cnt) as ushort

    for i = 0 to t_cnt
        f_pos = seek(f_num)

        disk_seek_table(new_channel, i) = f_pos

        get #f_num, , f_track
    
    next i

    seek #f_num, 1

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
            disk_seek channel, value
        case (disk_io_base + 4)
            disk_read value
        case (disk_io_base + 5)
            disk_write value
    end select

end sub

sub disk_cycle(byval userdata as any ptr)

    do
        sleep 500, 1

        if bus_get_stop_flag(5) = 1 then exit do
    loop

end sub

sub disk_create(file_path as string, track_count as ushort)

    dim file_number as integer    
    dim file_header as disk_header_t
    dim track as disk_track_t
    dim i as integer

    file_number = freefile()

    open file_path for binary as #file_number

    with file_header
        .magic = "XDI"
        .track_count = track_count
        .sectors_per_track = 512    'hardcoded for now
    end with

    put #file_number, , file_header

    for i = 0 to track_count - 1
        put #file_number, , track
    next i    

    close #file_number

end sub

sub disk_seek(new_channel as ushort, new_track as ushort)

    dim f_num as integer
    dim f_pos as integer

    f_num = installed_disks(new_channel).file_number

    seek #f_num, disk_seek_table(new_channel, new_track)

    f_pos = seek(f_num)

    message_print "disk_seek():  channel " & new_channel & ": track " & new_track & " (host file offset " & f_pos &")"

    installed_disks(new_channel).current_track = new_track

end sub

sub disk_read(tgt_sector as ushort)

    dim tmp_track as disk_track_t
    dim tmp_sector as disk_sector_t
    dim f_num as integer

    dim i as integer
    dim c_byte as integer = 0

    f_num = installed_disks(channel).file_number

    get #f_num, ,tmp_track
    
    tmp_sector = tmp_track.sectors(tgt_sector)

    for i = sect_buf_offset to sect_buf_offset + 512
        st_write_byte sect_buf_page, i, tmp_sector.sector(c_byte)
        c_byte += 1
    next i

end sub

sub disk_write(tgt_sector as ushort)

    dim tmp_track as disk_track_t
    dim tmp_sector as disk_sector_t
    dim f_num as integer

    f_num = installed_disks(channel).file_number    

    dim i as integer
    dim c_byte as integer = 0

    for i = sect_buf_offset to sect_buf_offset + 512
        tmp_sector.sector(c_byte) = st_read_byte(sect_buf_page, i)
        c_byte += 1
    next i

    tmp_track.sectors(tgt_sector) = tmp_sector

    put #f_num, , tmp_track

end sub

function disk_get_iobase() as ushort
    return disk_io_base
end function