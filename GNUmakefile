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
#  If you are interested in a warranty or support for this source code,
#  contact Scott Christley at scottc@net-community.com
#
#  You should have received a copy of the GNU Library General Public
#  License along with this library; see the file COPYING.LIB.
#  If not, write to the Free Software Foundation,
#  59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Renaissance
# Keep the following in sync with Source/GNUmakefile
VERSION = 0.5.0

CVS_MODULE_NAME = dev-libs/Renaissance
CVS_FLAGS = -d :pserver:anoncvs@subversions.gnu.org:/cvsroot/gnustep -z3
RELEASE_DIR = releases

ifeq ($(FOUNDATION_LIB), apple)
  SUBPROJECTS = Source
else
  SUBPROJECTS = Source Tools Documentation
endif

include $(GNUSTEP_MAKEFILES)/aggregate.make

after-distclean::
	-(cd Examples/Applications/Calculator && make distclean)
	-(cd Examples/Applications/CurrencyConverter && make distclean)
	-(cd Examples/Applications/Finger && make distclean)
