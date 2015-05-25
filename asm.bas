'
' asm.bas
'
' assembles instructions into dp:asm_offset
'

#include "asm.bi"
#include "cpu.bi"
#include "lexer.bi"
#include "storage.bi"
#include "ilxi.bi"

dim shared asm_offset as ushort

function asm_encode_amod(ops_following as ubyte, amod as ubyte, disp as ubyte) as ubyte
    '  7 6543 210
    ' +-+----+---+
    ' |O|MOD |DSP|
    ' +-+----+---+
    '  1 6318 421
    '  2 426
    '  8
    dim	t as ubyte = 0

    if ops_following = 1 then
        t or= (1 shl 7)
    end if    

    t or= (amod shl 3)   
    t or= (disp)

    return t
end function

function asm_amod_following(amod as ubyte) as ubyte
    return (amod and O_MASK) shr 7
end function

function asm_amod_amod(amod as ubyte) as ubyte
    return (amod and AMOD_MASK) shr 4
end function

function asm_amod_disp(amod as ubyte) as ubyte
    return (amod and DISP_MASK)
end function

function asm_encode_address(ops_following as ubyte, addr_string as string) as t_operand
    '
    '   xxxx    immediate
    '   %ga      reg direct
    '   #xxxx   mem direct
    '   (%ga)    reg indirect
    '   (#xxxx) mem indirect
    '   
    '   Any of the last 4 with +xxxx appended indicates displacement; 
    '   &H02-&HFF by powers of 2
    '

    dim byte_count as ubyte = 0
    dim addr_part as string
    dim addr_val as ushort
    dim amod as ubyte
    dim tmp as t_operand

    dim is_immediate as ubyte = 0
    dim is_register as ubyte = 0
    dim is_memory as ubyte = 0
    dim is_indirect as ubyte = 0
    dim has_displacement as ubyte = 0
    dim displacement as ubyte = 0

    select case left(addr_string, 1)
        case "%"
            is_register = 1
            addr_part = mid(addr_string, 2)
        case "#"
            is_memory = 1
            addr_part = mid(addr_string, 2)
        case "("
            is_indirect = 1
            
            select case mid(addr_string, 2, 1)
                case "%"
                    is_register = 1
                    addr_part = mid(addr_string, 3)
                    addr_part = left(addr_part, instr(addr_part, ")") - 1)
                case "#"
                    is_memory = 1
                    addr_part = mid(addr_string, 3)
                    addr_part = left(addr_part, instr(addr_part, ")") - 1)
            end select
        case else
            is_immediate = 1
    end select

    if instr(addr_string, "+") > 0 then 
        has_displacement = 1
        displacement = valint(mid(addr_string, instr(addr_string, "+") + 1))
    
        select case displacement
            case 2
                displacement = 0
            case 4
                displacement = 1
            case 8
                displacement = 2
            case 16
                displacement = 3
            case 32
                displacement = 4
            case 64
                displacement = 5
            case 128
                displacement = 6
            case 256
                displacement = 7
        end select
    end if

    if is_immediate = 1 then                ' immediate
        amod = asm_encode_amod(ops_following, AM_IMM, displacement)        
    elseif is_register = 1 then
        if is_indirect = 1 then
            if has_displacement = 1 then    ' register indirect + displacement
                amod = asm_encode_amod(ops_following, AM_REGID, displacement) 
            else                            ' reigster indirect, no displacement
                amod = asm_encode_amod(ops_following, AM_REGI, displacement)
            end if          
        else                                
            if has_displacement = 1 then    ' register direct + displacement
                amod = asm_encode_amod(ops_following, AM_REGDD, displacement)
            else                            ' register direct, no displacement
                amod = asm_encode_amod(ops_following, AM_REGD, displacement)
            end if
        end if
    elseif is_memory = 1 then
        if is_indirect = 1 then
            if has_displacement = 1 then    ' memory indirect + displacement
                amod = asm_encode_amod(ops_following, AM_MEMID, displacement) 
            else                            ' memory indirect, no displacement
                amod = asm_encode_amod(ops_following, AM_MEMI, displacement)
            end if          
        else                                
            if has_displacement = 1 then    ' memory direct + displacement
                amod = asm_encode_amod(ops_following, AM_MEMDD, displacement)
            else                            ' memory direct, no displacement
                amod = asm_encode_amod(ops_following, AM_MEMD, displacement)
            end if
        end if
    end if

    if is_memory = 1 then
        addr_val = valint(addr_part)        
        
        tmp.low_byte = addr_val and &HFF
        tmp.high_byte = (addr_val and &HFF00) shr 8

        if addr_val > 255 then
            tmp.byte_count = 2
        else
            tmp.byte_count = 1
        end if
    elseif is_register = 1 then
        addr_val = asm_encode_register(addr_part)
        
        tmp.low_byte = addr_val

        tmp.byte_count = 1
    endif
        
    tmp.amod = amod

    return tmp
end function

function asm_encode_register(register_name as string) as ubyte
    select case lcase(register_name)
        case "pc"
            return NREG_PC
        case "ec"
            return NREG_EC
        case "es"
            return NREG_ES
        case "hf"
            return NREG_HF
        case "rf"
            return NREG_RF
        case "ei"
            return NREG_EI
        case "te"
            return NREG_TE
        case "pl"
            return NREG_PL
        case "cp"
            return NREG_CP
        case "dp"
            return NREG_DP
        case "sp"
            return NREG_SP
        case "so"
            return NREG_SO
        case "ga"
            return NREG_GA
        case "gb"
            return NREG_GB
        case "gc"
            return NREG_GC
        case "gd"
            return NREG_GD
        case "ge"
            return NREG_GE
        case "gf"
            return NREG_GF
        case "gg"
            return NREG_GG
        case "gh"
            return NREG_GH
        case "gi"
            return NREG_GI
        case "gj"
            return NREG_GJ
        case "gk"
            return NREG_GK
        case "gl"
            return NREG_GL
        case "gm"
            return NREG_GM
        case "gn"
            return NREG_GN
        case "go"
            return NREG_GO
        case "gp"
            return NREG_GP
    end select       
end function

function asm_encode_opcode(instruction as string) as ubyte
    select case lcase(instruction)
        case "copy"
            return OP_COPY
        case "add"
            return OP_ADD
        case "sub"
            return OP_SUB
        case "mul"
            return OP_MUL
        case "div"
            return OP_DIV
        case "shl"
            return OP_SHL
        case "shr"
            return OP_SHR
        case "or"
            return OP_OR
        case "not"
            return OP_NOT
        case "and"
            return OP_AND
        case "xor"
            return OP_XOR
        case "eqv"
            return OP_EQV
        case "eq"
            return OP_EQ
        case "ne"
            return OP_NE
        case "gt"
            return OP_GT
        case "lt"
            return OP_LT
        case "ge"
            return OP_GE
        case "le"
            return OP_LE
        case "branch"
            return OP_BRANCH
        case "beq"
            return OP_BEQ
        case "bne"
            return OP_BNE
        case "ble"
            return OP_BLE
        case "bge"
            return OP_BGE
        case "blt"
            return OP_BLT
        case "bgt"
            return OP_BGT
        case "scall"
            return OP_SCALL
        case "lcall"
            return OP_LCALL
        case "icall"
            return OP_ICALL
        case "sret"
            return OP_SRET
        case "lret"
            return OP_LRET
        case "iret"
            return OP_IRET
        case "push"
            return OP_PUSH
        case "pop"
            return OP_POP
        case "nop"
            return OP_NOP
        case "hlt"
            return OP_HLT
    end select
end function

sub asm_assemble(instruction as string)

    dim op_size as ubyte = 1 ' instructions are always at least one byte long (for the opcode)
    dim arg_count as integer = 0
    dim operand_count as integer = 0
    dim opcode as ubyte = 0
    dim operand as t_operand
    dim ops_following as ubyte = 0

    dim i as integer

    dim inst as string

    arg_count = lex(instruction)
    
    inst = get_lexer_entry(0).strval
    opcode = asm_encode_opcode(inst)   

    st_write_byte cpu_state.dp, asm_offset, opcode
    asm_offset = asm_offset + 1

    select case opcode
        case OP_COPY, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SHL, OP_SHR, OP_OR, OP_NOT, OP_AND, OP_XOR, OP_EQV
            operand_count = 2
        case OP_EQ, OP_NE, OP_GT, OP_LT, OP_GE, OP_LE
            operand_count = 2
        case OP_BRANCH, OP_SCALL, OP_ICALL, OP_PUSH
            operand_count = 1
        case OP_LCALL
            operand_count = 2
        case OP_BEQ, OP_BNE, OP_BLE, OP_BGE, OP_BLT, OP_BGT
            operand_count = 3
        case OP_SRET, OP_LRET, OP_IRET, OP_POP, OP_NOP, OP_HLT
            operand_count = 0
    end select

    for i = 1 to operand_count

        if i < operand_count then
            ops_following = 1
        else
            ops_following = 0
        end if

        operand = asm_encode_address(ops_following, get_lexer_entry(i).strval)
            
        st_write_byte cpu_state.dp, asm_offset, operand.amod
        
        asm_offset = asm_offset + 1

        st_write_byte cpu_state.dp, asm_offset, operand.low_byte

        if operand.byte_count = 2 then
            asm_offset = asm_offset + 1
            st_write_byte cpu_state.dp, asm_offset, operand.high_byte
        end if
                
    next i

end sub

sub asm_assemble_interactive(origin_address as ushort)

    dim asm_prompt as string
    dim asm_inst as string

    asm_offset = origin_address

    do
        asm_prompt = ilxi_pad_left(hex(cpu_state.dp), "0", 4) & ":" & ilxi_pad_left(hex(asm_offset), "0", 4) & "  "
        line input asm_prompt, asm_inst

        if len(asm_inst) > 0 then
            asm_assemble asm_inst
    
            asm_offset = asm_offset + 1
        end if
    loop until asm_inst = ""
    
end sub