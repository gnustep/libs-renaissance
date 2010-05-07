/* main.m: Main Body of Finger.app, Renaissance version

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

#include "Controller.h"
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>

/* Dummy function pointer needed to link Renaissance.dll on Windows.  */
int (*linkRenaissanceIn)(int, const char **) = GSMarkupApplicationMain;

int main(int argc, const char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  Controller *controller;

  [NSApplication sharedApplication];
  [NSApp setApplicationIconImage: [NSImage imageNamed: @"finger.tiff"]];

  controller = [Controller new];
  [NSApp setDelegate: controller];

#ifdef GNUSTEP
  [NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: controller];
#else
  [NSBundle loadGSMarkupNamed: @"MainMenu-OSX"  owner: controller];
#endif

  [NSApp run];

  RELEASE (pool);
    
  return 0;
}
