'
' ilxi.bas
'

#include "ilxi.bi"
#include "cpu.bi"
#include "lexer.bi"
#include "storage.bi"
#include "asm.bi"
#include "util.bi"
#include "console.bi"
#include "bus.bi"
#include "message.bi"

startup

sub startup()

    color 12,0: color 7,0       ' hack to get around weird terminal bug around 7 being the default
    cls
    
    message_init
    

    message_print "ILXIM Virtual Machine"
    message_print " Copyright (C) 2015 Coherent Logic Development LLC"
    message_print ""

    bus_clear
    console_attach

    init_cpu    
    cli

    end
end sub

sub cli()

    dim last_cmd as string
    dim cli_cmd as string
    dim cmd_name as string
    dim trace as integer 
    dim arg_count as integer = 0

    trace = 0

    do
        last_cmd = cli_cmd

        mutexlock console_mutex
	    line input "ilxim> ", cli_cmd	
        mutexunlock console_mutex
        
        if cli_cmd = "" then cli_cmd = last_cmd
       
        

	    arg_count = lex(cli_cmd)
	    cmd_name = get_lexer_entry(0).strval
	
	    select case cmd_name
            case "loadpage", "lp"
                dim img_file as string = get_lexer_entry(1).strval
                dim page_index as integer

                
                if get_lexer_entry(2).lexer_class = LC_BYTE then
                    page_index = get_lexer_entry(2).byteval
                else
                    page_index = get_lexer_entry(2).intval
                end if

                st_load_page img_file, page_index
            case "savepage", "sp"
                dim img_file as string = get_lexer_entry(1).strval
                dim page_index as integer

                
                if get_lexer_entry(2).lexer_class = LC_BYTE then
                    page_index = get_lexer_entry(2).byteval
                else
                    page_index = get_lexer_entry(2).intval
                end if

                st_save_page img_file, page_index
            case "assemble", "a"
                dim le_origin as lexer_entry
                dim origin_addr as ushort

                if get_lexer_entry(1).lexer_class = LC_BYTE then
                    origin_addr = get_lexer_entry(1).byteval
                else
                    origin_addr = get_lexer_entry(1).intval
                end if

                asm_assemble_interactive origin_addr
            case "disassemble", "di"
                dim page_addr as ushort              
                dim start_offset_addr as ushort
                dim da_count as ushort

                page_addr = cpu_state.cp

                if get_lexer_entry(1).lexer_class = LC_BYTE then
                    start_offset_addr = get_lexer_entry(1).byteval
                else
                    start_offset_addr = get_lexer_entry(1).intval
                end if

                if get_lexer_entry(2).lexer_class = LC_BYTE then
                    da_count = get_lexer_entry(2).byteval
                else
                    da_count = get_lexer_entry(2).intval
                endif

                asm_disassemble_range page_addr, start_offset_addr, da_count

            case "step"            
                if cpu_get_flag(FL_HALT) = 0 then
                    if cpu_get_flag(FL_DEBUG) = 0 then cpu_set_flag FL_DEBUG
                    cpu             	    
                else
                    message_print "cli():  CPU is halted. Type 'reset' at the prompt before attempting 'step'."
                end if

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
            case "pushb"
                cpu_push_byte get_lexer_entry(1).byteval
            case "pushw"
                cpu_push_word get_lexer_entry(1).intval
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

                mutexlock console_mutex
	
	            for i = m_from to m_to step 8
	                print
	                print trim(ilxi_pad_left(hex(cpu_state.dp), "0", 4)); ":"; 
	                print trim(ilxi_pad_left(hex(i), "0", 4)),
	                
	                for k = i to i + 7
	                    print ilxi_pad_left(hex(st_read_byte(cpu_state.dp, k)), "0", 2); " ";
	                next k
	    
	                print " | ";
			
	                for k = i to i + 7
	                    if st_read_byte(cpu_state.dp, k) <= 31 then color 12,0: print ".";: color 7,0
	                    if st_read_byte(cpu_state.dp, k) > 31 then color 7,0: print chr(st_read_byte(cpu_state.dp, k));
	                next k											   
	            next i
		    
	            print
	            print

                mutexunlock console_mutex

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
	        case "dumpcpu","d"
	       	    cpu_dump_state
	        case "trace"	       	  		    
	            if get_lexer_entry(1).byteval = 0 then
                    cpu_clear_flag FL_TRACE
                else
                    cpu_set_flag FL_TRACE
                end if
	        case "ver"
	       	    print "ILXI 0.1"
	        case "run"
                if cpu_get_flag(FL_HALT) = 0 then
                    cpu_clear_flag FL_DEBUG
               	    cpu
                else
                    message_print "cli():  CPU is halted. Type 'reset' at the prompt before attempting 'run'."
                end if
	        case "reset"
	            init_cpu	            
            case "exit"
                end
	        case else
	       	    message_print "cli():  invalid command '" & cmd_name & "'"
	    end select
	
    loop until cli_cmd = "exit"
end sub

sub ilxi_getr(register as string)   
    message_print ucase(register) & ": " & trim(hex(cpu_get_reg_alpha(lcase(register))))
end sub

sub ilxi_setr(register as string, value as integer)
    cpu_set_reg_alpha lcase(register), value
end sub

