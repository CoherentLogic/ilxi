'
' profile.bas
'
'  Adapted from PROFILE.BAS from the book "Visual Basic for MS-DOS Workshop"
'  and updated to use more modern syntax and static variable declaration.
'
'  Also, completely re-factored to use more modern error handling.
'

#include "profile.bi"

function profile_read(ini_file as string, ini_section as string, ini_key as string) as string
    
    dim tmp_section as string = "[" & ini_section & "]"
    dim file_num as integer
    dim section_flag as integer
    dim current_line as string

    file_num = freefile()
    open ini_file for input as #file_num

    if err > 0 then
        close #file_num
        return ""
    end if

    do until eof(file_num)

        line input #file_num, current_line

        if left(current_line, 1) = "[" then

            if instr(current_line, tmp_section) = 1 then
                section_flag = 1
            else
                section_flag = 0
            end if

        end if

        if section_flag = 1 then

            if instr(current_line, ini_key) = 1 then
                close #file_num            
                return trim(mid(current_line, instr(current_line, "=") + 1))              
            end if
        
        end if
   
    loop            

end function ' profile_read()

sub profile_write (ini_file as string, ini_section as string, ini_key as string, ini_value as string)

    dim tmp_section as string = "[" & ini_section & "]"    
    dim file_num as integer
    dim n as integer
    dim i as integer
    dim section_found as integer
    dim section_flag as integer
    dim key_found as integer
    dim new_line as integer

    redim p(1) as string

    file_num = freefile()
    open ini_file for input as #file_num

    if err > 0 then exit sub

    do until eof(file_num)

        n += 1
        redim preserve p(n) as string

        line input #file_num, p(n)
    
    loop

    close #file_num

    for i = 1 to n

        if left(p(i), 1) = "[" then
            if instr(p(i), tmp_section) = 1 then
                section_flag = 1
                section_found = i
            else
                section_flag = 0
            end if
        end if

        if section_flag = 1 then
            if instr(p(i), ini_key) = 1 then
                p(i) = ini_key & "=" & ini_value
                key_found = 1
                exit for
            end if
        end if
    
    next i

    if section_found = 0 then

        redim preserve p(n + 3)

        p(n + 2) = tmp_section
        p(n + 3) = ini_key & "=" & ini_value

        n += 3
    
    elseif key_found = 0 then

        new_line = section_found + 1

        redim preserve p(n + 1)

        for i = n to new_line step - 1
            p(i + 1) = p(i)
        next i

        p(new_line) = ini_key & "=" & ini_value
        
        n += 1

    end if

    file_num = freefile()
    open ini_file for output as file_num

    for i = 1 to n
        print #file_num, p(i)
    next i

    close #file_num

end sub ' profile_write()

