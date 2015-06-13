'
' message.bas
'

#include "message.bi"
#include "console.bi"

sub message_init()

    console_mutex = mutexcreate()

end sub ' message_init()

sub message_print(output_string as string)

    mutexlock console_mutex

    print output_string

    mutexunlock console_mutex

end sub ' message_print()