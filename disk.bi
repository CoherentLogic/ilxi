'
' disk.bi
'
'
' OUT
'
'   IOBASE   +  0:  Set channel 
'               1:  Set sector memory buffer page
'               2:  Set sector memory buffer offset
'               3:  Set disk track for current channel
'               4:  Read sector X from current track into sector memory buffer
'               5:  Write current sector memory buffer to sector in current track
'
' IN
'
'   IOBASE   +  0:  Get installed channel count
'               1:  Get track count for current channel
'               2:  Get sectors-per-track count for current channel
'

type disk_header_t
    magic as string * 3
    track_count as ushort
    sectors_per_track as ushort
end type

type disk_sector_t
    sector(512) as ubyte
end type

type disk_track_t
    sectors(512) as disk_sector_t
end type

type installed_disk_t
    host_file as string
    file_number as integer
    current_track as ushort
    track_count as ushort
    sectors_per_track as ushort
end type

dim shared disk_seek_table(any, any) as ushort

dim shared installed_disks() as installed_disk_t
dim shared installed_disk_count as ushort

dim shared channel as ushort
dim shared sect_buf_page as ushort
dim shared sect_buf_offset as ushort
dim shared disk_io_base as ushort

declare sub disk_attach()
declare sub disk_init()
declare sub disk_build_seek_table(new_channel as ushort)
declare sub disk_reset()
declare function disk_input(port_number as ushort) as ushort
declare sub disk_output(port_number as ushort, value as ushort)
declare sub disk_cycle(byval userdata as any ptr)
declare sub disk_create(file_path as string, track_count as ushort)
declare sub disk_seek(new_channel as ushort, new_track as ushort)
declare sub disk_read(tgt_sector as ushort)
declare sub disk_write(tgt_sector as ushort)
declare function disk_get_iobase() as ushort