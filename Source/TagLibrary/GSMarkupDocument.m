/* -*-objc-*-
   GSMarkupDocument.m

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

#include "GSMarkupDocument.h"
#include "GSMarkupWindowController.h"

#ifdef GNUSTEP
# include <Foundation/NSException.h>
# include <Foundation/NSString.h>
#else
# include <Foundation/Foundation.h>
#endif

@implementation GSMarkupDocument
- (void) setWindow: (NSWindow *)window
{
  _gsMarkupWindow = window;
  [super setWindow: window];
}

- (NSWindow *) gsMarkupWindow
{
  return _gsMarkupWindow;
}

- (void) makeWindowControllers
{
  NSString *name = [self windowNibName];

  if (name != nil  &&  [name length] > 0)
    {
      GSMarkupWindowController *cont;

      cont = [[GSMarkupWindowController alloc] initWithWindowNibName: name
					       owner: self];
      [self addWindowController: cont];
      RELEASE (cont);
      return;
    }
  
  [NSException raise: NSInternalInconsistencyException
	       format: @"Class %@ must override -windowNibName or -makeWindowControllers",
	       NSStringFromClass ([self class])];
}

@end
