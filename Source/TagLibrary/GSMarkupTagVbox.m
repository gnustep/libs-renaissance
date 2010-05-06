/* -*-objc-*-
   GSMarkupTagVbox.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March-November 2002

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
#include "GSMarkupTagVbox.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
#endif

#include "GSAutoLayoutVBox.h"

@implementation GSMarkupTagVbox

+ (NSString *) tagName
{
  return @"vbox";
}

+ (Class) platformObjectClass
{
  return [GSAutoLayoutVBox class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [platformObject init];

  /* type */
  {
    NSString *type = [_attributes objectForKey: @"type"];
    if (type != nil)
      {
	/* Default is 'standard' */
	if ([type isEqualToString: @"proportional"])
	  {
	    [platformObject setBoxType: GSAutoLayoutProportionalBox];
	  }
      }
  }
  
  /* Now extract contents.  */
  {
    int i, count = [_content count];

    for (i = 0; i < count; i++)
      {
	GSMarkupTagView *v = [_content objectAtIndex: i];
	NSView *view = [v platformObject];

	if (view != nil  &&  [view isKindOfClass: [NSView class]])
	  {
	    [platformObject addView: view];

	    /* Now check attributes of the view: halign, valign,
	     * bottomPadding, topPadding, leftPadding, rightPadding,
	     * hPadding, vPadding, padding, proportion, (,
	     * minimumSize?) */

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
				     forView: view];
		  }
	      }
	    }
	  }
      }

    return platformObject;
  }
}

@end
