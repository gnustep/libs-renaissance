/* Calculator.h: Calculator.app, GNUstep Framework version

   Copyright (C) 1999-2002 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: 1999-2002
   
   This file is part of GNUstep Framework
   
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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

typedef enum {
  none = 0, 
  addition = 1, 
  subtraction = 2,
  multiplication = 3,
  division = 4
} calcOperation;

@interface Calculator: NSObject
{
  double result;
  double enteredNumber;
  calcOperation operation;
  int fractionalDigits;
  BOOL decimalSeparator;
  BOOL editing;

  /* The gsmarkup will set this field to point to the NSTextField
   * on the Calculator window loaded from the gsmarkup.
   */
  IBOutlet NSTextField *textField;
}
/* Load the gsmarkup.  */
- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;

/* The callbacks for the various buttons.  */
- (void) clear: (id)sender;
- (void) equal: (id)sender;
- (void) digit: (id)sender;
- (void) decimalSeparator: (id)sender;
- (void) operation: (id)sender;
- (void) squareRoot: (id)sender;

/* Jump to -error on calculation errors.  */
- (void) error;

/* Set the displayed number.  */
- (void) updateDisplay;

@end

