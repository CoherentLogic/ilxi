'
'
' xiasm.bas
'
' ILXIM external assembler
'
'
#include "libobj.bi"
#include "asm.bi"
#include "storage.bi"
#include "lexer.bi"
#include "util.bi"
#include "xiasm.bi"
#include "console.bi"
#include "cpu.bi"
#include "message.bi"
#include "asmerr.bi"

sub main(args as string)

    dim arg_count as integer = 0
    dim page as integer = 0

    arg_count = lex(args)
    
    redim input_lines(1) as string

	print "ILXI EXTERNAL ASSEMBLER V0.02    (C) COHERENT LOGIC DEVELOPMENT 2016"
	print ""
	print ""

    do_asm get_lexer_entry(0).strval, page
    
    end

end sub

sub do_asm(filename as string, page_number as integer)

    dim output_file_name as string   
    dim line_count as integer = read_source_file(filename)
    dim fnum as integer = freefile()

    dim obj_hdr as object_header
    dim rel_entr as relocation_entry
    dim section as section_header

    dim i as integer
    dim j as integer
    dim e as undef_entry
    dim f as symtab_entry
    dim cur_byte as ubyte
    dim sstr as string      'temp string for holding symtab output for listings
    
    list_heading "XIASM", filename
    
    output_file_name = left(filename, instrrev(filename, ".") - 1) & ".xio"

    open output_file_name for binary as #fnum

    section = assemble_section(page_number, filename)
    

    if udidx > 0 then       ' we have a need for a fix-up pass

        dim fixup_offset as ushort

        for i = 1 to udidx

            e = udtab(i)            
            fixup_offset = e.byte_offset

            f = lookup_symbol(e.e_key)

            if f.resolved = 1 then
                for j = 1 to s
            end if   
                                               
        next i

    end if

    with obj_hdr
        .magic = "XIO"
        .relocation_count = udidx
    end with
    
    put #fnum, , obj_hdr
    
   
    
    for i = 1 to udidx
        e = udtab(i)
        
        if len(e.e_key) > 24 then
            tool_message MSG_WARNING, "XIASM", ASMW001            
        end if
        
        with rel_entr
            .key = left(e.e_key, 24)
            .reference_offset = e.byte_offset
        end with
        
        put #fnum, , rel_entr
    next i
    


    for i = section.origin to section.origin + section.size
        cur_byte = st_read_byte(page_number, i)
        
        put #fnum, , cur_byte
    next i
    
    
    close #fnum

    list_output "", filename
    list_output "", filename
    list_output "   SYMBOL TABLE      CLASSES: 0 EQU, 1 VAR, 2 LABEL",filename
    list_output "", filename
    
    dim lfn as integer = freefile()
    dim lfnam as string = ucase(left(filename, instrrev(filename, ".") - 1)) & ".LIS"
    dim tst as symtab_entry
    
    open lfnam for append as #lfn
    
    print #lfn, "SYMB","CLASS","TYPE","RESOLVED","OFFSET","VALUE"
    print #lfn, string(80, "-")
    
    for i = 1 to stidx
        tst = symtab(i)
        
        print #lfn, tst.e_key, tst.e_class, tst.e_type,
        
        if tst.resolved = 1 then
            print #lfn, "LOCAL", 
        else
            print #lfn, "DEFER", 
        end if
        
        print #lfn, ilxi_pad_left(hex(tst.offset), "0", 4); "h", left(tst.strval, 10)
    next i
    
    print #lfn, ""
    print #lfn, ""
    print #lfn, "   ASSEMBLY OUTPUT SUMMARY"
    print #lfn, ""
    
    print #lfn, "SECTION", "ORIGIN", "SIZE"
    print #lfn, string(62, "-")
    
    print #lfn, trim(section.title), trim(ilxi_pad_left(hex(section.origin), "0", 4)); "h" , trim(ilxi_pad_left(hex(section.size), "0", 4)); "h"
    
    close #lfn

    tool_message MSG_INFO, "XIASM", ASMI001 + "FROM " + ucase(filename)

end sub

function read_source_file(filename as string) as integer


    redim input_lines(1) as string

    dim input_file_number as integer
    dim line_count as integer = 0
    dim tmp_line as string

    dim ifn as integer
    dim inc_file as string
    
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

        if left(ucase(tmp_line), 7) = "INCLUDE" then
            ifn = freefile()
            inc_file = mid(tmp_line, 9, len(tmp_line))
            open inc_file for input as #ifn
            if err > 0 then
                tool_message MSG_ERROR, "XIASM", ASME003 + ucase(inc_file)
                end
            end if
            do while not eof(ifn)
                line input #ifn, tmp_line
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
            close #ifn        
        else
            if (len(tmp_line) > 0) and (left(tmp_line, 1) <> ";") then
                line_count += 1
                redim preserve input_lines(line_count) as string
	    
                input_lines(line_count) = ltrim(tmp_line)
            end if
        end if
	loop

    close #input_file_number

    return line_count	

end function


function assemble_section(page_number as ushort, input_file as string) as section_header

    dim section as section_header
    dim arg_count as integer = 0
    dim cur_arg as string
	dim t_sym as symtab_entry
	dim i as integer
	dim origin as integer
	dim program_size as integer
	origin = 0

    cpu_state.ep = page_number

    section.title = "TEXT"

	for i = 1 to ubound(input_lines)

        t_sym.resolved = 0

	    arg_count = lex(input_lines(i))
	    cur_arg = get_lexer_entry(0).strval
	    
        with t_sym
            .e_key = ""
            .e_class = 0
            .e_type = ""
            .wordval = 0
            .byteval = 0
            .strval = ""
            .offset = 0
            .resolved = 0
        end with
        
	    select case cur_arg
            case "PROGRAM"
            case "SECTION"
                section.title = get_lexer_entry(1).strval            
	        case "ORIGIN"
                if get_lexer_entry(1).lexer_class = LC_BYTE then
                    asm_offset = get_lexer_entry(1).byteval
                else
                    asm_offset = get_lexer_entry(1).intval
                end if          
                tool_message MSG_INFO, "XIASM",  ASMI002 + ucase(hex(asm_offset))
				origin = asm_offset
                section.origin = origin
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

                listing i, ilxi_pad_left(hex(asm_offset), "0", 4), ucase(ts), input_file
	
	            asm_assemble ts
                asm_offset += 1

                if fixup_flag = 1 then udtab(udidx).byte_offset = asm_offset - 2
	    end select
	next i
	
	section.size = asm_offset - origin - 1
    
    return section
    
end function ' initial_pass()

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
        if udtab(i).e_key = key then
            return udtab(i)
        end if
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
                            print "FATAL UNRESOLVED EQU "; macro_name
                            end       
                        end if 

                        b &= trim(symbol.strval)
                    case SYMCLASS_VAR
                        if symbol.resolved = 0 then
                            print "FATAL UNRESOLVED VAR "; macro_name
                            end
                        end if

                        b &= trim(str(symbol.offset))

                    case SYMCLASS_LABEL
                        '
                        ' labels can be used before being declared - defer 
                        ' resolution until next pass if not resolved
                        '
                        if symbol.resolved = 0 then
                            
                            tool_message MSG_INFO, "XIASM",  ASMI003 + macro_name
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
