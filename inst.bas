'
' inst.bas
' 

#include "inst.bi"
#include "storage.bi"
#include once "asm.bi"
#include "cpu.bi"
#include "ilxi.bi"

sub inst_copy(dest as t_operand, source as t_operand)

end sub ' inst_copy()

sub inst_add(dest as t_operand, source as t_operand)

end sub ' inst_add()

sub inst_sub(dest as t_operand, source as t_operand)

end sub ' inst_sub()

sub inst_mul(dest as t_operand, source as t_operand)

end sub ' inst_mul()

sub inst_div(dest as t_operand, source as t_operand)

end sub ' inst_div()

sub inst_shl(dest as t_operand, count as t_operand)

end sub ' inst_shl()

sub inst_shr(dest as t_operand, count as t_operand)

end sub ' inst_shr()

sub inst_or(dest as t_operand, source as t_operand)

end sub ' inst_or()

sub inst_not(dest as t_operand, source as t_operand)

end sub ' inst_not()

sub inst_and(dest as t_operand, source as t_operand)

end sub ' inst_and()

sub inst_xor(dest as t_operand, source as t_operand)

end sub ' inst_xor()

sub inst_eqv(dest as t_operand, source as t_operand)

end sub ' inst_eqv()

sub inst_cmp(dest as t_operand, source as t_operand)

end sub ' inst_cmp()

sub inst_branch(dest as t_operand)

end sub ' inst_branch()

sub inst_beq(dest as t_operand)

end sub ' inst_beq()

sub inst_bne(dest as t_operand)

end sub ' inst_bne()

sub inst_blt(dest as t_operand)

end sub ' inst_blt()

sub inst_bgt(dest as t_operand)

end sub ' inst_bgt()

sub inst_bz(dest as t_operand)

end sub ' inst_bz()

sub inst_scall(dest as t_operand)

end sub ' inst_scall()

sub inst_lcall(dest as t_operand, page as t_operand)

end sub ' inst_lcall()

sub inst_icall(dest as t_operand)

end sub ' inst_icall()

sub inst_sret()

end sub ' inst_sret()

sub inst_lret()

end sub ' inst_lret()

sub inst_iret()

end sub ' inst_iret()

sub inst_push(dest as t_operand)

end sub ' inst_push()

sub inst_pop(dest as t_operand)

end sub ' inst_pop()

sub inst_hlt()
    cpu_set_flag FL_HALT
end sub ' inst_hlt()