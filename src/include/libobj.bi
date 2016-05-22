
'
' OBJECT FILE FORMAT
'
' object_header
'   magic:                  must be XIO
'   relocation_count:       number of relocation_entry records
'
' relocation_entry:         1 per relocation entry
' 
' section_header:
'
' st_page:                  binary image

type object_header
    magic as string * 3 ' XIO
    symbol_count as integer
    relocation_count as integer  
    section_count as integer 
end type

' these are references to symbols
type relocation_entry
    key as string * 24
    reference_offset as ushort
    section_title as string * 16
    section_offset as ushort
end type

type section_header
    title as string * 16
    origin as ushort
    size as ushort
end type
