/* -*-objc-*-
   GSMarkupTagView.h

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March 2002

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

#ifndef _GNUstep_H_GSMarkupTagView
#define _GNUstep_H_GSMarkupTagView

#include "GSMarkupTagObject.h"
#include "GSMarkupTagObjectAdditions.h"

@interface GSMarkupTagView : GSMarkupTagObject

/* Subclasses can override this method to return YES, in which case
 * the tag's content are added as subviews using the traditional
 * OpenStep mechanism.  Please note that they are added in the legacy
 * OpenStep non-autosizing philosophy at the very end of the
 * processing, so you are likely to want to hardcode the size (width,
 * height) of the superview because it won't be computed from the
 * frames of the subviews.  By default this is only done only for the
 * <view> tag and not for its subclasses.
 */
- (BOOL) shouldTreatContentAsSubviews;

/* Read the value of key 'hexpand'.  If set to true/yes/1 etc, return
 * GSAutoLayoutExpand; else, read the value of key 'halign'.
 * Return 0 (GSAutoLayoutExpand) if value of 'halign' is 'expand',
 * 1 (GSAutoLayoutAlignMin) if value of 'halign' is 'min' (or 'left')
 * 2 (GSAutoLayoutAlignCenter) if value of 'halign' is 'center',
 * 3 (GSAutoLayoutAlignMax) if value of 'halign' is 'max' (or 'right')
 * return 255 (nothing) if no value for 'halign' is set, or if it's not recognized.
 */
- (int) gsAutoLayoutHAlignment;

/* Read the value of key 'vexpand'.  If set to true/yes/1 etc, return
 * GSAutoLayoutExpand; else, read the value of key 'valign'.
 * Return 0 (GSAutoLayoutExpand) if value of 'valign' is 'expand',
 * 1 (GSAutoLayoutAlignMin) if value of 'valign' is 'min' (or 'bottom')
 * 2 (GSAutoLayoutAlignCenter) if value of 'valign' is 'center',
 * 3 (GSAutoLayoutAlignMax) if value of 'valign' is 'max' (or 'top')
 * return 255 (nothing) if no value for 'valign' is set, or if it's not recognized.
 */
- (int) gsAutoLayoutVAlignment;

@end

#endif /* _GNUstep_H_GSMarkupTagView */
