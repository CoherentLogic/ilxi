'
' cpu.bi
'

'
' register names (string)
'

#define REG_PC "pc"

#define REG_EC "ec"
#define REG_ES "es"
#define REG_HF "hf"
#define REG_RF "rf"
#define REG_EI "ei"
#define REG_TE "te"
#define REG_PL "pl"

#define REG_CP "cp"
#define REG_DP "dp"
#define REG_SP "sp"
#define REG_SO "so"

#define REG_GA "ga"
#define REG_GB "gb"
#define REG_GC "gc"
#define REG_GD "gd"
#define REG_GE "ge"
#define REG_GF "gf"
#define REG_GG "gg"
#define REG_GH "gh"
#define REG_GI "gi"
#define REG_GJ "gj"
#define REG_GK "gk"
#define REG_GL "gl"
#define REG_GM "gm"
#define REG_GN "gn"
#define REG_GO "go"
#define REG_GP "gp"

'
' register encodings (numeric)
'

#define NREG_PC 0

#define NREG_EC 1
#define NREG_ES 2
#define NREG_HF 3
#define NREG_RF 4
#define NREG_EI 5
#define NREG_TE 6
#define NREG_PL 7

#define NREG_CP 20
#define NREG_DP 21
#define NREG_SP 22
#define NREG_SO 23

#define NREG_GA 40
#define NREG_GB 41
#define NREG_GC 42
#define NREG_GD 43
#define NREG_GE 44
#define NREG_GF 45
#define NREG_GG 46
#define NREG_GH 47
#define NREG_GI 48
#define NREG_GJ 49
#define NREG_GK 50
#define NREG_GL 51
#define NREG_GM 52
#define NREG_GN 53
#define NREG_GO 54
#define NREG_GP 55

type t_cpu_state
     pc as integer	'program counter

     ec	as integer	'error code
     es as integer	'error severity
     hf as integer	'halt flag
     rf as integer	'result flag
     ei	as integer	'enable interrupts
     te as integer	'trace enable
     pl as integer	'privilege level

     cp as integer      'code page
     dp as integer      'data page
     sp as integer      'stack page
     so as integer 	'stack offset

     ga as integer	'general a
     gb as integer	'general b
     gc	as integer	'general c
     gd as integer	'general d
     ge as integer	'general e
     gf as integer	'general f
     gg as integer	'general g
     gh as integer	'general h
     gi	as integer	'general i
     gj as integer	'general j
     gk as integer	'general k
     gl as integer	'general l
     gm as integer	'general m
     gn as integer	'general n
     go as integer      'general o
     gp as integer	'general p
end type

common shared cpu_state as t_cpu_state

declare sub init_cpu()
declare sub cpu()
declare sub cpu_dump_state()
declare function cpu_fetch() as byte
declare function cpu_decode(opcode as byte) as byte
declare sub cpu_set_reg_alpha(register as string, value as byte)
declare function cpu_get_reg_alpha(register as string) as byte