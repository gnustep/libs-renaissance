/* -*-objc-*-
   GSMarkupTagScrollView.m

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

#include "GSMarkupTagScrollView.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
# include <AppKit/NSClipView.h>
# include <AppKit/NSScrollView.h>
# include <AppKit/NSTextContainer.h>
# include <AppKit/NSTextView.h>
# include <AppKit/NSView.h>
#endif

@implementation GSMarkupTagScrollView

+ (NSString *) tagName
{
  return @"scrollView";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSScrollView class];
}

- (void) platformObjectInit
{
  [self setPlatformObject: [_platformObject init]];
  
  /* hasHorizontalScroller (FIXME name) */
  if ([self boolValueForAttribute: @"hasHorizontalScroller"] == 0)
    {
      [_platformObject setHasHorizontalScroller: NO];
    }
  else
    {
      [_platformObject setHasHorizontalScroller: YES];
    }
  

  /* hasVerticalScroller (FIXME name) */  
  if ([self boolValueForAttribute: @"hasVerticalScroller"] == 0)
    {
      [_platformObject setHasVerticalScroller: NO];
    }
  else
    {
      [_platformObject setHasVerticalScroller: YES];
    }
  
  /* Add content.  */
  {
    if ([_content count] > 0)
      {
	GSMarkupTagView *view = [_content objectAtIndex: 0];
	NSView *v;
	
	v = [view platformObject];
	if (v != nil  &&  [v isKindOfClass: [NSView class]])
	  {
	    [_platformObject setDocumentView: v];
	    /* I think this is a bug in gnustep's gui library:
	     * NSClipView has autoresizesSubviews set, I'm not sure
	     * why.  */
	    [v setAutoresizingMask: NSViewNotSizable];
	  }
      }
  }
}

- (void) platformObjectAfterInit
{
  [super platformObjectAfterInit];

  /* FIXME - not sure how to set up this stuff for text view, if not
   * here.  */
  if ([[_platformObject documentView] isKindOfClass: [NSTextView class]])
    {
      NSRect textRect = [[_platformObject contentView] frame];
      NSTextView *tv = [_platformObject documentView];
      
      [tv setFrame: textRect];
      [tv setHorizontallyResizable: NO];
      [tv setVerticallyResizable: YES];
      [tv setMinSize: NSMakeSize (0, 0)];
      [tv setMaxSize: NSMakeSize (1E7, 1E7)];
      [tv setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
      [[tv textContainer] setContainerSize: NSMakeSize 
			  (textRect.size.width, 1e7)];
      [[tv textContainer] setWidthTracksTextView: YES];
    }
}

@end
