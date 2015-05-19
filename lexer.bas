'
' lexer.bas
'

#include "lexer.bi"

function lex(input_str as string) as integer

    dim i as integer
    dim c as string
    dim b as string

    dim tmp_byte as byte
    dim tmp_int as integer
    dim tmp_float as double

    dim in_quoted_string as integer = 0

    dim recog_state as byte = LC_UNKNOWN
    lex_reset_storage

    for i = 1 to len(input_str)
    	
	c = mid(input_str, i, 1)

	select case c
	       case chr(34) ' double quote
	       	    if recog_state = LC_STR then
		       lex_post_string b
		       recog_state = LC_UNKNOWN
		       b = ""
		    else
		       recog_state = LC_STR
		    end if
       	       case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
	       	    b = b & c
		    if (recog_state <> LC_STR) and (recog_state <> LC_WORD) then
		       if recog_state <> LC_FLOAT then
		           recog_state = LC_NUM
                       end if
		    end if
	       case "."
	       	    b = b & c
	       	    if (recog_state <> LC_STR) and (recog_state <> LC_WORD) then
		       recog_state = LC_FLOAT
		    end if
	       case " "
	       	    if recog_state = LC_NUM then
		       if val(b) < 256 then 
		       	  lex_post_byte cubyte(val(b))
		       elseif val(b) >= 256 then
		       	  lex_post_int valint(b)		    
		       end if
		       b = ""		      
		       recog_state = LC_UNKNOWN
		    elseif recog_state = LC_FLOAT then
		       lex_post_float val(b)
		       b = ""
		       recog_state = LC_UNKNOWN
		    elseif recog_state = LC_WORD then
		       lex_post_word b
		       b = ""
		       recog_state = LC_UNKNOWN
		    elseif recog_state = LC_STR then
		       b = b & c
		    end if		  
	       case else
	       	    b = b & c
	       	    if recog_state <> LC_STR then
		       recog_state = LC_WORD
		    end if		      
	end select

    next i

    '
    ' handle running off the end with no space found
    '
    if recog_state = LC_NUM then
       if val(b) < 256 then 
   	  lex_post_byte cubyte(val(b))
       elseif val(b) >= 256 then
   	  lex_post_int valint(b)		    
       end if
    elseif recog_state = LC_FLOAT then
       lex_post_float val(b)
       b = ""
    elseif recog_state = LC_WORD then
       lex_post_word b
       b = ""
    elseif recog_state = LC_STR then
       print "lex(): unterminated string literal"
       exit function
    end if


#ifdef LEXDEBUG
    print "lexer_index = "; lexer_index
    for i = 0 to lexer_index - 1 
    	print trim(str(i));": ";

	print " lexer_class = "; lexer_entries(i).lexer_class;
	print " byteval = "; lexer_entries(i).byteval; " intval = "; lexer_entries(i).intval; 
	print " floatval = "; lexer_entries(i).floatval;
	print " strval = "; lexer_entries(i).strval
    next i
#endif


    return lexer_index
end function

sub lex_reset_storage()
    dim i as integer

    for i = 0 to (LEXSIZE - 1)
    	with lexer_entries(i)
	     .lexer_class = LC_UNKNOWN
	     .intval = 0
	     .floatval = 0
	     .byteval = 0
	     .strval = ""
	end with
    next i
    
    lexer_index = 0
end sub

sub lex_post_word(input_string as string)

    with lexer_entries(lexer_index)
    	 .lexer_class = LC_WORD
	 .strval = input_string
    end with

    if lexer_index <= LEXSIZE then
        lexer_index = lexer_index + 1
    else
	print "lex_post_word(): lexer overflow"
	exit sub
    end if

end sub

sub lex_post_string(input_string as string)

    with lexer_entries(lexer_index)
    	 .lexer_class = LC_STR
	 .strval = input_string
    end with
    

    if lexer_index <= LEXSIZE then
        lexer_index = lexer_index + 1
    else
	print "lex_post_string(): lexer overflow"
	exit sub
    end if

end sub

sub lex_post_byte(input_byte as byte)
    
    with lexer_entries(lexer_index)
    	 .lexer_class = LC_BYTE
	 .byteval = input_byte
    end with

    if lexer_index <= LEXSIZE then
        lexer_index = lexer_index + 1
    else
	print "lex_post_byte(): lexer overflow"
	exit sub
    end if

end sub

sub lex_post_int(input_int as integer)
    
    with lexer_entries(lexer_index)
    	 .lexer_class = LC_INT
	 .intval = input_int
    end with

    if lexer_index <= LEXSIZE then
        lexer_index = lexer_index + 1
    else
	print "lex_post_int(): lexer overflow"
	exit sub
    end if

end sub

sub lex_post_float(input_float as double)
    
    with lexer_entries(lexer_index)
    	 .lexer_class = LC_FLOAT
	 .floatval = input_float
    end with

    if lexer_index <= LEXSIZE then
        lexer_index = lexer_index + 1
    else
	print "lex_post_float(): lexer overflow"
	exit sub
    end if

end sub

function get_lexer_entry(entry_index as integer) as lexer_entry
    if entry_index <= lexer_index then
       return lexer_entries(entry_index)
    else
       print "get_lexer_entry(): lexer entry access out of bounds"
       end
    end if
end function