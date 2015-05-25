'
' cpu.bi
'

'
' Instruction Format
'
'PC +  0      7 8 9  C D F 10     
'     +--------+-+----+---+--------+
'     |OPCODE  |O|MOD |DSP|OPERAND | 
'     +--------+-+----+---+--------+
'     |BYTE 1  | BYTE 2   |BYTE 3  |
'     +--------+----------+--------+
'
' OPCODE    (instruction opcode) 0-255
' O         (operands following)   0 = no operands following; 1 = 1 operand following
' MOD       (addressing mode)  
'           0   0000 = immediate
'           1   0001 = register direct
'           2   0010 = memory direct
'           3   0011 = register direct + displacement
'           4   0100 = memory direct + displacement
'           5   0101 = register indirect
'           6   0110 = memory indirect
'           7   0111 = register indirect + displacement
'           8   1000 = memory indirect + displacement
' DISP      0   000 = 2 bytes displacement
'           1   001 = 4 bytes displacement
'           2   010 = 8 bytes displacement
'           3   011 = 16 bytes displacement
'           4   100 = 32 bytes displacement
'           5   101 = 64 bytes displacement
'           6   110 = 128 bytes displacement
'           7   111 = 256 bytes displacement
'
' BYTE 1 is the OPCODE byte
' BYTE 2 is the AMOD byte for the first operand, describing
'        its addressing mode. If the addressing mode is one of the register modes,
'        the operand will be one byte. If the addressing mode is a memory address,
'        the operand will be two bytes.
'
' The end of an instruction is indicated by a zero in the most significant bit of
' the AMOD byte of a given operand.
' 
' Example:
'
' STORE GA, [CP]+2


' 
' opcodes
'

#define OP_DATA	  000

#define OP_COPY   001

#define OP_ADD    003
#define OP_SUB    004
#define OP_MUL	  005
#define OP_DIV	  006
#define OP_SHL	  007
#define OP_SHR    008
#define OP_OR     009
#define OP_NOT    010
#define OP_AND    011
#define OP_XOR    012
#define OP_EQV    013
#define OP_CMP    014

#define OP_BRANCH 020
#define OP_BEQ	  021
#define OP_BNE	  022
#define OP_BZ     023
#define OP_BLT	  025
#define OP_BGT	  026

#define OP_SCALL  027
#define OP_LCALL  028
#define OP_ICALL  029
#define OP_SRET   030
#define OP_LRET   031
#define OP_IRET   032

#define OP_PUSH	  033
#define	OP_POP	  034

#define OP_NOP	  254
#define OP_HLT	  255

'
' addressing modes; 4 least significant bits
' 
#define AM_IMM    0
#define AM_REGD   1
#define AM_MEMD   2
#define AM_REGDD  3
#define AM_MEMDD  4
#define AM_REGI   5
#define AM_MEMI   6
#define AM_REGID  7
#define AM_MEMID  8

'
' addressing displacements; 4 most significant bits
'
#define AM_DISP1  0
#define AM_DISP2  1
#define AM_DISP3  2
#define AM_DISP4  3
#define AM_DISP5  4
#define AM_DISP6  5
#define AM_DISP7  6
#define AM_DISP8  7
#define AM_DISP9  8
#define AM_DISP10 9
#define AM_DISP11 10
#define AM_DISP12 11
#define AM_DISP13 12
#define AM_DISP14 13
#define AM_DISP15 14
#define AM_DISP16 15


'
' register names (string)
'

#define REG_PC "pc"

#define REG_EC "ec"
#define REG_ES "es"
#define REG_FL "fl"

#define REG_CP "cp"
#define REG_DP "dp"
#define REG_EP "ep"
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
#define NREG_FL 3

#define NREG_CP 20
#define NREG_DP 21
#define NREG_EP 22
#define NREG_SP 23
#define NREG_SO 24

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

'
' flags
'
#define FL_HALT 1
#define FL_TRACE 2
#define FL_OVERFLOW 4
#define FL_CARRY 8
#define FL_INTERRUPT 16
#define FL_EQUALITY 32
#define FL_LESSTHAN 64
#define FL_GREATERTHAN 128
#define FL_ZERO 256
#define FL_PRIVILEGE_LSB 512
#define FL_PRIVILEVE_MSB 1024
#define FL_PARITY 2048
#define FL_SIGN 4096
#define FL_DEBUG 8192

'
' privilege mask
' 
#define PL_MASK &H600

'
' privilege levels
'
#define PL_KERNEL 0
#define PL_DEVICE 1
#define PL_EXEC 2
#define PL_USER 3

type t_cpu_state            
                 
     pc as ushort	'program counter

     ec	as ushort	'error code
     es as ushort	'error severity
     fl as ushort   'flags

     cp as ushort   'code page
     dp as ushort   'data page
     ep as ushort   'extra page
     sp as ushort   'stack page
     so as ushort 	'stack offset

     ga as ushort	'general a
     gb as ushort	'general b
     gc	as ushort	'general c
     gd as ushort	'general d
     ge as ushort	'general e
     gf as ushort	'general f
     gg as ushort	'general g
     gh as ushort	'general h
     gi	as ushort	'general i
     gj as ushort	'general j
     gk as ushort	'general k
     gl as ushort	'general l
     gm as ushort	'general m
     gn as ushort	'general n
     go as ushort   'general o
     gp as ushort	'general p
end type

type t_instruction
     opcode as byte
     src_amod as byte
     src_bytecount as byte
     src_address(256) as byte
     dst_amod as byte
     dst_bytecount as byte
     dst_address(256) as byte
end type

common shared cpu_state as t_cpu_state

declare sub init_cpu()
declare sub cpu()
declare sub cpu_dump_state()
declare sub cpu_set_flag(flag as ushort)
declare sub cpu_clear_flag(flag as ushort)
declare function cpu_get_pl() as ubyte
declare sub cpu_set_pl(privilege_level as ubyte)
declare function cpu_get_flag(flag as ushort) as ubyte
declare function cpu_fetch() as ubyte
declare function cpu_decode(opcode as ubyte) as ubyte
declare sub cpu_set_reg_alpha(register as string, value as ushort)
declare function cpu_get_reg_alpha(register as string) as ushort
