/*
 *  TableView.m: A mini NSTableView Renaissance demo/test
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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>

static NSString *typeColumn[19] =
{ 
  @"id",
  @"Class",
  @"SEL",
  @"char",
  @"unsigned char",
  @"short",
  @"unsigned short",
  @"int",
  @"unsigned int",
  @"long",
  @"unsigned long",
  @"long long",
  @"unsigned long long",
  @"float",
  @"double",
  @"void *",
  @"undefined",
  @"pointer to",
  @"char *"
};

static NSString *typeEncodingColumn[19] = 
  {
    @"@",
    @"#",
    @":",
    @"c",
    @"C",
    @"s",
    @"S",
    @"i",
    @"I",
    @"l",
    @"L",
    @"q",
    @"Q",
    @"f",
    @"d",
    @"v",
    @"?",
    @"^",
    @"*"
  };

@interface TableViewExample : NSObject
{
}
- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
- (int) numberOfRowsInTableView: (NSTableView *)aTableView;
- (id)           tableView: (NSTableView *)aTableView 
 objectValueForTableColumn: (NSTableColumn *)aTableColumn 
		       row:(int)rowIndex;
@end

@implementation TableViewExample
- (int) numberOfRowsInTableView: (NSTableView *)aTableView
{
  return 19;
}

- (id)           tableView: (NSTableView *)aTableView 
 objectValueForTableColumn: (NSTableColumn *)aTableColumn 
		       row:(int)rowIndex
{
  if (rowIndex >= 0  &&  rowIndex < 19)
    {
      NSString *identifier = [aTableColumn identifier];
      
      if ([identifier isEqual: @"type"])
	{
	  return typeColumn[rowIndex];
	}
      else if ([identifier isEqual: @"typeEncoding"])
	{
	  return typeEncodingColumn[rowIndex];
	}
    }
  
  return nil;
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  [NSBundle loadGSMarkupNamed: @"TableView"  owner: self];
}

@end

int main(int argc, const char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  [NSApplication sharedApplication];
  [NSApp setDelegate: [TableViewExample new]];

#ifdef GNUSTEP
  [NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: [NSApp delegate]];
#else
  [NSBundle loadGSMarkupNamed: @"MainMenu-OSX"  owner: [NSApp delegate]];
#endif

  RELEASE (pool);

  return NSApplicationMain (argc, argv);
}



