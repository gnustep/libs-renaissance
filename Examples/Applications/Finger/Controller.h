/*
 *  Controller.h: Main Object of Finger.app
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

#ifndef _CONTROLLER_H
#define _CONTROLLER_H

#include <Foundation/Foundation.h>

@class PreferencesController;

@interface Controller : NSObject
{
  /* Preferences Panel */
  PreferencesController *pref;
}
+(void)initialize;
-(void)applicationDidFinishLaunching: (NSNotification *)aNotification;
-(void)runPreferencesPanel: (id)sender;
-(void)startNewFingerWindow: (id)sender;
@end

#endif /* _CONTROLLER_H_ */
