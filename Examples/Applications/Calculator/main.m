/* main.m: Main Body of Calculator.app, Renaissance version

   Copyright (C) 1999-2002 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: 1999-2002
   
   This file is part of GNUstep Renaissance examples
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#include "Calculator.h"
#include <Renaissance/Renaissance.h>

int main (int argc, const char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  Calculator *calculator;

  [NSApplication sharedApplication];
  [NSApp setApplicationIconImage: [NSImage imageNamed: @"Calculator.tiff"]];

  calculator = [Calculator new];
  [NSApp setDelegate: calculator];

  /* Load the menu before calling NSApplicationMain(), because on
   * Apple OSX NSApplicationMain() creates automatically a menu if
   * none is there, and when we try to replace it later, it doesn't
   * really get replaced ... (?)
   *
   * After extensive experiments, loading the menu at this stage is the best
   * way of having it work on both platforms.
   */
#ifdef GNUSTEP
  [NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: calculator];
#else
  [NSBundle loadGSMarkupNamed: @"MainMenu-OSX"  owner: calculator];
#endif

  RELEASE (pool);
    
  return NSApplicationMain (argc, argv);
}
