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
    dim srcmod as ubyte
    dim srcbytes as ubyte
    dim src as integer
    dim dstmod as ubyte
    dim dstbytes as ubyte
    dim dst as integer
    dim inst_size as ubyte

    dim tmp as t_operand
    tmp = asm_encode_address(1, "%ga")
    tmp = asm_encode_address(1, "#05")
    tmp = asm_encode_address(1, "#1024")
    tmp = asm_encode_address(1, "(%ga)+4")
    tmp = asm_encode_address(1, "(#05)+4")
    tmp = asm_encode_address(1, "(#1024)+4")

    cpu_clear_flag FL_HALT

    do	  
   	  opcode = cpu_fetch()
	  inst_size = cpu_decode(opcode)
                        

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
	  
	  if cpu_state.pc >= (PAGESIZE - 1) then
	     cpu_set_flag FL_HALT
	     cpu_state.ec = 0
	     cpu_state.es = 0
	  end if

	  if cpu_get_flag(FL_HALT) then
	     if cpu_state.es > 0 then
	     	print "cpu(): trap "; trim(str(cpu_state.ec)); " at pc = "; trim(str(cpu_state.pc))
	     else
	        print "cpu(): halt at pc = "; trim(str(cpu_state.pc))
	     end if
	     
	     exit do
	  end if

	  if (cpu_state.pc + inst_size) <= PAGESIZE then	 
	     cpu_state.pc = cpu_state.pc + inst_size
	  end if

	  if cpu_get_flag(FL_TRACE) then cpu_dump_state
      if cpu_get_flag(FL_DEBUG) then
        print ""
        print ilxi_pad_left(hex(cpu_state.cp), "0", 4); ":";
        print ilxi_pad_left(hex(cpu_state.pc), "0", 4); " ";

        print asm_disassemble(cpu_state.cp, cpu_state.pc)

        exit do
      end if        
    loop

    
end sub

function cpu_fetch() as ubyte
	 return st_read_byte(cpu_state.cp, cpu_state.pc)
end function

function cpu_decode(opcode as ubyte) as ubyte
	 return 1
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