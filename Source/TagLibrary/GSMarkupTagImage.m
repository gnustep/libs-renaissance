/* -*-objc-*-
   GSMarkupTagImage.m

   Copyright (C) 2003 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: January 2003

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
#include "GSMarkupTagImage.h"


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSImage.h>
# include <AppKit/NSImageCell.h>
# include <AppKit/NSImageView.h>
#endif

@implementation GSMarkupTagImage
+ (NSString *) tagName
{
  return @"image";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSImageView class];
}

- (void) platformObjectInit
{
  [super platformObjectInit];

  /* On GNUstep, it seems image views are by default editable.  Turn
   * that off, we want uneditable images by default.
   */
  [_platformObject setEditable: NO];	

  /* editable */
  {
    int editable = [self boolValueForAttribute: @"editable"];
    
    if (editable == 1)
      {
	[_platformObject setEditable: YES];
      }
    else if (editable == 0)
      {
	[_platformObject setEditable: NO];
      }
  }

  /* name */
  {
    NSString *name = [_attributes objectForKey: @"name"];

    if (name != nil)
      {
	[(NSImageView *)_platformObject setImage: [NSImage imageNamed: name]];
      }
  }

  /* scaling */
  {
    NSString *scaling = [_attributes objectForKey: @"scaling"];
   
    if (scaling != nil  &&  [scaling length] > 0)
      {
	
	switch ([scaling characterAtIndex: 0])
	  {
	  case 'n':
	    if ([scaling isEqualToString: @"none"])
	      {
		[_platformObject setImageScaling: NSScaleNone];
	      }
	    break;
	  case 'p':
	    if ([scaling isEqualToString: @"proportionally"])
	      {
		[_platformObject setImageScaling: NSScaleProportionally];
	      }
	    break;
	  case 't':
	    if ([scaling isEqualToString: @"toFit"])
	      {
		[_platformObject setImageScaling: NSScaleToFit];
	      }
	    break;
	  }
      }
  }

  /* alignment */
  {
    NSString *alignment = [_attributes objectForKey: @"alignment"];
   
    if (alignment != nil  &&  [alignment length] > 0)
      {
	
	switch ([alignment characterAtIndex: 0])
	  {
	  case 'b':
	    if ([alignment isEqualToString: @"bottom"])
	      {
		[_platformObject setImageAlignment: NSImageAlignBottom];
	      }
	    else if ([alignment isEqualToString: @"bottomLeft"])
	      {
		[_platformObject setImageAlignment: NSImageAlignBottomLeft];
	      }
	    else if ([alignment isEqualToString: @"bottomRight"])
	      {
		[_platformObject setImageAlignment: NSImageAlignBottomRight];
	      }
	    break;

	  case 'c':
	    if ([alignment isEqualToString: @"center"])
	      {
		[_platformObject setImageAlignment: NSImageAlignCenter];
	      }
	    break;

	  case 'l':
	    if ([alignment isEqualToString: @"left"])
	      {
		[_platformObject setImageAlignment: NSImageAlignLeft];
	      }
	    break;

	  case 'r':
	    if ([alignment isEqualToString: @"right"])
	      {
		[_platformObject setImageAlignment: NSImageAlignRight];
	      }
	    break;

	  case 't':
	    if ([alignment isEqualToString: @"top"])
	      {
		[_platformObject setImageAlignment: NSImageAlignTop];
	      }
	    else if ([alignment isEqualToString: @"topLeft"])
	      {
		[_platformObject setImageAlignment: NSImageAlignTopLeft];
	      }
	    else if ([alignment isEqualToString: @"topRight"])
	      {
		[_platformObject setImageAlignment: NSImageAlignTopRight];
	      }
	    break;
	  }
      }
  }

  /* Implicit default for hasFrame is none.  */

  /* hasFrame */
  {
    int hasFrame = [self boolValueForAttribute: @"hasFrame"];
    
    if (hasFrame == 1)
      {
	[_platformObject setImageFrameStyle: NSImageFrameGroove];
      }
    else if (hasFrame == 0)
      {
	[_platformObject setImageFrameStyle: NSImageFrameNone];
      }
  }

  /* frameStyle.  This should very rarely be used.  It's better for
   * you to use the default frameStyle on the platform -- that is, to
   * rely on hasFrame="yes" and let it choose the right frame style
   * for your platform.  Anyway.  */
  {
    NSString *frameStyle = [_attributes objectForKey: @"frameStyle"];
   
    if (frameStyle != nil  &&  [frameStyle length] > 0)
      {
	switch ([frameStyle characterAtIndex: 0])
	  {
	  case 'b':
	    if ([frameStyle isEqualToString: @"button"])
	      {
		[_platformObject setImageFrameStyle: NSImageFrameButton];
	      }
	    break;

	  case 'g':
	    if ([frameStyle isEqualToString: @"grayBezel"])
	      {
		[_platformObject setImageFrameStyle: NSImageFrameGrayBezel];
	      }
	    else if ([frameStyle isEqualToString: @"groove"])
	      {
		[_platformObject setImageFrameStyle: NSImageFrameGroove];
	      }
	    break;

	  case 'n':
	    if ([frameStyle isEqualToString: @"none"])
	      {
		[_platformObject setImageFrameStyle: NSImageFrameNone];
	      }
	    break;

	  case 'p':
	    if ([frameStyle isEqualToString: @"photo"])
	      {
		[_platformObject setImageFrameStyle: NSImageFramePhoto];
	      }
	    break;
	  }
      }
  }
}

@end
