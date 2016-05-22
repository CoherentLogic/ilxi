'
' xiasm.bi
'

#define SYMCLASS_EQU 0
#define SYMCLASS_VAR 1
#define SYMCLASS_LABEL 2

type symtab_entry
    e_key as string
    e_class as ubyte
    e_type as string
    wordval as ushort
    byteval as ubyte
    strval as string

    offset as ushort
    resolved as byte
end type

type undef_entry
    e_key as string
    byte_offset as ushort
end type


    

dim shared symtab() as symtab_entry
dim shared udtab() as undef_entry

dim shared fixup_flag as integer = 0

dim shared stidx as integer = 0
dim shared udidx as integer = 0
dim shared page_idx as integer = 0

dim shared input_lines() as string

declare sub install_symbol(sym_entry as symtab_entry)
declare function lookup_symbol(key as string) as symtab_entry
declare function expand_macros(input_string as string) as string
declare sub do_asm(filename as string, argi as integer)
declare sub main(args as string)
declare function read_source_file(filename as string) as integer
declare function assemble_section(page_number as ushort, input_file as string) as section_header
declare sub install_undef(uent as undef_entry)
declare function lookup_undef(key as string) as undef_entry
