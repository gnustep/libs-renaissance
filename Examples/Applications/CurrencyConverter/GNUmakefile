#   GNUmakefile: makefile for CurrencyConverter.app
#
#   Copyright (C) 2002 Free Software Foundation, Inc.
#
#   Author:  Nicola Pero <n.pero@mi.flashnet.it>
#   Date: March 2002
#   
#   This file is part of GNUstep.
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

# YOU NEED TO INSTALL Renaissance BEFORE COMPILING THIS APPLICATION

APP_NAME = CurrencyConverter
CurrencyConverter_OBJC_FILES = CurrencyConverter.m 
CurrencyConverter_RESOURCE_FILES = \
  CurrencyConverter.gsmarkup \
  MainMenu-GNUstep.gsmarkup \
  MainMenu-OSX.gsmarkup
CurrencyConverter_LANGUAGES = Italian
CurrencyConverter_LOCALIZED_RESOURCE_FILES = \
  CurrencyConverter.strings \
  MainMenu-GNUstep.strings \
  MainMenu-OSX.strings

ifeq ($(FOUNDATION_LIB), nx)
  ADDITIONAL_INCLUDE_DIRS += -framework Renaissance
  ADDITIONAL_GUI_LIBS += -framework Renaissance
else
  ADDITIONAL_GUI_LIBS += -lRenaissance
endif

include $(GNUSTEP_MAKEFILES)/application.make

