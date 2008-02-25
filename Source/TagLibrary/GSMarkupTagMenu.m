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
#include <TagCommonInclude.h>
#include "GSMarkupTagMenu.h"
#include "GSMarkupTagMenuItem.h"


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

/* This is a hack because of a very confusing situation.  It seems
 * that on Apple Mac OS X you have to call [NSApp setAppleMenu: xxx]
 * to get your menu to work, but that method was removed from the
 * Apple headers, with no replacement.  So - like everyone else on the
 * internet - we use a hack and declare it here.
 */
#ifndef GNUSTEP
@interface NSApplication (AppleMenu)
- (void) setAppleMenu: (NSMenu *)menu;
@end
#endif

@implementation GSMarkupTagMenu
+ (NSString *) tagName
{
  return @"menu";
}

- (id) allocPlatformObject
{
  NSMenu *platformObject = nil;
  NSString *type = [_attributes objectForKey: @"type"];

  if (type != nil)
    {
      if ([type isEqualToString: @"font"])
	{
	  platformObject = [[NSFontManager sharedFontManager] fontMenu: YES];  
	  RETAIN (platformObject);
	}
    }
  
  if (platformObject == nil)
    {
      platformObject = [NSMenu alloc];
    }

  return platformObject;
}

- (id) initPlatformObject: (id)platformObject
{
  int i, count;

  /* title */
  {
    NSString *title = [self localizedStringValueForAttribute: @"title"];

    if ([[_attributes objectForKey: @"type"] isEqualToString: @"font"])
      {
	/* This is special.  In this case, allocPlatformObject gave us
	 * an instance which is already init-ed!
	 */
	if (title != nil)
	  {
	    [platformObject setTitle: title];
	  }
      }
    else
      {
	/* In all other cases, we must do an -init of some sort now.
	 * :-)
	 */
	if (title != nil)
	  {
	    platformObject = [platformObject initWithTitle: title];
	  }
	else
	  {
	    platformObject = [platformObject init];
	  }
      }
  }
  
  /* Create content.  */
  count = [_content count];
  
  for (i = 0; i < count; i++)
    {
      /* We have as content either <menuItem> tags, or <menu> tags.  */
      GSMarkupTagObject *tag = [_content objectAtIndex: i];
      NSMenuItem *item = [tag platformObject];

      /* If what we decoded really is a NSMenu, not a NSMenuItem,
       * wrap it up into a NSMenuItem.
       */
      if ([item isKindOfClass: [NSMenu class]])
	{
	  NSMenu *menu = (NSMenu *)item;
	  item = [[NSMenuItem alloc] initWithTitle: [menu title]
				     action: NULL
				     keyEquivalent: @""];
	  [item setSubmenu: menu];
	}
      
      if (item != nil  &&  [item isKindOfClass: [NSMenuItem class]])
	{
	  [platformObject addItem: item];
	}
    }
  
  /* type */
  {
    NSString *type = [_attributes objectForKey: @"type"];
  
    if (type != nil)
      {
	if ([type isEqualToString: @"main"])
	  {
	    [NSApp setMainMenu: platformObject];
	  }
	else if ([type isEqualToString: @"windows"])
	  {
	    [NSApp setWindowsMenu: platformObject];
	  }
	else if ([type isEqualToString: @"services"])
	  {
	    [NSApp setServicesMenu: platformObject];
	  }
	else if ([type isEqualToString: @"font"])
	  {
	    /* The menu has already been created as font menu.  */
          }
        else if ([type isEqualToString: @"apple"])
	  {
#ifndef GNUSTEP
	    [NSApp setAppleMenu: platformObject];
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
	[platformObject setAutoenablesItems: NO];
      }
  }
  
  return platformObject;
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObject: @"title"];
}

@end
