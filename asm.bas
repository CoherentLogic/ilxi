'
' asm.bas
'
' assembles instructions into ep:asm_offset
'

#include "asm.bi"
#include "cpu.bi"
#include "lexer.bi"
#include "storage.bi"
#include "util.bi"



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
    else
        t or= (0 shl 7)
    end if    

    t or= (amod shl 3)   
    t or= (disp)

    return t
end function ' asm_encode_amod()

function asm_amod_datatype(amod as ubyte) as ubyte
    return (amod and O_MASK) shr 7
end function ' asm_amod_datatype()

function asm_amod_amod(amod as ubyte) as ubyte
    return (amod and AMOD_MASK) shr 3
end function ' asm_amod_amod()

function asm_amod_disp(amod as ubyte) as ubyte
    return (amod and DISP_MASK)
end function ' asm_amod_disp()

function asm_decode_disp(disp as ubyte) as ushort
    select case disp
        case 0
            return 2
        case 1
            return 4
        case 2
            return 8
        case 3
            return 16
        case 4
            return 32
        case 5
            return 64
        case 6
            return 128
        case 7
            return 256
    end select       
end function ' asm_decode_disp()

function asm_encode_address(ops_following as ubyte, addr_string as string) as t_operand
    '
    '   xxxx    immediate    AM_IMM
    '   %ga     reg direct   AM_REGD
    '   #xxxx   mem direct   AM_MEMD
    '   (%ga)   reg indirect AM_REGI
    '   (#xxxx) mem indirect AM_MEMI
    '   
    '   Any of the last 4 with +xxxx appended indicates displacement; 
    '   &H02-&HFF by powers of 2 (AM_REGDD, AM_MEMDD, AM_REGID, AM_MEMID)
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
            addr_part = addr_string
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

        tmp.byte_count = 2 ' always assume byte count = 2 for memory
    elseif is_immediate = 1 then
        addr_val = valint(addr_part)

        tmp.low_byte = addr_val and &HFF
        tmp.high_byte = (addr_val and &HFF00) shr 8

        tmp.byte_count = 2  ' always assume byte count = 2 for immediate data   
    elseif is_register = 1 then
        addr_val = asm_encode_register(addr_part)
        
        tmp.low_byte = addr_val

        tmp.byte_count = 1
    endif
        
    tmp.amod = amod

    return tmp
end function ' asm_encode_address()

function asm_encode_register(register_name as string) as ubyte
    select case lcase(register_name)
        case "pc"
            return NREG_PC
        case "ec"
            return NREG_EC
        case "es"
            return NREG_ES
        case "fl"
            return NREG_FL
        case "cp"
            return NREG_CP
        case "dp"
            return NREG_DP
        case "ep"
            return NREG_EP
        case "sp"
            return NREG_SP
        case "so"
            return NREG_SO
        case "ss"
            return NREG_SS
        case "ds"
            return NREG_DS
        case "si"
            return NREG_SI
        case "di"
            return NREG_DI
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
        case "la"
            return NREG_LA
        case "lb"
            return NREG_LB
        case "lc"
            return NREG_LC
        case "ld"
            return NREG_LD
        case "le"
            return NREG_LE
        case "ha"
            return NREG_HA
        case "hb"
            return NREG_HB
        case "hc"
            return NREG_HC
        case "hd"
            return NREG_HD
        case "he"
            return NREG_HE
    end select       
end function ' asm_encode_register()

function asm_decode_register(reg as ubyte) as string
    select case reg
        case NREG_PC
            return "pc"
        case NREG_EC
            return "ec"
        case NREG_ES
            return "es"
        case NREG_FL
            return "fl"
        case NREG_CP
            return "cp"
        case NREG_DP
            return "dp"
        case NREG_EP
            return "ep"
        case NREG_SP
            return "sp"
        case NREG_SO
            return "so"
        case NREG_SS
            return "ss"
        case NREG_DS
            return "ds"
        case NREG_SI
            return "si"
        case NREG_DI
            return "di"
        case NREG_GA
            return "ga"
        case NREG_GB
            return "gb"
        case NREG_GC
            return "gc"
        case NREG_GD
            return "gd"
        case NREG_GE
            return "ge"
        case NREG_GF
            return "gf"
        case NREG_GG
            return "gg"
        case NREG_GH
            return "gh"
        case NREG_GI
            return "gi"
        case NREG_GJ
            return "gj"
        case NREG_GK
            return "gk"
        case NREG_GL
            return "gl"
        case NREG_GM
            return "gm"
        case NREG_GN
            return "gn"
        case NREG_GO
            return "go"
        case NREG_GP
            return "gp"
        case NREG_LA
            return "la"
        case NREG_LB
            return "lb"
        case NREG_LC
            return "lc"
        case NREG_LD
            return "ld"
        case NREG_LE
            return "le"
        case NREG_HA
            return "ha"
        case NREG_HB
            return "hb"
        case NREG_HC
            return "hc"
        case NREG_HD
            return "hd"
        case NREG_HE
            return "he"
    end select
end function ' asm_decode_register()

function asm_encode_opcode(instruction as string) as ubyte
    select case lcase(instruction)
        case "copy", "copy"
            return OP_COPY
        case "cpsz"
            return OP_CPSZ
        case "add", "add"
            return OP_ADD
        case "sub", "sub"
            return OP_SUB
        case "mul", "mul"
            return OP_MUL
        case "div", "div"
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
        case "cmp"
            return OP_CMP
        case "cmpsz"
            return OP_CMPSZ
        case "branch"
            return OP_BRANCH
        case "beq"
            return OP_BEQ
        case "bne"
            return OP_BNE
        case "blt"
            return OP_BLT        
        case "bgt"
            return OP_BGT
        case "bz"
            return OP_BZ
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
        case "in"
            return OP_IN
        case "out"
            return OP_OUT        
        case "nop"
            return OP_NOP
        case "hlt"
            return OP_HLT
    end select
end function ' asm_encode_opcode()

function asm_decode_opcode(opcode as ubyte) as string
    select case opcode
        case OP_COPY
            return "copy"
        case OP_CPSZ
            return "cpsz"
        case OP_ADD
            return "add"
        case OP_SUB
            return "sub"
        case OP_MUL
            return "mul"
        case OP_DIV
            return "div"
        case OP_SHL
            return "shl"
        case OP_SHR
            return "shr"
        case OP_OR
            return "or"
        case OP_NOT
            return "not"
        case OP_AND
            return "and"
        case OP_XOR
            return "xor"
        case OP_EQV
            return "eqv"
        case OP_CMP
            return "cmp"
        case OP_CMPSZ
            return "cmpsz"
        case OP_BRANCH
            return "branch"
        case OP_BEQ
            return "beq"
        case OP_BNE
            return "bne"
        case OP_BZ
            return "bz"
        case OP_BLT
            return "blt"
        case OP_BGT
            return "bgt"
        case OP_SCALL
            return "scall"
        case OP_LCALL
            return "lcall"
        case OP_ICALL
            return "icall"
        case OP_SRET
            return "sret"
        case OP_LRET
            return "lret"
        case OP_IRET
            return "iret"
        case OP_PUSH
            return "push"
        case OP_POP
            return "pop"
        case OP_IN
            return "in"
        case OP_OUT
            return "out"
        case OP_NOP
            return "nop"
        case OP_HLT
            return "hlt"
    end select      
end function ' asm_decode_opcode()

sub asm_assemble(instruction as string)

    dim op_size as ubyte = 1 ' instructions are always at least one byte long (for the opcode)
    dim arg_count as integer = 0
    dim operand_count as integer = 0
    dim opcode as ubyte = 0
    dim operand as t_operand
    dim ops_following as ubyte = 0
    dim data_type as ubyte = 0

    dim i as integer

    dim inst as string

    arg_count = lex(instruction)
    
    inst = get_lexer_entry(0).strval
    opcode = asm_encode_opcode(inst)   

    select case lcase(get_lexer_entry(1).strval)
        case "byte"
            data_type = DT_BYTE
        case "word"
            data_type = DT_WORD
    end select

    st_write_byte cpu_state.ep, asm_offset, opcode


    operand_count = asm_operand_count(opcode)

    for i = 2 to operand_count + 1
        
        asm_offset = asm_offset + 1
        
        operand = asm_encode_address(data_type, get_lexer_entry(i).strval)
            
'        print "operand_count: "; operand_count; " operand: "; i; " amod: "; hex(operand.amod);
'        print " low_byte: "; hex(operand.low_byte); " high_byte: "; hex(operand.high_byte)

        st_write_byte cpu_state.ep, asm_offset, operand.amod
        
        asm_offset = asm_offset + 1

        st_write_byte cpu_state.ep, asm_offset, operand.low_byte

        if operand.byte_count = 2 then
            asm_offset = asm_offset + 1
            st_write_byte cpu_state.ep, asm_offset, operand.high_byte
        end if
                
    next i

end sub ' asm_assemble()

function asm_operand_count(opcode as ubyte) as ubyte
    select case opcode
        case OP_COPY, OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_SHL, OP_SHR, OP_OR, OP_NOT, OP_AND, OP_XOR, OP_EQV
            return 2
        case OP_CMP, OP_LCALL
            return 2
        case OP_BRANCH, OP_SCALL, OP_ICALL, OP_PUSH, OP_POP
            return 1
        case OP_LCALL, OP_IN, OP_OUT
            return 2
        case OP_BEQ, OP_BNE, OP_BZ, OP_BLT, OP_BGT
            return 1
        case OP_SRET, OP_LRET, OP_IRET, OP_NOP, OP_HLT, OP_CPSZ, OP_CMPSZ
            return 0
    end select
end function ' asm_operand_count()

function asm_disassemble(page as ushort, offset as ushort) as string
    
    dim opcode as ubyte
    dim operands() as t_operand
    dim operand_count as ubyte
    dim i as ushort
    dim displacement as ushort
    dim ops_following as ubyte
    dim actual_amod as ubyte
    dim addr as ushort
    dim lsb as ubyte
    dim msb as ubyte
    dim tmp_str as string
    dim reg as ubyte

    opcode = st_read_byte(page, offset)
    operand_count = asm_operand_count(opcode)

    tmp_str &= asm_decode_opcode(opcode) & " "

    redim operands(operand_count) as t_operand

    for i = 1 to operand_count

        offset = offset + 1        

        ' get amod byte and increment the offset
        operands(i).amod = st_read_byte(page, offset)
        offset = offset + 1

        if i = 1 then
            select case asm_amod_datatype(operands(i).amod)
                case DT_BYTE
                    tmp_str &= "byte "
                case DT_WORD
                    tmp_str &= "word "
            end select
        end if 

        actual_amod = asm_amod_amod(operands(i).amod)

        displacement = asm_decode_disp(asm_amod_disp(operands(i).amod))

        select case actual_amod
            case AM_IMM   'immediate
            
                lsb = st_read_byte(page, offset)
                offset = offset + 1
                msb = st_read_byte(page, offset)
                addr = asm_bytes_to_ushort(lsb, msb)

                tmp_str &= trim(str(addr))                                                        
            
            case AM_REGD  'register direct
            
                reg = st_read_byte(page, offset)
                tmp_str &= "%" & asm_decode_register(reg)                
            
            case AM_MEMD  'memory direct

                lsb = st_read_byte(page, offset)
                offset = offset + 1
                msb = st_read_byte(page, offset)
                addr = asm_bytes_to_ushort(lsb, msb)

                tmp_str &= "#" & trim(str(addr))                                                                

            case AM_REGDD 'reg. direct + disp

                reg = st_read_byte(page, offset)
                tmp_str &= "%" & asm_decode_register(reg) & "+" & trim(str(displacement))

            case AM_MEMDD 'mem. direct + disp

                lsb = st_read_byte(page, offset)
                offset = offset + 1
                msb = st_read_byte(page, offset)
                addr = asm_bytes_to_ushort(lsb, msb)

                tmp_str &= "#" & trim(str(addr)) & "+" & trim(str(displacement))                                        
            case AM_REGI  'register indirect
            
                reg = st_read_byte(page, offset)
                tmp_str &= "(%" & asm_decode_register(reg) & ")"
    
            case AM_MEMI  'memory indirect

                lsb = st_read_byte(page, offset)
                offset = offset + 1
                msb = st_read_byte(page, offset)
                addr = asm_bytes_to_ushort(lsb, msb)

                tmp_str &= "(#" & trim(str(addr)) & ")"
            case AM_REGID 'reg. indirect + disp
    
                reg = st_read_byte(page, offset)
                tmp_str &= "(%" & asm_decode_register(reg) & ")+" & trim(str(displacement))
            
            case AM_MEMID 'mem. indirect + disp
                lsb = st_read_byte(page, offset)
                offset = offset + 1
                msb = st_read_byte(page, offset)
                addr = asm_bytes_to_ushort(lsb, msb)

                tmp_str &= "(#" & trim(str(addr)) & ")+" & trim(str(displacement))

        end select        

        if i < operand_count then tmp_str &= ","

    next i

    return tmp_str
end function ' asm_disassemble()

function asm_bytes_to_ushort(lsb as ubyte, msb as ubyte) as ushort
    return (msb shl 8) or lsb
end function ' asm_bytes_to_ushort() 

sub asm_assemble_interactive(origin_address as ushort)

    dim asm_prompt as string
    dim asm_inst as string

    asm_offset = origin_address

    do

        asm_prompt = ilxi_pad_left(hex(cpu_state.ep), "0", 4) & ":" & ilxi_pad_left(hex(asm_offset), "0", 4) & "  "
        line input asm_prompt, asm_inst

        if len(asm_inst) > 0 then
            asm_assemble asm_inst  
            asm_offset = asm_offset + 1
        else
            exit do
        end if

    loop until asm_inst = ""
    
end sub ' asm_assemble_interactive()