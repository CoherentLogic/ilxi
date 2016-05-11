'
' signal.bas
'

#include "signal.bi"
#include "cpu.bi"

sub signal_init()

    signal(SIGINT, @signal_sigint)

end sub ' signal_init()

sub signal_sigint(signum as integer)
    
    print "signal_sigint():  interrupted at "; cpu_get_cppc()

    cpu_set_flag FL_HALT

end sub ' signal_sigint()