/* -*-objc-*-
   GSMarkupTagTabView.m

   Copyright (C) 2008-2010 Free Software Foundation, Inc.

   Author: Xavier Glattard <xavier.glattard@online.fr>
   Date: March 2008

   Author: Nicola Pero <nicola.pero@meta-innovation.com>
   Date: May 2010

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
  else if ([self boolValueForAttribute: @"allowsTruncatedLabels"] == 1)
    {
      [platformObject setAllowsTruncatedLabels: YES];
    }

  /* drawsBackground */
  if ([self boolValueForAttribute: @"drawsBackground"] == 0)
    {
      [platformObject setDrawsBackground: NO];
    }
  else if ([self boolValueForAttribute: @"drawsBackground"] == 1)
    {
      [platformObject setDrawsBackground: YES];
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

  /* delegate doing with embedded outlets.  */

  /* Add content.  */
  {
    int i, count = [_content count];
    
    for (i = 0; i < count; i++)
      {
	/* We have as content <tabViewItem> tags.  */
	GSMarkupTagTabViewItem *t = [_content objectAtIndex: i];
	id item = [t platformObject];
	
	if (item != nil  &&  [item isKindOfClass: [NSTabViewItem class]])
	  {
	    /* Ok - here on Apple (10.5.8) we do have a problem.  When
	     * we add the very first tab view item to a tab view with
	     * noTabsNoBorder, the size of its view is forcefully set
	     * to zero (!!).  This obviously destroys the minimum size
	     * computed by autolayout containers.  It must be a bug.
	     * We work around it here by storing the original size,
	     * then restoring it after the tabViewItem has been added.
	     */
	    NSRect originalRect = [[item view] frame];

	    [platformObject addTabViewItem: item];

	    /* As explained, the following shouldn't be needed as it
	     * would be a no-op in a non-broken implementation, but on
	     * Apple it's needed to make sure the view's frame size is
	     * not lost.
	     */
	    [[item view] setFrameSize: originalRect.size];
	  }
      }
  }
  
  return platformObject;
}

@end
