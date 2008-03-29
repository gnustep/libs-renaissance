/*
 *  GSAutoLayoutVBoxDemo.app: A mini GSAutoLayoutVBox Renaissance demo/test
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
#include <Renaissance/GSAutoLayoutHBox.h>
#include <Renaissance/GSAutoLayoutVBox.h>

/* Dummy function pointer needed to link Renaissance.dll on Windows.  */
int (*linkRenaissanceIn)(int, const char **) = GSMarkupApplicationMain;

@interface GSAutoLayoutVBoxExample : NSObject
{
  GSAutoLayoutVBox *vbox;
  GSAutoLayoutHBox *hbox;
}
- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;

- (void) setHbox: (id)object;
- (void) setVbox: (id)object;

- (void) addViewToVBox: (id)sender;
- (void) removeViewFromVBox: (id)sender;
- (void) addViewToHBox: (id)sender;
- (void) removeViewFromHBox: (id)sender;
@end

@implementation GSAutoLayoutVBoxExample

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  [NSBundle loadGSMarkupNamed: @"GSAutoLayoutVBox"  owner: self];
  [NSBundle loadGSMarkupNamed: @"GSAutoLayoutHBox"  owner: self];
}

- (void) setHbox: (id)object
{
  ASSIGN (hbox, object);
}
- (void) setVbox: (id)object
{
  ASSIGN (vbox, object);
}
- (void) dealloc
{
  RELEASE (hbox);
  RELEASE (vbox);
  [super dealloc];
}

- (void) addViewToVBox: (id)sender
{
  NSView *view;

  view = [[NSColorWell alloc] initWithFrame: NSMakeRect (0, 0, 50, 50)];
  [vbox addView: view];
  RELEASE (view);
  [vbox setNeedsDisplay: YES];
}
- (void) removeViewFromVBox: (id)sender
{
  NSArray *views = [vbox subviews];

  if ([views count] > 0)
    {
      [vbox removeView: [views objectAtIndex: 0]];
    }
  [vbox setNeedsDisplay: YES];
}
- (void) addViewToHBox: (id)sender
{
  NSView *view;

  view = [[NSColorWell alloc] initWithFrame: NSMakeRect (0, 0, 50, 50)];
  [hbox addView: view];
  RELEASE (view);
  [hbox setNeedsDisplay: YES];
}
- (void) removeViewFromHBox: (id)sender
{
  NSArray *views = [hbox subviews];

  if ([views count] > 0)
    {
      [hbox removeView: [views objectAtIndex: 0]];
    }
  [hbox setNeedsDisplay: YES];
}

@end

int main(int argc, const char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  [NSApplication sharedApplication];
  [NSApp setDelegate: [GSAutoLayoutVBoxExample new]];

#ifdef GNUSTEP
  [NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: [NSApp delegate]];
#else
  [NSBundle loadGSMarkupNamed: @"MainMenu-OSX"  owner: [NSApp delegate]];
#endif

  RELEASE (pool);

  return NSApplicationMain (argc, argv);
}



