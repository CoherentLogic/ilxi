'
'
' xiasm.bas
'
' ILXIM external assembler
'
'

#include "asm.bi"
#include "storage.bi"
#include "lexer.bi"
#include "util.bi"
#include "xiasm.bi"

sub main(args as string)

    dim arg_count as integer = 0
    dim argi as integer = 0

    arg_count = lex(args)

    for argi = 0 to arg_count - 1
        do_asm get_lexer_entry(argi).strval, argi
    next argi
    
    end

end sub

sub do_asm(filename as string)
   

    dim line_count as integer = read_source_file(filename)

    st_save_page output_file_name, 0    

end sub

function read_source_file(filename as string) as integer


    redim input_lines(1) as string

    dim input_file_number as integer
    dim line_count as integer = 0
    dim tmp_line as string

    input_file_number = freefile()
    open filename for input as #input_file_number

	do while not eof(input_file_number)
	
	    line input #input_file_number, tmp_line
	
        '
        ' ignore blank lines, leading and trailing whitespace, and comments
        ' 

        if instr(tmp_line, ";") > 0 then
            tmp_line = left(tmp_line, instr(tmp_line, ";") - 1)
        end if

        tmp_line = trim(tmp_line)

	    if (len(tmp_line) > 0) and (left(tmp_line, 1) <> ";") then
	        line_count += 1
	        redim preserve input_lines(line_count) as string
	    
	        input_lines(line_count) = ltrim(tmp_line)
	    end if
	loop

    close #input_file_number

    return line_count	

end function


function pass(pass_number as integer) as byte

    dim arg_count as integer = 0
    dim cur_arg as string
	dim t_sym as symtab_entry
	dim i as integer

	for i = 1 to ubound(input_lines)

	    arg_count = lex(input_lines(i))
	    cur_arg = get_lexer_entry(0).strval
	    
	            
	    select case cur_arg
	        case "ORIGIN"
	        case "PROGRAM"
	            output_file_name = get_lexer_entry(3).strval
	        case "SYMBOL"            
	            t_sym.e_key = get_lexer_entry(2).strval        
	            t_sym.e_type = get_lexer_entry(1).strval
	            t_sym.offset = asm_offset
	    
	            select case t_sym.e_type
	                case "ZSTRING"
	                    dim j as integer
	                    dim b as ubyte
	
	                    t_sym.offset = asm_offset
	
	                    for j = 1 to len(get_lexer_entry(3).strval)
	
	
	                        b = asc(mid(get_lexer_entry(3).strval, j, 1))    
	                        st_write_byte 0, asm_offset, b                            
	
	                        asm_offset += 1
	                    next j 
	
	                    asm_offset += 1
	                    
	                    t_sym.strval = get_lexer_entry(3).strval
	                case "WORD"
	'                    st_write_byte 0, asm_offset, 
	                    asm_offset += 2
	                case "BYTE"
	                    t_sym.byteval = get_lexer_entry(3).byteval
	                    t_sym.offset = asm_offset
	                    st_write_byte 0, asm_offset, t_sym.byteval
	                    asm_offset += 1
	            end select
	
	            install_symbol t_sym
	        case "LABEL"
	            t_sym.e_key = get_lexer_entry(1).strval
	            t_sym.e_type = "LABEL"
	            t_sym.offset = asm_offset
	        case else
	            dim ts as string
	            ts = expand_macros(input_lines(i))
	
	            print ilxi_pad_left(hex(asm_offset), "0", 4); ": "; ts
	
	            asm_assemble ts
	    end select
	next i
	
end function

sub install_symbol(sym_entry as symtab_entry)
    stidx += 1
    redim preserve symtab(stidx) as symtab_entry

    symtab(stidx) = sym_entry
end sub

function lookup_symbol(key as string) as symtab_entry
    dim i as integer

    for i = 1 to stidx
        if symtab(i).e_key = key then return symtab(i)
    next i

    dim tmp as symtab_entry
    tmp.offset = -1

    return tmp
end function

function expand_macros(input_string as string) as string

    dim macro_name as string
    dim label_name as string
    dim i as integer
    dim j as integer
    dim c as string = ""
    dim b as string = ""

    dim symbol as symtab_entry    

    dim in_macro as ubyte = 0
    dim in_label as ubyte = 0

    for i = 1 to len(input_string)
        c = mid(input_string, i, 1)

        select case c
            case "["
                in_label = 1
            case "]"
                in_label = 0

                symbol = lookup_symbol(label_name)

            case "{"
                in_macro = 1
            case "}"
                in_macro = 0

                symbol = lookup_symbol(macro_name)
                if symbol.offset = -1 then
                    print "Unresolved symbol "; macro_name
                    end
                end if

                b &= trim(str(symbol.offset))

                macro_name = ""
            case else
                if in_macro = 1 then
                    macro_name &= c
                elseif in_label = 1 then
                    label_name &= c         
                else
                    b &= c
                end if
        end select    
    next i

    return b
end function

main command()  'call main sub, passing to it the command line
end
