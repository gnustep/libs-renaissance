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
#include <TagCommonInclude.h>
#include "GSMarkupTagMenu.h"
#include "GSMarkupTagMenuItem.h"


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

- (id) allocPlatformObject
{
  return [NSMenuItem alloc];
}

- (id) initPlatformObject: (id)platformObject
{
  /* title key action */
  NSString *title = [self localizedStringValueForAttribute: @"title"];
  NSString *keyEquivalent = [_attributes objectForKey: @"keyEquivalent"];
  SEL action = NULL;
 
  {
    NSString *actionString = [_attributes objectForKey: @"action"];
    if (actionString != nil)
      {
	action = NSSelectorFromString (actionString);
      }
  }

  /* Backward-compatible hack to support obsolete attribute 'key'.
   * It will be removed one year from now, on 4 March 2009.
   */
  if (keyEquivalent == nil)
    {
      keyEquivalent = [_attributes objectForKey: @"key"];
      if (keyEquivalent != nil)
	{
	  NSLog (@"The 'key' attribute of the <menuItem> tag is obsolete; please replace it with 'keyEquivalent'");
	}
    }

  /* Mac OS X barfs on a nil keyEquivalent.  */
  if (keyEquivalent == nil)
    {
      keyEquivalent = @"";
    }
  
  /* Mac OS X barfs on a nil title.  */
  if (title == nil)
    {
      title = @"";
    }
  
  platformObject = [platformObject initWithTitle: title
				   action: action
				   keyEquivalent: keyEquivalent];
  
  /* image */
  {
    NSString *image = [_attributes objectForKey: @"image"];

    if (image != nil)
      {
	[platformObject setImage: [NSImage imageNamed: image]];
      }
  }

  /* tag */
  {
    NSString *tag = [_attributes objectForKey: @"tag"];
    if (tag != nil)
      {
	[platformObject setTag: [tag intValue]];
      }
  }

  /* enabled */
  {
    int enabled = [self boolValueForAttribute: @"enabled"];
    if (enabled == 1)
      {
	[platformObject setEnabled: YES];
      }
    else if (enabled == 0)
      {
	[platformObject setEnabled: NO];
      }
  }

  /* state */
  {
    NSString *state = [_attributes objectForKey: @"state"];
    if (state != nil)
      {
	if ([state isEqualToString: @"on"])
	  {
	    [platformObject setState: NSOnState];
	  }
	else if ([state isEqualToString: @"off"])
	  {
	    [platformObject setState: NSOffState];
	  }
	else if ([state isEqualToString: @"mixed"])
	  {
	    [platformObject setState: NSMixedState];
	  }
      }
  }

  return platformObject;
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObject: @"title"];
}

@end
