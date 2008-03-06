/* The GNUstep Markup Browser
   Copyright (C) 2002 Free Software Foundation, Inc.

   Written by: Nicola Pero <nicola@brainstorm.co.uk>
   Date: March 2002

   This file is part of GNUstep Renaissance

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   You should have received a copy of the GNU General Public
   License along with this program; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
   */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#ifdef GNUSTEP
/* When compiling on-site, on GNUstep the headers are not installed
 * yet.  */
# include "Renaissance.h"
#else
/* Here compiling on-site is simply not supported :-).  */
# include <Renaissance/Renaissance.h>
#endif

/* Important - on Windows we need to reference something from the
 * Renaissance.dll else it will not be linked in.
 *
 * Here is our random useless dummy reference.
 */
int (*linkRenaissanceIn)(int, const char **) = GSMarkupApplicationMain;

@interface Owner : NSObject
{
  NSString *fileName;
}

- (id) initWithFile: (NSString *)f;

- (void) takeValue: (id)anObject  forKey: (NSString*)aKey;

/* A dummy action method that you can use in your gsmarkup files
 * to test sending an action to the #NSOwner.  */
- (void) dummyAction: (id)aSender;

- (void) bundleDidLoadGSMarkup: (NSNotification *)aNotification;

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;

@end


@implementation Owner 

- (id) initWithFile: (NSString *)f
{
  ASSIGN (fileName, f);
  return self;
}

- (void) dealloc
{
  RELEASE (fileName);
  [super dealloc];
}

- (void) dummyAction: (id)aSender
{
  NSLog (@"Dummy action invoked by %@", aSender);
}

- (void) takeValue: (id)anObject  forKey: (NSString*)aKey
{
  NSLog (@"Set value \"%@\" for key \"%@\" of NSOwner", anObject, aKey);
}

- (void) bundleDidLoadGSMarkup: (NSNotification *)aNotification
{
  /* You can turn on DisplayAutoLayout by setting it in the user
   * defaults ('defaults write NSGlobalDomain DisplayAutoLayout
   * YES'), or by passing it on the command line ('openapp
   * GSMarkupBrowser.app file.gsmarkup -DisplayAutoLayout YES').
   */
  if ([[NSUserDefaults standardUserDefaults] boolForKey: 
					       @"DisplayAutoLayout"])
    {
      NSArray *topLevelObjects;
      int i, count;
      
      topLevelObjects = [[aNotification userInfo] objectForKey: 
						    @"NSTopLevelObjects"];
      
      /* Now enumerate the top-level objects.  If there is any
       * NSWindow or NSView, mark it as displaying autolayout
       * containers.
       */
      count = [topLevelObjects count];
      
      for (i = 0; i < count; i++)
	{
	  id object = [topLevelObjects objectAtIndex: i];
	  if ([object isKindOfClass: [NSWindow class]]
	      || [object isKindOfClass: [NSView class]])
	    {
	      [(NSWindow *)object setDisplayAutoLayoutContainers: YES];
	    }
	}
    }
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  BOOL b;
  CREATE_AUTORELEASE_POOL (pool);

  NSLog (@"Loading %@", fileName);
 
  b = [NSBundle loadGSMarkupFile: fileName
		externalNameTable: [NSDictionary dictionaryWithObject: self  
						 forKey: @"NSOwner"]
		withZone: NULL];
  

  RELEASE (pool);

  if (b)
    {
      NSLog (@"%@ loaded!", fileName);
    }
  else
    {
      NSLog (@"Could not load %@!", fileName);
      exit (1);
    }
}
@end

int main (void)
{
  CREATE_AUTORELEASE_POOL(pool);
  NSArray *args;
  Owner *owner;
  NSString *path;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  [defaults registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:
					      @"NO", @"DisplayAutoLayout",
					    nil]];

  args = [[NSProcessInfo processInfo] arguments];
  
  if ([args count] < 2)
    {
#ifdef GNUSTEP
      NSLog (@"Usage: GSMarkupBrowser file.gsmarkup [options]\n");
#else
      NSLog (@"Usage: open GSMarkupBrowser.app file.gsmarkup [options]\n");
#endif
      NSLog (@"Loads the file so you can see what it is like :-)\n");
      NSLog (@"Use the -DisplayAutoLayout YES option to display autolayout\n");
      NSLog (@"container boundaries for debugging the layout of your gsmarkup files\n");

      exit (0);
    }

  path = [args objectAtIndex: 1];
  
  if (![path isAbsolutePath])
    {
      path = [[[NSFileManager defaultManager] currentDirectoryPath]
	       stringByAppendingPathComponent: path];
    }

  [NSApplication sharedApplication];   

  owner = [[Owner alloc] initWithFile: path];

  [NSApp setDelegate: owner];

  [NSApp run];

  RELEASE (pool);
  return 0;
}

