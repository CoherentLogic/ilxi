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

all: vm xiasm util

dist: all
	mkdir -p dist/
	cp src/vm/ilxi dist/
	cp src/util/mkdisk dist/
	cp src/xiasm/xiasm dist/
	cp doc/ilxi.xmf dist/
	cp bin/.ilximrc dist/

lib:
	cd src/lib; make
	
vm: lib
	cd src/vm; make
	
xiasm: lib
	cd src/xiasm; make

util: lib
	cd src/util; make

clean:
	cd src/lib; make clean
	cd src/vm; make clean
	cd src/util; make clean
	cd src/xiasm; make clean
	rm -rf dist
