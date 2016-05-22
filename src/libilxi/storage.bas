#include "storage.bi"
#include "error.bi"
#include "ilxi.bi"

dim shared mem(0 to PAGECOUNT) as st_page

function st_read_byte(page as integer, offset as integer) as byte
	if (page > (PAGECOUNT - 1)) or (page < 0) then
	   machine_error ERR_INVALID_PAGE_ID, 10
	end if

	if (offset > (PAGESIZE - 1)) or (offset < 0) then
	   machine_error ERR_INVALID_OFFSET, 10
	end if 

	return mem(page).contents(offset)
end function

function st_read_page(page as integer) as st_page
    return mem(page)
end function

sub st_write_byte(page as integer, offset as integer, value as byte)
	if (page > (PAGECOUNT - 1)) or (page < 0) then
	   machine_error ERR_INVALID_PAGE_ID, 10
	end if

	if (offset > (PAGESIZE - 1)) or (offset < 0) then
	   machine_error ERR_INVALID_OFFSET, 10
	end if 

	mem(page).contents(offset) = value
end sub

function st_read_word(page as integer, offset as integer) as ushort
    dim lsb as ubyte
    dim msb as ubyte

	if (page > (PAGECOUNT - 1)) or (page < 0) then
	   machine_error ERR_INVALID_PAGE_ID, 10
	end if

	if ((offset + 1) > (PAGESIZE - 1)) or (offset < 0) then
	   machine_error ERR_INVALID_OFFSET, 10
	end if 

    lsb = st_read_byte(page, offset)
    msb = st_read_byte(page, offset + 1)

    return (msb shl 8) or lsb
end function

sub st_write_word(page as integer, offset as integer, wordval as ushort)
    dim lsb as ubyte
    dim msb as ubyte

	if (page > (PAGECOUNT - 1)) or (page < 0) then
	   machine_error ERR_INVALID_PAGE_ID, 10
	end if

	if ((offset + 1) > (PAGESIZE - 1)) or (offset < 0) then
	   machine_error ERR_INVALID_OFFSET, 10
	end if 

    lsb = wordval and &HFF
    msb = (wordval and &HFF00) shr 8

    st_write_byte page, offset, lsb
    st_write_byte page, offset + 1, msb
end sub

sub st_load_page(file as string, page as integer)
    dim file_handle as integer

    file_handle = freefile()
    open file for binary as #file_handle

    get #file_handle, , mem(page)

    close #file_handle
end sub

sub st_save_page(file as string, page as integer)
    dim file_handle as integer

    file_handle = freefile()
    open file for binary as #file_handle
    
    put #file_handle, , mem(page)

    close #file_handle
end sub
