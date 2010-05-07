/* -*-objc-*-
   GSMarkupTagGridEmptyCell.m

   Copyright (C) 2010 Free Software Foundation, Inc.

   Author: Nicola Pero <nicola.pero@meta-innovation.com>
   Date: May 2010

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
#include "GSMarkupTagGridEmptyCell.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
#endif

@implementation GSMarkupTagGridEmptyCell

+ (NSString *) tagName
{
  return @"gridEmptyCell";
}

- (id) allocPlatformObject
{
  /* We don't really have a _platformObject.  We are here just so
   * that the enclosing tags know about empty cells.
   */
  return nil;
}

/* This is not a real class and creates no real object, so the
 * instanceOf attribute makes no sense here.
 */
+ (BOOL) useInstanceOfAttribute
{
  return NO;
}

@end
