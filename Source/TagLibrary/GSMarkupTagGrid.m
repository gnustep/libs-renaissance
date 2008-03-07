/* -*-objc-*-
   GSMarkupTagGrid.m

   Copyright (C) 2008 Free Software Foundation, Inc.

   Author: Nicola Pero <nicola.pero@meta-innovation.com>
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
#include "GSMarkupTagGrid.h"
#include "GSMarkupTagGridRow.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
#endif

#include "GSAutoLayoutGrid.h"

@implementation GSMarkupTagGrid

+ (NSString *) tagName
{
  return @"grid";
}

+ (Class) platformObjectClass
{
  return [GSAutoLayoutGrid class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [platformObject init];

  /* rowType */
  {
    NSString *type = [_attributes objectForKey: @"rowType"];
    if (type != nil)
      {
	/* Default is 'standard' */
	if ([type isEqualToString: @"proportional"])
	  {
	    [platformObject setRowGridType: GSAutoLayoutProportionalBox];
	  }
      }
  }

  /* columnType */
  {
    NSString *type = [_attributes objectForKey: @"columnType"];
    if (type != nil)
      {
	/* Default is 'standard' */
	if ([type isEqualToString: @"proportional"])
	  {
	    [platformObject setColumnGridType: GSAutoLayoutProportionalBox];
	  }
      }
  }
  
  /* Now the contents.  An array of gridRow objects, each of them
   * containing some view objects.
   */
  {
    int i, numberOfRows, numberOfColumns;
    numberOfRows = [_content count];

    /* Now determine the number of columns.  */
    numberOfColumns = 0;
    for (i = 0; i < numberOfRows; i++)
      {
	GSMarkupTagGridRow *row = [_content objectAtIndex: i];
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
 
    /* Now add the views.  */
    for (i = 0; i < numberOfRows; i++)
      {
	GSMarkupTagGridRow *row = [_content objectAtIndex: i];
	NSArray *views = [row content];
	int j, count = [views count];
	
	for (j = 0; j < count; j++)
	  {
	    GSMarkupTagView *v = [views objectAtIndex: j];
	    NSView *view = [v platformObject];
	    
	    if (view != nil  &&  [view isKindOfClass: [NSView class]])
	      {
		/* Please note that we change the row, this is because
		 * the grid numbers the rows from the bottom, while
		 * we want to add them from the top.  */
		[platformObject addView: view
				inRow: (numberOfRows - 1 - i)
				column: j];
		
		/* Now check attributes of the view: halign, valign,
		 * hborder, vborder, proportion, (, minimumSize?) */
		
		/* view->halign */
		{
		  int halign = [v gsAutoLayoutHAlignment];
		  
		  if (halign != 255)
		    {
		      [platformObject setHorizontalAlignment: halign
				      forView: view];
		    }
		}
		
		/* view->valign */
		{
		  int valign = [v gsAutoLayoutVAlignment];
		  
		  if (valign != 255)
		    {
		      [platformObject setVerticalAlignment: valign
				      forView: view];
		    }
		}
		{
		  NSDictionary *attributes = [v attributes];
		  
		  /* view->hborder */
		  {
		    NSString *hborder = [attributes valueForKey: @"hborder"];
		    
		    /* Try view->border if view->hborder not set.  */
		    if (hborder == nil)
		      {
			hborder = [attributes valueForKey: @"border"];
		      }
		    
		    if (hborder != nil)
		      {
			[platformObject setHorizontalBorder: [hborder intValue]
					forView: view];
		      }
		  }
		  
		  /* view->vborder */
		  {
		    NSString *vborder = [attributes valueForKey: @"vborder"];
		    
		    /* Try view->border if view->vborder not set.  */
		    if (vborder == nil)
		      {
			vborder = [attributes valueForKey: @"border"];
		      }
		    
		    if (vborder != nil)
		      {
			[platformObject setVerticalBorder: [vborder intValue]
					forView: view];
		      }
		  }
		  
		  /* view->proportion */
		  {
		    NSString *proportion = [attributes valueForKey: @"proportion"];
		    
		    if (proportion != nil)
		      {
			[platformObject setProportion: [proportion floatValue]
					forColumn: j];
		      }
		  }
		}
	      }
	  }
	/* TODO: <gridRow proportion="2.0"> */
      }

    [platformObject updateLayout];

    return platformObject;
  }
}

@end
