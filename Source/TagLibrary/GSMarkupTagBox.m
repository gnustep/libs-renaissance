/* -*-objc-*-
   GSMarkupTagBox.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March 2002

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

#include <GSMarkupTagBox.h>
#include "GSAutoLayoutDefaults.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSBox.h>
#endif

/* We need this intermediate class so that we can ignore the sizeToFit
 * calls made by the NSBox to its content view ... */
@interface GSMarkupBoxContentView : NSView
- (void) sizeToFit;
@end

@implementation GSMarkupBoxContentView

- (NSView *)firstSubview
{
  NSArray *subviews = [self subviews];

  if (subviews != nil  &&  [subviews count] > 0)
    {
      return [subviews objectAtIndex: 0];  
    }
  else
    {
      return nil;
    }
}

/* This is only used when setting up the thing at startup, and never
 * afterwards.  */
- (void) sizeToFit
{
  NSView *firstSubview = [self firstSubview];

  [self setAutoresizesSubviews: NO];
  
  if (firstSubview)
    {
      [self setFrameSize: [firstSubview frame].size];
    }
  else
    {
      [self setFrameSize: NSMakeSize (50, 50)];
    }

  [self setAutoresizesSubviews: YES];
}

/* Use the autolayout defaults of the first subview.  */
- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{
  NSView *firstSubview = [self firstSubview];

  if (firstSubview)
    {
      return [firstSubview autolayoutDefaultVerticalAlignment];
    }
  else
    {
      return [super autolayoutDefaultVerticalAlignment];
    }
}

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  NSView *firstSubview = [self firstSubview];

  if (firstSubview)
    {
      return [firstSubview autolayoutDefaultHorizontalAlignment];
    }
  else
    {
      return [super autolayoutDefaultHorizontalAlignment];
    }
}

@end

@implementation GSMarkupTagBox

+ (NSString *) tagName
{
  return @"box";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSBox class];
}

/* Basically, we only recognize the following options -
 *
 * title (yes / no); if yes, it is always on top
 * border (yes / no); if yes, the platform default border is always used.
 */
- (void) platformObjectInit
{
  [self setPlatformObject: [_platformObject init]];

  /* title */
  {
    NSString *title = [self localizedStringValueForAttribute: @"title"];

    if (title == nil)
      {
	/* Set the title even if nil ... to remove the default 'Title'
	 * label! */
	/* Mac OS X barfs on nil title  */
	[_platformObject setTitle: @""];
	/* Make sure to remove it completely if nil.  */
	[_platformObject setTitlePosition: NSNoTitle];
      }
    else
      {
	[_platformObject setTitle: title];
      }
  }

  /* no border - FIXME tag attribute name */
  {
    if ([self boolValueForAttribute: @"hasBorder"] == 0)
      {
	[_platformObject setBorderType: NSNoBorder];
      }
  }

  /* Content view.  */
  if (_content != nil  &&  [_content count] > 0)
    {
      NSView *subview = [(GSMarkupTagObject *)[_content objectAtIndex: 0] 
					  platformObject];
      if ([subview isKindOfClass: [NSView class]])
	{
	  GSMarkupBoxContentView *v;
	  
	  v = [GSMarkupBoxContentView new];
	  [v setAutoresizesSubviews: YES];
	  [(NSBox *)_platformObject setContentView: v];
	  RELEASE (v);

	  [v addSubview: subview];
	}
    }
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObject: @"title"];
}

@end
