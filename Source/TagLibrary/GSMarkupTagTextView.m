/* -*-objc-*-
   GSMarkupTagTextView.m

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

#include <GSMarkupTagTextView.h>
#include <GSMarkupLocalizer.h>

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSClipView.h>
# include <AppKit/NSScrollView.h>
# include <AppKit/NSTextContainer.h>
# include <AppKit/NSTextView.h>
#endif

@implementation GSMarkupTagTextView
+ (NSString *) tagName
{
  return @"textView";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSTextView class];
}

- (void) platformObjectInit
{
  /* Create the textview.  */
  [super platformObjectInit];
  
  /* Set attributes of the textview.  */

  /* eventual text is in the content.  */
  {
    int count = [_content count];

    if (count > 0)
      {
	NSString *s = [_content objectAtIndex: 0];
	
	if (s != nil  &&  [s isKindOfClass: [NSString class]])
	  {
	    [_platformObject setString: [_localizer localizeString: s]];
	  }
      }
  }

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

  /* selectable */
  {
    int selectable = [self boolValueForAttribute: @"selectable"];
    
    if (selectable == 1)
      {
	[_platformObject setSelectable: YES];
      }
    else if (selectable == 0)
      {
	[_platformObject setSelectable: NO];
      }
  }

  /* TODO: font (big/medium/small, or bold etc)
   *       alignment (left/right/center/natural) */

  /* Previoulsy, we were replacing here the _platformObject with an enclosing
     scrollview, so that size/resizing behaviours etc would be set for the
     scrollview.  Unfortunately, a id="text" attached to the textView tag
     would then refer to the scrollview ... making it difficult to have
     an outlet refer to the textview.  Code to set up the textview has been
     moved in the scrollview class, so that now id="xxx" works fine, but you
     manually have to always enclose a textView into a scrollView.
  */
}

- (void) platformObjectAfterInit
{
  [super platformObjectAfterInit];
}

@end
