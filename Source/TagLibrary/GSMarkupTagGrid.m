/* -*-objc-*-
   GSMarkupTagGrid.m

   Copyright (C) 2008-2010 Free Software Foundation, Inc.

   Author: Nicola Pero <nicola.pero@meta-innovation.com>
   Date: March 2008, May 2010

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

	/* Row attributes.  */
	{
	  NSDictionary *attributes = [row attributes];
	  /* row->proportion */
	  {
	    NSString *proportion = [attributes valueForKey: @"proportion"];
	    
	    if (proportion != nil)
	      {
		[platformObject setProportion: [proportion floatValue]
				forRow: i];
	      }
	  }
	}

	for (j = 0; j < count; j++)
	  {
	    GSMarkupTagView *v = [views objectAtIndex: j];
	    NSView *view = [v platformObject];

	    /* Note that a <emptyGridCell> tag will have a nil
	     * platformObject and so automatically generate no view.
	     */
	    if (view != nil  &&  [view isKindOfClass: [NSView class]])
	      {
		[platformObject addView: view
				inRow: i
				column: j];
		
		/* Now check attributes of the view: halign, valign,
		 * bottomPadding, topPadding, leftPadding,
		 * rightPadding, hPadding, vPadding, padding,
		 * proportion, rowSpan, columnSpan (, minimumSize?) */
		
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
		  
		  /* view->bottomPadding */
		  {
		    NSString *padding = [attributes valueForKey: @"bottomPadding"];
		    
		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"vPadding"];
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"padding"];
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"vborder"];
			if (padding != nil)
			  {
			    /* 'vborder' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'vborder' attribute is obsolete; please replace it with 'vPadding'");
			  }
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"border"];
			if (padding != nil)
			  {
			    /* 'border' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'border' attribute is obsolete; please replace it with 'padding'");
			  }
		      }
		    
		    if (padding != nil)
		      {
			[platformObject setBottomPadding: [padding floatValue]
					forView: view];
		      }
		  }

		  /* view->topPadding */
		  {
		    NSString *padding = [attributes valueForKey: @"topPadding"];
		    
		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"vPadding"];
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"padding"];
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"vborder"];
			if (padding != nil)
			  {
			    /* 'vborder' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'vborder' attribute is obsolete; please replace it with 'vPadding'");
			  }
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"border"];
			if (padding != nil)
			  {
			    /* 'border' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'border' attribute is obsolete; please replace it with 'padding'");
			  }
		      }
		    
		    if (padding != nil)
		      {
			[platformObject setTopPadding: [padding floatValue]
					forView: view];
		      }
		  }

		  /* view->leftPadding */
		  {
		    NSString *padding = [attributes valueForKey: @"leftPadding"];
		    
		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"hPadding"];
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"padding"];
		      }
		    
		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"hborder"];
			if (padding != nil)
			  {
			    /* 'hborder' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'hborder' attribute is obsolete; please replace it with 'hPadding'");
			  }
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"border"];
			if (padding != nil)
			  {
			    /* 'border' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'border' attribute is obsolete; please replace it with 'padding'");
			  }
		      }

		    if (padding != nil)
		      {
			[platformObject setLeftPadding: [padding floatValue]
					forView: view];
		      }
		  }

		  /* view->rightPadding */
		  {
		    NSString *padding = [attributes valueForKey: @"rightPadding"];
		    
		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"hPadding"];
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"padding"];
		      }
		    
		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"hborder"];
			if (padding != nil)
			  {
			    /* 'hborder' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'hborder' attribute is obsolete; please replace it with 'hPadding'");
			  }
		      }

		    if (padding == nil)
		      {
			padding = [attributes valueForKey: @"border"];
			if (padding != nil)
			  {
			    /* 'border' was deprecated on 30 March 2008; remove it on 30 March 2009.  */
			    NSLog (@"The 'border' attribute is obsolete; please replace it with 'padding'");
			  }
		      }

		    if (padding != nil)
		      {
			[platformObject setRightPadding: [padding floatValue]
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

		  /* view->rowSpan */
		  {
		    NSString *rowSpan = [attributes valueForKey: @"rowSpan"];
		    
		    if (rowSpan != nil)
		      {
			NS_DURING
			  {
			    [platformObject setRowSpan: [rowSpan floatValue]
					    forView: view];
			  }
			NS_HANDLER
			  {
			    NSLog (@"Exception while setting row span: %@", localException);
			  }
			NS_ENDHANDLER
		      }
		  }

		  /* view->columnSpan */
		  {
		    NSString *columnSpan = [attributes valueForKey: @"columnSpan"];
		    
		    if (columnSpan != nil)
		      {
			NS_DURING
			  {
			    [platformObject setColumnSpan: [columnSpan floatValue]
					    forView: view];
			  }
			NS_HANDLER
			  {
			    NSLog (@"Exception while setting column span: %@", localException);
			  }
			NS_ENDHANDLER
		      }
		  }
		}
	      }
	  }
      }

    [platformObject updateLayout];

    return platformObject;
  }
}

@end
