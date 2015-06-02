'
' xiasm.bi
'

type symtab_entry
    e_key as string
    e_type as string
    wordval as ushort
    byteval as ubyte
    strval as string

    offset as byte
end type

type undef_entry
    byte_offset as ubyte
    label_name as string
end type

dim shared symtab() as symtab_entry
dim shared undefs() as undef_entry

dim shared stidx as integer = 0
dim shared page_idx as integer = 0

dim shared input_lines() as string

declare sub install_symbol(sym_entry as symtab_entry)
declare function lookup_symbol(key as string) as symtab_entry
declare function expand_macros(input_string as string) as string
