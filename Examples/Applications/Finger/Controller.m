/*
 *  Controller.m: Main Object of Finger.app
 *
 *  Copyright (c) 2000 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: February 2000
 *
 *  This sample program is part of GNUstep.
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

#include "Finger.h"
#include "Controller.h"
#include "PreferencesController.h"
#include "FingerWindow.h"
#include <Renaissance/Renaissance.h>

@implementation Controller

+(void)initialize
{
  if (self == [Controller class])
    {
      NSUserDefaults *defaults;
      NSMutableDictionary   *dict; 
      
      defaults = [NSUserDefaults standardUserDefaults];      
      dict = AUTORELEASE ([NSMutableDictionary new]);
      [dict setObject: WHOIS_DEFAULT_COMMAND forKey: @"WhoisCommand"];
      [dict setObject: FINGER_DEFAULT_COMMAND forKey: @"FingerCommand"];
      [dict setObject: PING_DEFAULT_COMMAND forKey: @"PingCommand"];
      [dict setObject: TRACEROUTE_DEFAULT_COMMAND 
	    forKey: @"TracerouteCommand"];
      [dict setObject: DEFAULT_BUTTON_SIZE forKey: @"ButtonSize"];
      [defaults registerDefaults: dict];
    }
}

-(id) init
{
  return self;
}

-(void) dealloc
{
  TEST_RELEASE (pref);
  [super dealloc];
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  [self startNewFingerWindow: self];
}

- (void)startNewFingerWindow: (id) sender
{
  FingerWindow *win;

  win = [FingerWindow new];
  [win orderFront: self];
}

-(void) runPreferencesPanel: (id) sender
{
  if (pref == nil)
    {
      pref = [PreferencesController new];
    }
  
  [pref orderFrontPanel];
}

@end

