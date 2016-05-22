'
' lexer.bas
'

#include "lexer.bi"

dim shared hex_number as byte = 0

function lex(input_str as string) as integer

    dim i as integer
    dim c as string
    dim b as string

    dim tmp_byte as byte
    dim tmp_int as integer
    dim tmp_float as double

    dim leader as string = ""

    dim recog_state as byte = LC_UNKNOWN

#ifdef LEXDEBUG
    print "initial recog_state = LC_UNKNOWN"
#endif

    lex_reset_storage

    for i = 1 to len(input_str)
	    	
		c = mid(input_str, i, 1)
	
		select case c
	        case chr(34) ' double quote
	            if recog_state = LC_STR then
	                lex_post_string b

#ifdef LEXDEBUG
    print "lex():  state transition (quote found) "; recog_state; "->";
#endif                    

	                recog_state = LC_UNKNOWN

#ifdef LEXDEBUG
    print recog_state
#endif

	                b = ""
                    if not (i + 1 >= len(input_str)) then
                        if mid(input_str, i + 1, 1) = " " or mid(input_str, i + 1, 1) = "," then
                            i += 1
                            continue for
                        end if
                    end if
	            else

#ifdef LEXDEBUG
    print "lex():  state transition (quote found) "; recog_state; "->";
#endif                    

	                recog_state = LC_STR
#ifdef LEXDEBUG
    print recog_state
#endif

	            end if
	        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
	            b = b & c
	            if (recog_state <> LC_STR) and (recog_state <> LC_WORD) then
	                if recog_state <> LC_FLOAT then

#ifdef LEXDEBUG
    print "lex():  state transition (found 0-9) "; recog_state; "->";
#endif                    


	                    recog_state = LC_NUM

#ifdef LEXDEBUG
    print recog_state
#endif

	                end if
	            end if
            case "a", "A", "b", "B", "c", "C", "d", "D", "e", "E", "f", "F"
                if recog_state = LC_NUM then
                    hex_number = 1
                    b = b & ucase(c)
                else
                    b = b & c
                end if                                
            case "h"
                if recog_state = LC_NUM and (mid(input_str, i + 1, 1) = " " or mid(input_str, i + 1, 1) = "," or i = len(input_str)) then
                    hex_number = 1
                else
                    b = b & c
                end if
	        case "."
	            b = b & c
	            if (recog_state <> LC_STR) and (recog_state <> LC_WORD) then

#ifdef LEXDEBUG
    print "lex():  state transition (found .) "; recog_state; "->";
#endif                    

	                recog_state = LC_FLOAT

#ifdef LEXDEBUG
    print recog_state
#endif

	            end if
	        case " ", ","
                leader = ""
                if hex_number = 1 and mid(input_str, i - 1, 1) = "h" then 
                    leader = "&H"
                else

                    if (recog_state <> LC_NUM) and (recog_state <> LC_STR) then

#ifdef LEXDEBUG
    print "lex():  state transition (found delimiter) "; recog_state; "->";
#endif                    
                        recog_state = LC_WORD
#ifdef LEXDEBUG
    print recog_state
#endif
                    end if

                end if

	            if recog_state = LC_NUM then
	                if val(leader & b) < 256 then                    
	                    lex_post_byte cubyte(val(leader & b))                       
	                elseif val(leader & b) >= 256 then
	                    lex_post_int valint(leader & b)		    
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

    leader = ""
    if hex_number = 1 and mid(input_str, i - 1, 1) = "h" then 
        leader = "&H"
    else

        if (recog_state <> LC_NUM) and (recog_state <> LC_STR) then
#ifdef LEXDEBUG
    print "lex():  state transition "; recog_state; "->";
#endif                    
            recog_state = LC_WORD
#ifdef LEXDEBUG
    print recog_state
#endif
        end if

    end if        

    if recog_state = LC_NUM then                
        if val(leader & b) < 256 then 
            lex_post_byte cubyte(val(leader & b))
        elseif val(leader & b) >= 256 then
            lex_post_int valint(leader & b)		    
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

#ifdef LEXDEBUG
    print "lex_reset_storage():  called"
#endif

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

#ifdef LEXDEBUG
    print "lex_post_word():  "; input_string
#endif



    hex_number = 0

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

#ifdef LEXDEBUG
    print "lex_post_string():  "; input_string
#endif


    hex_number = 0

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

sub lex_post_byte(input_byte as ubyte)

#ifdef LEXDEBUG
    print "lex_post_byte():  "; input_byte
#endif


    hex_number = 0
    
    with lexer_entries(lexer_index)
    	.lexer_class = LC_BYTE
        .byteval = input_byte
        .strval = trim(str(input_byte))
    end with

    if lexer_index <= LEXSIZE then
        lexer_index = lexer_index + 1
    else
        print "lex_post_byte(): lexer overflow"
        exit sub
    end if

end sub

sub lex_post_int(input_int as ushort)

#ifdef LEXDEBUG
    print "lex_post_int():  "; input_int
#endif

    
    hex_number = 0

    with lexer_entries(lexer_index)
        .lexer_class = LC_INT
        .intval = input_int
        .strval = trim(str(input_int))
    end with

    if lexer_index <= LEXSIZE then
        lexer_index = lexer_index + 1
    else
        print "lex_post_int(): lexer overflow"
        exit sub
    end if

end sub

sub lex_post_float(input_float as double)

    hex_number = 0
    
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