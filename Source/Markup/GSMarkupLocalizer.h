/* -*-objc-*-
   GSMarkupLocalizer.h

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

#ifndef _GNUstep_H_GSMarkupLocalizer
#define _GNUstep_H_GSMarkupLocalizer

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSObject.h>
#endif

@class NSBundle;
@class NSString;

/* An object of this class is able to localize strings.  */
@interface GSMarkupLocalizer : NSObject
{
  /* Normally, the localizer just looks up strings in a table of a
   * bundle.  */
  NSBundle *_bundle;
  NSString *_table;
}
- (id) initWithTable: (NSString *)table
	      bundle: (NSBundle *)bundle;

- (NSString *) localizeString: (NSString *)string;

@end

#endif /* _GNUstep_H_GSMarkupLocalizer */
