/* -*-objc-*-
   GSMarkupBundleAdditions.h

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: 2002
   
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
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/ 

#ifndef _GNUstep_H_GSMarkupBundleAdditions
#define _GNUstep_H_GSMarkupBundleAdditions

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSObject.h>
# include <Foundation/NSBundle.h>
#endif

@class	NSString;
@class	NSDictionary;
@class	NSMutableDictionary;

@interface NSObject (GSMarkupAwaking)

- (void) awakeFromGSMarkup;

@end

@interface NSBundle (GSMarkupBundleAdditions)

+ (BOOL)    loadGSMarkupData: (NSData *)data
		    withName: (NSString *)fileName
	   externalNameTable: (NSDictionary *)context
		    withZone: (NSZone *)zone
     localizableStringsTable: (NSString *)table
		    inBundle: (NSBundle *)bundle
                  tagMapping: (NSDictionary *)mapping;

+ (BOOL)    loadGSMarkupData: (NSData *)data
		    withName: (NSString *)fileName
	   externalNameTable: (NSDictionary *)context
		    withZone: (NSZone *)zone
     localizableStringsTable: (NSString *)table
		    inBundle: (NSBundle *)bundle;

+ (BOOL)    loadGSMarkupFile: (NSString *)fileName
	   externalNameTable: (NSDictionary *)context
		    withZone: (NSZone *)zone
     localizableStringsTable: (NSString *)table
		    inBundle: (NSBundle *)localizableStringsTableBundle;

+ (BOOL) loadGSMarkupFile: (NSString *)fileName
	externalNameTable: (NSDictionary *)context
		 withZone: (NSZone *)zone;

+ (BOOL) loadGSMarkupNamed: (NSString *)fileName
		     owner: (id)owner;

- (BOOL)    loadGSMarkupFile: (NSString *)fileName
	   externalNameTable: (NSDictionary *)context
		    withZone: (NSZone *)zone
     localizableStringsTable: (NSString *)table;

- (BOOL) loadGSMarkupFile: (NSString *)fileName
	externalNameTable: (NSDictionary *)context
		 withZone: (NSZone *)zone;

/* Return the array of localizable strings in the GSMarkup file.  Raise an
 * exception if the file can't be parsed.  */
+ (NSArray *) localizableStringsInGSMarkupFile: (NSString *)fileName;

/* fileName must include extension.  */
- (NSString *) pathForLocalizedResource: (NSString *)fileName;
@end

#endif /* _GNUstep_H_GSMarkupBundleAdditions */

