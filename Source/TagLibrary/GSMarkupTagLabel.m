/* -*-objc-*-
   GSMarkupTagTextLabel.m

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
#include <TagCommonInclude.h>
#include "GSMarkupTagLabel.h"
#include "GSMarkupLocalizer.h"


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSTextField.h>
#endif

@implementation GSMarkupTagLabel
+ (NSString *) tagName
{
  return @"label";
}

+ (Class) platformObjectClass
{
  return [NSTextField class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [super initPlatformObject: platformObject];

  /* this is not editable, without border and without background.  */
  [platformObject setEditable: NO];
  [platformObject setBezeled: NO];
  [platformObject setBordered: NO];

  /* selectable; by default we are selectable so the user can copy&paste
   * strings from a GUI (eg, error messages).  */
  {
    int selectable = [self boolValueForAttribute: @"selectable"];
    
    if (selectable == 0)
      {
	[platformObject setSelectable: NO];
      }
    else
      {
	[platformObject setSelectable: YES];
      }
  }

  /* textColor */
  {
    NSColor *c = [self colorValueForAttribute: @"textColor"];

    /* Backward-compatible hack to support obsolete attribute 'color'.
     * It will be removed one year from now, on 4 March 2009.
     */
    if (c == nil)
      {
	c = [self colorValueForAttribute: @"color"];
	if (c != nil)
	  {
	    NSLog (@"The 'color' attribute of the <label> tag is obsolete; please replace it with 'textColor'");
	  }
      }

    if (c != nil)
      {
	[platformObject setTextColor: c];
      }
  }

  /* backgroundColor */
  {
    NSColor *c = [self colorValueForAttribute: @"backgroundColor"];
    if (c != nil)
      {
	[platformObject setBackgroundColor: c];
	[platformObject setDrawsBackground: YES];
      }
    else
      {
	[platformObject setDrawsBackground: NO];
      }
  }
  
  /* eventual text is in the content.  */
  {
    int count = [_content count];

    if (count > 0)
      {
	NSString *s = [_content objectAtIndex: 0];
	
	if (s != nil  &&  [s isKindOfClass: [NSString class]])
	  {
	    [platformObject setStringValue: [_localizer localizeString: s]];
	  }
      }
  }
  
  return platformObject;
}

@end
