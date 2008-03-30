/* -*-objc-*-
   GSMarkupTagSpace.h

   Copyright (C) 2008 Free Software Foundation, Inc.

   Author: Nicola Pero <nicola.pero@meta-innovation.com>
   Date: March 2008

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

#ifndef _GNUstep_H_GSMarkupTagSpace
#define _GNUstep_H_GSMarkupTagSpace

#include "GSMarkupTagView.h"

/* A space object is an empty view with, by default, halign="wexpand",
 * valign="wexpand", padding="0".  It is by default of size 0; you can
 * set a different basic size by setting a different width, height of
 * the view.
 *
 * This tag generates an instance of GSAutoLayoutSpace.
 */
@interface GSMarkupTagSpace : GSMarkupTagView
@end

#endif /* _GNUstep_H_GSMarkupTagSpace */
