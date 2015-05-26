'
' inst.bi
'

#include once "asm.bi"

declare sub inst_copy(dest as t_operand, source as t_operand)
declare sub inst_add(dest as t_operand, source as t_operand)
declare sub inst_sub(dest as t_operand, source as t_operand)
declare sub inst_mul(dest as t_operand, source as t_operand)
declare sub inst_div(dest as t_operand, source as t_operand)
declare sub inst_shl(dest as t_operand, count as t_operand)
declare sub inst_shr(dest as t_operand, count as t_operand)
declare sub inst_or(dest as t_operand, source as t_operand)
declare sub inst_not(dest as t_operand, source as t_operand)
declare sub inst_and(dest as t_operand, source as t_operand)
declare sub inst_xor(dest as t_operand, source as t_operand)
declare sub inst_eqv(dest as t_operand, source as t_operand)
declare sub inst_cmp(dest as t_operand, source as t_operand)
declare sub inst_branch(dest as t_operand)
declare sub inst_beq(dest as t_operand)
declare sub inst_bne(dest as t_operand)
declare sub inst_blt(dest as t_operand)
declare sub inst_bgt(dest as t_operand)
declare sub inst_bz(dest as t_operand)
declare sub inst_scall(dest as t_operand)
declare sub inst_lcall(dest as t_operand, page as t_operand)
declare sub inst_icall(dest as t_operand)
declare sub inst_sret()
declare sub inst_lret()
declare sub inst_iret()
declare sub inst_push(dest as t_operand)
declare sub inst_pop(dest as t_operand)
declare sub inst_hlt()