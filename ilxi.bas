#include "ilxi.bi"
#include "cpu.bi"
#include "lexer.bi"

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
	       case "gr"
		    
	       case "dumpcpu"
	       	    cpu_dump_state
	       case "trace"
	       	    if trace = 0 then
		       trace = 1
		       print "trace on"
		    else
		       trace = 0
		       print "trace off"		             	
		    end if
		    
		    cpu_state.te = trace	
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