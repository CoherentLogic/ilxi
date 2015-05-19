#define PAGESIZE 65536
#define PAGECOUNT 512

type st_page
     task_id as ubyte
     label as string * 255
     contents(PAGESIZE) as ubyte
end type

declare function st_read_byte(page as integer, offset as integer) as byte
declare sub st_write_byte(page as integer, offset as integer, value as byte)
