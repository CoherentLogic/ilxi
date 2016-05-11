#
#  ILXI Virtual Machine
#
#  Makefile (libilxi)
#  
#  Copyright 2016 John P. Willis <jpw@coherent-logic.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#

OBJS = asm.o cpu.o error.o host.o storage.o lexer.o inst.o util.o bus.o console.o signal.o message.o profile.o config.o disk.o help.o

FBCFLAGS = -g -mt -i ../include

libilxi.a: $(OBJS)
	fbc $(FBCFLAGS) -lib -x libilxi.a $(OBJS)
	
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
	
util.o: util.bas
	fbc $(FBCFLAGS) -o util.o -c util.bas

bus.o: bus.bas
	fbc $(FBCFLAGS) -o bus.o -c bus.bas

console.o: console.bas
	fbc $(FBCFLAGS) -o console.o -c console.bas

signal.o: signal.bas
	fbc $(FBCFLAGS) -o signal.o -c signal.bas

message.o: message.bas
	fbc $(FBCFLAGS) -o message.o -c message.bas

profile.o: profile.bas
	fbc $(FBCFLAGS) -o profile.o -c profile.bas
	
config.o: config.bas
	fbc $(FBCFLAGS) -o config.o -c config.bas
	
disk.o: disk.bas
	fbc $(FBCFLAGS) -o disk.o -c disk.bas

help.o: help.bas
	fbc $(FBCFLAGS) -o help.o -c help.bas
	
clean:
	rm -f libilxi.a $(OBJS)
	

