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
#include <TagCommonInclude.h>
#include "GSMarkupTagForm.h"
#include "GSMarkupLocalizer.h"
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

+ (Class) platformObjectClass
{
  return [NSForm class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [super initPlatformObject: platformObject];

  /* titleFont */
  {
    NSFont *f = [self fontValueForAttribute: @"titleFont"];
    if (f != nil)
      {
	[platformObject setTitleFont: f];
      }
  }

  /* titleAlignment */
  {
    NSString *align = [_attributes objectForKey: @"titleAlignment"];
    
    if (align != nil)
      {
	if ([align isEqualToString: @"left"])
	  {
	    [platformObject setTitleAlignment: NSLeftTextAlignment];
	  }
	else if ([align isEqualToString: @"right"])
	  {
	    [platformObject setTitleAlignment: NSRightTextAlignment];
	  }
	else if ([align isEqualToString: @"center"])    
	  {
	    [platformObject setTitleAlignment: NSCenterTextAlignment];
	  }
      }
  }

  /* Create content.  */
  {
    int i, count = [_content count];
    
    for (i = 0; i < count; i++)
      {
	GSMarkupTagFormItem *item = [_content objectAtIndex: i];
	NSString *title = [item localizedStringValueForAttribute: @"title"];
	NSFormCell *cell;

	if (title == nil)
	  {
	    title = @"";
	  }
	cell = [platformObject addEntry: title];

	/* The following call will cause the item to load all
	 * additional attributes into the platform object.
	 */
	cell = [item initPlatformObject: cell];
	[item setPlatformObject: cell];
      }
  }

  return platformObject;
}

@end
