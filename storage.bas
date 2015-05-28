#include "storage.bi"
#include "error.bi"
#include "ilxi.bi"

dim shared mem(PAGECOUNT) as st_page

function st_read_byte(page as integer, offset as integer) as byte
	if (page > (PAGECOUNT - 1)) or (page < 0) then
	   machine_error ERR_INVALID_PAGE_ID, 10
	end if

	if (offset > (PAGESIZE - 1)) or (offset < 0) then
	   machine_error ERR_INVALID_OFFSET, 10
	end if 

	return mem(page).contents(offset)
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