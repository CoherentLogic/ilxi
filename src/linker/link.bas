/'
   ILXI Virtual Machine
   
   link.bas (external linker)
   
   Copyright 2016 John P. Willis <jpw@coherent-logic.com>
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
   
'/

#include "asm.bi"
#include "storage.bi"
#include "lexer.bi"
#include "util.bi"
#include "link.bi"
#include "console.bi"
#include "cpu.bi"
#include "libobj.bi"
#include "message.bi"

#define LNKE001 "LNKE001 INVALID OBJECT FILE OR OBJECT FILE CORRUPT"

dim shared relocation_table(1) as relocation_record
dim shared relct as integer = 0
dim shared base_addr as ushort = 0
dim shared current_page as ushort = 0

sub main(args as string)
    
    dim arg_count as integer = 0
    dim argi as integer = 0
    dim i as integer

    arg_count = lex(args)

    print "ILXI SEGMENTED LINKER V0.01    (C) COHERENT LOGIC DEVELOPMENT 2016"
    
    for i = 0 to arg_count - 1
        read_object get_lexer_entry(i).strval
    next
    
end sub

sub read_object(object_file as string)
    
    dim fnum as integer = freefile()
    dim objhdr as object_header
    dim relentr as relocation_entry
    dim sechdr as section_header
    dim i as integer
    dim reloc as relocation_record
    dim mcode as ubyte
    
    open object_file for binary as #fnum
    
    get #fnum, , objhdr
    
    if objhdr.magic <> "XIO" then
        tool_message MSG_ERROR, "LINK", LNKE001
        end
    end if
    
    ' read the relocation table
    for i = 0 to objhdr.relocation_count - 1
        get #fnum, , relentr
        
       
        with reloc
            .object_file = object_file
            .key = trim(relentr.key)
            .base_addr = base_addr
            .byte_offset = relentr.reference_offset
        end with   
        
        install_relocation reloc 
    next i
    
    get #fnum, , sechdr
    
    ' read in all of the machine code
    for i = sechdr.origin to sechdr.origin + sechdr.size
        get #fnum, , mcode
        
        st_write_byte current_page, i, mcode
    next i
    
    ' process relocations
    for i = 0 to relct - 1
        reloc = relocation_table(i)
        
        
    next i
        
    
    if sechdr.origin > 0 then
        for i = 0 to relct 
            if relocation_table(i).object_file = object_file then
                
            end if
        next i    
    end if
    
end sub

sub install_relocation(reloc as relocation_record)
    redim preserve relocation_table(relct) as relocation_record
    
    relocation_table(relct) = reloc
    
    relct += 1
end sub

main command()
end

/'
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
                print "FATAL UNRESOLVED SYMBOL "; e.e_key
                end
            else
                print ">>> PASS 2 [INFO]:   Resolved symbol "; e.e_key; " (symbol found at offset "; hex(f.offset); "h, inserted at fix-up offset "; hex(fixup_offset); "h)"
                st_write_word argi, fixup_offset, f.offset
            end if   
                                               
        next i

    end if


    st_save_page output_file_name, argi
'/
