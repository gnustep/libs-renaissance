/* -*-objc-*-
   GSMarkupLocalizer.m

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

#include <GSMarkupLocalizer.h>

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
#else
# include <Foundation/NSBundle.h>
# include <Foundation/NSString.h>
#endif

@implementation GSMarkupLocalizer

- (id) initWithTable: (NSString *)table
	      bundle: (NSBundle *)bundle;
{
  ASSIGN (_bundle, bundle);
  ASSIGN (_table, table);
  return self;
}

- (void) dealloc
{
  RELEASE (_bundle);
  RELEASE (_table);
  [super dealloc];
}

- (NSString *) localizeString: (NSString *)string;
{
  NSString *localized;
  
  /* Here we need to look for the string in a few tables, in order
   * of preference.  Unfortunately, the normal API does not really
   * allow us to do it.  There is no way to tell the libraries to
   * return nil or raise an exception when the string is not found,
   * so that we can be informed about it.
   */
  localized = [_bundle localizedStringForKey: string
		       value: nil
		       table: _table];

  /* To work around this, we compare the result against the original
   * string - which is just a hack, since the string might have been
   * found in the table, and mapped to itself: in that case, we should
   * really search no longer, but we can't tell this case from the case
   * that the string has not been found, so we go on looking in the next
   * table.
   */
  if ([localized isEqualToString: @""]  ||  [localized isEqualToString: string])
    {
      /* Not found in the specified table ... try in
       * Localizable.strings.  */
      localized = [_bundle localizedStringForKey: string
			   value: string
			   table: nil];
    }

  return localized;
}

@end

