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