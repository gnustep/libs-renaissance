/* -*-objc-*-
   GSMarkupDocument.h

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

#ifndef _GNUstep_H_GSMarkupDocument_h
#define _GNUstep_H_GSMarkupDocument_h

#ifdef GNUSTEP
# include <AppKit/NSDocument.h>
#else
# include <AppKit/AppKit.h>
#endif

/* This class is meant to be a drop-in replacement for NSDocument,
 * which just uses GSMarkupWindowController instead of
 * NSWindowController as its window controller class (and so
 * automatically loads windows from gsmarkup files instead of nib/gorm
 * files).  You should use this class instead of NSDocument (and in
 * the same way as you use NSDocument) if you want to write a
 * NSDocument-based application using Renaissance gsmarkup files
 * instead of nib/gorm files.
 */

@interface GSMarkupDocument : NSDocument
{
  /* Super does not give us access to the window set via setWindow:  */
  NSWindow *_gsMarkupWindow;
}

/* A private method used by GSMarkupWindowController to retrieve the window
 * set via setWindow:.  */
- (NSWindow *) gsMarkupWindow;
@end

#endif /* _GNUstep_H_GSMarkupDocument_h */
