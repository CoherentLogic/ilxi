#include "ilxi.bi"
#include "cpu.bi"
#include "lexer.bi"
#include "storage.bi"
startup

sub startup()
    print "ILXI Virtual Machine"
    print " Copyright (C) 2015 Coherent Logic Development LLC"
    print ""

    init_cpu    
    cli

    end
end sub

sub cli()
    dim cli_cmd as string
    dim cmd_name as string
    dim trace as integer 

    dim arg_count as integer = 0

    trace = 0

    do
        line input "ilxi> ", cli_cmd	

	arg_count = lex(cli_cmd)
	cmd_name = get_lexer_entry(0).strval

	select case cmd_name
	       case "getr"
	       	    ilxi_getr get_lexer_entry(1).strval
	       case "setr"
	       	    dim regval as integer

		    if get_lexer_entry(2).lexer_class = LC_BYTE then
		       regval = get_lexer_entry(2).byteval
		    elseif get_lexer_entry(2).lexer_class = LC_INT then
		       regval = get_lexer_entry(2).intval
		    end if
   
	       	    ilxi_setr get_lexer_entry(1).strval, regval
	       case "getm"
	       	    dim le_from as lexer_entry
		    dim le_to as lexer_entry

		    dim m_from as integer
		    dim m_to as integer
		    
		    le_from = get_lexer_entry(1)
		    le_to = get_lexer_entry(2)

		    if le_from.lexer_class = LC_BYTE then 
		        m_from = le_from.byteval
		    else
		        m_from = le_from.intval
		    end if


		    if le_to.lexer_class = LC_BYTE then 
		        m_to = le_to.byteval
		    else
		        m_to = le_to.intval
		    end if
		   
		    dim i as integer
		    dim k as integer

		    for i = m_from to m_to step 8
		    	print
			print trim(ilxi_pad_left(hex(cpu_state.dp), "0", 4)); ":"; 
			print trim(ilxi_pad_left(hex(i), "0", 4)),
			for k = i to i + 7
			  	print ilxi_pad_left(hex(st_read_byte(cpu_state.dp, k)), "0", 2); " ";
			next k
			print " | ";
			for k = i to i + 7
			    if st_read_byte(cpu_state.dp, k) = 0 then print ".";
			    if st_read_byte(cpu_state.dp, k) > 0 then print chr(st_read_byte(cpu_state.dp, k));
			next k											   
		    next i
		    print
		    print
	       case "setm"
	       	    dim le_setm_addr as lexer_entry
		    dim le_setm_value as lexer_entry

		    dim setm_addr as integer
		    dim setm_value as integer

		    le_setm_addr = get_lexer_entry(1)
		    le_setm_value = get_lexer_entry(2)

		    
		    if le_setm_addr.lexer_class = LC_BYTE then
		        setm_addr = le_setm_addr.byteval
		    else
		       	setm_addr = le_setm_addr.intval
		    end if

		    setm_value = le_setm_value.byteval		 

		    st_write_byte cpu_state.dp, setm_addr, setm_value
    	       case "dumpcpu"
	       	    cpu_dump_state
	       case "trace"	       	  		    
		    cpu_state.te = get_lexer_entry(1).byteval
	       case "ver"
	       	    print "ILXI 0.1"
	       case "run"
	       	    cpu
	       case "reset"
	            init_cpu
		    cpu_state.te = trace
	       case else
	       	    shell cli_cmd
        end select

    loop until cli_cmd = "exit"
end sub

sub ilxi_getr(register as string)
    print ucase(register); ": "; trim(str(cpu_get_reg_alpha(lcase(register))))
end sub

sub ilxi_setr(register as string, value as integer)
    cpu_set_reg_alpha lcase(register), value
end sub

function ilxi_pad_left(input_str as string, pad_char as string, total_size as integer) as string
	 dim output_str as string
	 dim diff as integer
	 dim i as integer

	 diff = total_size - len(input_str)
	 
	 for i = 1 to diff
	     output_str = output_str & pad_char
	 next
	
 	 output_str = output_str & input_str
	 
	 return output_str
end function