/*
 *  FingerWindow.h: One of Finger.app windows
 *
 *  Copyright (c) 2000-2002 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: February 2000, December 2002
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

#ifndef _FINGER_WINDOW_H
#define _FINGER_WINDOW_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

@interface FingerWindow : NSObject
{
  IBOutlet NSWindow *window;
  IBOutlet NSButton *stopButton;
  IBOutlet NSForm *form;
  IBOutlet NSTextView *text;
  
  NSPipe *pipe[2];
  NSTask *task; 
}
-(void)resetResults: (id)sender;
-(void)saveResults: (id)sender;
-(void)startFinger: (id)sender;
-(void)startWhois: (id)sender;
-(void)startPing: (id)sender;
-(void)startTraceroute: (id)sender;
-(void)startTask: (NSString *)fullBinaryPath
    withArgument: (NSString *)argument;
-(void)stopTask: (id)sender;
-(void)taskEnded: (NSNotification *)aNotification;
-(void)readPipeZeroData: (NSNotification *)aNotification;
-(void)readPipeOneData: (NSNotification *)aNotification;
-(void)readData: (NSNotification *)aNotification;
-(void)orderFront: (id)sender;
-(void)windowWillClose: (NSNotification *)aNotification;
@end

#endif /* _FINGER_WINDOW_H */
