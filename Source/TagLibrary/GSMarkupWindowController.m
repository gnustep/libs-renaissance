/* -*-objc-*-
   GSMarkupWindowController.m

   Copyright (C) 2003 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: January 2003

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

#include "GSMarkupWindowController.h"
#include "GSMarkupDocument.h"
#include "GSMarkupBundleAdditions.h"

#ifdef GNUSTEP
# include <Foundation/NSArray.h>
# include <Foundation/NSBundle.h>
# include <Foundation/NSString.h>
#else
# include <Foundation/Foundation.h>
# include <GNUstep.h>
#endif

@implementation GSMarkupWindowController

/* Override the -init methods to store in _gsMarkupWindowNibName and
 * _gsMarkupWindowNibPath the eventual name and path of the nib (gsmarkup
 * really) to load later, then call super's.
 */
- (id) initWithWindow: (NSWindow *)window
{
  return [super initWithWindow: window];
}

- (id) initWithWindowNibName: (NSString *)windowNibName
{
  ASSIGN (_gsMarkupWindowNibName, windowNibName);
  return [super initWithWindowNibName: windowNibName];
}

- (id) initWithWindowNibName: (NSString *)windowNibName
		       owner: (id)owner
{
  ASSIGN (_gsMarkupWindowNibName, windowNibName);
  return [super initWithWindowNibName: windowNibName  owner: owner];
}
  
- (id) initWithWindowNibPath: (NSString *)windowNibPath
		       owner: (id)owner
{
  ASSIGN (_gsMarkupWindowNibPath, windowNibPath);
  return [super initWithWindowNibPath: windowNibPath  owner: owner];
}

- (void) destroyTopLevelObjects
{
  int i, count = [_gsMarkupTopLevelObjects count];
  
  for (i = 0; i < count; i++)
    {
      id object = [_gsMarkupTopLevelObjects objectAtIndex: i];
      RELEASE (object);
    }
}

- (void) dealloc
{
  RELEASE (_gsMarkupWindowNibName);
  RELEASE (_gsMarkupWindowNibPath);
  [self destroyTopLevelObjects];
  RELEASE (_gsMarkupTopLevelObjects);
  [super dealloc];
}

- (NSString *) windowNibName
{
  if (_gsMarkupWindowNibName != nil)
    {
      return _gsMarkupWindowNibName;
    }

  if (_gsMarkupWindowNibPath != nil)
    {
      return [[_gsMarkupWindowNibPath lastPathComponent] 
	       stringByDeletingPathExtension];
    }

  return nil;
}

- (NSString *) windowNibPath
{
  if (_gsMarkupWindowNibPath != nil)
    {
      return _gsMarkupWindowNibPath;
    }

  if (_gsMarkupWindowNibName != nil)
    {
      NSString *path = nil;
      NSBundle *bundle = nil;
      NSString *fileName;

      fileName = [_gsMarkupWindowNibName stringByAppendingPathExtension: 
					   @"gsmarkup"];

      bundle = [NSBundle bundleForClass: [[self owner] class]];
      if (bundle != nil)
	{
	  path = [bundle pathForLocalizedResource: fileName];
	}
      
      if (path != nil)
	{
	  return path;
	}
      
      bundle = [NSBundle mainBundle];
      if (bundle != nil)
	{
	  path = [bundle pathForLocalizedResource: fileName];
	}

      return path;
    }
  
  return nil;
}

- (void) setWindow: (NSWindow *)window
{
  [super setWindow: window];
  
  [self destroyTopLevelObjects];
  DESTROY (_gsMarkupTopLevelObjects);
}

/* Our private method to set the top level objects (and the window
 * from them).  */
- (void) setTopLevelObjects: (NSArray *)topLevelObjects
{
  id owner = [self owner];
  GSMarkupDocument *document = [self document];

  /* Usually, we are the owner of the loaded gsmarkup.  In this
   * case, the outlet in the gsmarkup will have used setWindow:
   * to set the window in us.
   *
   * If the owner is the document, setWindow: has been called on the
   * document instead.  This is unfortunate and we need to fix it
   * by manually retrieving the window which has been set, and 
   * setting it to us.
   */
  if (owner == document)
    {
      if ([document isKindOfClass: [GSMarkupDocument class]])
	{
	  NSWindow *window = [document gsMarkupWindow];
	  
	  [self setWindow: window];
	  [document setWindow: nil];
	}
    }

  /* Assign the objects after the window, because setting the window
   * will destroy the previous ones.
   */
  ASSIGN (_gsMarkupTopLevelObjects, topLevelObjects);
}


- (void) loadWindow
{
  if ([self isWindowLoaded]) 
    {
      return;
    }

  /* FIXME - in theory, according to the API, all this should just get
   * the path from windowNibPath, and use it.  But - but if we do
   * that, we loose the information on the bundle in which the
   * gsmarkup file is.  That information can be used by the loading
   * code to locate the appropriate strings file (for translation) in
   * the bundle, so we don't want to loose it.  The Apple API doesn't
   * need this, because they can't translate nib files at run time
   * anyway.
   */

  if (_gsMarkupWindowNibPath != nil)
    {
      NSDictionary *table;
      NSMutableArray *topLevelObjects = [NSMutableArray array];

      table = [NSDictionary dictionaryWithObjectsAndKeys: 
			      [self owner], @"NSOwner",
			    topLevelObjects, @"NSTopLevelObjects",
			    nil];
      
      if ([NSBundle loadGSMarkupFile: _gsMarkupWindowNibPath
		    externalNameTable: table
		    withZone: [[self owner] zone]])
	{
	  [self setTopLevelObjects: topLevelObjects];
	  return;
	}
    }
  
  if (_gsMarkupWindowNibName != nil)
    {
      NSBundle *bundle;

      bundle = [NSBundle bundleForClass: [[self owner] class]];
      if (bundle != nil)
	{
	  NSDictionary *table;
	  NSMutableArray *topLevelObjects = [NSMutableArray array];
	  
	  table = [NSDictionary dictionaryWithObjectsAndKeys: 
				  [self owner], @"NSOwner",
				topLevelObjects, @"NSTopLevelObjects",
				nil];
      
	  if ([bundle loadGSMarkupFile: _gsMarkupWindowNibName
		      externalNameTable: table
		      withZone: [[self owner] zone]])
	    {
	      [self setTopLevelObjects: topLevelObjects];
	      return;
	    }
      
	  bundle = [NSBundle mainBundle];
	  if (bundle != nil)
	    {
	      if ([bundle loadGSMarkupFile: _gsMarkupWindowNibName
			  externalNameTable: table
			  withZone: [[self owner] zone]])
		{
		  [self setTopLevelObjects: topLevelObjects];
		  return;
		}
	    }
	}
    }
}

@end
