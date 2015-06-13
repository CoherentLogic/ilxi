#define PAGESIZE 65536
#define PAGECOUNT 2048

type st_page
     task_id as ubyte
     label as string * 255
     contents(0 to PAGESIZE - 1) as ubyte
end type

declare function st_read_byte(page as integer, offset as integer) as byte
declare sub st_write_byte(page as integer, offset as integer, value as byte)
declare sub st_load_page(file as string, page as integer)
declare sub st_save_page(file as string, page as integer)
declare sub st_write_word(page as integer, offset as integer, wordval as ushort)
declare function st_read_word(page as integer, offset as integer) as ushort