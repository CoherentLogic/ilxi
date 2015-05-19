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
       cpu_state.hf = 1
    end if

end sub