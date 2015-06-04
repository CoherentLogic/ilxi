'
' console.bas
'

#include "console.bi"
#include "storage.bi"

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

end sub