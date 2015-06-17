#include "error.bi"
#include "cpu.bi"

sub machine_error(error_code as integer, severity as integer)
    
    '
    ' copy error info to proper flags and dump state
    '
    dim new_ec as integer
        
    cpu_state.ec = error_code
    cpu_state.es = severity

    if severity >= 10 then
       cpu_set_flag FL_HALT
    end if

end sub

function error_string(error_code as integer) as string

    select case error_code
        case ERR_INVALID_PAGE_ID
            return "invalid memory access (page out of bounds)"
        case ERR_INVALID_OFFSET
            return "invalid memory access (offset out of bounds)"
        case ERR_DIVZERO
            return "division by zero"
        case ERR_INVALID_IOPORT
            return "invalid I/O port"
        case ERR_INVALID_DATA_TYPE
            return "invalid data type in instruction operand"
    end select

    return "invalid error code"

end function