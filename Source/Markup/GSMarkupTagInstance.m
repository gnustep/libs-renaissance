/* -*-objc-*-
   GSMarkupTagInstance.m

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

#include <GSMarkupTagInstance.h>

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSDictionary.h>
#endif

@implementation GSMarkupTagInstance

+ (NSString *) tagName
{
  return @"instance";
}

- (void) platformObjectAlloc
{
  NSString *className;
  
  className = [_attributes objectForKey: @"instanceOf"];
  
  if (className != nil)
    {
      Class c = NSClassFromString (className);
      
      if (c != Nil)
	{
	  [self setPlatformObject: AUTORELEASE ([c alloc])];
	  return;
	}
    }

  [self setPlatformObject: nil];
}

@end

