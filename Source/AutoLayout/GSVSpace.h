/* -*-objc-*-
   GSVSpace.h

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

#ifndef _GNUstep_H_GSVSpace
#define _GNUstep_H_GSVSpace

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <AppKit/NSView.h>
#endif

#include "GSAutoLayoutDefaults.h"

/* A GSVSpace, by default, has zero size (but you can create it with a
 * non-zero size, if you want).  It has:
 *
 * halign="center"
 * valign="wexpand"
 * hborder="0"
 * vborder="0"
 *
 * In practice, if you put a GSVSpace object in a GSVBox, the object
 * will start with size 0, and expand to get more space when the box
 * is expanded.  You need such an object if you want additional space
 * to be put into borders or empty space between objects, or for other
 * special alignment needs.
 */
@interface GSVSpace : NSView
@end

#endif 
