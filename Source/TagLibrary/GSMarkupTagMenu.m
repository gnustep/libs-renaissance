/* -*-objc-*-
   GSMarkupTagMenu.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March 2002, November 2002

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

#include <GSMarkupTagMenu.h>
#include <GSMarkupTagMenuItem.h>


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSApplication.h>
# include <AppKit/NSFontManager.h>
# include <AppKit/NSMenu.h>
# include <AppKit/NSView.h>
#endif

@implementation GSMarkupTagMenu
+ (NSString *) tagName
{
  return @"menu";
}

- (void) platformObjectAlloc
{
  _platformObject = [NSMenu alloc];
}

- (void) platformObjectInit
{
  int i, count;

  /* title */
  {
    NSString *title = [self localizedStringValueForAttribute: @"title"];
    
    if (title != nil)
      {
	_platformObject = [_platformObject initWithTitle: title];
      }
    else
      {
        _platformObject = [_platformObject init];
      }
  }
  
  /* Create content.  */
  count = [_content count];
  
  for (i = 0; i < count; i++)
    {
      GSMarkupTagMenuItem *item = [_content objectAtIndex: i];
      NSMenuItem *menuItem;

      menuItem = [item platformObject];
      if (menuItem != nil  &&  [menuItem isKindOfClass: [NSMenuItem class]])
	{
	  [_platformObject addItem: menuItem];
	}
    }
  
  /* type */
  {
    NSString *type = [_attributes objectForKey: @"type"];
  
    if (type != nil)
      {
	if ([type isEqualToString: @"main"])
	  {
	    [NSApp setMainMenu: _platformObject];
	  }
	else if ([type isEqualToString: @"windows"])
	  {
	    [NSApp setWindowsMenu: _platformObject];
	  }
	else if ([type isEqualToString: @"services"])
	  {
	    [NSApp setServicesMenu: _platformObject];
	  }
	else if ([type isEqualToString: @"font"])
	  {
	    [[NSFontManager sharedFontManager] setFontMenu: _platformObject];
          }
        else if ([type isEqualToString: @"apple"])
	  {
#ifndef GNUSTEP
	    [NSApp setAppleMenu: _platformObject];
#endif
          }
	/* Other types ignored for compatibility with future
	 * expansions.  */
      }    
  }

  /* autoenablesItems */
  {
    int autoenablesItems = [self boolValueForAttribute: @"autoenablesItems"];
    if (autoenablesItems == 0)
      {
	[_platformObject setAutoenablesItems: NO];
      }
  }
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObject: @"title"];
}

@end
