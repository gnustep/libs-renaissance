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

+ (Class) platformObjectClass
{
  return [NSImageView class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [super initPlatformObject: platformObject];

  /* On GNUstep, it seems image views are by default editable.  Turn
   * that off, we want uneditable images by default.
   */
  [platformObject setEditable: NO];	

  /* editable */
  {
    int editable = [self boolValueForAttribute: @"editable"];
    
    if (editable == 1)
      {
	[platformObject setEditable: YES];
      }
    else if (editable == 0)
      {
	[platformObject setEditable: NO];
      }
  }

  /* name */
  {
    NSString *name = [_attributes objectForKey: @"name"];

    if (name != nil)
      {
	[(NSImageView *)platformObject setImage: [NSImage imageNamed: name]];
      }
  }

  /* animates */
  {
    int animates = [self boolValueForAttribute: @"animates"];
    
    if (animates == 1)
      {
	[platformObject setAnimates: YES];
      }
    else if (animates == 0)
      {
	[platformObject setAnimates: NO];
      }
  }

  /* allowsCutCopyPaste */
  {
    int allowsCutCopyPaste = [self boolValueForAttribute: @"allowsCutCopyPaste"];
    
    if (allowsCutCopyPaste == 1)
      {
	[platformObject setAllowsCutCopyPaste: YES];
      }
    else if (allowsCutCopyPaste == 0)
      {
	[platformObject setAllowsCutCopyPaste: NO];
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
		[platformObject setImageScaling: NSScaleNone];
	      }
	    break;
	  case 'p':
	    if ([scaling isEqualToString: @"proportionally"])
	      {
		[platformObject setImageScaling: NSScaleProportionally];
	      }
	    break;
	  case 't':
	    if ([scaling isEqualToString: @"toFit"])
	      {
		[platformObject setImageScaling: NSScaleToFit];
	      }
	    break;
	  }
      }
  }

  /* imageAlignment */
  {
    NSString *alignment = [_attributes objectForKey: @"imageAlignment"];
   
    /* Backwards-compatible check introduced on 27 Feb 2008, will be
     * removed on 27 Feb 2009.
     */
    if (alignment == nil)
      {
	/* Check for the old name "alignment"  */
	alignment = [_attributes objectForKey: @"alignment"];

	if (alignment != nil)
	  {
	    NSLog (@"The 'alignment' attribute has been renamed to 'imageAlignment'.  Please update your gsmarkup files");
	  }
      }

    if (alignment != nil  &&  [alignment length] > 0)
      {
	
	switch ([alignment characterAtIndex: 0])
	  {
	  case 'b':
	    if ([alignment isEqualToString: @"bottom"])
	      {
		[platformObject setImageAlignment: NSImageAlignBottom];
	      }
	    else if ([alignment isEqualToString: @"bottomLeft"])
	      {
		[platformObject setImageAlignment: NSImageAlignBottomLeft];
	      }
	    else if ([alignment isEqualToString: @"bottomRight"])
	      {
		[platformObject setImageAlignment: NSImageAlignBottomRight];
	      }
	    break;

	  case 'c':
	    if ([alignment isEqualToString: @"center"])
	      {
		[platformObject setImageAlignment: NSImageAlignCenter];
	      }
	    break;

	  case 'l':
	    if ([alignment isEqualToString: @"left"])
	      {
		[platformObject setImageAlignment: NSImageAlignLeft];
	      }
	    break;

	  case 'r':
	    if ([alignment isEqualToString: @"right"])
	      {
		[platformObject setImageAlignment: NSImageAlignRight];
	      }
	    break;

	  case 't':
	    if ([alignment isEqualToString: @"top"])
	      {
		[platformObject setImageAlignment: NSImageAlignTop];
	      }
	    else if ([alignment isEqualToString: @"topLeft"])
	      {
		[platformObject setImageAlignment: NSImageAlignTopLeft];
	      }
	    else if ([alignment isEqualToString: @"topRight"])
	      {
		[platformObject setImageAlignment: NSImageAlignTopRight];
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
	[platformObject setImageFrameStyle: NSImageFrameGroove];
      }
    else if (hasFrame == 0)
      {
	[platformObject setImageFrameStyle: NSImageFrameNone];
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
		[platformObject setImageFrameStyle: NSImageFrameButton];
	      }
	    break;

	  case 'g':
	    if ([frameStyle isEqualToString: @"grayBezel"])
	      {
		[platformObject setImageFrameStyle: NSImageFrameGrayBezel];
	      }
	    else if ([frameStyle isEqualToString: @"groove"])
	      {
		[platformObject setImageFrameStyle: NSImageFrameGroove];
	      }
	    break;

	  case 'n':
	    if ([frameStyle isEqualToString: @"none"])
	      {
		[platformObject setImageFrameStyle: NSImageFrameNone];
	      }
	    break;

	  case 'p':
	    if ([frameStyle isEqualToString: @"photo"])
	      {
		[platformObject setImageFrameStyle: NSImageFramePhoto];
	      }
	    break;
	  }
      }
  }
  
  return platformObject;
}

@end
