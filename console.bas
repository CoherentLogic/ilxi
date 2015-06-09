'
' console.bas
'

#include "console.bi"
#include "storage.bi"
#include "bus.bi"


sub console_attach()

    dim dev as dev_entry

    with dev
        .dev_tag = "ILXIM System Console"
        .io_base = 0
        .io_port_count = 4
        .dev_init = @console_init
        .dev_reset = @console_reset
        .dev_cycle = @console_refresh
        .dev_input = @console_input
        .dev_output = @console_output
    end with        

    bus_attach 0, dev

end sub

sub console_init()

end sub

sub console_reset()

end sub

function console_input(port_number as ushort) as ushort
    return 0
end function

sub console_output(port_number as ushort, value as ushort)

end sub

sub console_refresh()
    dim i as integer
    dim c as ubyte

    dim col as ubyte = 1   'x 
    dim row as ubyte = 1   'y
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

    sleep 25

end sub