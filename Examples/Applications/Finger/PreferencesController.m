/*
 *  PreferencesController.m: Finger.app Preferences Panel
 *
 *  Copyright (c) 2000-2002 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: February 2000, December 2002
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

#include "PreferencesController.h"
#include <Renaissance/Renaissance.h>

/* We cache here the shared file manager for speed */
static NSFileManager *fm;

@implementation PreferencesController

- (id) init
{
  [NSBundle loadGSMarkupNamed: @"Preferences"  owner: self];

  if (fm == nil)
    {
      fm = [NSFileManager defaultManager];
    }

  return [super init];
}

-(void) reset
{   
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  [fingerCommand setStringValue: [ud stringForKey: @"FingerCommand"]];
  [whoisCommand setStringValue: [ud stringForKey: @"WhoisCommand"]];
  [pingCommand setStringValue: [ud stringForKey: @"PingCommand"]];
  [tracerouteCommand setStringValue: [ud stringForKey: 
					   @"TracerouteCommand"]];
  [buttonsSize selectItemWithTitle: [ud stringForKey: @"ButtonSize"]];
}

-(void) resetToDefault:(id)sender
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud removeObjectForKey: @"FingerCommand"];
  [ud removeObjectForKey: @"WhoisCommand"];
  [ud removeObjectForKey: @"PingCommand"];
  [ud removeObjectForKey: @"TracerouteCommand"];
  [ud removeObjectForKey: @"ButtonSize"];
  [self reset];
}

-(void) set:(id)sender
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  [ud setObject: [fingerCommand stringValue] forKey: @"FingerCommand"];
  [ud setObject: [whoisCommand stringValue] forKey: @"WhoisCommand"];
  [ud setObject: [pingCommand stringValue] forKey: @"PingCommand"];
  [ud setObject: [tracerouteCommand stringValue] forKey: 
	@"TracerouteCommand"];
  [ud setObject: [buttonsSize titleOfSelectedItem] forKey: @"ButtonSize"];
  [ud synchronize];
}

-(void) changePreference: (id)sender
{
  NSOpenPanel *openPanel;
  NSString    *file;
  int result;

  openPanel = [NSOpenPanel openPanel];
  
  [openPanel setTitle: @"Choose Command"];
  [openPanel setAllowsMultipleSelection: NO];

  switch ([sender tag]) 
    {
    case PING_TAG: 
      [openPanel setPrompt: @"Ping Command:"];
      file = [pingCommand stringValue];
      break;
    case WHOIS_TAG:
      [openPanel setPrompt: @"Whois Command:"];
      file = [whoisCommand stringValue];
      break;
    case FINGER_TAG:
      [openPanel setPrompt: @"Finger Command:"];
      file = [fingerCommand stringValue];
      break;
    case TRACEROUTE_TAG:
      [openPanel setPrompt: @"Traceroute Command:"];
      file = [tracerouteCommand stringValue];
      break;
    default:
      return;
    }

  [openPanel setDelegate: self];

  result = [openPanel 
	     runModalForDirectory: [file stringByDeletingLastPathComponent]
	     file: [file lastPathComponent]
	     types: nil];

  if (result == NSOKButton)
    {
      switch ([sender tag])
	{
	case PING_TAG: 
	  [pingCommand setStringValue: [openPanel filename]];
	  break;
        case WHOIS_TAG:
          [whoisCommand setStringValue: [openPanel filename]];
          break;
	case FINGER_TAG:
	  [fingerCommand setStringValue: [openPanel filename]];
	  break;
	case TRACEROUTE_TAG:
	  [tracerouteCommand setStringValue: [openPanel filename]];
	  break;
	}
      [self set: self];
    }
}

- (void)controlTextDidEndEditing: (NSNotification *)aNotification
{
  NSTextField *sender = (NSTextField *)[aNotification object];
  NSString  *filename = [sender stringValue];
  BOOL      bip, bop;

  bip = [fm fileExistsAtPath: filename isDirectory: &bop]; 
  
  if (bip)
    bip = [fm isExecutableFileAtPath: filename]; 
  
  if ((bip == YES) && (bop == NO))
    {
      [setButton performClick: self];
      [self set: self];
    }
  else
    {
      NSString *alert;
      NSString *pref;
      NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

      alert = [filename stringByAppendingString: @" is not executable!"];
      NSRunAlertPanel (NULL, alert, @"OK", NULL, NULL);
      switch ([sender tag])
	{
	case PING_TAG: 
	  pref = @"PingCommand";
	  break;
        case WHOIS_TAG:
          pref = @"WhoisCommand";
          break;
	case FINGER_TAG:
	  pref = @"FingerCommand";
	  break;
	case TRACEROUTE_TAG:
	  pref = @"TracerouteCommand";
	  break;
	default:
	  return;
	}
      [sender setStringValue: [ud stringForKey: pref]];
    }
}

-(void) orderFrontPanel
{
  [self reset];
  [pan makeKeyAndOrderFront: self];
}

-(void) dealloc
{
  RELEASE (fingerCommand);
  RELEASE (pingCommand);  
  RELEASE (tracerouteCommand);
  RELEASE (whoisCommand);
  RELEASE (buttonsSize);
  RELEASE (setButton);
  RELEASE (pan);

  /* At this point, the loaded panel is not yet destroyed; We've just
   * released all our retain counters on the panel and the objects.  A
   * final RELEASE destroys the panel!  */
  RELEASE (pan);
  
  [super dealloc];
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename
{
  /* NB: We show directories here */
  return [fm isExecutableFileAtPath: filename]; 
}

- (BOOL)panel:(id)sender isValidFilename:(NSString *)filename
{
  BOOL bip, bop;

  /* Do not accept not existing files or directories */
  bip = [fm fileExistsAtPath: filename isDirectory: &bop]; 
  return ((bip) && (!bop));
}

@end

