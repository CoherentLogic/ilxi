'
' disk.bi
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