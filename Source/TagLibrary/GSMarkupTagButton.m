/* -*-objc-*-
   GSMarkupTagButton.m

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

#include <GSMarkupTagButton.h>


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSButton.h>
# include <AppKit/NSImage.h>
#endif

@implementation GSMarkupTagButton
+ (NSString *) tagName
{
  return @"button";
}

- (void) platformObjectAlloc
{
  _platformObject = [NSButton alloc];
}

- (void) platformObjectInit
{
  [super platformObjectInit];

  /* FIXME */
  [_platformObject setAutoresizingMask: NSViewMinXMargin | NSViewMaxXMargin
		   | NSViewMinYMargin | NSViewMaxYMargin];
  
  /* title */
  {
    NSString *title = [self localizedStringValueForAttribute: @"title"];

    if (title != nil)
      {
	[_platformObject setTitle: title];
      }
    else
      {
	[_platformObject setTitle: @""];
      }
  }

  /* font */
  {
    NSFont *f = [self fontValueForAttribute: @"font"];
    if (f != nil)
      {
	[_platformObject setFont: f];
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

  /* imagePosition */
  {
    NSString *imagePosition = [_attributes objectForKey: @"imagePosition"];
   
    if (imagePosition != nil  &&  [imagePosition length] > 0)
      {
	
	switch ([imagePosition characterAtIndex: 0])
	  {
	  case 'a':
	    if ([imagePosition isEqualToString: @"above"])
	      {
		[_platformObject setImagePosition: NSImageAbove];
	      }
	    break;
	  case 'b':
	    if ([imagePosition isEqualToString: @"below"])
	      {
		[_platformObject setImagePosition: NSImageBelow];
	      }
	    break;
	  case 'l':
	    if ([imagePosition isEqualToString: @"left"])
	      {
		[_platformObject setImagePosition: NSImageLeft];
	      }
	    break;
	  case 'o':
	    if ([imagePosition isEqualToString: @"overlaps"])
	      {
		[_platformObject setImagePosition: NSImageOverlaps];
	      }
	    break;
	  case 'r':
	    if ([imagePosition isEqualToString: @"right"])
	      {
		[_platformObject setImagePosition: NSImageRight];
	      }
	    break;
	    /* FIXME/TODO - what about imageOnly ? */
	  case 'i':
	    if ([imagePosition isEqualToString: @"imageOnly"])
	      {
		[_platformObject setImagePosition: NSImageOnly];
	      }
	    break;
	  }
      }
  }
  
  /* key */
  {
    NSString *key = [_attributes objectForKey: @"key"];

    if (key != nil)
      {
	[_platformObject setKeyEquivalent: key];
      }
  }

  /* alternateTitle */
  {
    NSString *t = [self localizedStringValueForAttribute: @"alternateTitle"];

    if (t != nil)
      {
	[_platformObject setAlternateTitle: t];
      }
  }

  /* alternateImage */
  {
    NSString *image = [_attributes objectForKey: @"alternateImage"];

    if (image != nil)
      {
	[_platformObject setAlternateImage: [NSImage imageNamed: image]];
      }
  }

  /* type */
  {
    NSString *type = [_attributes objectForKey: @"type"];
    
    if (type != nil)
      {
	/* TODO/FIXME ... what types of buttons do we need ? */
      }
    
  }
  
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObjects: @"title", @"alternateTitle", nil];
}

@end
