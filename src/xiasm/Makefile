#
#  ILXI Virtual Machine
#
#  Makefile (xiasm)
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

OBJS = xiasm.o
FBCFLAGS = -g -mt -i ../include -p ../libilxi -p ../libobj

xiasm: $(OBJS)
	fbc $(FBCFLAGS) -l ilxi -x xiasm $(OBJS)
	
xiasm.o: xiasm.bas
	fbc $(FBCFLAGS) -m xiasm -o xiasm.o -c xiasm.bas

clean:
	rm -f xiasm $(OBJS)
