/* -*-objc-*-
   GSMarkupTagForm.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: November 2002

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

#include <GSMarkupTagForm.h>
#include <GSMarkupLocalizer.h>
#include "GSMarkupTagFormItem.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSForm.h>
#endif

@implementation GSMarkupTagForm
+ (NSString *) tagName
{
  return @"form";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSForm class];
}

- (void) platformObjectInit
{
  [super platformObjectInit];

  /* titleFont */
  {
    NSFont *f = [self fontValueForAttribute: @"titleFont"];
    if (f != nil)
      {
	[_platformObject setTitleFont: f];
      }
  }

  /* titleAlignment */
  {
    NSString *align = [_attributes objectForKey: @"titleAlignment"];
    
    if (align != nil)
      {
	if ([align isEqualToString: @"left"])
	  {
	    [_platformObject setTitleAlignment: NSLeftTextAlignment];
	  }
	else if ([align isEqualToString: @"right"])
	  {
	    [_platformObject setTitleAlignment: NSRightTextAlignment];
	  }
	else if ([align isEqualToString: @"center"])    
	  {
	    [_platformObject setTitleAlignment: NSCenterTextAlignment];
	  }
      }
  }

  /* Create content.  */
  {
    int i, count = [_content count];
    
    for (i = 0; i < count; i++)
      {
	GSMarkupTagFormItem *item = [_content objectAtIndex: i];
	
	NSString *title = [[item attributes] objectForKey: @"title"];
	
	if (title != nil)
	  {
	    /* NSFormCell *cell = */ [_platformObject addEntry: title];
	    
	    /* FIXME/TODO: Now the 'item' attributes, if any, should
	     * be moved onto the 'cell' ones.  A problem might be if
	     * you put an id="xxx" attribute to a formItem and hope
	     * that it gets to the cell.  */
	  }
      }
  }
}

@end
