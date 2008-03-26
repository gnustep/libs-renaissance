/* -*-objc-*-
   GSMarkupTagTabViewItem.m

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
#include "GSMarkupTagObjectAdditions.h"


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSCell.h>
# include <AppKit/NSImage.h>
# include <AppKit/NSTabView.h>
# include <AppKit/NSTabViewItem.h>
# include <AppKit/NSView.h>
#endif

@implementation GSMarkupTagTabViewItem
+ (NSString *) tagName
{
  return @"tabViewItem";
}

- (id) allocPlatformObject
{
  return [NSTabViewItem alloc];
}

- (id) initPlatformObject: (id)platformObject
{
  /* identifier */
  NSString *identifier = [_attributes objectForKey: @"identifier"];

  platformObject = [platformObject initWithIdentifier: identifier];
  
  /* label */
  NSString *label = [self localizedStringValueForAttribute: @"label"];
  [platformObject setLabel:label];

  /* color */
  {
    NSColor *c = [self colorValueForAttribute: @"color"];

    if (c != nil)
      {
	[platformObject setColor: c];
	NSLog (@"The 'color' attribute of the <tabViewItem> tag is obsolete; color should be supplied by the current theme.");
      }
  }

  /* Add content.  */
  {
    int count = [_content count];
    NSView *view = nil;
    
    if( count > 1 )
      {
	GSMarkupTagView *v =
	  [[GSMarkupTagView alloc] initWithAttributes: _attributes
	                                      content: _content];
	view = [v platformObject];
	NSRect r = [view frame];
	NSLog(@"subView %@ size : %d %d",view,r.size.width,r.size.height);
	NSLog(@"subviews %@",[[view subviews] objectAtIndex:0]);
      }
    else if( count == 1 )
      {
	GSMarkupTagView *v = [_content objectAtIndex: 0];
	view = [v platformObject];
      }

    if (view != nil  &&  [view isKindOfClass: [NSView class]])
      {
	[platformObject setView: view];
      }
  }

  return platformObject;
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObject: @"label"];
}

@end
