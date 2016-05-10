#ILXI Virtual Machine

ILXI provides a virtual computer, somewhat reminiscent of the microcomputers of the 1970s.

##Architecture Overview

###Memory Model

ILXI presents a 16-bit architecture with a 32-bit address bus.

The ILXI memory model consists of non-overlapping, 64Kb pages. Up to 
64K of these pages may be present, depending on options set at compile time.

The maximum amount of memory accessible in ILXI is 4096MB.

Addresses are in the form of <page>:<offset>, where <page> is typically 
one of the page registers CP, DP, EP, or SP.

###Data Types

The native data types of ILXI are an 8-bit BYTE and a 16-bit WORD. Signed
and floating-point numbers are not natively supported at this time. WORD
registers employ big-endian byte ordering, as does main memory.

###Registers

The CPU exposes sixteen general-purpose WORD registers, GA through GP. 
The first five of these registers can also be accessed as ten eight-bit 
registers, LA through LE, and HA through HE, where Lx and Hx represent
the low-order and high-order bytes of the corresponding Gx register, 
respectively.

There are four page registers, CP, DP, EP, and SP. These are the Code 
Page, Data Page, Extra Page, and Stack Page registers, respectively.

There is a Stack Offset register, called SO.

There are two register pairs for memory block operations, SS:SI and DS:DI,
and a BP (Base Pointer) register for high-level subroutines.

The PC (Program Counter) register is used in conjunction with the CP 
(Code Page) register.

Finally, there are three registers indicating CPU state. These are
EC (Error Code), ES (Error Severity), and FL (Flags).

###Flags

The FL register is used to represent the present status of thirteen
distinct flags. They are summarized as follows


| Flag | Size (bits) | Meaning |
| --- | --- | --- |
| HF | 1 | HALT |
| TF | 1 | TRACE |
| OF | 1 | OVERFLOW |
| CF | 1 | CARRY |
| IF | 1 | INTERRUPT ENABLE |
| EF | 1 | EQUALITY |
| LF | 1 | LESS THAN |
| GF | 1 | GREATER THAN |
| ZF | 1 | ZERO |
| PL | 2 | PRIVILEGE LEVEL |
| PF | 1 | PARITY |
| SF | 1 | SIGN |
| DF | 1 | DEBUG |


###Stack

An ILXI program may define a stack at any memory page the user wishes.
This page is specified in the SP register, and the current stack position
The stack grows downward from the top of this page, with the current
position specified in the SO (Stack Offset) register.

###Code Execution

A CPU instruction will be fetched from the memory location referred to
by the CP:PC register pair, decoded, and executed. PC will then be 
incremented.

Instructions (ICALL, SCALL, and LCALL) are 


ILXI Interactive Commands

loadpage, lp - load memory segment from host file
savepage, sp    - save memory segment to host file
writesect, ws   - write sector to disk
assemble, a     - interactively assemble instructions to a memory segment
disassemble, di - disassemble instructions in memory
step            - single-step through a program
pushb		- push a byte to the stack
pushw		- push a word to the stack
getm		- dump memory segments to the screen
setm		- set the value of bytes or words in memory
getr		- get the value of a CPU register
setr		- set the value of a CPU register
dumpcpu, d	- display the current state of CPU registers
trace	 	- toggles instruction tracing
ver		- display the current version of ILXI
run		- run the CPU
reset		- re-initialize the CPU
help		- display online help topics
?		- display this list of ILXI operations
exit, quit	- exit ILXI

@loadpage
loadpage - Load a memory segment from host file

Syntax:  [loadpage|lp] <host-file> <segment-number>

Details:

loadpage loads a single 64Kb segment from a memory image file
on the host machine. This can be a program, assembled with
the xiasm assembler, or generated from other ILXI compilers.
@lp
lp - see help for "loadpage"
@savepage
savepage - Save a memory segment to host file

Syntax:  [savepage|sp] <host-file> <segment-index>

Details:

savepage saves a single 64Kb segment from ilxi into the specified
memory image file on the host. When used with the assemble command,
this allows the user to use ILXI as an interactive program development
environment.
@sp
sp - see help for "savepage"
@writesect
writesect - Write to one sector of an attached disk

Syntax: [writesect|ws] <segment-number> <offset> <channel> <track> <sector>

Details:

writesect writes data from segment-number:offset to the specified disk sector.
@ws
ws - see help for "writesect"
@assemble
assemble - interactively assemble instructions directly into memory

Syntax: assemble <origin>

Details:

assemble allows you to interactively assemble instructions into ILXI memory.
The starting address is EP:<origin>, where EP is the CPU's EP register.
@disassemble
disassemble - disassemble instructions in memory

Syntax: [disassemble|di] <starting-offset> <instruction-count>

Details:

disassemble will convert <instruction-count> instructions of machine code 
starting at CP:<starting-offset>
@di
di - see help for "disassemble"
@step
step - single-step through program instructions

Syntax: step

Details:

step will advance the program counter register and execute the next instruction.
@getr
getr - get the value of a CPU register

Syntax: getr <register-name>

Details:

getr will return the value contained in the CPU register denoted by <register-name>
@setr
setr - set the value of a CPU register

Syntax: setr <register-name> <value>

Details:

setr will set the CPU register denoted by <register-name> to <value>
@pushb
pushb - push a BYTE value onto the stack

Syntax: pushb <byte-value>

Details:

pushb will push <byte-value> onto the stack, and update CPU registers
accordingly.
@pushw
pushw - push a WORD value onto the stack

Syntax: pushw <word-value>

Details:

pushw will push <word-value> onto the stack, and update CPU registers
accordingly.
@getm
getm - dump memory contents to screen

Syntax: getm <start-offset> <end-offset>

Details:

getm will display the contents of memory from DP:<start-offset> to
DP:<end-offset> on the screen.
@setm
setm - set the value of bytes or words in memory

Syntax: setm <offset> <value>

Details:

setm will write <value> to memory address DP:<offset>.
The <value> can be either a BYTE or a WORD.
@dumpcpu
dumpcpu - displays the state of CPU registers

Syntax: [dumpcpu|d]

Details:

The dumpcpu command will display the current contents of
all CPU registers and flags.
@d
See help for "dumpcpu"
@trace
trace - toggle program trace

Syntax: trace <value>

Details:

trace will turn program trace on and off. <value> can be
either 1 or 0, where 1 turns tracing on and 0 turns tracing off.

In program trace mode, the CPU will halt after each instruction,
something like an automated single-step.
@ver
ver - display the current version of ILXI

Syntax:  ver

Details:

Displays the current version of ILXI.
@run
run - run the CPU

Syntax:  run

Details:

The "run" command will start the CPU running at address CP:PC
@reset
reset - re-initialize the CPU

Syntax:  reset

Details:

This command resets the CPU. The interrupt queue will be cleared,
registers zeroed, the INTERRUPT flag enabled, the ROM firmware reloaded,
the bus initialized, and signals initialized.

This command must be used in order to perform single-step operations
on a program after a program-generated HALT is encountered.
@help
help - display online help

Syntax:  help <topic>

Details:

Displays online help topic <topic> on the screen.
@?
? - display list of help topics

Syntax:  ?

Details:

Displays a list of available help topics
@exit
exit - exit the ILXI environment

Syntax:  exit

Details:

Exits the ILXI environment.
@quit
See help for "exit"
@registers
ILXI CPU Registers

0        8        16
+-----------------+
|        PC       |  PROGRAM COUNTER
+-----------------+
|        EC       |  ERROR CODE
+-----------------+
|        ES       |  ERROR SEVERITY
+-----------------+
|        FL       |  FLAGS
+-----------------+
|        CP       |  CODE PAGE
+-----------------+
|        DP       |  DATA PAGE
+-----------------+
|        EP       |  EXTRA PAGE
+-----------------+
|        SP       |  STACK PAGE
+-----------------+
|        SO       |  STACK OFFSET
+-----------------+
|        SS       |  SOURCE PAGE
+-----------------+
|        DS       |  DESTINATION PAGE
+-----------------+
|        SI       |  SOURCE INDEX
+-----------------+
|        DI       |  DESTINATION INDEX
+-----------------+
|        BP       |  BASE POINTER
+--------+--------+
|   LA   |   HA   |  GENERAL A
|        GA       | 
+--------+--------+
|   LB   |   HB   |  GENERAL B
|        GB       | 
+--------+--------+
|   LC   |   HC   |  GENERAL C
|        GC       | 
+--------+--------+
|   LD   |   HD   |  GENERAL D
|        GD       | 
+--------+--------+
|   LE   |   HE   |  GENERAL E
|        GE       | 
+-----------------+
|        GF       |  GENERAL F
+-----------------+
|        GG       |  GENERAL G
+-----------------+
|        GH       |  GENERAL H
+-----------------+
|        GI       |  GENERAL I
+-----------------+
|        GJ       |  GENERAL J
+-----------------+
|        GK       |  GENERAL K
+-----------------+
|        GL       |  GENERAL L
+-----------------+
|        GM       |  GENERAL M
+-----------------+
|        GN       |  GENERAL N
+-----------------+
|        GO       |  GENERAL O
+-----------------+
|        GP       |  GENERAL P
+-----------------+
@clear
clear - clear the screen

Syntax:  clear

Details:

Clears the ILXI screen.
@cls
See help for "clear"

