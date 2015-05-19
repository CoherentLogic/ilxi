'
' error.bi
'

'
' 1 - 50: storage
'
#define ERR_INVALID_PAGE_ID 1
#define ERR_INVALID_OFFSET 2


' 
' 51-100: scheduling
'

'
' 101-150: alu
'

declare sub machine_error(error_code as integer, severity as integer)