/*
 *  main.m of a mini sample GNUstep Renaissance document-based app
 *
 *  Copyright (c) 2003 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: January 2003
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

/* Dummy function pointer needed to link Renaissance.dll on Windows.  */
int (*linkRenaissanceIn)(int, const char **) = GSMarkupApplicationMain;

@interface SimpleEditor : NSObject
@end

@implementation SimpleEditor
@end

int main (int argc, const char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  [NSApplication sharedApplication];
  [NSApp setDelegate: [SimpleEditor new]];

  /* Load the menu before calling NSApplicationMain(), because on
   * Apple Mac OS X NSApplicationMain() creates automatically a menu
   * if none is there, and when we try to replace it later, it doesn't
   * really get replaced ... (?)
   *
   * After extensive experiments, loading the menu at this stage is the best
   * way of having it work on both platforms.
   */
#ifdef GNUSTEP
  [NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: [NSApp delegate]];
#else
  [NSBundle loadGSMarkupNamed: @"MainMenu-OSX"  owner: [NSApp delegate]];
#endif

  RELEASE (pool);

  return NSApplicationMain (argc, argv);
}



