/*
 *  FingerWindow.m: One of Finger.app windows
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

#include "FingerWindow.h"
#include "Controller.h"
#include "NSTextViewAdd.h"
#include <Renaissance/Renaissance.h>

@implementation FingerWindow

-(void) dealloc
{
  if (task && [task isRunning])
    {
      [task terminate];
    }
  TEST_RELEASE (task);
  TEST_RELEASE (pipe[0]);
  TEST_RELEASE (pipe[1]);
  [[NSNotificationCenter defaultCenter] removeObserver: self];
  RELEASE (form);
  RELEASE (stopButton);
  RELEASE (text);
  RELEASE (window);
  [super dealloc];
}
- (id) init
{
  /* As an initial hack, I have two separate .gsmarkup files.  More
   * advanced ways will be hopefully possible in the future.  */

  if ([[[NSUserDefaults standardUserDefaults] stringForKey: @"ButtonSize"]
	isEqualToString: @"Small"])
    {
      [NSBundle loadGSMarkupNamed: @"FingerWindowSmall"  owner: self];
    }
  else
    {
      [NSBundle loadGSMarkupNamed: @"FingerWindowBig"  owner: self];
    }

  return self;
}

- (void)taskEnded: (NSNotification *)aNotification
{
  [stopButton setEnabled: NO];
}

-(void)startFinger: (id)sender
{
  NSString *username;
  NSString *hostname;
  NSString *command;
  NSString *argument;

  command = [[NSUserDefaults standardUserDefaults] stringForKey: 
						     @"FingerCommand"];

  username = [[form cellAtIndex: 0] stringValue];
  hostname = [[form cellAtIndex: 1] stringValue];

  if ([hostname length] > 0)
    hostname = [@"@" stringByAppendingString: hostname];
  
  if (username)
    argument = [username stringByAppendingString: hostname];
  else
    argument = hostname;

  [self startTask: command
	withArgument: argument];
}

-(void)startWhois: (id)sender
{
  NSString *command;
  NSString *argument;

  command = [[NSUserDefaults standardUserDefaults] stringForKey: 
						     @"WhoisCommand"];

  argument = [[form cellAtIndex: 1] stringValue];

  [self startTask: command
	withArgument: argument];
}

-(void)startPing: (id)sender
{
  NSString *command;
  NSString *argument;

  command = [[NSUserDefaults standardUserDefaults] stringForKey: 
						     @"PingCommand"];

  argument = [[form cellAtIndex: 1] stringValue];

  [self startTask: command
	withArgument: argument];
}

-(void)startTraceroute: (id)sender
{
  NSString *command;
  NSString *argument;

  command = [[NSUserDefaults standardUserDefaults] stringForKey: 
						     @"TracerouteCommand"];

  argument = [[form cellAtIndex: 1] stringValue];

  [self startTask: command
	withArgument: argument];
}

-(void)startTask: (NSString *)fullBinaryPath
    withArgument: (NSString *)argument
{
  NSArray      *arguments;
  NSFileHandle *fileHandle;
  NSString     *stringToShow;
  NSFileManager *fm;
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

  [self stopTask: self];

  /* Check if binary is executable */
  fm = [NSFileManager defaultManager];
  /* Uhm -- if it is a directory, we are "executing" it.  This will
     not do any harm ?. */
  if ([fm isExecutableFileAtPath: fullBinaryPath] == NO)
    {
      NSString *alert;
      int       result;

      alert = [fullBinaryPath stringByAppendingString: 
				@" is not executable!"];
      result = NSRunAlertPanel (NULL, alert, @"Cancel", 
				@"Change command", NULL);
      if (result == NSAlertAlternateReturn)
	{
	  [(Controller *)[NSApp delegate] runPreferencesPanel: self];
	}
      return;
    }

  /* Show command we are issuing in the text view */
  stringToShow = [fullBinaryPath stringByAppendingString: @" "];
  stringToShow = [stringToShow stringByAppendingString: argument];
  stringToShow = [stringToShow stringByAppendingString: @"\n"];
  [text appendBoldString: stringToShow];

  /* Show command in the window title */
  stringToShow = [fullBinaryPath lastPathComponent];
  stringToShow = [stringToShow stringByAppendingString: @" "];
  stringToShow = [stringToShow stringByAppendingString: argument];
  [window setTitle: stringToShow];
  
  /* Run the task */
  ASSIGN (task, AUTORELEASE ([NSTask new]));
  [task setLaunchPath: fullBinaryPath];
  
  arguments = [NSArray arrayWithObjects: argument, nil]; 
  [task setArguments: arguments];

  ASSIGN (pipe[0], [NSPipe pipe]);
  fileHandle = [pipe[0] fileHandleForReading];
  [task setStandardOutput: pipe[0]];
  [fileHandle readInBackgroundAndNotify];
  [nc addObserver: self 
      selector: @selector(readPipeZeroData:) 
      name: NSFileHandleReadCompletionNotification
      object: (id) fileHandle];
  
  ASSIGN (pipe[1], [NSPipe pipe]);
  fileHandle = [pipe[1] fileHandleForReading];
  [task setStandardError: pipe[1]];
  [fileHandle readInBackgroundAndNotify];
  [nc addObserver: self 
      selector: @selector(readPipeOneData:) 
      name: NSFileHandleReadCompletionNotification
      object: (id) fileHandle];

  [nc addObserver: self 
      selector: @selector(taskEnded:) 
      name: NSTaskDidTerminateNotification 
      object: (id) task];

  [task launch];
  
  [stopButton setEnabled: YES];
}

-(void)stopTask: (id)sender
{
  NSFileHandle *fileHandle;

  if ([task isRunning])
    {    
      /* Be fine so that ping gives us all the statistical infos */
      [task interrupt];
      if ([task isRunning])
	{
	  [task terminate];
	  DESTROY (task);
	}
      /* Now wait 0.1 seconds for the ping statistical info */ 
      /* [FIXME Some better solution -- or at least make the 0.1
           seconds configurable] */
      [[NSRunLoop currentRunLoop] 
	runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
      /* Then discard the remaining data */
      fileHandle = [pipe[0] fileHandleForReading];
      [fileHandle closeFile]; 
      fileHandle = [pipe[1] fileHandleForReading];
      [fileHandle closeFile];
      /* Remove us from notifications */
      [[NSNotificationCenter defaultCenter] 
	removeObserver: self
	name: NSFileHandleReadCompletionNotification
	object: nil];
      [[NSNotificationCenter defaultCenter] 
	removeObserver: self 
	name: NSTaskDidTerminateNotification
	object: nil];
    }
}

-(void)readPipeZeroData: (NSNotification *)aNotification
{
  if ([task isRunning])
    {
      NSFileHandle *fileHandle = [pipe[0] fileHandleForReading];
      [fileHandle readInBackgroundAndNotify];
    }
  [self readData: aNotification];
}

-(void)readPipeOneData: (NSNotification *)aNotification
{
  if ([task isRunning])
    {
      NSFileHandle *fileHandle = [pipe[1] fileHandleForReading];
      [fileHandle readInBackgroundAndNotify];
    }
  [self readData: aNotification];
}

-(void)readData: (NSNotification *)aNotification
{
  NSData   *readData;
  NSString *readString;
  NSFileHandle *fileHandle;

  readData = [[aNotification userInfo] 
	       objectForKey: NSFileHandleNotificationDataItem];
  readString = [[NSString alloc] initWithData: readData
				 encoding:  NSNonLossyASCIIStringEncoding];
  AUTORELEASE (readString);
  [text appendString: readString];
}

- (void)resetResults: (id)sender
{
  [self stopTask: self];
  [text resetString];
}

- (void)saveResults: (id)sender
{
  NSSavePanel *savePanel;
  int result;

  [self stopTask: self];

  savePanel = [NSSavePanel savePanel];
  result = [savePanel runModal];
  if (result == NSOKButton)
    {
      /* TODO: Ask before overwriting file ?*/
      [[text string] writeToFile: [savePanel filename] 
		     atomically: YES];
    }
}

- (void)orderFront: (id)sender
{
  [window orderFront: sender];
}

/* When the window is closed, release self (that should cause both us
 * and the window to be deallocated.  */
- (void)windowWillClose: (NSNotification *)aNotification
{
  RELEASE (self);
}

@end
