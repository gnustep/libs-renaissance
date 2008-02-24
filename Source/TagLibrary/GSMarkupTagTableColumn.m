/* -*-objc-*-
   GSMarkupTagTableColumn.m

   Copyright (C) 2003 Free Software Foundation, Inc.

   Authors: David Wetzel <dave@turbocat.de>,
            Nicola Pero <n.pero@mi.flashnet.it>
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
#include "GSMarkupTagTableColumn.h"


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSDictionary.h>
# include <Foundation/NSString.h>
# include <AppKit/NSCell.h>
# include <AppKit/NSTableColumn.h>
#endif

@implementation GSMarkupTagTableColumn

+ (NSString *) tagName
{
  return @"tableColumn";
}

+ (Class) platformObjectClass
{
  return [NSTableColumn class];
}

- (id) initPlatformObject: (id)platformObject
{
  /* identifier */
  {
    NSString *identifier = [_attributes objectForKey: @"identifier"];

    if (identifier != nil)
      {
	platformObject = [platformObject initWithIdentifier: identifier];
      }  
    else
      {
	/* FIXME: truly, this is invalid ... identifier *must* be
	 * there.  */
	platformObject = [platformObject init];
      }
  }
  
  /* editable */
  {
    int editable = [self boolValueForAttribute: @"editable"];
    
    if (editable == 1)
      {
	[platformObject setEditable: YES];
      }
    else if (editable == 0)
      {
	[platformObject setEditable: NO];
      }
  }

  /* title */
  {
    NSString *title = [self localizedStringValueForAttribute: @"title"];
    if (title != nil)
      {
	[[platformObject headerCell] setStringValue: title];
      }
  }

  /* minWidth */
  {
    id aValue = [_attributes objectForKey: @"minWidth"];
    
    if (aValue != nil)
      {
	[platformObject setMinWidth: [aValue intValue]];
      }
  }

  /* maxWidth */
  {
    id aValue = [_attributes objectForKey: @"maxWidth"];
    
    if (aValue != nil)
      {
	[platformObject setMaxWidth: [aValue intValue]];
      }
  }

  /* width */
  {
    id aValue = [_attributes objectForKey: @"width"];
    
    if (aValue != nil)
      {
	[platformObject setWidth: [aValue intValue]];
      }
  }
  
  /* resizable */
  {
    int resizable = [self boolValueForAttribute: @"resizable"];
    if (resizable == 1)
      {
	[platformObject setResizable: YES];	
      }
    else if (resizable == 0)
      {
	[platformObject setResizable: NO];
      }
  }
  
  return platformObject;
}

+ (NSArray *) localizableAttributes
{
  return [NSArray arrayWithObject: @"title"];
}

@end
