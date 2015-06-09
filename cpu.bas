'
' cpu.bas
'

#include "cpu.bi"
#include "storage.bi"
#include "asm.bi"
#include "util.bi"
#include "inst.bi"
#include "console.bi"
#include "bus.bi"

sub init_cpu()
            
	with cpu_state
		.pc = 1
		
		.ec = 0
		.es = 0
		.fl = 0

		.cp = 0
		.dp = 0
        .ep = 0
		.sp = 0
		.so = PAGESIZE - 2

        .ss = 0
        .ds = 0
    
        .si = 0
        .di = 0
		
		.ga = 0
		.gb = 0
		.gc = 0
		.gd = 0
		.ge = 0
		.gf = 0
		.gg = 0
		.gh = 0
		.gi = 0
		.gj = 0
		.gk = 0
		.gl = 0
		.gm = 0
		.gn = 0
		.go = 0
		.gp = 0
	end with   

    cpu_set_flag FL_INTERRUPT	

    st_load_page "rom.bin", 0

    bus_init

end sub

sub cpu()

    dim clock_count as long = 0

    dim opcode as ubyte
    dim inst_pc as ushort
    dim op_count as ubyte
    dim i as ubyte
    dim displacement as ushort
    
    dim operands() as t_operand
    dim address_mode as ubyte
    dim data_type as ubyte

    cpu_clear_flag FL_HALT
    cls

    bus_start

    ' main cpu loop
    do	  

        inst_pc = cpu_state.pc

        if cpu_get_flag(FL_DEBUG) then
            print ilxi_pad_left(hex(cpu_state.cp), "0", 4); ":";
            print ilxi_pad_left(hex(inst_pc), "0", 4); " ";

            print asm_disassemble(cpu_state.cp, inst_pc)
        end if

        opcode = cpu_fetch()

        op_count = asm_operand_count(opcode)                        
        redim operands(op_count) as t_operand

        for i = 1 to op_count
            operands(i).amod = cpu_fetch()


            operands(i).data_type = asm_amod_datatype(operands(i).amod)
    
            address_mode = asm_amod_amod(operands(i).amod)
            displacement = asm_decode_disp(asm_amod_disp(operands(i).amod))

            select case address_mode
                case AM_IMM
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .high_byte = cpu_fetch()
                        .byte_count = 2
                        .immediate = 1
                    end with
                case AM_REGD
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .byte_count = 1
                        .register = 1
                    end with
                case AM_MEMD
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .high_byte = cpu_fetch()
                        .byte_count = 2
                        .memory = 1
                    end with
                case AM_REGDD
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .byte_count = 1
                        .displacement = displacement
                        .register = 1
                        .has_displacement = 1
                    end with
                case AM_MEMDD
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .high_byte = cpu_fetch()
                        .byte_count = 2
                        .displacement = displacement
                        .has_displacement = 1
                        .memory = 1
                    end with
                case AM_REGI
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .byte_count = 1
                        .register = 1
                        .indirect = 1
                    end with
                case AM_MEMI
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .high_byte = cpu_fetch()
                        .byte_count = 2
                        .memory = 1
                        .indirect = 1
                    end with
                case AM_REGID
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .byte_count = 1
                        .displacement = displacement
                        .register = 1
                        .indirect = 1
                        .has_displacement = 1
                    end with
                case AM_MEMID
                    with operands(i)
                        .low_byte = cpu_fetch()
                        .high_byte = cpu_fetch()
                        .byte_count = 2
                        .displacement = displacement
                        .memory = 1
                        .has_displacement = 1
                        .indirect = 1
                    end with
            end select                          
        next i

        select case opcode
            case OP_COPY		 		 
                inst_copy operands(1), operands(2) 
            case OP_CPSZ
                inst_cpsz          
            case OP_ADD
                inst_add operands(1), operands(2)
            case OP_SUB
                inst_sub operands(1), operands(2)
            case OP_MUL
                inst_mul operands(1), operands(2)
            case OP_DIV
                inst_div operands(1), operands(2)
            case OP_SHL
                inst_shl operands(1), operands(2)
            case OP_SHR
                inst_shr operands(1), operands(2)
            case OP_OR  
                inst_or operands(1), operands(2)
            case OP_NOT
                inst_not operands(1), operands(2)
            case OP_AND
                inst_and operands(1), operands(2)
            case OP_XOR
                inst_xor operands(1), operands(2)
            case OP_EQV
                inst_eqv operands(1), operands(2)
            case OP_CMP
                inst_cmp operands(1), operands(2)
            case OP_CMPSZ
                inst_cmpsz
            case OP_BRANCH
                inst_branch operands(1)
            case OP_BEQ
                inst_beq operands(1)
            case OP_BNE
                inst_bne operands(1)
            case OP_BLT
                inst_blt operands(1)
            case OP_BGT
                inst_bgt operands(1)
            case OP_BZ
                inst_bz operands(1)
            case OP_SCALL
                inst_scall operands(1)
            case OP_LCALL
                inst_lcall operands(1), operands(2)
            case OP_ICALL
                inst_icall operands(1)
            case OP_SRET
                inst_sret
            case OP_LRET
                inst_lret
            case OP_IRET
                inst_iret
            case OP_PUSH
                inst_push operands(1)
            case OP_POP
                inst_pop operands(1)
            case OP_NOP
                ' do nothing
            case OP_HLT
                inst_hlt
            case else

        end select

        ' WARNING  WARNING  WARNING
        '
        ' --- MUST NOT ALTER CP:PC AFTER THIS POINT!!!! ---
        '
        '

        if cpu_get_flag(FL_TRACE) then cpu_dump_state
	  
        if cpu_state.pc >= (PAGESIZE - 1) then
            cpu_set_flag FL_HALT
            cpu_state.ec = 0
            cpu_state.es = 0
        end if

        if cpu_get_flag(FL_HALT) then

            if cpu_state.es > 0 then
                print ""
                print "cpu(): trap "; trim(str(cpu_state.ec)); " at pc = "; trim(str(cpu_state.pc))
            else
                print ""
                print "cpu(): halt at "; ilxi_pad_left(hex(cpu_state.cp), "0", 4); ":"; ilxi_pad_left(hex(inst_pc), "0", 4)
            end if        
	     
            exit do
        end if

        if cpu_get_flag(FL_DEBUG) then exit do
        
    loop

    bus_stop

end sub ' cpu()

function cpu_fetch() as ubyte
    dim t_byte as ubyte = 0
    t_byte = st_read_byte(cpu_state.cp, cpu_state.pc)

    cpu_state.pc += 1

    return t_byte
end function ' cpu_fetch()

function cpu_get_effective_address(operand as t_operand) as ushort

end function ' cpu_get_effective_address()

sub cpu_push_byte(byteval as ubyte)
    st_write_byte cpu_state.sp, cpu_state.so, byteval
    
    cpu_state.so -= 1
end sub ' cpu_push_byte()

function cpu_pop_byte() as ubyte
    dim retval as ubyte
    
    retval = st_read_byte(cpu_state.sp, cpu_state.so)
    cpu_state.so += 1

    return retval
end function ' cpu_pop_byte()

sub cpu_push_word(wordval as ushort)
    st_write_word cpu_state.sp, cpu_state.so - 1, wordval
    cpu_state.so -= 2
end sub ' cpu_push_word()

function cpu_pop_word() as ushort
    dim retval as ushort

    retval = st_read_word(cpu_state.sp, cpu_state.so)
    cpu_state.so += 2
end function ' cpu_pop_word()

sub cpu_dump_state()
    dim x as t_cpu_state
    x = cpu_state

    print ""
    print ""
    print "Page Size:", PAGESIZE,"Page Count:",PAGECOUNT
    print ""
    print "PC "; ilxi_pad_left(hex(x.pc),"0",4), "EC "; ilxi_pad_left(hex(x.ec),"0",4), "ES "; ilxi_pad_left(hex(x.es),"0",4), "CP "; ilxi_pad_left(hex(x.cp),"0",4), "DP "; ilxi_pad_left(hex(x.dp),"0",4)
    print "EP "; ilxi_pad_left(hex(x.ep),"0",4), "SP "; ilxi_pad_left(hex(x.sp),"0",4), "SO "; ilxi_pad_left(hex(x.so),"0",4), "FL "; ilxi_pad_left(hex(x.fl),"0",4), "SS "; ilxi_pad_left(hex(x.ss),"0",4)
    print "DS "; ilxi_pad_left(hex(x.ds),"0",4), "SI "; ilxi_pad_left(hex(x.ds),"0",4), "DI "; ilxi_pad_left(hex(x.di),"0",4)
    print ""
    print "GA "; ilxi_pad_left(hex(x.ga),"0",4), "GB "; ilxi_pad_left(hex(x.gb),"0",4), "GC "; ilxi_pad_left(hex(x.gc),"0",4), "GD "; ilxi_pad_left(hex(x.gd),"0",4), "GE "; ilxi_pad_left(hex(x.ge),"0",4)
    print "GF "; ilxi_pad_left(hex(x.gf),"0",4), "GG "; ilxi_pad_left(hex(x.gg),"0",4), "GH "; ilxi_pad_left(hex(x.gh),"0",4), "GI "; ilxi_pad_left(hex(x.gi),"0",4), "GJ "; ilxi_pad_left(hex(x.gj),"0",4)
    print "GK "; ilxi_pad_left(hex(x.gk),"0",4), "GL "; ilxi_pad_left(hex(x.gl),"0",4), "GM "; ilxi_pad_left(hex(x.gm),"0",4), "GN "; ilxi_pad_left(hex(x.gn),"0",4), "GO "; ilxi_pad_left(hex(x.go),"0",4)
    print "GP "; ilxi_pad_left(hex(x.gp),"0",4)
    print ""
    print "Flags:"
    print ""
    print "HF="; cpu_get_flag(FL_HALT); " TF="; cpu_get_flag(FL_TRACE); " OF="; cpu_get_flag(FL_OVERFLOW);
    print " CF="; cpu_get_flag(FL_CARRY); " IF="; cpu_get_flag(FL_INTERRUPT); " EF="; cpu_get_flag(FL_EQUALITY);
    print " LF="; cpu_get_flag(FL_LESSTHAN); " GF="; cpu_get_flag(FL_GREATERTHAN); " ZF="; cpu_get_flag(FL_ZERO);
    print " PL="; cpu_get_pl(); " PF="; cpu_get_flag(FL_PARITY); " SF="; cpu_get_flag(FL_SIGN); " DF="; cpu_get_flag(FL_DEBUG);
    print ""

end sub ' cpu_dump_state()

sub cpu_set_flag(flag as ushort)
    cpu_state.fl = cpu_state.fl or flag
end sub ' cpu_set_flag()

sub cpu_clear_flag(flag as ushort)
    if cpu_get_flag(flag) = 1 then
        cpu_state.fl = (not cpu_state.fl) and flag
    end if
end sub ' cpu_clear_flag()

function cpu_get_flag(flag as ushort) as ubyte
    if (cpu_state.fl and flag) = flag then
        return 1
    else
        return 0
    end if
end function ' cpu_get_flag()

function cpu_get_pl() as ubyte
    return (cpu_state.fl and PL_MASK) shr 9
end function ' cpu_get_pl()

sub cpu_set_pl(privilege_level as ubyte)
    cpu_state.fl or= (privilege_level shl 9)
end sub ' cpu_set_pl()

sub cpu_set_reg_alpha(register as string, value as ushort)
    
    select case register
	    case REG_PC 	 
	    	 cpu_state.pc = value
	    case REG_EC
	    	 cpu_state.ec = value
	    case REG_ES
   	    	 cpu_state.es = value
        case REG_FL
             cpu_state.fl = value
	    case REG_CP
	    	 cpu_state.cp = value
	    case REG_DP
	    	 cpu_state.dp = value
        case REG_EP
             cpu_state.ep = value
	    case REG_SP
	    	 cpu_state.sp = value
	    case REG_SO
	    	 cpu_state.so = value
        case REG_SS
             cpu_state.ss = value
        case REG_DS
             cpu_state.ds = value
        case REG_SI
             cpu_state.si = value
        case REG_DI
             cpu_state.di = value
	    case REG_GA
	    	 cpu_state.ga = value
	    case REG_GB
	    	 cpu_state.gb = value
	    case REG_GC
	    	 cpu_state.gc = value
	    case REG_GD
	    	 cpu_state.gd = value
	    case REG_GE
	    	 cpu_state.ge = value
	    case REG_GF
	    	 cpu_state.gf = value
	    case REG_GG
	    	 cpu_state.gg = value
	    case REG_GH
	    	 cpu_state.gh = value
	    case REG_GI
	    	 cpu_state.gi = value
	    case REG_GJ
	    	 cpu_state.gj = value
	    case REG_GK
	    	 cpu_state.gk = value
	    case REG_GL
	    	 cpu_state.gl = value
	    case REG_GM
	    	 cpu_state.gm = value
	    case REG_GN
	    	 cpu_state.gn = value
	    case REG_GO
	    	 cpu_state.go = value
	    case REG_GP
	    	 cpu_state.gp = value
        
        ' LSB of regs GA through GE
        case REG_LA
            cpu_state.ga = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HA))
        case REG_LB
            cpu_state.gb = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HB))
        case REG_LC
            cpu_state.gc = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HC))
        case REG_LD
            cpu_state.gd = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HD))
        case REG_LE
            cpu_state.ge = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HE))

        'MSB of regs GA through GEs
        case REG_HA
            cpu_state.ga = asm_bytes_to_ushort(cpu_get_reg(NREG_LA), cubyte(value))
        case REG_HB
            cpu_state.gb = asm_bytes_to_ushort(cpu_get_reg(NREG_LB), cubyte(value))
        case REG_HC
            cpu_state.gc = asm_bytes_to_ushort(cpu_get_reg(NREG_LC), cubyte(value))
        case REG_HD
            cpu_state.gd = asm_bytes_to_ushort(cpu_get_reg(NREG_LD), cubyte(value))
        case REG_HE
            cpu_state.ge = asm_bytes_to_ushort(cpu_get_reg(NREG_LE), cubyte(value))
    end select
end sub ' cpu_set_reg_alpha()

function cpu_get_reg_alpha(register as string) as ushort

    select case register
	    case REG_PC 	 
	    	 return cpu_state.pc 
	    case REG_EC
	    	 return cpu_state.ec
	    case REG_ES
   	    	 return cpu_state.es
        case REG_FL
             return cpu_state.fl
	    case REG_CP
	    	 return cpu_state.cp
	    case REG_DP
	    	 return cpu_state.dp
        case REG_EP
             return cpu_state.ep
	    case REG_SP
	    	 return cpu_state.sp
	    case REG_SO
	    	 return cpu_state.so
        case REG_SS
            return cpu_state.ss
        case REG_DS
            return cpu_state.ds
        case REG_SI
            return cpu_state.si
        case REG_DI
            return cpu_state.di
	    case REG_GA
	    	 return cpu_state.ga
	    case REG_GB
	    	 return cpu_state.gb
	    case REG_GC
	    	 return cpu_state.gc
	    case REG_GD
	    	 return cpu_state.gd
	    case REG_GE
	    	 return cpu_state.ge
	    case REG_GF
	    	 return cpu_state.gf
	    case REG_GG
	    	 return cpu_state.gg
	    case REG_GH
	    	 return cpu_state.gh
	    case REG_GI
	    	 return cpu_state.gi
	    case REG_GJ
	    	 return cpu_state.gj
	    case REG_GK
	    	 return cpu_state.gk
	    case REG_GL	
	    	 return cpu_state.gl
	    case REG_GM
	    	 return cpu_state.gm
	    case REG_GN
	    	 return cpu_state.gn
	    case REG_GO
	    	 return cpu_state.go
	    case REG_GP
	    	 return cpu_state.gp

        case REG_LA
            return (cpu_state.ga and LSB_MASK)
        case REG_LB
            return (cpu_state.gb and LSB_MASK)
        case REG_LC
            return (cpu_state.gc and LSB_MASK)
        case REG_LD
            return (cpu_state.gd and LSB_MASK)
        case REG_LE
            return (cpu_state.ge and LSB_MASK)

        case REG_HA
            return (cpu_state.ga and MSB_MASK) shr 8
        case REG_HB
            return (cpu_state.gb and MSB_MASK) shr 8
        case REG_HC
            return (cpu_state.gc and MSB_MASK) shr 8
        case REG_HD
            return (cpu_state.gd and MSB_MASK) shr 8
        case REG_HE
            return (cpu_state.ge and MSB_MASK) shr 8

    end select

end function ' cpu_get_reg_alpha()

sub cpu_set_reg(register as ubyte, value as ushort)
    
    select case register
	    case NREG_PC 	 
	    	 cpu_state.pc = value
	    case NREG_EC
	    	 cpu_state.ec = value
	    case NREG_ES
   	    	 cpu_state.es = value
        case NREG_FL
             cpu_state.fl = value
	    case NREG_CP
	    	 cpu_state.cp = value
	    case NREG_DP
	    	 cpu_state.dp = value
        case NREG_EP
             cpu_state.ep = value
	    case NREG_SP
	    	 cpu_state.sp = value
	    case NREG_SO
	    	 cpu_state.so = value
        case NREG_SS
             cpu_state.ss = value
        case NREG_DS
             cpu_state.ds = value
        case NREG_SI
             cpu_state.si = value
        case NREG_DI
             cpu_state.di = value
	    case NREG_GA
	    	 cpu_state.ga = value
	    case NREG_GB
	    	 cpu_state.gb = value
	    case NREG_GC
	    	 cpu_state.gc = value
	    case NREG_GD
	    	 cpu_state.gd = value
	    case NREG_GE
	    	 cpu_state.ge = value
	    case NREG_GF
	    	 cpu_state.gf = value
	    case NREG_GG
	    	 cpu_state.gg = value
	    case NREG_GH
	    	 cpu_state.gh = value
	    case NREG_GI
	    	 cpu_state.gi = value
	    case NREG_GJ
	    	 cpu_state.gj = value
	    case NREG_GK
	    	 cpu_state.gk = value
	    case NREG_GL
	    	 cpu_state.gl = value
	    case NREG_GM
	    	 cpu_state.gm = value
	    case NREG_GN
	    	 cpu_state.gn = value
	    case NREG_GO
	    	 cpu_state.go = value
	    case NREG_GP
	    	 cpu_state.gp = value
        
        ' LSB of regs GA through GE
        case NREG_LA
            cpu_state.ga = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HA))
        case NREG_LB
            cpu_state.gb = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HB))
        case NREG_LC
            cpu_state.gc = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HC))
        case NREG_LD
            cpu_state.gd = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HD))
        case NREG_LE
            cpu_state.ge = asm_bytes_to_ushort(cubyte(value), cpu_get_reg(NREG_HE))

        'MSB of regs GA through GEs
        case NREG_HA
            cpu_state.ga = asm_bytes_to_ushort(cpu_get_reg(NREG_LA), cubyte(value))
        case NREG_HB
            cpu_state.gb = asm_bytes_to_ushort(cpu_get_reg(NREG_LB), cubyte(value))
        case NREG_HC
            cpu_state.gc = asm_bytes_to_ushort(cpu_get_reg(NREG_LC), cubyte(value))
        case NREG_HD
            cpu_state.gd = asm_bytes_to_ushort(cpu_get_reg(NREG_LD), cubyte(value))
        case NREG_HE
            cpu_state.ge = asm_bytes_to_ushort(cpu_get_reg(NREG_LE), cubyte(value))

    end select
end sub ' cpu_set_reg()

function cpu_get_reg(register as ubyte) as ushort

    select case register
	    case NREG_PC 	 
	    	 return cpu_state.pc 
	    case NREG_EC
	    	 return cpu_state.ec
	    case NREG_ES
   	    	 return cpu_state.es
        case NREG_FL
             return cpu_state.fl
	    case NREG_CP
	    	 return cpu_state.cp
	    case NREG_DP
	    	 return cpu_state.dp
        case NREG_EP
             return cpu_state.ep
	    case NREG_SP
	    	 return cpu_state.sp
	    case NREG_SO
	    	 return cpu_state.so
        case NREG_SS
             return cpu_state.ss
        case NREG_DS
             return cpu_state.ds
        case NREG_SI
             return cpu_state.si
        case NREG_DI
             return cpu_state.di
	    case NREG_GA
	    	 return cpu_state.ga
	    case NREG_GB
	    	 return cpu_state.gb
	    case NREG_GC
	    	 return cpu_state.gc
	    case NREG_GD
	    	 return cpu_state.gd
	    case NREG_GE
	    	 return cpu_state.ge
	    case NREG_GF
	    	 return cpu_state.gf
	    case NREG_GG
	    	 return cpu_state.gg
	    case NREG_GH
	    	 return cpu_state.gh
	    case NREG_GI
	    	 return cpu_state.gi
	    case NREG_GJ
	    	 return cpu_state.gj
	    case NREG_GK
	    	 return cpu_state.gk
	    case NREG_GL	
	    	 return cpu_state.gl
	    case NREG_GM
	    	 return cpu_state.gm
	    case NREG_GN
	    	 return cpu_state.gn
	    case NREG_GO
	    	 return cpu_state.go
	    case NREG_GP
	    	 return cpu_state.gp

        case NREG_LA
            return (cpu_state.ga and LSB_MASK)
        case NREG_LB
            return (cpu_state.gb and LSB_MASK)
        case NREG_LC
            return (cpu_state.gc and LSB_MASK)
        case NREG_LD
            return (cpu_state.gd and LSB_MASK)
        case NREG_LE
            return (cpu_state.ge and LSB_MASK)

        case NREG_HA
            return (cpu_state.ga and MSB_MASK) shr 8
        case NREG_HB
            return (cpu_state.gb and MSB_MASK) shr 8
        case NREG_HC
            return (cpu_state.gc and MSB_MASK) shr 8
        case NREG_HD
            return (cpu_state.gd and MSB_MASK) shr 8
        case NREG_HE
            return (cpu_state.ge and MSB_MASK) shr 8

    end select

end function ' cpu_get_reg()