/* -*-objc-*-
   GSMarkupAwaker.m

   Copyright (C) 2002 Free Software Foundation, Inc.

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

#include <GSMarkupAwaker.h>
#include <GSMarkupBundleAdditions.h>

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
#else
# include <Foundation/NSEnumerator.h>
# include <Foundation/NSObject.h>
# include <Foundation/NSSet.h>
#endif

@implementation GSMarkupAwaker

- (id) init
{
  _objects = [NSMutableSet new];

  return self;
}

- (void) dealloc
{
  RELEASE (_objects);
  [super dealloc];
}

- (void) registerObject: (id)object
{
  [_objects addObject: object];
}

- (void) deregisterObject: (id)object
{
  [_objects removeObject: object];
}

- (void) awakeObjects
{
  NSEnumerator *e = [_objects objectEnumerator];
  id object;

  while ((object = [e nextObject]) != nil)
    {
      if ([object respondsToSelector: @selector(awakeFromGSMarkup)])
      {
	[object awakeFromGSMarkup];
      }
    }
}

@end

