#
#  Copyright (C) 2002 Free Software Foundation, Inc.
#
#  Author: Nicola Pero <n.pero@mi.flashnet.it>
#
#  This file is part of GNUstep Renaissance.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Library General Public License for more details.
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; see the file COPYING.LIB.
#  If not, write to the Free Software Foundation,
#  59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# This file is the makefile normally used to built AutoLayout as
# part of Renaissance.

include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME = libgnustep-autolayout

libgnustep-autolayout_HEADER_FILES_DIR = .
libgnustep-autolayout_HEADER_FILES_INSTALL_DIR = Renaissance

# Include the files
include GNUmakefile.files

ADDITIONAL_OBJCFLAGS = -Wall

# Only for GNUstep.h on OSX
ADDITIONAL_INCLUDE_DIRS += -I../

include $(GNUSTEP_MAKEFILES)/subproject.make
