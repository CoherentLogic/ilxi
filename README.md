#ILXI Virtual Machine

ILXI provides a virtual computer, somewhat reminiscent of the microcomputers of the 1970s.

##Architecture Overview

###Memory Model

ILXI presents a 16-bit architecture with a 32-bit address bus.

The ILXI memory model consists of non-overlapping, 64Kb pages. Up to 
64K of these pages may be present, depending on options set at compile time.

The maximum amount of memory accessible in ILXI is 4096MB.

Addresses are in the form of *page*:*offset*, where *page* is typically 
one of the page registers CP, DP, EP, or SP, and *offset* is the number of
bytes from the beginning of the page by which the address is offset.

###Data Types

The native data types of ILXI are an 8-bit BYTE and a 16-bit WORD. Signed
and floating-point numbers are not natively supported at this time. WORD
registers employ big-endian byte ordering, as does main memory.

###Registers

The CPU exposes sixteen general-purpose WORD registers, GA through GP. 
The first five of these registers can also be accessed as ten BYTE 
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
distinct flags. They are summarized as follows:


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
This page is specified in the SP register, and the current stack position.
The stack grows downward from the top of this page, with the current
position specified in the SO (Stack Offset) register.

###Code Execution

A CPU instruction will be fetched from the memory location referred to
by the CP:PC register pair, decoded, and executed. PC will then be 
incremented.

Instructions (ICALL, SCALL, and LCALL) are provided for calling subroutines.
The RET family of instructions (IRET, SRET, and LRET) are provided to clean
up the stack and return.

##Addressing Modes

###Immediate

###Register-Direct

###Memory-Direct

###Register-Direct + Displacement

###Memory-Direct + Displacement

###Register-Indirect

###Memory-Indirect

###Register-Indirect + Displacement

###Memory-Indirect + Displacement

##Instruction Set

###COPY

###CPSZ

###ADD

###SUB

###MUL

###DIV

###SHL

###SHR

###OR

###NOT

###AND

###XOR

###EQV

###CMP

###CMPSZ

###CNS

###CSN

###BRANCH

###BEQ

###BNE

###BZ

###BLT

###BGT

###SCALL

###LCALL

###ICALL

###SRET

###LRET

###IRET

###PUSH

###POP

###IN

###OUT

###NOP

###HLT


##ILXI Interactive Commands

| Command | Description |
| --- | --- |
| loadpage, lp | Load memory page from host file |
| savepage, sp | Save memory page to host file |
| writesect, ws | Write sector to disk |
| assemble, a | Interactively assemble instructions to a memory page |
| disassemble, di | Disassemble instructions in memory |
| step | Single-step through a program |
| pushb	| Push a BYTE value onto the stack |
| pushw	| Push a WORD value onto the stack |
| getm | Dump memory pages to the screen |
| setm | Set the value of bytes or words in memory |
| getr | Get the value of a CPU register |
| setr | Set the value of a CPU register |
| dumpcpu, d | Display the current state of CPU registers and flags |
| trace | Toggles instruction tracing on and off |
| ver | Display the current version of ILXI |
| run | Run the CPU |
| reset | Re-initialize the CPU |
| help | Display online help topics |
| ?	| Display a list of ILXI operations |
| exit, quit | exit ILXI |

###loadpage, lp
loadpage - Load a memory page from host file

Syntax:  [loadpage|lp] *host-file* *page-number*

Details:

loadpage loads a single 64Kb page from a memory image file
on the host machine. This can be a program, assembled with
the xiasm assembler, or generated from other ILXI compilers.

###savepage, sp
savepage - Save a memory page to host file

Syntax:  [savepage|sp] *host-file* *page-index*

Details:

savepage saves a single 64Kb page from ilxi into the specified
memory image file on the host. When used with the assemble command,
this allows the user to use ILXI as an interactive program development
environment.

###writesect, ws
writesect - Write to one sector of an attached disk

Syntax: [writesect|ws] *page-number* *offset* *channel* *track* *sector*

Details:

writesect writes data from *page-number*:*offset* to the specified disk sector.

###assemble
assemble - interactively assemble instructions directly into memory

Syntax: assemble *origin*

Details:

assemble allows you to interactively assemble instructions into ILXI memory.
The starting address is EP:*origin*, where EP is the CPU's EP register.

###disassemble, di
disassemble - disassemble instructions in memory

Syntax: [disassemble|di] *starting-offset* *instruction-count*

Details:

disassemble will convert *instruction-count* instructions of machine code 
starting at CP:*starting-offset*

###step
step - single-step through program instructions

Syntax: step

Details:

step will advance the program counter register and execute the next instruction.

###getr
getr - get the value of a CPU register

Syntax: getr *register-name*

Details:

getr will return the value contained in the CPU register denoted by *register-name*

###setr
setr - set the value of a CPU register

Syntax: setr *register-name* *value*

Details:

setr will set the CPU register denoted by *register-name* to *value*

###pushb
pushb - push a BYTE value onto the stack

Syntax: pushb *byte-value*

Details:

pushb will push *byte-value* onto the stack, and update CPU registers
accordingly.

###pushw
pushw - push a WORD value onto the stack

Syntax: pushw *word-value*

Details:

pushw will push *word-value* onto the stack, and update CPU registers
accordingly.

###getm
getm - dump memory contents to screen

Syntax: getm *start-offset* *end-offset*

Details:

getm will display the contents of memory from DP:*start-offset* to
DP:*end-offset* on the screen.

###setm
setm - set the value of bytes or words in memory

Syntax: setm *offset* *value*

Details:

setm will write *value* to memory address DP:*offset*.
The *value* can be either a BYTE or a WORD.

###dumpcpu, d
dumpcpu - displays the state of CPU registers

Syntax: [dumpcpu|d]

Details:

The dumpcpu command will display the current contents of
all CPU registers and flags.

###trace
trace - toggle program trace

Syntax: trace *value*

Details:

trace will turn program trace on and off. *value* can be
either 1 or 0, where 1 turns tracing on and 0 turns tracing off.

In program trace mode, the CPU will halt after each instruction,
something like an automated single-step.

### ver
ver - display the current version of ILXI

Syntax:  ver

Details:

Displays the current version of ILXI.

###run
run - run the CPU

Syntax:  run

Details:

The "run" command will start the CPU running at address CP:PC

###reset
reset - re-initialize the CPU

Syntax:  reset

Details:

This command resets the CPU. The interrupt queue will be cleared,
registers zeroed, the INTERRUPT flag enabled, the ROM firmware reloaded,
the bus initialized, and signals initialized.

This command must be used in order to perform single-step operations
on a program after a program-generated HALT is encountered.

###help
help - display online help

Syntax:  help *topic*

Details:

Displays online help topic *topic* on the screen.

###?
? - display list of help topics

Syntax:  ?

Details:

Displays a list of available help topics

###exit, quit
exit - exit the ILXI environment

Syntax:  exit

Details:

Exits the ILXI environment.

###clear, cls
clear - clear the screen

Syntax:  [clear|cls]

Details:

Clears the ILXI screen.
