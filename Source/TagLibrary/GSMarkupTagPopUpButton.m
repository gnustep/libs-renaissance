/* -*-objc-*-
   GSMarkupTagPopUpButton.m

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
#include "GSMarkupTagPopUpButton.h"
#include "GSMarkupLocalizer.h"
#include "GSMarkupTagPopUpButtonItem.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSPopUpButton.h>
#endif

@implementation GSMarkupTagPopUpButton
+ (NSString *) tagName
{
  return @"popUpButton";
}

+ (Class) platformObjectClass
{
  return [NSPopUpButton class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [super initPlatformObject: platformObject];
  
  /* title */
  {
    NSString *title = [self localizedStringValueForAttribute: @"title"];
  
    if (title != nil)
      {
	[platformObject setTitle: title];
      }
  }

  /* Create content.  */
  {
    int i, count = [_content count];
    
    for (i = 0; i < count; i++)
      {
	GSMarkupTagPopUpButtonItem *item = [_content objectAtIndex: i];
	NSString *title = [item localizedStringValueForAttribute: @"title"];
	
	if (title == nil)
	  {
	    title = @"";
	  }

	[platformObject addItemWithTitle: title];

	/* Now get the item we have just added ... it's the last one,
	 * and set it as the platform object of the item.  */
	{
	  id platformItem = [platformObject lastItem];

	  /* The following call will cause the item to load all
	   * additional attributes into the init platform object.  */

	  platformItem = [item initPlatformObject: platformItem];
	  [item setPlatformObject: platformItem];
	}
      }
  }
  
  /* pullsDown */
  {
    int pullsDown = [self boolValueForAttribute: @"pullsDown"];
    
    if (pullsDown == 1)
      {
	[platformObject setPullsDown: YES];
      }
    else if (pullsDown == 0)
      {
	[platformObject setPullsDown: NO];
      }
  }

  /* autoenablesItems */
  {
    int autoenablesItems = [self boolValueForAttribute: @"autoenablesItems"];
    if (autoenablesItems == 0)
      {
	[platformObject setAutoenablesItems: NO];
      }
  }

  return platformObject;
}

+ (NSArray *) localizableAttributes
{
  return [[GSMarkupTagControl localizableAttributes] arrayByAddingObject: @"title"];
}

@end
