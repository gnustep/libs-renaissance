#
#  Copyright (C) 2002 Free Software Foundation, Inc.
#
#  Author: Nicola Pero <nicola.pero@meta-innovation.com>
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
VERSION = 0.9.0

SVN_MODULE_NAME = renaissance
SVN_BASE_URL = http://svn.gna.org/svn/gnustep/libs
RELEASE_DIR = releases

ifeq ($(FOUNDATION_LIB), apple)

# Tools must be compiled after the main Renaissance has been installed
# on Apple.  Documentation can't be built as TeX doesn't seem
# installed by default on Apple.
  SUBPROJECTS = Source

else

# Do not include Documentation here, just because sometime building
# Documentation can fail, and it can be a stopper for newcomers --
# just to make sure nothing can go wrong, we don't build it.
  SUBPROJECTS = Source Tools

endif

include $(GNUSTEP_MAKEFILES)/aggregate.make

after-distclean::
	-(cd Examples/Applications/Calculator && $(MAKE) distclean)
	-(cd Examples/Applications/CurrencyConverter && $(MAKE) distclean)
	-(cd Examples/Applications/Finger && $(MAKE) distclean)
	-(cd Examples/Applications/Ink && $(MAKE) distclean)
	-(cd Examples/Applications/SimpleEditor && $(MAKE) distclean)
	-(cd Examples/Applications/Templates/Standard && $(MAKE) distclean)
	-(cd Examples/Classes/OutlineView && $(MAKE) distclean)
	-(cd Examples/Classes/TableView && $(MAKE) distclean)

