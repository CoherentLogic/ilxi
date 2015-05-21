'
' ilxi.bi
' 

declare sub startup()
declare sub cli()
declare sub ilxi_getr(register as string)
declare sub ilxi_setr(register as string, value as integer)
declare function ilxi_pad_left(input_str as string, pad_char as string, total_size as integer) as string