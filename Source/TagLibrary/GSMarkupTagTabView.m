/* -*-objc-*-
   GSMarkupTagTabView.m

   Copyright (C) 2008 Free Software Foundation, Inc.

   Author: Xavier Glattard <xavier.glattard@online.fr>
   Date: March 2008

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
#include "GSMarkupTagTabView.h"
#include "GSMarkupTagTabViewItem.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
# include <AppKit/NSTabView.h>
# include <AppKit/NSView.h>
#endif

@implementation GSMarkupTagTabView

+ (Class) platformObjectClass
{
  return [NSTabView class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [platformObject init];
  
  /* allowsTruncatedLabels */
  if ([self boolValueForAttribute: @"allowsTruncatedLabels"] == 0)
    {
      [platformObject setAllowsTruncatedLabels: NO];
    }
  else
    {
      [platformObject setAllowsTruncatedLabels: YES];
    }

  /* viewType */
  {
    NSString *viewType = [_attributes objectForKey: @"viewType"];
    if (viewType!= nil)
      {
	if ([viewType isEqualToString: @"topTabsBezelBorder"])
	  {
	    [platformObject setTabViewType: NSTopTabsBezelBorder];
	  }
	else if ([viewType isEqualToString: @"leftTabsBezelBorder"])
	  {
	    [platformObject setTabViewType: NSLeftTabsBezelBorder];
	  }
	else if ([viewType isEqualToString: @"bottomTabsBezelBorder"])
	  {
	    [platformObject setTabViewType: NSBottomTabsBezelBorder];
	  }
	else if ([viewType isEqualToString: @"rightTabsBezelBorder"])
	  {
	    [platformObject setTabViewType: NSRightTabsBezelBorder];
	  }
	else if ([viewType isEqualToString: @"noTabsBezelBorder"])
	  {
	    [platformObject setTabViewType: NSNoTabsBezelBorder];
	  }
	else if ([viewType isEqualToString: @"noTabsLineBorder"])
	  {
	    [platformObject setTabViewType: NSNoTabsLineBorder];
	  }
	else if ([viewType isEqualToString: @"noTabsNoBorder"])
	  {
	    [platformObject setTabViewType: NSNoTabsNoBorder];
	  }
      }
  }

  /* drawsBackground */
  if ([self boolValueForAttribute: @"drawsBackground"] == 0)
    {
      [platformObject setDrawsBackground: NO];
    }
  else
    {
      [platformObject setDrawsBackground: YES];
    }
  
  /* font */
  {
    NSFont *f = [self fontValueForAttribute: @"font"];

    /* Superclass will set the font; this is just a hack for a special
     * case on Apple Mac OS X.
     */
    if (f == nil)
      {
	/* Unbelievable, isn't it ?  The default font of a button on
	 * Mac OS X is not the right font for buttons.  It's 12 points
	 * instead of 13 points.  Fix it.  */
	[platformObject setFont: [NSFont systemFontOfSize: 0]];
      }
  }

 /* Add content.  */
  {
    int i, count = [_content count];

    for (i = 0; i < count; i++)
      {
	/* We have as content either <tabViewItem> tags, or any <view> tags.*/
	GSMarkupTagTabViewItem *t = [_content objectAtIndex: i];
	id item = [t platformObject];
	
	if (item != nil  &&  [item isKindOfClass: [NSTabViewItem class]])
	  {
	    [platformObject addTabViewItem: item];
	  }
      }
  }
  
  return platformObject;
}

- (id) postInitPlatformObject: (id)platformObject
{
  platformObject = [super postInitPlatformObject: platformObject];

  /* Make sure subviews are adjusted.  This must be done after the
   * size of the splitview has been set.
   */
//  [platformObject adjustSubviews];

  return platformObject;
}

@end
