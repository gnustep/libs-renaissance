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
@class	NSNotification;

@interface NSObject (GSMarkupAwaking)
/*
 * This method is called, after the objects have been created and the
 * connections fully established.  It is called for all objects
 * created from a gsmarkup which implement it, and for the file owner
 * if it implements it.
 */
- (void) awakeFromGSMarkup;

@end

/* The following notification is posted after the gsmarkup file has been
 * loaded.  The notification object is the file owner (or nil if no file
 * owner was set); the userInfo is a dictionary, where the object for 
 * the key 'NSTopLevelObjects' is the array of top-level objects which
 * have been loaded from the gsmarkup file.
 *
 * If the file owner responds to the -bundleDidLoadGSMarkup: method
 * below, it is automatically invoked passing the notification as
 * argument, so that you don't need to manually register the
 * file owner with the notification center.
 *
 * This stuff is useful if you need to keep track of the top-level
 * objects, so that you can easily destroy them when you no longer
 * need them.
 */
extern NSString *GSMarkupBundleDidLoadGSMarkupNotification;

@interface NSObject (GSMarkupTopLevelObjects)

/* If the file owner implements this method, NSBundle calls it
 * automatically, passing the GSMarkupBundleDidLoadGSMarkup
 * notification as argument.
 */
- (void) bundleDidLoadGSMarkup: (NSNotification *)aNotification;

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

