/* -*-objc-*-
   Markup.h - header for GNUstep Renaissance giving access to the Markup
   internals

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: November 2002

   This file is part of GNUstep Renaissance

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/ 

#ifndef _GNUstep_H_Renaissance_Markup
#define _GNUstep_H_Renaissance_Markup

/* Include all end-application Renaissance headers.  */
#include "Renaissance.h"

/* Now the Markup specific headers; those are only needed if you are
   adding custom tags, or manipulating the markup objects directly
   (such as in a .gsmarkup visual editor).  */

/* Markup */
#include "GSMarkupCoder.h"
#include "GSMarkupCoding.h"
#include "GSMarkupConnector.h"
#include "GSMarkupDecoder.h"
#include "GSMarkupDecoderBackend.h"
#include "GSMarkupLocalizer.h"
#include "GSMarkupTagInstance.h"
#include "GSMarkupTagObject.h"

/* TagLibrary */
#include "GSMarkupTagBox.h"
#include "GSMarkupTagBoxSeparator.h"
#include "GSMarkupTagButton.h"
#include "GSMarkupTagColorWell.h"
#include "GSMarkupTagControl.h"
#include "GSMarkupTagForm.h"
#include "GSMarkupTagFormItem.h"
#include "GSMarkupTagHbox.h"
#include "GSMarkupTagHspace.h"
#include "GSMarkupTagLabel.h"
#include "GSMarkupTagMatrix.h"
#include "GSMarkupTagMatrixCell.h"
#include "GSMarkupTagMatrixRow.h"
#include "GSMarkupTagMenu.h"
#include "GSMarkupTagMenuItem.h"
#include "GSMarkupTagMenuSeparator.h"
#include "GSMarkupTagObjectAdditions.h"
#include "GSMarkupTagPanel.h"
#include "GSMarkupTagPopUpButton.h"
#include "GSMarkupTagPopUpButtonItem.h"
#include "GSMarkupTagScrollView.h"
#include "GSMarkupTagSeparator.h"
#include "GSMarkupTagTextField.h"
#include "GSMarkupTagTextView.h"
#include "GSMarkupTagVbox.h"
#include "GSMarkupTagView.h"
#include "GSMarkupTagVspace.h"
#include "GSMarkupTagWindow.h"

#endif /* _GNUstep_H_Renaissance_Markup */
