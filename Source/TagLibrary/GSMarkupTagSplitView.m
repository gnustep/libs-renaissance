/* -*-objc-*-
   GSMarkupTagSplitView.m

   Copyright (C) 2003 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: Februrary 2003

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

#include "GSMarkupTagSplitView.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
# include <AppKit/NSSplitView.h>
# include <AppKit/NSView.h>
#endif

@implementation GSMarkupTagSplitView

+ (NSString *) tagName
{
  return @"splitView";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSSplitView class];
}

- (void) platformObjectInit
{
  [self setPlatformObject: [_platformObject init]];
  
  if ([self boolValueForAttribute: @"vertical"] == 0)
    {
      [_platformObject setVertical: NO];
    }
  else
    {
      [_platformObject setVertical: YES];
    }
  
  /* Add content.  */
  {
    int i, count = [_content count];

    for (i = 0; i < count; i++)
      {
	GSMarkupTagView *view = [_content objectAtIndex: i];
	NSView *v;
	
	v = [view platformObject];
	if (v != nil  &&  [v isKindOfClass: [NSView class]])
	  {
	    [_platformObject addSubview: v];
	  }
      }
  }
}

- (void) platformObjectAfterInit
{
  [super platformObjectAfterInit];

  /* Make sure subviews are adjusted.  This must be done after the
   * size of the splitview has been set.
   */
  [_platformObject adjustSubviews];
}

@end
