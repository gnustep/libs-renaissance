/* GSMarkupBundleAdditions

   GSMarkup Bundle Additions to load GSMarkup files

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: 2002

   Resource searching code partially derived from gnustep-gui 
   NSBundleAdditions.h by Richard Frith-Macdonald and Simon Frankau

   This file is part of GNUstep Renaissance.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library;
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/ 

#include <GSMarkupBundleAdditions.h>
#include <GSMarkupDecoder.h>
#include <GSMarkupTagObject.h>
#include <GSMarkupConnector.h>
#include <GSMarkupLocalizer.h>

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSException.h>
# include <Foundation/NSDictionary.h>
# include <Foundation/NSFileManager.h>
# include <Foundation/NSUserDefaults.h>
# include <Foundation/NSData.h>
#endif

/*
 * In gnustep-gui applications, we want NSApp to be always available
 * from gsmarkup as '#NSApp'.  More generally, it is possible to
 * register static objects so that they are available to all
 * gsmarkup loaded with a certain id.
 */

/* The private dictionary holding the static objects.  */
static NSMutableDictionary *staticNameTable = nil;

@implementation NSBundle (GSMarkupBundleStaticObjects)

/* The method to call to register a static object.  The object 
 * will be retained, and whenever a gsmarkup file is loaded, it will
 * be available with id 'itsId'.  This method should/will probably
 * be public.
 */
+ (void) registerStaticObject: (id)object
		     withName: (NSString *)itsId
{
  if (staticNameTable == nil)
    {
      staticNameTable = [NSMutableDictionary new];
    }

  [staticNameTable setObject: object  forKey: itsId];
}

@end

/*
 * initNSApp() is a private function; it registers NSApp as a static
 * object (for gui applications only) the first time that it is
 * called; it does nothing when called again.  We could register
 * other objects in the main table, maybe the MainBundle, or
 * NSProcessInfo.  Or maybe it's better not to add more names
 * as they could conflict with ones defined in .gsmarkup files.
 */
static void initStandardStaticNameTable (void)
{
  static BOOL didInit = NO;
  
  if (didInit)
    {
      return;
    }

  didInit = YES;
  
  {
    Class app = NSClassFromString (@"NSApplication");
    
    if (app != Nil)
      {
	SEL selector = NSSelectorFromString (@"sharedApplication");
	if (selector != NULL)
	  {
	    id sharedApp = [app performSelector: selector];
	    if (sharedApp != nil)
	      {
		[NSBundle registerStaticObject: sharedApp  withName: @"NSApp"];
	      }
	  }
      }
  }
}

@implementation NSBundle (GSMarkupBundleAdditions)

+ (BOOL) loadGSMarkupFile: (NSString*)fileName
	externalNameTable: (NSDictionary*)context
		 withZone: (NSZone*)zone
{
  return [self loadGSMarkupFile: fileName
	       externalNameTable: context
	       withZone: zone
	       localizableStringsTable: nil
	       inBundle: nil];
}


+ (BOOL)    loadGSMarkupFile: (NSString *)fileName
	   externalNameTable: (NSDictionary *)context
		    withZone: (NSZone *)zone
     localizableStringsTable: (NSString *)table
		    inBundle: (NSBundle *)bundle
{
  NSData	*data;

  if (fileName == nil)
    {
      return NO;
    }
  
  /* Add .gsmarkup if missing.  */
  if (![[fileName pathExtension] isEqual: @"gsmarkup"])
    {
      fileName = [fileName stringByAppendingPathExtension: @"gsmarkup"];
    }

  data = [NSData dataWithContentsOfFile: fileName];

  return [self loadGSMarkupData: data
		       withName: fileName
	      externalNameTable: context
		       withZone: zone
        localizableStringsTable: table
		       inBundle: bundle];
}


+ (BOOL)    loadGSMarkupData: (NSData *)data
		    withName: (NSString*)fileName
	   externalNameTable: (NSDictionary *)context
		    withZone: (NSZone *)zone
     localizableStringsTable: (NSString *)table
		    inBundle: (NSBundle *)bundle
{
  return [self  loadGSMarkupData: data
		        withName: fileName
               externalNameTable: context
		        withZone: zone
         localizableStringsTable: table
		        inBundle: bundle
		      tagMapping: nil];
}

+ (BOOL)    loadGSMarkupData: (NSData *)data
		    withName: (NSString *)fileName
	   externalNameTable: (NSDictionary *)context
		    withZone: (NSZone *)zone
     localizableStringsTable: (NSString *)table
		    inBundle: (NSBundle *)bundle
                  tagMapping: (NSDictionary *)mapping;
{
  BOOL success = NO;

  if (data == nil)
    {
      return NO;
    }

  if (fileName == nil)
    {
      return NO;
    }

  /* If the table is not specified, translate stuff from a table with
   * the same name as the .gsmarkup file we are loading.  */
  if (table == nil)
    {
      table = [fileName stringByDeletingPathExtension];
      table = [table lastPathComponent];
    }

  /* If bundle is specified, use it; otherwise, use mainBundle.  */
  if (bundle == nil)
    {
      bundle = [NSBundle mainBundle];
    }

  initStandardStaticNameTable ();

  /* Read the data.  */
  NS_DURING
    {
      NSArray *objects;
      NSMutableDictionary *nameTable;
      NSMutableDictionary *outputTable;
      NSArray *connectors;
      NSMutableArray *platformObjects;
      int i, count;
      NSEnumerator *e;
      NSString *key;
      NSMutableArray *topLevelObjects = nil;

      /* Parse the XML file.  */
      {
	GSMarkupDecoder *decoder;

	decoder = [[GSMarkupDecoder alloc] initWithData: data];
	AUTORELEASE(decoder);
	
	if (mapping != nil)
	  {
	    e = [mapping keyEnumerator];
	    while ((key = [e nextObject]) != nil)
	      {
	        NSString *value = [mapping objectForKey: key];
	        [decoder setObjectClass: value  forTagName: key];
	      }
	  }

        [decoder parse];
	
	objects = [decoder objects];
	nameTable = [[decoder nameTable] mutableCopy];
	AUTORELEASE (nameTable);
	connectors = [decoder connectors];
      }

      /* Generate the platform objects from the decoded objects.  */
      platformObjects = [NSMutableArray arrayWithCapacity: [objects count]];
      
      {
	GSMarkupLocalizer *localizer;
	
	localizer = [[GSMarkupLocalizer alloc] initWithTable: table
					   bundle: bundle];
	
	
	count = [objects count];
	for (i = 0; i < count; i++)
	  {
	    GSMarkupTagObject *o;
	    id platformObject;
	    
	    o = [objects objectAtIndex: i];
	    [o setLocalizer: localizer];

	    /* platformObject is autoreleased.  */
	    platformObject = [o platformObject];

	    if (platformObject != nil)
	      {
		/* we need to RETAIN it (to balance this autorelease),
		 * as per spec.  */
		RETAIN (platformObject);

		[platformObjects addObject: platformObject];
	      }
	  }
	
	RELEASE (localizer);
      }
      

      /* Now update the nameTable replacing each decoded object with
       * its platformObject in the nameTable.  */
      e = [nameTable keyEnumerator];
      while ((key = [e nextObject]) != nil)
	{
	  id object = [nameTable objectForKey: key];
	  id platformObject = [object platformObject];

	  if (platformObject != nil)
	    {	  
	      [nameTable setObject: platformObject  forKey: key];
	    }
	  else
	    {
	      [nameTable removeObjectForKey: key];
	    }
	}
      
      /* Now extend the nameTable by adding the externalNameTable
       * (which contains references to object outside the GSMarkup
       * file).  */
      e = [context keyEnumerator];
      while ((key = [e nextObject]) != nil)
	{
	  id object = [context objectForKey: key];
	  
	  /* NSTopLevelObjects is special ... if it exists, it is a
	   * key to a mutable array where we store the top-level
	   * objects so that the caller can access them.  Inspired by
	   * an undocumented feature of nib loading on other
	   * platforms.  */
	  if ([key isEqualToString: @"NSTopLevelObjects"]
	      && [object isKindOfClass: [NSMutableArray class]])
	    {
	      topLevelObjects = object;
	    }
	  else
	    {
	      [nameTable setObject: object  forKey: key];
	    }
	}

      /* Now extend the nameTable adding the static objects (for example,
       * NSApp if it's a gui application).
       */
      if (staticNameTable != nil)
	{
	  [nameTable addEntriesFromDictionary: staticNameTable];
	}

      /* Now establish the connectors.  Our connectors can manage
       * the nameTable automatically.  */
      count = [connectors count];
      for (i = 0; i < count; i++)
	{
	  GSMarkupConnector *connector = [connectors objectAtIndex: i];
	  [connector establishConnectionUsingNameTable: nameTable];
	}

      /* Now awake the objects.  */
      count = [platformObjects count];
      for (i = 0; i < count; i++)
	{
	  id object = [platformObjects objectAtIndex: i];
	  if ([object respondsToSelector: @selector(awakeFromGSMarkup)])
	    {
	      [object awakeFromGSMarkup];
	    }
	  /* Save the object in the NSTopLevelObjects mutable array if there
	   * is one.  */
	  if (topLevelObjects != nil)
	    {
	      [topLevelObjects addObject: object];
	    }
	}

      /*
       * Finally, pass back name table contents in the context if possible.
       */
      outputTable = [context objectForKey: @"GSMarkupNameTable"];
      if (outputTable != nil
	&& [outputTable isKindOfClass: [NSMutableDictionary class]] == YES)
	{
	  NSString	*k;

	  [outputTable removeAllObjects];
	  e = [nameTable keyEnumerator];
	  while ((k = [e nextObject]) != nil)
	    {
	      if ([context objectForKey: k] == nil)
		{
		  [outputTable setObject: [nameTable objectForKey: k]
				  forKey: k];
		}
	    }
	}

      success = YES;
    }
  NS_HANDLER
    {
      NSLog (@"Exception while reading %@: %@", fileName, localException);
    }
  NS_ENDHANDLER

  if (!success)
    {
      NSLog (@"Failed to load %@", fileName);
    }

  return success;
}

+ (BOOL) loadGSMarkupNamed: (NSString *)fileName
		     owner: (id)owner
{
  NSDictionary	*table;
  NSBundle	*bundle;

  if (owner == nil || fileName == nil)
    {
      return NO;
    }
  table = [NSDictionary dictionaryWithObject: owner  forKey: @"NSOwner"];
  bundle = [self bundleForClass: [owner class]];

  if (bundle == nil)
    {
      bundle = [self mainBundle];
    }

  return [bundle loadGSMarkupFile: fileName
		 externalNameTable: table
		 withZone: NSDefaultMallocZone()];
}

/* We really want a localized resource!  This is not really relevant,
 * since .gsmarkup are not normally localized, but anyway might be useful
 * elsewhere and we want to add the facility from the
 * beginning.  fileName must include extension.  */
- (NSString *) pathForLocalizedResource: (NSString *)fileName
{
  NSFileManager		*mgr = [NSFileManager defaultManager];
  NSMutableArray	*array = [NSMutableArray arrayWithCapacity: 8];
  NSArray		*languages;
  NSString		*rootPath = [self bundlePath];
  NSString		*primary;
  NSString		*language;
  NSEnumerator		*enumerator;

#ifdef GNUSTEP
  languages  = [NSUserDefaults userLanguages];
#else /* FIXME!! */
  languages = [NSMutableArray arrayWithObject: @"English"];
#endif
  
  /*
   * Build an array of resource paths that differs from the normal order -
   * we want a localized file in preference to a generic one.
   */
#ifdef GNUSTEP
  primary = [rootPath stringByAppendingPathComponent: @"Resources"];
#else
  primary = [rootPath stringByAppendingPathComponent: @"Contents/Resources"];
#endif
  enumerator = [languages objectEnumerator];
  while ((language = [enumerator nextObject]))
    {
      NSString	*langDir;

      langDir = [NSString stringWithFormat: @"%@.lproj", language];
      [array addObject: [primary stringByAppendingPathComponent: langDir]];
    }
  [array addObject: primary];
  primary = rootPath;
  enumerator = [languages objectEnumerator];
  while ((language = [enumerator nextObject]))
    {
      NSString	*langDir;

      langDir = [NSString stringWithFormat: @"%@.lproj", language];
      [array addObject: [primary stringByAppendingPathComponent: langDir]];
    }
  [array addObject: primary];

  enumerator = [array objectEnumerator];
  while ((rootPath = [enumerator nextObject]) != nil)
    {
      NSString	*path;

      path = [rootPath stringByAppendingPathComponent: fileName];
      if ([mgr isReadableFileAtPath: path])
	{
	  return path;
	}
    }

  return nil;
}

- (BOOL)    loadGSMarkupFile: (NSString *)fileName
       externalNameTable: (NSDictionary *)context
		withZone: (NSZone *)zone
 localizableStringsTable: (NSString *)table;
{
  NSString *path;

  if (![[fileName pathExtension] isEqual: @"gsmarkup"])
    {
      fileName = [fileName stringByAppendingPathExtension: @"gsmarkup"];
    }

  path = [self pathForLocalizedResource: fileName];
  
  if (path != nil)
    {
      return [NSBundle loadGSMarkupFile: path
		       externalNameTable: context
		       withZone: zone
		       localizableStringsTable: table
		       inBundle: self];
    }
  else 
    {
      /* TODO/FIXME: Turn this into a debug log.  */
      NSLog (@"NSBundle(GSMarkupAdditions): File %@ not found - skipping loading", fileName);
      return NO;
    }
}

- (BOOL) loadGSMarkupFile: (NSString*)fileName
    externalNameTable: (NSDictionary*)context
	     withZone: (NSZone*)zone
{
  return [self loadGSMarkupFile: fileName
	       externalNameTable: context
	       withZone: zone
	       localizableStringsTable: nil];
}

+ (NSArray *) localizableStringsInGSMarkupFile: (NSString *)fileName
{
  NSMutableArray *strings = [NSMutableArray array];

  if (fileName == nil)
    {
      return strings;
    }
  
  /* Add .gsmarkup if missing.  */
  if (![[fileName pathExtension] isEqual: @"gsmarkup"])
    {
      fileName = [fileName stringByAppendingPathExtension: @"gsmarkup"];
    }

  /* Read the file.  */
  {
    NSArray *objects;
    
    /* Parse the XML file and extract the objects.  */
    {
      GSMarkupDecoder *decoder;
      
      decoder = [GSMarkupDecoder decoderWithContentsOfFile: fileName];
      [decoder parse];
      
      objects = [decoder objects];
    }
    
    /* Prepare the array of localizable strings.  */
    {
      int i, count;
      count = [objects count];
      for (i = 0; i < count; i++)
	{
	  GSMarkupTagObject *o = (GSMarkupTagObject *)[objects objectAtIndex: i];
	  NSArray *a = [o localizableStrings];
	  
	  if (a != nil)
	    {  
	      [strings addObjectsFromArray: a];
	    }
	}
    }

    /* FIXME/TODO: Need to purge duplicates in the array.  */
  }
  return strings;
}

@end
