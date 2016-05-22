#
#  ILXI Virtual Machine
#
#  ILXI Virtual Machine
#
#  Makefile (master build file)
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
BINFILES = xiasm mkdisk ilxi ilxi.xmf

all: vm xiasm util linker

dist: all
	mkdir -p dist/
	cp src/linker/link dist/
	cp src/vm/ilxi dist/
	cp src/util/mkdisk dist/
	cp src/xiasm/xiasm dist/
	cp doc/ilxi.xmf dist/
	cp bin/.ilximrc dist/
	cp examples/input/input.xa dist/

libilxi:
	cd src/libilxi; make

libobj: libilxi
	cd src/libobj; make

linker: libilxi libobj
	cd src/linker; make

vm: libilxi
	cd src/vm; make

xiasm: libilxi libobj
	cd src/xiasm; make

util: libilxi
	cd src/util; make

clean:
	cd src/libilxi; make clean
	cd src/libobj; make clean
	cd src/vm; make clean
	cd src/util; make clean
	cd src/xiasm; make clean
	cd src/linker; make clean
	rm -rf dist
