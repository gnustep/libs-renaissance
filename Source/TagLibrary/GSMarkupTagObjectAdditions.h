/* -*-objc-*-
   GSMarkupObject.h

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

#ifndef _GNUstep_H_GSMarkupTagObjectAdditions
#define _GNUstep_H_GSMarkupTagObjectAdditions

#include "GSMarkupTagObject.h"

@class NSColor;
@class NSFont;

@interface GSMarkupTagObject (TagLibraryAdditions)

/* Handy method.  Return nil if attribute is not defined.  If attribute
 * is defined, and the value is xxx, it returns [NSColor xxxColor],
 * if NSColor responds to +xxxColor.  Otherwise, xxx is interpreted
 * as calibrated RGBA values in the standard format RRGGBBAA, or
 * RRGGBB if it only has 6 digits :-)
 *
 * For example, 
 * red --> [NSColor redColor]
 * text --> [NSColor textColor]
 * black --> [NSColor blackColor]
 * FFFFFF --> color with Red: 255, Green: 255, Blue: 255 (white)
 * 000000 --> color with Red: 0, Green: 0, Blue: 0 (black)
 * etc
 */
- (NSColor *) colorValueForAttribute: (NSString *)attribute;

/* Handy method.  Return nil if attributed is not defined.  If
 * attribute is defined, value might be 'label', `boldSystem', 'user',
 * 'userFixedPitch', 'menu', 'message', 'palette', 'system',
 * 'titleBar', toolTips', in which case [NSFont labelFontOfSize: 0],
 * [NSFont boldSystemFontOfSize: 0] etc. is returned.  If missing,
 * label is assumed.
 * Additional modifiers might be added:
 *
 * Tiny (1/3 of the original size)
 * tiny (1/2 of the original size)
 * Small (2/3 of the original size)
 * small (4/5 of the original size)
 * medium (the original size)
 * big (5/4 times the original size)
 * Big (3/2 times the original size)
 * huge (2 times the original size)
 * Huge (3 times the original size)
 *
 * You can also specify a float, which is read and interpreted as a
 * scaling factor.  For example, '2' would multiply the size by 2; 1.1
 * would multiply the size by 1.1.
 *
 * FIXME - perhaps also bold (tries to make the font bold) [TODO]
 * italic (tries to make the font italic) [TODO]
 */
- (NSFont *) fontValueForAttribute: (NSString *)attribute;

@end

#endif /* _GNUstep_H_GSMarkupTagObjectAdditions */
