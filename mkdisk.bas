'
' mkdisk.bas
'

#include "mkdisk.bi"
#include "disk.bi"
#include "lexer.bi"

sub main(args as string)

    dim arg_count as integer
    dim file_name as string 
    dim track_count as ushort

    arg_count = lex(args) 
   
    file_name = get_lexer_entry(0).strval

    track_count = val(get_lexer_entry(1).strval)    
    

    disk_create file_name, track_count

end sub

main command()
end