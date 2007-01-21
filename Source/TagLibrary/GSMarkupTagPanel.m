/* -*-objc-*-
   GSMarkupTagPanel.m

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
#include "GSMarkupTagPanel.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSView.h>
# include <AppKit/NSPanel.h>
#endif

@implementation GSMarkupTagPanel
+ (NSString *) tagName
{
  return @"panel";
}

+ (Class) defaultPlatformObjectClass
{
  return [NSPanel class];
}

- (void) platformObjectInit
{
  [super platformObjectInit];

  /* floating */
  {
    int flag;
    flag = [self boolValueForAttribute: @"floating"];
    if (flag == 1)
      {
	[_platformObject setFloatingPanel: YES];
      }
  }

  /* becomesKeyOnlyIfNeeded */
  {
    int flag;
    flag = [self boolValueForAttribute: @"becomesKeyOnlyIfNeeded"];
    if (flag == 1)
      {
	[_platformObject setBecomesKeyOnlyIfNeeded: YES];
      }
  }
  
  /* worksWhenModal */
  {
    int flag;
    flag = [self boolValueForAttribute: @"worksWhenModal"];
    if (flag == 1)
      {
	[_platformObject setWorksWhenModal: YES];
      }
  }

}



@end
