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
#include <TagCommonInclude.h>
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

+ (Class) platformObjectClass
{
  return [NSScrollView class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [platformObject init];
  
  /* hasHorizontalScroller (FIXME name) */
  if ([self boolValueForAttribute: @"hasHorizontalScroller"] == 0)
    {
      [platformObject setHasHorizontalScroller: NO];
    }
  else
    {
      [platformObject setHasHorizontalScroller: YES];
    }
  

  /* hasVerticalScroller (FIXME name) */  
  if ([self boolValueForAttribute: @"hasVerticalScroller"] == 0)
    {
      [platformObject setHasVerticalScroller: NO];
    }
  else
    {
      [platformObject setHasVerticalScroller: YES];
    }

#ifdef GNUSTEP
  [(NSScrollView *)platformObject setBorderType: NSBezelBorder];
#endif
  
/* borderType - if none is given, the default is Bezel on GNUstep and
 * none on Apple Mac OS X.  You should use sparingly this attribute -
 * usually you can/should allow the default border type for your
 * platform to be used.
 */
  {
#ifdef GNUSTEP
    NSBorderType theType = NSBezelBorder; /* Default on GNUstep */
#else
    NSBorderType theType = NSNoBorder;    /* Default on Apple Mac OS X */
#endif
    NSString *border = [_attributes objectForKey: @"borderType"];
    
    if (border != nil)
      {
	if ([border isEqualToString: @"none"] == YES)
	  {
	    theType = NSNoBorder;
	  }
	else if ([border isEqualToString: @"line"] == YES)
	  {
	    theType = NSLineBorder;
	  }
	else if ([border isEqualToString: @"bezel"] == YES)
	  {
	    theType =  NSBezelBorder;
	  }
	else if ([border isEqualToString: @"groove"] == YES)
	  {
	    theType =  NSGrooveBorder;
          }
      }
    
    [platformObject setBorderType: theType];
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
	    [platformObject setDocumentView: v];
	    /* I think this is a bug in gnustep's gui library:
	     * NSClipView has autoresizesSubviews set, I'm not sure
	     * why.  */
	    [v setAutoresizingMask: NSViewNotSizable];
	  }
      }
  }

  return platformObject;
}

- (id) postInitPlatformObject: (id)platformObject
{
  platformObject = [super postInitPlatformObject: platformObject];

  /* FIXME - not sure how to set up this stuff for text view, if not
   * here.  */
  if ([[platformObject documentView] isKindOfClass: [NSTextView class]])
    {
      NSRect textRect = [[platformObject contentView] frame];
      NSTextView *tv = [platformObject documentView];
      
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

  return platformObject;
}

@end
