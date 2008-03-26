/* -*-objc-*-
   GSMarkupTagStepper.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Xavier Glattard <xavier.glattard@online.fr>
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
#include "GSMarkupTagStepper.h"
#include "GSMarkupLocalizer.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSStepper.h>
#endif

@implementation GSMarkupTagStepper
+ (NSString *) tagName
{
  return @"stepper";
}

+ (Class) platformObjectClass
{
  return [NSStepper class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [super initPlatformObject: platformObject];

  /* autorepeat */
  {
    int autorepeat = [self boolValueForAttribute: @"autorepeat"];
    
    if (autorepeat == 0)
      {
        [platformObject setAutorepeat: NO];
      }
    else
      {
        [platformObject setAutorepeat: YES];
      }
  }
  /* increment */
  {
    NSString *increment = [_attributes objectForKey: @"increment"];
    if( increment != nil )
      {
        [platformObject setIncrement: [increment doubleValue]];
      }
  }
  /* maxValue */
  {
    NSString *maxValue = [_attributes objectForKey: @"maxValue"];
    if( maxValue != nil )
      {
        [platformObject setMaxValue: [maxValue doubleValue]];
      }
  }
  /* minValue */
  {
    NSString *minValue = [_attributes objectForKey: @"minValue"];
    if( minValue != nil )
      {
        [platformObject setMinValue: [minValue doubleValue]];
      }
  }
  /* valueWraps */
  {
    int valueWraps = [self boolValueForAttribute: @"valueWraps"];
    
    if (valueWraps == 0)
      {
        [platformObject setValueWraps: NO];
      }
    else
      {
        [platformObject setValueWraps: YES];
      }
  }

  return platformObject;
}

@end
