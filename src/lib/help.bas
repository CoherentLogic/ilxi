'
' help
'

#include "help.bi"

function help_get_topic(input_file as string, topic as string) as string


#ifndef __FB_LINUX__
  const endl as string = chr(13) & chr(10)
#else
  const endl as string = chr(10) 
#endif

   
   dim file_no as integer
   dim current_line as string
   dim topic_part as string
   dim topic_found as integer
   dim in_topic as integer
   dim topic_text as string
   
   file_no = freefile()	
   topic_found = 0
   in_topic = 0
   
   open input_file for input as #file_no
   
   do while not eof(file_no)
      line input #file_no, current_line
      
      if left(current_line, 1) = "@" Then

	 if topic_found = 1 then exit do
	 
	 topic_part = lcase(trim(mid(current_line, 2, len(current_line))))	       
	 
	 if topic_part = lcase(topic) then 
	    topic_found = 1
	 else
	    topic_found = 0
	 end if
      else
	 if topic_found = 1 then
	    topic_text = topic_text & current_line & endl
	 end if
      end if	    
   loop

   if topic_found = 0 then
      topic_text = "Topic " & topic & " not found."
   end if
   
   close #file_no

   return topic_text
end function

