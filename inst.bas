'
' inst.bas
' 

#include "inst.bi"
#include "storage.bi"
#include once "asm.bi"
#include "cpu.bi"
#include "ilxi.bi"
#include "error.bi"

function inst_getbyte(op as t_operand, page as integer) as ubyte

    if op.register = 1 then
        if op.indirect = 0 then                'register direct

            select case op.low_byte
                case NREG_LA, NREG_LB, NREG_LC, NREG_LC, NREG_LD, NREG_LE, NREG_HA, NREG_HB, NREG_HC, NREG_HD, NREG_HE
                    return cubyte(cpu_get_reg(op.low_byte))
                case else
                    machine_error ERR_INVALID_DATA_TYPE, 10
                    exit function
            end select 
        else                                'register indirect             
            return st_read_byte(page, cpu_get_reg(op.low_byte) + op.displacement)
        end if
    elseif op.memory = 1 then
        if op.indirect = 0 then                'memory direct
            return st_read_byte(page, ((op.high_byte shl 8) or op.low_byte) + op.displacement)
        else                                'memory indirect
            dim ptr_offset as ushort = (op.high_byte shl 8) or op.low_byte
            dim ptr_val as ushort = st_read_word(page, ((op.high_byte shl 8) or op.low_byte))
    
            return st_read_byte(page, ptr_val + op.displacement)    
        end if
    elseif op.immediate = 1 then
        return op.low_byte
    end if

end function ' inst_getbyte()

function inst_getword(op as t_operand, page as integer) as ushort

    if op.register = 1 then
        if op.indirect = 0 then                'register direct

            select case op.low_byte
                case NREG_LA, NREG_LB, NREG_LC, NREG_LC, NREG_LD, NREG_LE, NREG_HA, NREG_HB, NREG_HC, NREG_HD, NREG_HE
                    machine_error ERR_INVALID_DATA_TYPE, 10
                case else
                    return cpu_get_reg(op.low_byte)
            end select 
        else                                'register indirect             
            return st_read_word(page, cpu_get_reg(op.low_byte) + op.displacement)
        end if
    elseif op.memory = 1 then
        if op.indirect = 0 then                'memory direct
            return st_read_word(page, ((op.high_byte shl 8) or op.low_byte) + op.displacement)
        else                                'memory indirect
            dim ptr_offset as ushort = (op.high_byte shl 8) or op.low_byte
            dim ptr_val as ushort = st_read_word(page, ((op.high_byte shl 8) or op.low_byte))
    
            return st_read_word(page, ptr_val + op.displacement)    
        end if
    elseif op.immediate = 1 then
        return ((op.high_byte shl 8) or op.low_byte)
    end if

end function ' inst_getword()

sub inst_setbyte(op as t_operand, page as integer, value as ubyte)

    if op.register = 1 then
        if op.indirect = 0 then                'register direct

            select case op.low_byte
                case NREG_LA, NREG_LB, NREG_LC, NREG_LC, NREG_LD, NREG_LE, NREG_HA, NREG_HB, NREG_HC, NREG_HD, NREG_HE
                    cpu_set_reg op.low_byte, value
                case else
                    machine_error ERR_INVALID_DATA_TYPE, 10
                    exit sub
            end select 
        else                                'register indirect             
            st_write_byte page, cpu_get_reg(op.low_byte) + op.displacement, value
        end if
    elseif op.memory = 1 then
        if op.indirect = 0 then                'memory direct
            st_write_byte page, ((op.high_byte shl 8) or op.low_byte) + op.displacement, value
        else                                'memory indirect
            dim ptr_offset as ushort = (op.high_byte shl 8) or op.low_byte
            dim ptr_val as ushort = st_read_word(page, ((op.high_byte shl 8) or op.low_byte))
    
            st_write_byte page, ptr_val + op.displacement, value    
        end if
    elseif op.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10        
        exit sub
    end if

end sub ' inst_setbyte()

sub inst_setword(op as t_operand, page as integer, value as ushort)

    if op.register = 1 then
        if op.indirect = 0 then                'register direct

            select case op.low_byte
                case NREG_LA, NREG_LB, NREG_LC, NREG_LC, NREG_LD, NREG_LE, NREG_HA, NREG_HB, NREG_HC, NREG_HD, NREG_HE
                    machine_error ERR_INVALID_DATA_TYPE, 10
                    exit sub
                case else
                    cpu_set_reg op.low_byte, value
            end select 
        else                                'register indirect             
            st_write_word page, cpu_get_reg(op.low_byte) + op.displacement, value
        end if
    elseif op.memory = 1 then
        if op.indirect = 0 then                'memory direct
            st_write_word page, ((op.high_byte shl 8) or op.low_byte) + op.displacement, value
        else                                'memory indirect
            dim ptr_offset as ushort = (op.high_byte shl 8) or op.low_byte
            dim ptr_val as ushort = st_read_word(page, ((op.high_byte shl 8) or op.low_byte))
    
            st_write_word page, ptr_val + op.displacement, value
        end if
    elseif op.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if

end sub ' inst_setword()

sub inst_copy(dest as t_operand, source as t_operand)

    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if

    dim source_page as ushort = cpu_state.ss
    dim dest_page as ushort = cpu_state.ds

'    if dest.data_type <> source.data_type then
'        machine_error ERR_INVALID_DATA_TYPE, 10
'        exit sub
'    end if
    
    select case dest.data_type
        case DT_BYTE
            inst_setbyte dest, dest_page, inst_getbyte(source, source_page)
        case DT_WORD
            inst_setword dest, dest_page, inst_getword(source, source_page)
    end select

end sub ' inst_copy()

sub inst_add(dest as t_operand, source as t_operand)

    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if   

    dim a1 as ushort
    dim a2 as ushort

    dim result as integer

    cpu_clear_flag FL_CARRY
    cpu_clear_flag FL_OVERFLOW   
    cpu_clear_flag FL_ZERO

    select case dest.data_type
        case DT_BYTE
            a1 = inst_getbyte(dest, cpu_state.dp)
            a2 = inst_getbyte(source, cpu_state.dp)

            result = a1 + a2
            if result > &HFF then 
                result = &HFE
                cpu_set_flag FL_CARRY
                cpu_set_flag FL_OVERFLOW
            end if

            inst_setbyte dest, cpu_state.dp, cubyte(result)
        case DT_WORD
            a1 = inst_getword(dest, cpu_state.dp)
            a2 = inst_getword(source, cpu_state.dp)

            result = a1 + a2
            if result > &HFFFF then 
                result = &HFFFE
                cpu_set_flag FL_CARRY
                cpu_set_flag FL_OVERFLOW
            end if

            inst_setword dest, cpu_state.dp, cushort(result)
    end select

    if result = 0 then cpu_set_flag FL_ZERO
    
end sub ' inst_add()

sub inst_sub(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if

end sub ' inst_sub()

sub inst_mul(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_mul()

sub inst_div(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_div()

sub inst_shl(dest as t_operand, count as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_shl()

sub inst_shr(dest as t_operand, count as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_shr()

sub inst_or(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_or()

sub inst_not(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_not()

sub inst_and(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_and()

sub inst_xor(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_xor()

sub inst_eqv(dest as t_operand, source as t_operand)
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
end sub ' inst_eqv()

sub inst_cmp(dest as t_operand, source as t_operand)

    cpu_clear_flag FL_EQUALITY
    cpu_clear_flag FL_LESSTHAN
    cpu_clear_flag FL_GREATERTHAN

    dim d as ushort
    dim s as ushort

    select case dest.data_type
        case DT_BYTE
            d = inst_getbyte(dest, cpu_state.dp)
            s = inst_getbyte(source, cpu_state.dp)
        case DT_WORD
            d = inst_getword(dest, cpu_state.dp)
            s = inst_getword(source, cpu_state.dp)
    end select

    if d = s then cpu_set_flag FL_EQUALITY
    if d < s then cpu_set_flag FL_LESSTHAN
    if d > s then cpu_set_flag FL_GREATERTHAN

end sub ' inst_cmp()

sub inst_branch(dest as t_operand)
    select case dest.data_type
        case DT_BYTE
            cpu_set_reg NREG_PC, inst_getbyte(dest, cpu_state.ds)
        case DT_WORD
            cpu_set_reg NREG_PC, inst_getword(dest, cpu_state.ds)
    end select
end sub ' inst_branch()

sub inst_beq(dest as t_operand)
    if cpu_get_flag(FL_EQUALITY) = 1 then inst_branch dest
end sub ' inst_beq()

sub inst_bne(dest as t_operand)
    if cpu_get_flag(FL_EQUALITY) = 0 then inst_branch dest
end sub ' inst_bne()

sub inst_blt(dest as t_operand)
    if cpu_get_flag(FL_LESSTHAN) = 1 then inst_branch dest
end sub ' inst_blt()

sub inst_bgt(dest as t_operand)
    if cpu_get_flag(FL_GREATERTHAN) = 1 then inst_branch dest
end sub ' inst_bgt()

sub inst_bz(dest as t_operand)
    if cpu_get_flag(FL_ZERO) = 1 then inst_branch dest
end sub ' inst_bz()

sub inst_scall(dest as t_operand)
    cpu_push_word cpu_get_reg(NREG_PC)

    select case dest.data_type
        case DT_BYTE
            cpu_state.pc = inst_getbyte(dest, cpu_state.ds)
        case DT_WORD
            cpu_state.pc = inst_getword(dest, cpu_state.ds)
    end select
end sub ' inst_scall()

sub inst_lcall(dest as t_operand, page as t_operand)
    cpu_push_word cpu_state.cp
    cpu_push_word cpu_state.pc

    select case dest.data_type
        case DT_BYTE
            cpu_state.pc = inst_getbyte(dest, cpu_state.ds)
            cpu_state.cp = inst_getbyte(page, cpu_state.ds)
        case DT_WORD
            cpu_state.pc = inst_getword(dest, cpu_state.ds)
            cpu_state.cp = inst_getword(page, cpu_state.ds)
    end select

end sub ' inst_lcall()

sub inst_icall(dest as t_operand)
    if dest.data_type <> DT_BYTE then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if

    
end sub ' inst_icall()

sub inst_sret()
    cpu_state.pc = cpu_pop_word()
end sub ' inst_sret()

sub inst_lret()
    cpu_state.pc = cpu_pop_word()
    cpu_state.cp = cpu_pop_word()
end sub ' inst_lret()

sub inst_iret()
    
end sub ' inst_iret()

sub inst_push(dest as t_operand)

    select case dest.data_type
        case DT_BYTE
            cpu_push_byte inst_getbyte(dest, cpu_state.ds)
        case DT_WORD
            cpu_push_word inst_getword(dest, cpu_state.ds)
    end select

end sub ' inst_push()

sub inst_pop(dest as t_operand)
    
    ' cannot store a result in an immediate value
    if dest.immediate = 1 then
        machine_error ERR_INVALID_DATA_TYPE, 10
        exit sub
    end if
    
    select case dest.data_type
        case DT_BYTE
            inst_setbyte dest, cpu_state.ds, cpu_pop_byte()
        case DT_WORD
            inst_setword dest, cpu_state.ds, cpu_pop_word()
    end select 

end sub ' inst_pop()

sub inst_hlt()
    cpu_set_flag FL_HALT
end sub ' inst_hlt()