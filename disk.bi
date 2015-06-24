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

type disk_header_t
    magic as string * 3
    track_count as ushort
    sectors_per_track as ushort
end type

type disk_track_t
    sectors(512) as disk_sector_t
end type

type disk_sector_t
    sector(512) as ubyte
end type

type installed_disk_t
    host_file as string
    track_count as ushort
    sectors_per_track as ushort
end type

dim shared installed_disks() as installed_disk_t
dim shared installed_disk_count as ushort

dim shared channel as ushort
dim shared sect_buf_page as ushort
dim shared sect_buf_offset as ushort
dim shared track as ushort
dim shared sector as ushort

declare sub disk_attach()
declare sub disk_init()
declare sub disk_reset()
declare function disk_input(port_number as ushort) as ushort
declare sub disk_output(port_number as ushort, value as ushort)
declare sub disk_cycle()