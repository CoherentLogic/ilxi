'
' cpu.bas
'

#include "cpu.bi"
#include "storage.bi"
#include "asm.bi"
#include "ilxi.bi"

sub init_cpu()
            
	with cpu_state
		.pc = 0 
		
		.ec = 0
		.es = 0
		.fl = 0

		.cp = 0
		.dp = 0
        .ep = 0
		.sp = 0
		.so = 0
		
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
	
end sub

sub cpu()

    dim opcode as ubyte
    dim inst_pc as ushort
    dim op_count as ubyte
    dim i as ubyte
    dim displacement as ushort
    
    dim operands() as t_operand
    dim address_mode as ubyte

    cpu_clear_flag FL_HALT

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
            address_mode = asm_amod_amod(operands(i).amod)
            displacement = asm_decode_disp(asm_amod_disp(operands(i).amod))

            select case address_mode
                case AM_IMM
                    operands(i).low_byte = cpu_fetch()
                    operands(i).high_byte = cpu_fetch()
                    operands(i).byte_count = 2
                    operands(i).immediate = 1
                case AM_REGD
                    operands(i).low_byte = cpu_fetch()
                    operands(i).byte_count = 1
                    operands(i).displacement = displacement
                    operands(i).register = 1
                    operands(i).has_displacement = 1
                case AM_MEMD
                    operands(i).low_byte = cpu_fetch()
                    operands(i).high_byte = cpu_fetch()
                    operands(i).byte_count = 2
                    operands(i).displacement = displacement
                    operands(i).memory = 1
                    operands(i).has_displacement = 1
                case AM_REGDD
                    operands(i).low_byte = cpu_fetch()
                    operands(i).byte_count = 1
                    operands(i).displacement = displacement
                    operands(i).register = 1
                    operands(i).has_displacement = 1
                case AM_MEMDD
                    operands(i).low_byte = cpu_fetch()
                    operands(i).high_byte = cpu_fetch()
                    operands(i).byte_count = 2
                    operands(i).displacement = displacement
                    operands(i).has_displacement = 1
                    operands(i).memory = 1
                case AM_REGI
                    operands(i).low_byte = cpu_fetch()
                    operands(i).byte_count = 1
                    operands(i).register = 1
                    operands(i).indirect = 1
                case AM_MEMI
                    operands(i).low_byte = cpu_fetch()
                    operands(i).high_byte = cpu_fetch()
                    operands(i).byte_count = 2
                    operands(i).memory = 1
                    operands(i).indirect = 1
                case AM_REGID
                    operands(i).low_byte = cpu_fetch()
                    operands(i).byte_count = 1
                    operands(i).displacement = displacement
                    operands(i).register = 1
                    operands(i).indirect = 1
                    operands(i).has_displacement = 1
                case AM_MEMID
                    operands(i).low_byte = cpu_fetch()
                    operands(i).high_byte = cpu_fetch()
                    operands(i).byte_count = 2
                    operands(i).displacement = displacement
                    operands(i).memory = 1
                    operands(i).has_displacement = 1
                    operands(i).indirect = 1
            end select                          
        next i

        select case opcode
            case OP_COPY		 		 
		 
            case OP_ADD
		 
            case OP_SUB
		 
            case OP_MUL
		 
            case OP_DIV
		 
            case OP_SHL

            case OP_SHR

            case OP_OR
		 
            case OP_NOT

            case OP_AND

            case OP_XOR

            case OP_EQV

            case OP_CMP

            case OP_BRANCH

            case OP_BEQ

            case OP_BNE

            case OP_BLT

            case OP_BGT
		 
            case OP_SCALL

            case OP_LCALL

            case OP_ICALL

            case OP_SRET
		 
            case OP_LRET

            case OP_IRET

            case OP_PUSH

            case OP_POP

            case OP_NOP
		      
            case OP_HLT
                cpu_set_flag FL_HALT
            case else

        end select

        if cpu_get_flag(FL_TRACE) then cpu_dump_state
	  
        if cpu_state.pc >= (PAGESIZE - 1) then
            cpu_set_flag FL_HALT
            cpu_state.ec = 0
            cpu_state.es = 0
        end if

        if cpu_get_flag(FL_HALT) then
            if cpu_state.es > 0 then
                print "cpu(): trap "; trim(str(cpu_state.ec)); " at pc = "; trim(str(cpu_state.pc))
            else
                print "cpu(): halt at "; ilxi_pad_left(hex(cpu_state.cp), "0", 4); ":"; ilxi_pad_left(hex(inst_pc), "0", 4)
            end if
	     
            exit do
        end if

        if cpu_get_flag(FL_DEBUG) then exit do
        
    loop

    
end sub

function cpu_fetch() as ubyte
    dim t_byte as ubyte = 0
    t_byte = st_read_byte(cpu_state.cp, cpu_state.pc)

    cpu_state.pc += 1

    return t_byte
end function

sub cpu_dump_state()
    dim x as t_cpu_state
    x = cpu_state

    print ""
    print ""
    print "Page Size:", PAGESIZE,"Page Count:",PAGECOUNT
    print ""
    print "PC "; x.pc, "EC "; x.ec, "ES "; x.es, "CP "; x.cp, "DP "; x.dp
    print "EP "; x.ep, "SP "; x.sp, "SO "; x.so, "FL "; x.fl
    print ""
    print "GA "; x.ga, "GB "; x.gb, "GC "; x.gc, "GD "; x.gd, "GE "; x.ge 
    print "GF "; x.gf, "GG "; x.gg, "GH "; x.gh, "GI "; x.gi, "GJ "; x.gj 
    print "GK "; x.gk, "GL "; x.gl, "GM "; x.gm, "GN "; x.gn, "GO "; x.go
    print "GP "; x.gp
    print ""
    print "Flags:"
    print ""
    print "HF="; cpu_get_flag(FL_HALT); " TF="; cpu_get_flag(FL_TRACE); " OF="; cpu_get_flag(FL_OVERFLOW);
    print " CF="; cpu_get_flag(FL_CARRY); " IF="; cpu_get_flag(FL_INTERRUPT); " EF="; cpu_get_flag(FL_EQUALITY);
    print " LF="; cpu_get_flag(FL_LESSTHAN); " GF="; cpu_get_flag(FL_GREATERTHAN); " ZF="; cpu_get_flag(FL_ZERO);
    print " PL=0 PF="; cpu_get_flag(FL_PARITY); " SF="; cpu_get_flag(FL_SIGN); " DF="; cpu_get_flag(FL_DEBUG);
    print ""
end sub

sub cpu_set_flag(flag as ushort)
    cpu_state.fl = cpu_state.fl or flag
end sub

sub cpu_clear_flag(flag as ushort)
    if cpu_get_flag(flag) = 1 then
        cpu_state.fl = (not cpu_state.fl) and flag
    end if
end sub

function cpu_get_flag(flag as ushort) as ubyte
    if (cpu_state.fl and flag) = flag then
        return 1
    else
        return 0
    end if
end function

function cpu_get_pl() as ubyte
    return (cpu_state.fl and PL_MASK) shr 9
end function

sub cpu_set_pl(privilege_level as ubyte)
    cpu_state.fl or= (privilege_level shl 9)
end sub

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
    end select
end sub

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
    end select

end function