/* -*-objc-*-
   GSMarkupWindowController.h

   Copyright (C) 2003 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: January 2003

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

#ifndef _GNUstep_H_GSMarkupWindowController_h
#define _GNUstep_H_GSMarkupWindowController_h

#ifdef GNUSTEP
# include <AppKit/NSWindowController.h>
#else
# include <AppKit/AppKit.h>
#endif

/* This class is a drop-in replacement for NSWindowController, which loads
 * windows from .gsmarkup files rather than from .nib/.gorm files.
 *
 * You should use this class instead of (and in the same way as)
 * NSWindowController if you want to use Renaissance with
 * NSWindowController.
 */
@interface GSMarkupWindowController : NSWindowController
{
  /* Super doesn't give us access to the window nib path and window
   * nib name as used in the -init methods, so we need to store them
   * here to implement our own proper lookup and loading.  It's a bit
   * wasteful, but works nicely.
   */
  NSString *_gsMarkupWindowNibPath;
  NSString *_gsMarkupWindowNibName;

  /* We keep here the top level objects decoded from the gsmarkup file.
   * To destroy them, we loop on all objects in the array, and send them
   * a 'release' message.  Then we destroy the array as well.
   */
  NSArray *_gsMarkupTopLevelObjects;
}

@end

#endif /* _GNUstep_H_GSMarkupWindowController_h */
