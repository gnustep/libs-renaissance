/* -*-objc-*-
   GSMarkupTagOutlineView.m

   Copyright (C) 2003 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: April 2003

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
#include "GSMarkupTagOutlineView.h"
#include "GSMarkupTagTableColumn.h"


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
# include <AppKit/NSOutlineView.h>
#endif

@implementation GSMarkupTagOutlineView

+ (NSString *) tagName
{
  return @"outlineView";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSOutlineView class];
}

- (void) platformObjectInit
{
  [super platformObjectInit];

  /* outlineColumn */
  {
    /* This attribute is a number (starting from 0); the table column
     * at that index (according to the order in the XML file!) is set
     * as the OutlineTableColumn of the OutlineView.  */
    NSString *outlineColumn = [_attributes objectForKey: @"outlineColumn"];
    
    if (outlineColumn != nil)
      {
	/* If outlineColumn is not a number, column at index 0 will be
	 * chosen.  */
	int index = [outlineColumn intValue];
	int numberOfColumns = [_content count];
	
	if (index >= 0  &&  index < numberOfColumns)
	  {
	    GSMarkupTagTableColumn *tag = [_content objectAtIndex: index];
	    
	    if (tag != nil && [tag isKindOfClass: 
				     [GSMarkupTagTableColumn class]])
	      {
		NSTableColumn *column = [tag platformObject];
		
		[(NSOutlineView *)_platformObject setOutlineTableColumn: 
				    column];
	      }
	  }
      }
  }

#ifdef GNUSTEP
  /* FIXME */
  [(NSOutlineView *)_platformObject setIndentationPerLevel: 10];
#endif
}

@end
