/*
 *  AutoLayoutUpdateDemo.app: A mini AutoLayoutUpdate Renaissance demo/test
 *
 *  Copyright (c) 2008 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: March 2008
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
#include <Renaissance/GSAutoLayoutVBox.h>
#include <Renaissance/NSViewSize.h>

/* Dummy function pointer needed to link Renaissance.dll on Windows.  */
int (*linkRenaissanceIn)(int, const char **) = GSMarkupApplicationMain;

@interface AutoLayoutUpdateExample : NSObject
{
  NSButton *_button;
  GSAutoLayoutVBox *_vbox;
}
- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;

- (void)setButton: (NSButton *)button;

- (void)setVbox: (GSAutoLayoutVBox *)vbox;

- (void)awakeFromGSMarkup;
@end

@implementation AutoLayoutUpdateExample

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  [NSBundle loadGSMarkupNamed: @"MainWindow"  owner: self];
}

- (void)setButton: (NSButton *)button
{
  ASSIGN (_button, button);
}

- (void)setVbox: (GSAutoLayoutVBox *)vbox
{
  ASSIGN (_vbox, vbox);
}

- (void)dealloc
{
  RELEASE (_button);
  RELEASE (_vbox);
  [super dealloc];
}

- (void) awakeFromGSMarkup
{
  NSSize newButtonSize;

  /* Change the button title programmatically.  */
  [_button setTitle: @"This is a long string, much longer than the original title"];

  /* Redo the button autolayout.  */
  [_button sizeToFitContent];

  /* Tell the <vbox> that the button minimum size changed.  */
  newButtonSize = [_button frame].size;
  [_vbox setMinimumSize: newButtonSize  forView: _button];

  /* Redo the <vbox> autolayout.  */
  [_vbox sizeToFitContent];

  /* Redo the <window> size.  */
  [[_vbox window] setContentSize: [_vbox frame].size];
}
@end

int main(int argc, const char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  [NSApplication sharedApplication];
  [NSApp setDelegate: [AutoLayoutUpdateExample new]];

#ifdef GNUSTEP
  [NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: [NSApp delegate]];
#else
  [NSBundle loadGSMarkupNamed: @"MainMenu-OSX"  owner: [NSApp delegate]];
#endif

  RELEASE (pool);

  return NSApplicationMain (argc, argv);
}



