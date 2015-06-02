'
' asm.bi
'
common shared asm_offset as ushort

#define O_MASK &H80
#define AMOD_MASK &H78
#define DISP_MASK &H7

type t_operand
    amod as ubyte
    low_byte as ubyte
    high_byte as ubyte
    byte_count as ubyte
    displacement as ubyte
    register as ubyte
    memory as ubyte
    immediate as ubyte
    has_displacement as ubyte
    indirect as ubyte

    data_type as ubyte ' 0 = byte, 1 = word
end type

declare function asm_encode_amod(ops_following as ubyte, amod as ubyte, disp as ubyte) as ubyte
declare function asm_amod_datatype(amod as ubyte) as ubyte
declare function asm_amod_amod(amod as ubyte) as ubyte
declare function asm_amod_disp(amod as ubyte) as ubyte
declare function asm_decode_disp(disp as ubyte) as ushort
declare function asm_encode_address(ops_following as ubyte, addr_string as string) as t_operand
declare function asm_encode_register(register_name as string) as ubyte
declare function asm_decode_register(reg as ubyte) as string
declare function asm_encode_opcode(instruction as string) as ubyte
declare function asm_decode_opcode(opcode as ubyte) as string
declare function asm_operand_count(opcode as ubyte) as ubyte
declare sub asm_assemble(instruction as string)
declare function asm_disassemble(page as ushort, offset as ushort) as string
declare function asm_bytes_to_ushort(lsb as ubyte, msb as ubyte) as ushort
declare sub asm_assemble_interactive(origin_address as ushort)
