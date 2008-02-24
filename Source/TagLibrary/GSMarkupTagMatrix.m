/* -*-objc-*-
   GSMarkupTagMatrix.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: December 2002

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
#include "GSMarkupTagMatrix.h"
#include "GSMarkupTagMatrixRow.h"
#include "GSMarkupTagMatrixCell.h"


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
# include <AppKit/NSMatrix.h>
#endif

@implementation GSMarkupTagMatrix

+ (NSString *) tagName
{
  return @"matrix";
}

+ (Class) platformObjectClass
{
  return [NSMatrix class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [super initPlatformObject: platformObject];

  /* type ... not really supported.  Only radio button matrix supported at the 
     moment.  Maybe it shouldn't be called matrix but radioMatrix ? */
  {
    NSString *type = [_attributes objectForKey: @"type"];
    /* Default is 'radio'  */
    int mode = NSRadioModeMatrix;

    if (type != nil)
      {
	if ([type isEqualToString: @"track"])
	  {
	    mode = NSTrackModeMatrix;
	  }
	else if ([type isEqualToString: @"highlight"])
	  {
	    mode = NSHighlightModeMatrix;
	  }
	else if ([type isEqualToString: @"list"])
	  {
	    mode = NSListModeMatrix;
	  }
      }

    [(NSMatrix *)platformObject setMode: mode];
  }

  /* doubleAction */
  {
    NSString *doubleAction = [_attributes objectForKey: @"doubleAction"];
  
    if (doubleAction != nil)
      {
	[platformObject setDoubleAction: NSSelectorFromString (doubleAction)];
      }
  }  

  /* Now the contents.  An array of matrixRow objects, each of them containing 
   * matrixCell objects.
   */
  {
    int i, numberOfRows, numberOfColumns;
    numberOfRows = [_content count];

    /* Now determine the number of columns.  */
    numberOfColumns = 0;
    for (i = 0; i < numberOfRows; i++)
      {
	GSMarkupTagMatrixRow *row = [_content objectAtIndex: i];
	int cols = [[row content] count];
	if (cols > numberOfColumns)
	  {
	    numberOfColumns = cols;
	  }
      }

    /* Add that many columns.  */
    while ([platformObject numberOfColumns] < numberOfColumns)
      {
	[platformObject addColumn];
      }

    /* And that many rows.  */
    while ([platformObject numberOfRows] < numberOfRows)
      {
	[platformObject addRow];
      }

    /* Now add the cells.  */
    for (i = 0; i < numberOfRows; i++)
      {
	GSMarkupTagMatrixRow *row = [_content objectAtIndex: i];
	NSArray *cells = [row content];
	int j, count = [cells count];
	
	for (j = 0; j < count; j++)
	  {
	    GSMarkupTagMatrixCell *tagCell = [cells objectAtIndex: j];
	    [platformObject putCell: [tagCell platformObject]
			     atRow: i
			     column: j];
	  }
      }
  }
  
  return platformObject;
}

@end
