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
