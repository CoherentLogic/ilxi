'
' console.bas
'

#include "console.bi"
#include "storage.bi"
#include "bus.bi"

sub console_attach()

    dim dev as dev_entry

    with dev
        .dev_tag = "console"
        .io_base = 0
        .io_port_count = 4
        .dev_init = @console_init
        .dev_reset = @console_reset
        .dev_cycle = @console_cycle
        .dev_input = @console_input
        .dev_output = @console_output
    end with        

    bus_attach 0, dev

end sub

sub console_init()
    console_mutex = mutexcreate()
end sub

sub console_reset()

end sub

function console_input(port_number as ushort) as ushort
    return 0
end function

sub console_output(port_number as ushort, value as ushort)

end sub

sub console_cycle(byval userdata as any ptr)
    
    dim i as integer
    dim c as ubyte


    dim old_row as integer
    dim old_col as integer

    dim col as ubyte = 1   'x 
    dim row as ubyte = 1   'y

    do
        col = 1
        row = 1

        old_row = csrlin()
        old_col = pos()

        mutexlock console_mutex

	    for i = CONSOLE_OFFSET to CONSOLE_LIMIT - 1
	        c = st_read_byte(CONSOLE_PAGE, i)
	        locate row, col, 0: print chr(c);
	        
	        if col >= CONSOLE_WIDTH then
	            row = row + 1
	            col = 1
	        else
	            col = col + 1
	        end if
	    next i       

        locate old_row, old_col	

        mutexunlock console_mutex

	    sleep 25

        if bus_get_stop_flag(0) = 1 then exit do
    loop


    locate 26,1

end sub