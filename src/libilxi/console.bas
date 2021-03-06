'
' console.bas
'               

#include "console.bi"
#include "storage.bi"
#include "bus.bi"
#include "config.bi"
#include "message.bi"
#include "cpu.bi"

sub console_attach()

    dim console_device as dev_entry

    dim console_mode as string = config_get("console", "mode")
    
    select case console_mode
        case "local"
	
	        with console_device
	            .dev_tag = "console"
	            .io_base = 0
	            .io_port_count = 7
	            .dev_init = @console_init_local
	            .dev_reset = @console_reset_local
	            .dev_cycle = @console_cycle_local
	            .dev_input = @console_input_local
	            .dev_output = @console_output
	        end with        

            console_refresh = @console_refresh_local
            
            message_print "console_attach():  local console configured at I/O port " & console_device.io_base & "h"

        case "serial"

            with console_device
                .dev_tag = "console"
                .io_base = 0
                .io_port_count = 7
                .dev_init = @console_init_serial
                .dev_reset = @console_reset_serial
                .dev_cycle = @console_cycle_serial
                .dev_input = @console_input_serial
                .dev_output = @console_output
            end with

            console_refresh = @console_refresh_serial

            console_port = config_get("console", "port")
            console_bps = config_get("console", "bps")            
            console_parity = config_get("console", "parity")
            console_data_bits = config_get("console", "data_bits")
            console_stop_bits = config_get("console", "stop_bits")

            message_print "console_attach():  serial console configured at I/O port " & console_device.io_base & "h (host device " & console_port & "):  (" & console_bps & " " & console_parity & console_data_bits & console_stop_bits & ")"

    end select	
    

    bus_attach 0, console_device

end sub ' console_attach()

sub console_init_local()
    console_mutex = mutexcreate()
end sub ' console_init_local()

sub console_init_serial()
    console_mutex = mutexcreate()

    console_file_number = freefile()

    dim result as long
    dim serial_string as string

    serial_string = console_port & ":" & console_bps & "," & console_parity & "," & console_data_bits & "," & console_stop_bits & ",cs0,ds0,cd0,rs"

    result = open com(serial_string, as console_file_number)

    if err > 0 then
        message_print "console_init_serial():  error #" & trim(str(err)) & " occurred opening " & console_port & ":"
    end if

    print #console_file_number, chr(27) & "[2J"

end sub ' console_init_serial()

sub console_reset_local()

end sub ' console_reset_local()

sub console_reset_serial()

end sub ' console_reset_serial()

function console_input_local(port_number as ushort) as ushort

    select case port_number
        case (console_io_base + 0)
            return cursor_enabled
        case (console_io_base + 1)
            return sleep_duration
        case (console_io_base + 2)
            return horizontal_offset
        case (console_io_base + 3)
            return vertical_offset
		case (console_io_base + 4)
			console_refresh_local
			return asc(input(1))
        case else
            return 0
    end select
    
end function ' console_input_local()

function console_input_serial(port_number as ushort) as ushort

    select case port_number
        case (console_io_base + 0)
            return cursor_enabled
        case (console_io_base + 1)
            return sleep_duration
        case (console_io_base + 2)
            return horizontal_offset
        case (console_io_base + 3)
            return vertical_offset
		case (console_io_base + 4)
			return asc(input(1, console_file_number))
        case else
            return 0
    end select
    
end function ' console_input_serial()


sub console_output(port_number as ushort, value as ushort)

    dim i as integer

    select case port_number 
        case (console_io_base + 0)

            if value = 0 then
                cursor_enabled = 0
            else
                cursor_enabled = 1
            end if

        case (console_io_base + 1)
    
            sleep_duration = value
            
        case (console_io_base + 2)

            horizontal_offset = value

        case (console_io_base + 3)

            vertical_offset = value

        case (console_io_base + 4)

    	    for i = CONSOLE_OFFSET to CONSOLE_LIMIT - 1
                st_write_byte CONSOLE_PAGE, i, value
            next i

    end select

end sub ' console_output()

sub console_cycle_local(byval userdata as any ptr)
    

    do
	sleep sleep_duration, 1

	console_refresh_local

        if bus_get_stop_flag(0) = 1 then exit do
    loop

end sub ' console_cycle_local()

sub console_cycle_serial(byval userdata as any ptr)


    do
	sleep sleep_duration, 1

	console_refresh_serial

        if bus_get_stop_flag(0) = 1 then exit do
    loop


end sub ' console_cycle_serial()

sub console_refresh_local()
    dim i as integer
    dim c as ubyte


    dim old_row as integer
    dim old_col as integer

    dim col as ubyte = 1   'x 
    dim row as ubyte = 1   'y


    mutexlock console_mutex

    col = 1
    row = 1

    old_row = csrlin()
    old_col = pos()

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


end sub ' console_refresh_local()

sub console_refresh_serial()

    dim i as integer
    dim c as ubyte

    dim output_str as string

    dim col as ubyte = 1   'x 
    dim row as ubyte = 1   'y

    for i = CONSOLE_OFFSET to CONSOLE_LIMIT - 1
        c = st_read_byte(CONSOLE_PAGE, i)
	        

        output_str = chr(27) & "[" & trim(str(row + horizontal_offset)) & ";" & trim(str(col + vertical_offset)) & "H" & chr(c)

        print #console_file_number, output_str;
	        
        if col >= CONSOLE_WIDTH then
            row = row + 1
            col = 1
        else
            col = col + 1
        end if
    next i       


end sub ' console_refresh_serial()
