/* -*-objc-*-
   GSMarkupTagMenuItem.m

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
# include <AppKit/NSCell.h>
# include <AppKit/NSImage.h>
# include <AppKit/NSMenu.h>
# include <AppKit/NSMenuItem.h>
# include <AppKit/NSView.h>
#endif

@implementation GSMarkupTagMenuItem
+ (NSString *) tagName
{
  return @"menuItem";
}

- (void) platformObjectAlloc
{
  _platformObject = [NSMenuItem alloc];
}

- (void) platformObjectInit
{
  /* title key action */
  NSString *title = [self localizedStringValueForAttribute: @"title"];
  NSString *keyEquivalent = [_attributes objectForKey: @"key"];
  NSString *actionString = [_attributes objectForKey: @"action"];
  SEL action = NULL;
 
  if (actionString != nil)
    {
      action = NSSelectorFromString (actionString);
    }

  /* Apple OSX barfs on a nil keyEquivalent.  */
  if (keyEquivalent == nil)
    {
      keyEquivalent = @"";
    }

  /* Apple OSX barfs on a nil title.  */
  if (title == nil)
    {
      title = @"";
    }
  
  _platformObject = [_platformObject initWithTitle: title
				     action: action
				     keyEquivalent: keyEquivalent];
  
  /* If there is a submenu, is stored in the content.  Create it.  */
  if ([_content count] > 0)
    {
      GSMarkupTagMenu *m = [_content objectAtIndex: 0];
      NSMenu *menu = [m platformObject];
      
      if (menu != nil  &&  [menu isKindOfClass: [NSMenu class]])
	{
	  /* On Apple OSX we need to make sure submenus have properly
	   * set titles.  But we want to allow it to be omitted in the
	   * .gsmarkup file if the enclosing NSMenuItem has a title
	   * set.  So ... manually push the menuItem title onto the
	   * submenu, unless a different title has been set in the
	   * submenu. 
	   */
          if (title != nil)
	    {
	      if ([menu title] == nil)
		{
		  [menu setTitle: title];
		}
	    }	  
	  [_platformObject setSubmenu: menu];
	}
    }
  
  /* image */
  {
    NSString *image = [_attributes objectForKey: @"image"];

    if (image != nil)
      {
	[_platformObject setImage: [NSImage imageNamed: image]];
      }
  }

  /* tag */
  {
    NSString *tag = [_attributes objectForKey: @"tag"];
    if (tag != nil)
      {
	[_platformObject setTag: [tag intValue]];
      }
  }

  /* enabled */
  {
    int enabled = [self boolValueForAttribute: @"enabled"];
    if (enabled == 1)
      {
	[_platformObject setEnabled: YES];
      }
    else if (enabled == 0)
      {
	[_platformObject setEnabled: NO];
      }
  }

  /* state */
  {
    NSString *state = [_attributes objectForKey: @"state"];
    if (state != nil)
      {
	if ([state isEqualToString: @"on"])
	  {
	    [_platformObject setState: NSOnState];
	  }
	else if ([state isEqualToString: @"off"])
	  {
	    [_platformObject setState: NSOffState];
	  }
	else if ([state isEqualToString: @"mixed"])
	  {
	    [_platformObject setState: NSMixedState];
	  }
      }
  }
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObject: @"title"];
}

@end
