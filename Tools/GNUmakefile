#   Makefile for GNUstep Renaissance developer Tools
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
#   Date: 2002
#   
#   This file is part of GNUstep Renaissance.
#   
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#   
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

include $(GNUSTEP_MAKEFILES)/common.make

# YOU MUST INSTALL Renaissance BEFORE YOU CAN RUN THESE APPS

APP_NAME = GSMarkupBrowser GSMarkupLocalizableStrings
GSMarkupBrowser_OBJC_FILES = GSMarkupBrowser.m
GSMarkupLocalizableStrings_OBJC_FILES = GSMarkupLocalizableStrings.m

ifeq ($(FOUNDATION_LIB),gnu)
  # Find Renaissance headers and library before it's installed
  ADDITIONAL_INCLUDE_DIRS += \
     -I../Source/AutoLayout -I../Source/Markup -I../Source/TagLibrary \
     -I../Source
  ADDITIONAL_LIB_DIRS += -L../Source/obj

  GSMarkupBrowser_GUI_LIBS += -lRenaissance
  GSMarkupLocalizableStrings_GUI_LIBS += -lRenaissance
else

  # Renaissance must be installed inside /Library/Frameworks on OSX
  # before you can compile this stuff
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  GSMarkupBrowser_GUI_LIBS += -framework Renaissance
  GSMarkupLocalizableStrings_GUI_LIBS += -framework Renaissance
endif

include $(GNUSTEP_MAKEFILES)/application.make
