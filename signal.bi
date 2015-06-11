'
' signal.bi
'

#define SIGINT 2
#define SIG_IGN cptr(sighandler_t, 1)

type sighandler_t as sub cdecl (byval as integer)

declare function signal cdecl alias "signal" (byval signum as integer, byval handler as sighandler_t) as sighandler_t

declare sub signal_init()
declare sub signal_sigint(signum as integer)