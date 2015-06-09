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
#include "console.bi"
#include "cpu.bi"

sub main(args as string)

    dim arg_count as integer = 0
    dim argi as integer = 0

    arg_count = lex(args)

    for argi = 0 to arg_count - 1
        do_asm get_lexer_entry(argi).strval, argi
    next argi
    
    end

end sub

sub do_asm(filename as string, argi as integer)

    dim output_file_name as string   
    dim line_count as integer = read_source_file(filename)

    initial_pass argi

    if udidx > 0 then       ' we have a need for a fix-up pass

        print ">>> PASS 2 [INFO]:   Attempting to resolve "; trim(str(udidx)); " symbol(s) left over from pass 1"

        dim i as integer
        dim e as undef_entry
        dim f as symtab_entry

        dim fixup_offset as ushort

        for i = 1 to udidx

            e = udtab(i)            
            fixup_offset = e.byte_offset

            f = lookup_symbol(e.e_key)

            if f.resolved = 0 then
                print ">>> PASS 2 [FATAL]: Unresolved symbol "; e.e_key
                end
            else
                print ">>> PASS 2 [INFO]:   Resolved symbol "; e.e_key; " (symbol found at offset "; hex(f.offset); "h, inserted at fix-up offset "; hex(fixup_offset); "h)"
                st_write_word argi, fixup_offset, f.offset
            end if   
                                               
        next i

    end if

    output_file_name = left(filename, instrrev(filename, ".") - 1) & ".bin"

    st_save_page output_file_name, argi

    print ">>> FILE OUTPUT [INFO]:  Produced "; output_file_name; " from "; filename

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


sub initial_pass(page_number as ushort)

    dim arg_count as integer = 0
    dim cur_arg as string
	dim t_sym as symtab_entry
	dim i as integer
   

    cpu_state.ep = page_number

	for i = 1 to ubound(input_lines)

        t_sym.resolved = 0

	    arg_count = lex(input_lines(i))
	    cur_arg = get_lexer_entry(0).strval
	    
	            
	    select case cur_arg
            case "PROGRAM"
	        case "ORIGIN"
                if get_lexer_entry(1).lexer_class = LC_BYTE then
                    asm_offset = get_lexer_entry(1).byteval
                else
                    asm_offset = get_lexer_entry(1).intval
                end if          
                print ">>> PASS 1 [INFO]:   Program ORIGIN set to offset "; hex(asm_offset)
            case "EQU"
                t_sym.e_key = get_lexer_entry(1).strval
                t_sym.e_class = SYMCLASS_EQU
                t_sym.strval = get_lexer_entry(2).strval
                t_sym.resolved = 1

                install_symbol t_sym
	        case "VAR"            
	            t_sym.e_key = get_lexer_entry(2).strval        
	            t_sym.e_type = get_lexer_entry(1).strval
                t_sym.e_class = SYMCLASS_VAR
	            t_sym.offset = asm_offset
                t_sym.resolved = 1

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
                        t_sym.byteval = get_lexer_entry(3).byteval                       
	                    st_write_word page_number, asm_offset, t_sym.wordval
	                    asm_offset += 2
	                case "BYTE"
	                    t_sym.byteval = get_lexer_entry(3).byteval
	                    t_sym.offset = asm_offset
	                    st_write_byte page_number, asm_offset, t_sym.byteval
	                    asm_offset += 1
	            end select
	
	            install_symbol t_sym
	        case "LABEL"
	            t_sym.e_key = get_lexer_entry(1).strval
	            t_sym.e_class = SYMCLASS_LABEL
	            t_sym.offset = asm_offset
                t_sym.resolved = 1

                install_symbol t_sym
	        case else
	            dim ts as string

                fixup_flag = 0
	            ts = expand_macros(input_lines(i))
	
	            print ">>> PASS 1 [OUTPUT]: "; ilxi_pad_left(hex(asm_offset), "0", 4); ":  "; ts
	
	            asm_assemble ts
                asm_offset += 1

                if fixup_flag = 1 then udtab(udidx).byte_offset = asm_offset - 2
	    end select
	next i
	
end sub ' initial_pass()

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
    tmp.resolved = 0
    tmp.e_class = SYMCLASS_LABEL    'what a hack...

    return tmp
end function

sub install_undef(uent as undef_entry)
    udidx += 1
    redim preserve udtab(udidx) as undef_entry

    udtab(udidx) = uent
end sub

function lookup_undef(key as string) as undef_entry
    dim i as integer

    for i = 1 to udidx
    next

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

    for i = 1 to len(input_string)
        c = mid(input_string, i, 1)

        select case c
            case "{"
                in_macro = 1
            case "}"
                in_macro = 0

                symbol = lookup_symbol(macro_name)
                                
                select case symbol.e_class
                    case SYMCLASS_EQU
                        if symbol.resolved = 0 then
                            print ">>> PASS 1 [FATAL]: Unresolved EQU symbol "; macro_name
                            end       
                        end if 

                        b &= trim(symbol.strval)
                    case SYMCLASS_VAR
                        if symbol.resolved = 0 then
                            print ">>> PASS 1 [FATAL]: Unresolved VAR symbol "; macro_name
                            end
                        end if

                        b &= trim(str(symbol.offset))

                    case SYMCLASS_LABEL
                        '
                        ' labels can be used before being declared - defer 
                        ' resolution until next pass if not resolved
                        '
                        if symbol.resolved = 0 then
                            print ">>> PASS 1 [INFO]:   Deferring resolution of '"; macro_name; "' until next pass"
                            
                            dim uent as undef_entry
                        
                            fixup_flag = 1

                            with uent
                                .e_key = macro_name
                                .byte_offset = asm_offset
                            end with                                

                            install_undef uent

                            b &= "0"                           
                        else
                            b &= trim(str(symbol.offset))
                        end if

                end select

                macro_name = ""
            case else
                if in_macro = 1 then
                    macro_name &= c
                else
                    b &= c
                end if
        end select    
    next i

    return b
end function

main command()  'call main sub, passing to it the command line
end
