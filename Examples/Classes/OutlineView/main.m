/*
 *  OutlineView.m: A mini NSOutlineView Renaissance demo/test
 *
 *  Copyright (c) 2003 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: April 2003
 *
 *  This sample program is part of GNUstep Renaissance
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/* TODO: Port the code to OS X/NeXT runtime.  
 * It is a basic class browser, showing all classes loaded, and the
 * instance_size of each.  */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>

@interface OutlineViewExample : NSObject
{
}
- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
- (id)         outlineView: (NSOutlineView *)outlineView 
 objectValueForTableColumn: (NSTableColumn *)tableColumn 
		    byItem: (id)item;
- (BOOL)outlineView: (NSOutlineView *)outlineView
   isItemExpandable: (id)item;
- (int)        outlineView: (NSOutlineView *)outlineView 
    numberOfChildrenOfItem: (id)item;
- (id)outlineView: (NSOutlineView *)outlineView
	    child: (int)index
	   ofItem: (id)item;
@end

@implementation OutlineViewExample
- (id)         outlineView: (NSOutlineView *)outlineView 
 objectValueForTableColumn: (NSTableColumn *)tableColumn 
		    byItem: (id)item
{
  if ([[tableColumn identifier] isEqualToString: @"name"])
    {
      return item;
    }
  else
    {
#if GNU_RUNTIME
      struct objc_class *c = NSClassFromString (item);
      return [[NSNumber numberWithLong: c->instance_size] description];
#else

#warning "Not implemented yet!"
      return 0;

#endif  
    }
}


- (BOOL)outlineView: (NSOutlineView *)outlineView
   isItemExpandable: (id)item
{
  if (item == nil)
    {
      return YES;
    }
  else
    {
#if GNU_RUNTIME
      Class c = NSClassFromString (item);
      struct objc_class *subclass = ((struct objc_class *)c)->subclass_list;
      if (subclass != NULL)
	{
	  return YES;
	}
      else
	{
	  return NO;
	}
#else

#warning "Not implemented yet!"
      return NO;
      
#endif
    }
}

- (int)        outlineView: (NSOutlineView *)outlineView 
    numberOfChildrenOfItem: (id)item
{
  if (item == nil)
    {
      return 1;
    }
  else
    {
#if GNU_RUNTIME
      Class c = NSClassFromString (item);
      struct objc_class *subclass = ((struct objc_class *)c)->subclass_list;
      int count = 0;

      while (subclass != NULL)
	{
	  subclass = subclass->sibling_class;
	  count++;
	}

      return count;
#else

#warning "Not implemented yet!"
      return 0;

#endif
    }
}



- (id)outlineView: (NSOutlineView *)outlineView
	    child: (int)index
	   ofItem: (id)item
{
  if (item == nil)
    {
      return @"NSObject";
    }
  else
    {
#if GNU_RUNTIME
      Class c = NSClassFromString (item);
      struct objc_class *subclass = ((struct objc_class *)c)->subclass_list;
      int count = 0;
      
      while (subclass != NULL)
	{
	  if (count == index)
	    {
	      return NSStringFromClass (subclass);
	    }
	  
	  subclass = subclass->sibling_class;
	  count++;
	}

      return @"Unknown Class (?)";
#else

#warning "Not implemented yet!"
      return 0;

#endif
    }
  
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  [NSBundle loadGSMarkupNamed: @"OutlineView"  owner: self];
}

@end

int main(int argc, const char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  [NSApplication sharedApplication];
  [NSApp setDelegate: [OutlineViewExample new]];

#ifdef GNUSTEP
  [NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: [NSApp delegate]];
#else
  [NSBundle loadGSMarkupNamed: @"MainMenu-OSX"  owner: [NSApp delegate]];
#endif

  RELEASE (pool);

  return NSApplicationMain (argc, argv);
}



