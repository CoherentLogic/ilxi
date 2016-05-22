'
' message.bi
'
#define MSG_INFO 0
#define MSG_WARN 1
#define MSG_WARNING 1
#define MSG_ERROR 2
#define MSG_LISTING 3

declare sub message_init()
declare sub message_print(output_string as string)
declare sub tool_message(msg_level as ubyte, tool as string, message as string, byval output_location as string = "")
declare sub list_heading(tool as string, byval input_file as string)
declare sub listing(line_number as integer, address as string, code_output as string, byval listfile as string)
declare sub list_output(msg as string, byval listfile as string)
dim shared message_row as integer
dim shared message_col as integer

