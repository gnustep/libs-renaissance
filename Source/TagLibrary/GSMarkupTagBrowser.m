/* -*-objc-*-
   GSMarkupTagBrowser.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Pete French <pete@twisted.org.uk>
   Date: March 2003

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
#include "GSMarkupTagBrowser.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <Foundation/NSDictionary.h>
# include <AppKit/NSBrowser.h>
# include <AppKit/NSView.h>
#endif


/*
 * Private function to check that 'aClass' is the same, or a subclass,
 * of 'aPotentialSuperClass'.  Return YES if so, and NO if not.
 *
 * This is Nicola Pero's implementation from GSMarkupTagObject.m
 */
static BOOL isClassSubclassOfClass (Class aClass,
				    Class aPotentialSuperClass)
{
  if (aClass == aPotentialSuperClass)
    {
      return YES;
    }
  else
    {
      while (aClass != Nil)
        {
          aClass = [aClass superclass];
	  
          if (aClass == aPotentialSuperClass)
            {
              return YES;
            }
        } 
      return NO;
    }
}

@implementation GSMarkupTagBrowser

+ (NSString *) tagName
{
  return @"browser";
}

+ (Class) platformObjectClass
{
  return [NSBrowser class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [super initPlatformObject: platformObject];

  /* is the browser titled ? - default is 'no' */
  if ([self boolValueForAttribute: @"titled"] == 1)
    {
      [platformObject setTitled: YES];
    }
  else
    {
      [platformObject setTitled: NO];
    }
  
  /* branch selection - default is 'yes' */
  if ([self boolValueForAttribute: @"allowsBranchSelection"] == 0)
    {
      [platformObject setAllowsBranchSelection: NO];
    }
  else
    {
      [platformObject setAllowsBranchSelection: YES];
    }

  /* empty selection - default is 'no' */
  if ([self boolValueForAttribute: @"allowsEmptySelection"] == 1)
    {
      [platformObject setAllowsEmptySelection: YES];
    }
  else
    {
      [platformObject setAllowsEmptySelection: NO];
    }

  /* multiple selection - default is 'no' */
  if ([self boolValueForAttribute: @"allowsMultipleSelection"] == 1)
    {
      [platformObject setAllowsMultipleSelection: YES];
    }
  else
    {
      [platformObject setAllowsMultipleSelection: NO];
    }

  /* previous column title - default is 'yes' */
  if ([self boolValueForAttribute: @"takesTitleFromPreviousColumn"] == 0)
    {
      [platformObject setTakesTitleFromPreviousColumn: NO];
    }
  else
    {
      [platformObject setTakesTitleFromPreviousColumn: YES];
    }

  /* separates columns - default is 'yes' */
  if ([self boolValueForAttribute: @"separatesColumns"] == 0)
    {
      [platformObject setSeparatesColumns: NO];
    }
  else
    {
      [platformObject setSeparatesColumns: YES];
    }

  /* accepts arrow keys - default is 'yes' */
  if ([self boolValueForAttribute: @"acceptsArrowKeys"] == 0)
    {
      [platformObject setAcceptsArrowKeys: NO];
    }
  else
    {
      [platformObject setAcceptsArrowKeys: YES];
    }

  /* sends action on arrow keys - default is 'yes' */
  if ([self boolValueForAttribute: @"sendsActionOnArrowKeys"] == 0)
    {
      [platformObject setSendsActionOnArrowKeys: NO];
    }
  else
    {
      [platformObject setSendsActionOnArrowKeys: YES];
    }

  /* horizontal scrollbars - default is 'no' */
  if ([self boolValueForAttribute: @"hasHorizontalScroller"] == 1)
    {
      [platformObject setHasHorizontalScroller: YES];
    }
  else
    {
      [platformObject setHasHorizontalScroller: NO];
    }

  /* the double click action */
  {
    NSString *doubleAction = [_attributes objectForKey: @"doubleAction"];

    if (doubleAction != nil)
      {
        [platformObject setDoubleAction: NSSelectorFromString (doubleAction)];
      }
  }

  /* minimum column width */
  {
    NSString *width = [_attributes objectForKey: @"minColumnWidth"];
    if (width != nil)
      {
        float w = [width floatValue];
        if (w > 0)
          {
            [platformObject setMinColumnWidth: w];
          }
      }
  }

  /* maximum number of visible columns */
  {
    NSString *count = [_attributes objectForKey: @"maxVisibleColumns"];
    if (count != nil)
      {
        int c = [count intValue];
        if (c > 0)
          {
            [platformObject setMaxVisibleColumns: c];
          }
      }
  }

  /* non standard matrix class - must be a subclass of NSMatrix */
  {
    NSString *className = [_attributes objectForKey: @"matrixClass"];
 
    if (className != nil)
      {
        Class customSubclass = NSClassFromString (className); 
 
        if (customSubclass != nil)
          {
            if (isClassSubclassOfClass (customSubclass, [NSMatrix class]))
              {
                [platformObject setMatrixClass: customSubclass];
              }
          }
      }
  }

  /* non standard cell class - must be a subclass of NSCell */
  {
    NSString *className = [_attributes objectForKey: @"cellClass"];
 
    if (className != nil)
      {
        Class customSubclass = NSClassFromString (className); 
 
        if (customSubclass != nil)
          {
            if (isClassSubclassOfClass (customSubclass, [NSCell class]))
              {
                [platformObject setCellClass: customSubclass];
              }
          }
      }
  }

  return platformObject;
}

@end
