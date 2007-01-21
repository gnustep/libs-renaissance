/* -*-objc-*-
   GSMarkupTagView.m

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
#include <TagCommonInclude.h>
#include "GSMarkupTagView.h"
#include "GSAutoLayoutDefaults.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSView.h>
#endif

#include <NSViewSize.h>

@implementation GSMarkupTagView

+ (NSString *) tagName
{
  return @"view";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSView class];
}

+ (BOOL) useInstanceOfAttribute
{
  return YES;
}

- (void) platformObjectInit
{
  [self setPlatformObject: [_platformObject init]];

  /* nextKeyView, previousKeyView are outlets :-), done
   * automatically.  */
}

/* This is done at init time, but should be done *after* all other
 * initialization - so it is in a separate method which subclasses
 * can/must call at the end of their platformObjectInit method.  */
- (void) platformObjectAfterInit
{
  [(NSView *)_platformObject sizeToFitContent];

  /* Now set the hardcoded frame if any.  */
  {
    NSRect frame = [_platformObject frame];
    NSString *x, *y, *width, *height;
    BOOL needToSetFrame = NO;
    
    x = [_attributes objectForKey: @"x"];
    if (x != nil)
      {
	frame.origin.x = [x floatValue];
	needToSetFrame = YES;
      }

    y = [_attributes objectForKey: @"y"];
    if (y != nil)
      {
	frame.origin.y = [y floatValue];
	needToSetFrame = YES;
      }

    width = [_attributes objectForKey: @"width"];
    if (width != nil)
      {
	float w = [width floatValue];
	if (w > 0)
	  {
	    frame.size.width = w;
	    needToSetFrame = YES;
	  }
      }

    height = [_attributes objectForKey: @"height"];
    if (height != nil)
      {
	float h = [height floatValue];
	if (h > 0)
	  {
	    frame.size.height = h;
	    needToSetFrame = YES;
	  }
      }
    if (needToSetFrame)
      {
	[_platformObject setFrame: frame];
      }
  }

  /* We don't normally use autoresizing masks, except in special
   * cases: stuff contained inside NSBox objects mostly.  As a
   * simplification for those cases, by default we want a subview to
   * get any autoresizing stuff which the superview generates (we will
   * then always turn off generating the autoresizing in the superview
   * except in the special cases).
   */
  [_platformObject setAutoresizingMask: 
		     NSViewWidthSizable | NSViewHeightSizable];
  

  /* You can set autoresizing masks if you're trying to build views in the
   * old hardcoded size style.  Else, it's pretty useless.
   *
   * Subclasses have each one their own default autoresizing mask.  We
   * only modify the existing one if a different one is specified in
   * the .gsmarkup file.  The format for specifying them is as in
   * autoresizingMask="hw" for NSViewHeightSizable |
   * NSViewWidthSizable, and autoresizingMask="" for nothing,
   * autoresizingMask="xXhy" for NSViewMinXMargin | NSViewMaxXMargin |
   * NSViewHeightSizable | NSViewMinYMargin.
   */
  {
    unsigned autoresizingMask = [_platformObject autoresizingMask];
    NSString *autoresizingMaskString = [_attributes objectForKey: 
						      @"autoresizingMask"];

    if (autoresizingMaskString != nil)
      {
	int i, count = [autoresizingMaskString length];
	unsigned newAutoresizingMask = 0;
	
	for (i = 0; i < count; i++)
	  {
	    unichar c = [autoresizingMaskString characterAtIndex: i];

	    switch (c)
	      {
	      case 'h':
		newAutoresizingMask |= NSViewHeightSizable;
		break;
	      case 'w':
		newAutoresizingMask |= NSViewWidthSizable;
		break;
	      case 'x':
		newAutoresizingMask |= NSViewMinXMargin;
		break;
	      case 'X':
		newAutoresizingMask |= NSViewMaxXMargin;
		break;
	      case 'y':
		newAutoresizingMask |= NSViewMinYMargin;
		break;
	      case 'Y':
		newAutoresizingMask |= NSViewMaxYMargin;
		break;
	      default:
		break;
	      }
	  }
      if (newAutoresizingMask != autoresizingMask)
        {	
          [_platformObject setAutoresizingMask: newAutoresizingMask];
        }
      }
  }
}

- (int) gsAutoLayoutHAlignment
{
  NSString *halign;

  if ([self boolValueForAttribute: @"hexpand"] == 1)
    {
      return GSAutoLayoutExpand;
    }

  halign = [_attributes objectForKey: @"halign"];

  if (halign != nil)
    {
      if ([halign isEqualToString: @"expand"])
	{
	  return GSAutoLayoutExpand;
	}
      else if ([halign isEqualToString: @"wexpand"])
	{
	  return GSAutoLayoutWeakExpand;
	}
      else if ([halign isEqualToString: @"min"])
	{
	  return GSAutoLayoutAlignMin;
	}
      else if ([halign isEqualToString: @"left"])
	{
	  return GSAutoLayoutAlignMin;
	}
      else if ([halign isEqualToString: @"center"])
	{
	  return GSAutoLayoutAlignCenter;
	}
      else if ([halign isEqualToString: @"max"])
	{
	  return GSAutoLayoutAlignMax;
	}
      else if ([halign isEqualToString: @"right"])
	{
	  return GSAutoLayoutAlignMax;
	}
    }

  return 255;
}

- (int) gsAutoLayoutVAlignment
{
  NSString *valign;

  if ([self boolValueForAttribute: @"vexpand"] == 1)
    {
      return GSAutoLayoutExpand;
    }

  valign = [_attributes objectForKey: @"valign"];

  if (valign != nil)
    {
      if ([valign isEqualToString: @"expand"])
	{
	  return GSAutoLayoutExpand;
	}
      else if ([valign isEqualToString: @"wexpand"])
	{
	  return GSAutoLayoutWeakExpand;
	}
      else if ([valign isEqualToString: @"min"])
	{
	  return GSAutoLayoutAlignMin;
	}
      else if ([valign isEqualToString: @"bottom"])
	{
	  return GSAutoLayoutAlignMin;
	}
      else if ([valign isEqualToString: @"center"])
	{
	  return GSAutoLayoutAlignCenter;
	}
      else if ([valign isEqualToString: @"max"])
	{
	  return GSAutoLayoutAlignMax;
	}
      else if ([valign isEqualToString: @"top"])
	{
	  return GSAutoLayoutAlignMax;
	}
    }

  return 255;
}

@end
