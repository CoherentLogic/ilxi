'
' error.bi
'

'
' 1 - 50: storage
'
#define ERR_INVALID_PAGE_ID 1
#define ERR_INVALID_OFFSET 2

' 
' 51-100: arithmetic
'
#define ERR_DIVZERO 51

'
' 101-150: i/o
'
#define ERR_INVALID_IOPORT 101

'
' 151-200: instruction decoder
'
#define ERR_INVALID_DATA_TYPE 151

declare sub machine_error(error_code as integer, severity as integer)