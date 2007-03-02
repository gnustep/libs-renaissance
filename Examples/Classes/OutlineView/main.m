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

/* It is a basic class browser, showing all classes loaded in an outline view.
 * If it's complex, it's only for this reason, due to runtime differences
 * between the GNU and NeXT runtimes.
 */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>

/* Dummy function pointer needed to link Renaissance.dll on Windows.  */
int (*linkRenaissanceIn)(int, const char **) = GSMarkupApplicationMain;

#ifndef GNU_RUNTIME
# include <objc/objc-class.h>
#endif

@interface OutlineViewExample : NSObject
{
  /* The 'classTree' dictionary holds entries of the form: key(a
   * string, a class name) = value (an array of strings, the list of
   * the subclass names).  We create this data structure at the
   * beginning, as it's simple to do it in the same way on the two
   * runtimes.
   */
  NSMutableDictionary *classTree;
}
- (void)setupClassTree;
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
- (void)setupClassTree
{
  classTree = [NSMutableDictionary new];

#if GNU_RUNTIME
  {
    Class class;
    void *es = NULL;
    
    while ((class = objc_next_class (&es)) != Nil)
      {
	NSMutableArray *array = [NSMutableArray array];
	struct objc_class *subclass = ((struct objc_class *)class)->subclass_list;
	
	while (subclass != Nil)
	  {
	    [array addObject: NSStringFromClass (subclass)];
	    subclass = subclass->sibling_class;
	  }
	[classTree setObject: array  forKey: NSStringFromClass (class)];
      }
  }
#else
  {
    int i, count = objc_getClassList (NULL, 0);
    Class *classes = malloc (sizeof (Class) * count);
    
    objc_getClassList (classes, count);
    
    for (i = 0; i < count; i++)
      {
	NSString *superclass = NSStringFromClass (((classes[i])->super_class));
	
	if (superclass != nil)
	  {
	    NSString *subclass = NSStringFromClass (classes[i]);
	    NSMutableArray *subclasses = [classTree objectForKey: superclass];
	    
	    if (subclasses == nil)
	      {
		subclasses = [NSMutableArray array];
		[classTree setObject: subclasses  forKey: superclass];
	      }
	    
	    [subclasses addObject: subclass];
	  }
      }
    
    free (classes);
  }
#endif
}

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
      NSArray *subclasses = [classTree objectForKey: item];
      
      if (subclasses == nil)
	{
	  return @"0";
	}
      
      return [NSString stringWithFormat: @"%d", [subclasses count]];
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
      NSArray *subclasses = [classTree objectForKey: item];
      
      if ([subclasses count] > 0)
	{
	  return YES;
	}
      else
	{
	  return NO;
	}
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
      NSArray *subclasses = [classTree objectForKey: item];
      
      return [subclasses count];
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
      NSArray *subclasses = [classTree objectForKey: item];

      if (index >= [subclasses count])
	{
	  return @"Unknown class (?)";
	}
      else
	{
	  return [subclasses objectAtIndex: index];
	}
    }
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  [self setupClassTree];
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



