'
' console.bas
'

#include "console.bi"
#include "storage.bi"
#include "bus.bi"
#include "config.bi"
#include "message.bi"

sub console_attach()

    dim dev as dev_entry

    dim console_mode as string = config_get("console", "mode")
    
    select case console_mode
        case "local"
	
	        with dev
	            .dev_tag = "console"
	            .io_base = 0
	            .io_port_count = 4
	            .dev_init = @console_init_local
	            .dev_reset = @console_reset_local
	            .dev_cycle = @console_cycle_local
	            .dev_input = @console_input
	            .dev_output = @console_output
	        end with        

            message_print "console_attach():  local console"

        case "serial"

            with dev
                .dev_tag = "console"
                .io_base = 0
                .io_port_count = 4
                .dev_init = @console_init_serial
                .dev_reset = @console_reset_serial
                .dev_cycle = @console_cycle_serial
                .dev_input = @console_input
                .dev_output = @console_output
            end with

            console_port = config_get("console", "port")
            console_bps = config_get("console", "bps")            
            console_parity = config_get("console", "parity")
            console_data_bits = config_get("console", "data_bits")
            console_stop_bits = config_get("console", "stop_bits")

            message_print "console_attach():  serial console at " & console_port & ":  (" & console_bps & " " & console_parity & console_data_bits & console_stop_bits & ")"

    end select	
    

    bus_attach 0, dev

end sub

sub console_init_local()
    console_mutex = mutexcreate()
end sub

sub console_init_serial()
    console_mutex = mutexcreate()

    console_file_number = freefile()

    dim result as long
    dim serial_string as string

    serial_string = console_port & ":" & console_bps & "," & console_parity & "," & console_data_bits & "," & console_stop_bits

    result = open com(serial_string, as console_file_number)

    if err > 0 then
        message_print "console_init_serial():  error #" & trim(str(err)) & " occurred opening " & console_port & ":"
    end if

    print #console_file_number, chr(27) & "[2J"

end sub

sub console_reset_local()

end sub

sub console_reset_serial()

end sub

function console_input(port_number as ushort) as ushort
    return 0
end function

sub console_output(port_number as ushort, value as ushort)

end sub

sub console_cycle_local(byval userdata as any ptr)
    
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
	        
            locate row, col

            print chr(c);
	        
	        if col >= CONSOLE_WIDTH then
	            row = row + 1
	            col = 1
	        else
	            col = col + 1
	        end if
	    next i       

        mutexunlock console_mutex

	    sleep 25

        if bus_get_stop_flag(0) = 1 then exit do
    loop


    locate 26,1

end sub ' console_cycle_local()

sub console_cycle_serial(byval userdata as any ptr)

    dim i as integer
    dim c as ubyte

    dim output_str as string

    dim col as ubyte = 1   'x 
    dim row as ubyte = 1   'y

    do
        col = 1
        row = 1

        mutexlock console_mutex

	    for i = CONSOLE_OFFSET to CONSOLE_LIMIT - 1
	        c = st_read_byte(CONSOLE_PAGE, i)
	        

            output_str = chr(27) & "[" & trim(str(row)) & ";" & trim(str(col)) & "H" & chr(c)

            print #console_file_number, output_str;
	        
	        if col >= CONSOLE_WIDTH then
	            row = row + 1
	            col = 1
	        else
	            col = col + 1
	        end if
	    next i       

        mutexunlock console_mutex

	    sleep 25

        if bus_get_stop_flag(0) = 1 then exit do
    loop


end sub ' console_cycle_serial()

