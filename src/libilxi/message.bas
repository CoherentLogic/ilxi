'
' message.bas
'

#include "message.bi"
#include "console.bi"
#include "cpu.bi"
#include "asm.bi"

sub message_init()

    console_mutex = mutexcreate()

end sub ' message_init()

sub message_print(output_string as string)

    mutexlock console_mutex

    print output_string

    mutexunlock console_mutex

end sub ' message_print()

sub tool_message(msg_level as ubyte, tool as string, message as string, byval output_location as string = "")
    
    dim msg_prefix as string 
    msg_prefix = ucase(tool) + ": "

    select case msg_level
        case MSG_INFO
            msg_prefix += "INFO " + message
        case MSG_WARN
            msg_prefix += "WARNING " + message
        case MSG_ERROR
            msg_prefix += "ERROR " + message        
    end select
    
    if len(output_location) > 0 then
        dim fnum as integer = freefile()
        open output_location for append as #fnum
        print #fnum, msg_prefix
        close #fnum
    else
        print msg_prefix
    end if

end sub

sub list_heading(tool as string, byval input_file as string)
    dim fnum as integer = freefile()
    dim listfile as string
    
    listfile = ucase(left(input_file, instrrev(input_file, ".") - 1)) & ".LIS"
    
    open listfile for append as #fnum
    print #fnum,""
    print #fnum,
    print #fnum, "", tool; " LISTING FOR "; ucase(input_file), date()
    print #fnum,""
    print #fnum," LINE", "OFFSET" , "CODE"
    print #fnum, string(72, "-")
    close #fnum
    
end sub

sub listing(line_number as integer, address as string, code_output as string, byval listfile as string)

    dim fnum as integer = freefile()
    listfile = ucase(left(listfile, instrrev(listfile, ".") - 1)) & ".LIS"

    open listfile for append as #fnum
    
    print #fnum, line_number, address, code_output
    
    close #fnum

end sub

sub list_output(msg as string, byval listfile as string)
    dim fnum as integer = freefile()
    listfile = ucase(left(listfile, instrrev(listfile, ".") - 1)) & ".LIS"
    
    open listfile for append as #fnum
    
    print #fnum, msg
    
    close #fnum
    
end sub

