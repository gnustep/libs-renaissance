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

# This file is the makefile normally used to built TagLibrary as part
# of Renaissance.

# TagLibrary depends on both AutoLayout and Markup, so I don't see
# much point in building it standalone :-) - you rather want to build
# all of Renaissance, and use Renaissance.

include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECT_NAME = libgnustep-markup-gui

libgnustep-markup-gui_OBJC_FILES = \
GSMarkupTagObjectAdditions.m \
GSMarkupTagBox.m \
GSMarkupTagBoxSeparator.m \
GSMarkupTagButton.m \
GSMarkupTagColorWell.m \
GSMarkupTagControl.m \
GSMarkupTagForm.m \
GSMarkupTagFormItem.m \
GSMarkupTagHbox.m \
GSMarkupTagHspace.m \
GSMarkupTagImage.m \
GSMarkupTagLabel.m \
GSMarkupTagMatrix.m \
GSMarkupTagMatrixRow.m \
GSMarkupTagMatrixCell.m \
GSMarkupTagMenu.m \
GSMarkupTagMenuItem.m \
GSMarkupTagMenuSeparator.m \
GSMarkupTagPanel.m \
GSMarkupTagPopUpButton.m \
GSMarkupTagPopUpButtonItem.m \
GSMarkupTagScrollView.m \
GSMarkupTagTextField.m \
GSMarkupTagTextView.m \
GSMarkupTagVbox.m \
GSMarkupTagVspace.m \
GSMarkupTagView.m \
GSMarkupTagWindow.m \
GSMarkupDocument.m \
GSMarkupWindowController.m

libgnustep-markup-gui_HEADER_FILES = \
GSMarkupTagObjectAdditions.h \
GSMarkupTagBox.h \
GSMarkupTagBoxSeparator.h \
GSMarkupTagButton.h \
GSMarkupTagColorWell.h \
GSMarkupTagControl.h \
GSMarkupTagForm.h \
GSMarkupTagFormItem.h \
GSMarkupTagHbox.h \
GSMarkupTagHspace.h \
GSMarkupTagImage.h \
GSMarkupTagLabel.h \
GSMarkupTagMatrix.h \
GSMarkupTagMatrixRow.h \
GSMarkupTagMatrixCell.h \
GSMarkupTagMenu.h \
GSMarkupTagMenuItem.h \
GSMarkupTagMenuSeparator.h \
GSMarkupTagPanel.h \
GSMarkupTagPopUpButton.h \
GSMarkupTagPopUpButtonItem.h \
GSMarkupTagScrollView.h \
GSMarkupTagTextField.h \
GSMarkupTagTextView.h \
GSMarkupTagVbox.h \
GSMarkupTagView.h \
GSMarkupTagWindow.h \
GSMarkupDocument.h \
GSMarkupWindowController.h

libgnustep-markup-gui_HEADER_FILES_INSTALL_DIR = Renaissance

ADDITIONAL_OBJCFLAGS = -Wall
ADDITIONAL_INCLUDE_DIRS += -I../AutoLayout -I../Markup -I../

include $(GNUSTEP_MAKEFILES)/subproject.make
