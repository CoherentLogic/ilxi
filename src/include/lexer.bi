'
' lexer.bi
'

#define LEXSIZE 255

#define LC_UNKNOWN 0
#define LC_BYTE 1
#define LC_INT 2
#define LC_FLOAT 3
#define LC_WORD 4
#define LC_STR 5


' this define is for a number whose precise data type is as yet unknown
#define LC_NUM 6


type lexer_entry
     lexer_class as byte

     intval as ushort
     floatval as double
     byteval as ubyte
     strval as string
end type

dim shared lexer_entries(LEXSIZE) as lexer_entry
common shared lexer_index as integer

declare function lex(input_str as string) as integer
declare sub lex_reset_storage()
declare sub lex_post_byte(input_byte as ubyte)
declare sub lex_post_int(input_int as ushort)
declare sub lex_post_float(input_float as double)
declare sub lex_post_word(input_string as string)
declare sub lex_post_string(input_string as string)
declare function get_lexer_entry(entry_index as integer) as lexer_entry
