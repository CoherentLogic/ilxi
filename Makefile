VM_OBJS = ilxi.o alu.o asm.o cpu.o error.o host.o storage.o lexer.o inst.o util.o
XIASM_OBJS = xiasm.o asm.o cpu.o lexer.o storage.o inst.o error.o util.o
FBCFLAGS = -g 
#-d LEXDEBUG

vm: ilxi

assembler: xiasm  

xiasm: $(XIASM_OBJS)
	fbc $(FBCFLAGS) -x xiasm $(XIASM_OBJS)

xiasm.o: xiasm.bas
	fbc $(FBCFLAGS) -m xiasm -o xiasm.o -c xiasm.bas

ilxi: $(VM_OBJS)
	fbc $(FBCFLAGS) -x ilxi $(VM_OBJS)

alu.o: alu.bas 
	fbc $(FBCFLAGS) -o alu.o -c alu.bas

asm.o: asm.bas
	fbc $(FBCFLAGS) -o asm.o -c asm.bas

cpu.o: cpu.bas
	fbc $(FBCFLAGS) -o cpu.o -c cpu.bas

error.o: error.bas
	fbc $(FBCFLAGS) -o error.o -c error.bas

host.o: host.bas
	fbc $(FBCFLAGS) -o host.o -c host.bas

storage.o: storage.bas
	fbc $(FBCFLAGS) -o storage.o -c storage.bas

lexer.o: lexer.bas
	fbc $(FBCFLAGS) -o lexer.o -c lexer.bas

inst.o: inst.bas
	fbc $(FBCFLAGS) -o inst.o -c inst.bas

ilxi.o: ilxi.bas
	fbc -m ilxi $(FBCFLAGS) -o ilxi.o -c ilxi.bas

util.o: util.bas
	fbc $(FBCFLAGS) -o util.o -c util.bas

clean:
	rm -f *.o ilxi
