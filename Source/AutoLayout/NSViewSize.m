/* -*-objc-*-
   NSViewSize.m

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

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
#else
# include <AppKit/NSBox.h>
# include <AppKit/NSCell.h>
# include <AppKit/NSControl.h>
# include <AppKit/NSMatrix.h>
# include <AppKit/NSScrollView.h>
# include <AppKit/NSSplitView.h>
# include <AppKit/NSTextField.h>
# include <Foundation/NSString.h>
#endif

#include "NSViewSize.h"

@implementation NSView (sizeToContent)

- (void) sizeToFitContent
{
  [self setFrameSize: NSMakeSize (0, 0)];
}

- (NSSize) minimumSizeForContent
{
  NSRect oldFrame;
  NSSize minimumSize;

  /* Save the oldFrame.  */
  oldFrame = [self frame];
  
  /* Resize the view to fit the contents ... this is the only
   * way available in the AppKit to get the minimum size.  */
  [self sizeToFitContent];

  /* Get the minimum size by reading the frame.  */
  minimumSize = [self frame].size;
  
  /* Restore the original frame.  */
  [self setFrame: oldFrame];
  
  return minimumSize;
}

@end

@implementation NSControl (sizeToContent)

- (void) sizeToFitContent
{
  [self sizeToFit];
}

@end

/* NSBox comments - make sure you realize that NSBox -sizeToFit calls
 * the contentView's -sizeToFit method.  If you want the NSBox
 * contentview to have a hardcoded frame which is not the minimum
 * size, you need to embed it in a [hv]box before putting it in
 * the NSBox, to make sure this hardcoded frame overrides the minimum
 * size.
 */
@implementation NSBox (sizeToContent)

- (void) sizeToFitContent
{
  [self sizeToFit];
}

@end

/* NSSplitView's sizeToContent makes the splitview just big enough
 * to display its subviews, plus the dividers.  
 *
 * NB: (not really relevant any longer, but for future memories of
 * past problems) the default implementation of setting a NSZeroSize
 * would not work because resizing a splitview resizes all subviews,
 * and resizing a splitview to a zero size, at least on GNUstep,
 * resizes all subviews to have zero size, loosing all size
 * relationships between them ... it's an unrecoverable operation on
 * GNUstep.
 */
@implementation NSSplitView (sizeToContent)
- (void) sizeToFitContent
{
  NSSize newSize = NSZeroSize;
  NSArray *subviews = [self subviews];
  int i, count = [subviews count];
  float dividerThickness = [self dividerThickness];

  if (count == 0)
    {
      [self setFrameSize: newSize];
      return;
    }

  if ([self isVertical])
    {
      NSView *subview = [subviews objectAtIndex: 0];
      NSRect subviewRect = [subview frame];

      newSize.height = subviewRect.size.height;

      for (i = 0; i < count; i++)
	{
	  subview = [subviews objectAtIndex: i];
	  subviewRect = [subview frame];
	  
	  newSize.width += subviewRect.size.width;
	}
      
      newSize.width += dividerThickness * (count - 1);
    }
  else
    {
      NSView *subview = [subviews objectAtIndex: 0];
      NSRect subviewRect = [subview frame];

      newSize.width = subviewRect.size.width;

      for (i = 0; i < count; i++)
	{
	  subview = [subviews objectAtIndex: i];
	  subviewRect = [subview frame];
	  
	  newSize.height += subviewRect.size.height;
	}
      
      newSize.height += dividerThickness * (count - 1);
    }
  
  [self setFrameSize: newSize];
}
@end

@implementation NSTextField (sizeToContent)

/* We want text fields to get a reasonable size when empty.  */
- (void) sizeToFitContent
{
  NSString *stringValue = [self stringValue];
  
  if (stringValue == nil  ||  [stringValue length] == 0)
    {
      [self setStringValue: @"Nicola"];
      [self sizeToFit];
      [self setStringValue: @""];
    }
  else
    {
      [self sizeToFit];
    }
}

@end

@implementation NSMatrix (sizeToContent)
- (void) sizeToFitContent
{
  /* Unbelievable how it may be, -sizeToFit or -sizeToCells on Apple
   * don't seem to compute the cell size.  This is taken from code I
   * originally wrote for gnustep-gui.  */
  NSSize newSize = NSZeroSize;

  int numRows = [self numberOfRows];
  int numCols = [self numberOfColumns];
  int i, j;

  for (i = 0; i < numRows; i++)
    {
      for (j = 0; j < numCols; j++)
	{
	  NSCell *cell = [self cellAtRow: i  column: j];
	  if (cell != nil)
	    {
	      NSSize tempSize = [cell cellSize];
	      if (tempSize.width > newSize.width)
		{
		  newSize.width = tempSize.width;
		}
	      if (tempSize.height > newSize.height)
		{
		  newSize.height = tempSize.height;
		}
	    }
	}
    }
  
  [self setCellSize: newSize];
  [self sizeToCells];
}
@end

/* NSImageView does not support sizeToFit on Apple!  The following
 * hack only works after the image has just been set.  */
#ifndef GNUSTEP
@implementation NSImageView (sizeToContent)
- (void) sizeToFitContent
{
  [self setFrameSize: [[self image] size]];
}
@end
#endif

