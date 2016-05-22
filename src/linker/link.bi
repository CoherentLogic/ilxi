/'
   link.bi
   
   Copyright 2016 John P. Willis <jpw@coherent-logic.com>
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
   
'/

type relocation_record
    object_file as string
    key as string
    base_addr as integer
    byte_offset as ushort
end type

declare sub main(args as string)
declare sub read_object(object_file as string)
declare sub install_relocation(reloc as relocation_record)
