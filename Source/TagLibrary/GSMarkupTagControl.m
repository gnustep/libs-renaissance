/* -*-objc-*-
   GSMarkupTagControl.m

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

#include <GSMarkupTagControl.h>


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
# include <AppKit/NSControl.h>
#endif

@implementation GSMarkupTagControl

+ (NSString *) tagName
{
  return @"control";
}

- (void) platformObjectAlloc
{
  _platformObject = [NSControl alloc];
}

- (void) platformObjectInit
{
  _platformObject = [_platformObject init];
  
  /* action */
  {
    NSString *action = [_attributes objectForKey: @"action"];
  
    if (action != nil)
      {
	[_platformObject setAction: NSSelectorFromString (action)];
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

  /* tag */
  {
    NSString *tag = [_attributes objectForKey: @"tag"];
    if (tag != nil)
      {
	[(NSControl *)_platformObject setTag: [tag intValue]];
      }
  }
}

@end
