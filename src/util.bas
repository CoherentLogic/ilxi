'
' util.bas
'

function ilxi_pad_left(input_str as string, pad_char as string, total_size as integer) as string
	 dim output_str as string
	 dim diff as integer
	 dim i as integer

	 diff = total_size - len(input_str)
	 
	 for i = 1 to diff
	     output_str = output_str & pad_char
	 next
	
 	 output_str = output_str & input_str
	 
	 return output_str
end function

function file_exists(file_name as string) as integer

    dim file_num as integer = freefile()

    open file_name for input as #file_num

    if err > 0 then
        return 0
    else
        close #file_num
        return 1
    end if    

end function

