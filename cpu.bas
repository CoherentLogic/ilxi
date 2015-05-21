'
' cpu.bas
'

'
' instruction format
' 
' OPCODE SRCMOD SRCBYTES SRC DSTMOD DSTBYTES DST
'
#include "cpu.bi"
#include "storage.bi"

sub init_cpu()
    
    with cpu_state
       	 .pc = 0 
	 
	 .ec = 0
	 .es = 0
	 .hf = 0
	 .rf = 0
	 .ei = 1
	 .te = 0
	 .pl = 0
	 
	 .cp = 0
	 .dp = 0
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

    cpu_state.hf = 0

    do	  
    	  opcode = cpu_fetch()
	  inst_size = cpu_decode(opcode)


	  select case opcode
	  	 case OP_LOAD
		 
		 case OP_STORE
		 
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

		 case OP_EQ

		 case OP_NE

		 case OP_GT
		 
		 case OP_LT

		 case OP_GE

		 case OP_LE

		 case OP_BRANCH

		 case OP_BEQ

		 case OP_BNE
		 
		 case OP_BLE

		 case OP_BGE

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
		      cpu_state.hf = 1
		 case else

          end select
	  
	  if cpu_state.pc >= PAGESIZE then
	     cpu_state.hf = 1
	     cpu_state.ec = 0
	     cpu_state.es = 0
	  end if

	  if cpu_state.hf > 0 then
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

	  if cpu_state.te > 0 then cpu_dump_state
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
    print "PC "; x.pc, "EC "; x.ec, "ES "; x.es, "HF "; x.hf, "RF "; x.rf
    print "CP "; x.cp, "DP "; x.dp, "SP "; x.sp, "SO "; x.so, "EI"; x.ei
    print "TE "; x.te, "PL "; x.pl
    print ""
    print "GA "; x.ga, "GB "; x.gb, "GC "; x.gc, "GD "; x.gd, "GE "; x.ge 
    print "GF "; x.gf, "GG "; x.gg, "GH "; x.gh, "GI "; x.gi, "GJ "; x.gj 
    print "GK "; x.gk, "GL "; x.gl, "GM "; x.gm, "GN "; x.gn, "GO "; x.go
    print "GP "; x.gp
    print ""
end sub

sub cpu_set_reg_alpha(register as string, value as integer)
    
    select case register
	    case REG_PC 	 
	    	 cpu_state.pc = value
	    case REG_EC
	    	 cpu_state.ec = value
	    case REG_ES
     	    	 cpu_state.es = value
	    case REG_HF
	    	 cpu_state.hf = value
	    case REG_RF
	    	 cpu_state.rf = value
	    case REG_EI
	    	 cpu_state.ei = value
	    case REG_TE
	    	 cpu_state.te = value
	    case REG_PL
	    	 cpu_state.pl = value
	    case REG_CP
	    	 cpu_state.cp = value
	    case REG_DP
	    	 cpu_state.dp = value
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

function cpu_get_reg_alpha(register as string) as integer

    select case register
	    case REG_PC 	 
	    	 return cpu_state.pc 
	    case REG_EC
	    	 return cpu_state.ec
	    case REG_ES
     	    	 return cpu_state.es
	    case REG_HF
	    	 return cpu_state.hf
	    case REG_RF
	    	 return cpu_state.rf
	    case REG_EI
	    	 return cpu_state.ei
	    case REG_TE
	    	 return cpu_state.te
	    case REG_PL
	    	 return cpu_state.pl
	    case REG_CP
	    	 return cpu_state.cp
	    case REG_DP
	    	 return cpu_state.dp
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