/* Calculator.m: Calculator.app, GNUstep Renaissance version

   Copyright (C) 1999-2002 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: 1999-2002
   
   This file is part of GNUstep.
   
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

#include <math.h>
#include "Calculator.h"
#include <Renaissance/Renaissance.h>

@implementation Calculator

-(id) init
{
  [super init];
  result = 0;
  enteredNumber = 0;
  operation = none;
  fractionalDigits = 0;
  decimalSeparator = NO;
  editing = YES;

  return self;
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification
{
  [NSBundle loadGSMarkupNamed: @"Calculator"  owner: self];
  
  [self updateDisplay];
}

- (void) updateDisplay
{
  NSString *value;
  
  if (decimalSeparator)
    {
      value = [NSString stringWithFormat: 
			  [NSString stringWithFormat: 
				      @"%%#.%df", fractionalDigits], 
			enteredNumber];
    }
  else
    {
      value = [NSString stringWithFormat: @"%.0f", enteredNumber];
    }
  
  [textField setStringValue: value];
}

/* The callbacks for the various buttons  */
-(void) clear: (id)sender
{
  result = 0;
  enteredNumber = 0;
  operation = none;
  fractionalDigits = 0;
  decimalSeparator = NO;
  editing = YES;
  [self updateDisplay];
}
-(void) equal: (id)sender
{
  switch (operation)
    {
    case none: 
      result = enteredNumber;
      enteredNumber = 0;
      decimalSeparator = NO;
      fractionalDigits = 0;
      return;
      break;
    case addition:
      result = result + enteredNumber;
      break;
    case subtraction:
      result = result - enteredNumber;
      break;
    case multiplication:
      result = result * enteredNumber;
      break;
    case division:
      if (enteredNumber == 0)
	{
	  [self error];
	  return;
	}
      else 
	result = result / enteredNumber;
      break;
    }
  enteredNumber = result;
  fractionalDigits = 7;

  if (ceil(result) != result)
    decimalSeparator = YES;
  else
    decimalSeparator = NO;

  [self updateDisplay];

  operation = none;
  editing = NO;
}
-(void) digit: (id)sender
{
  if (!editing)
    {
      enteredNumber = 0;
      decimalSeparator = NO;
      fractionalDigits = 0;
      editing = YES;
    }
  if (decimalSeparator)
    {
      enteredNumber = enteredNumber 
	+ ([sender tag] * pow (0.1, 1 + fractionalDigits));
      fractionalDigits++;
    }
  else
    {
      enteredNumber = enteredNumber * 10 + ([sender tag]);
      /* Check overflow.  */
      if (enteredNumber > pow (10, 15))
	{
	  [self error];
	  return;
	}
    }
  [self updateDisplay];
}
-(void) decimalSeparator: (id)sender
{
  if (!editing)
    {
      enteredNumber = 0;
      decimalSeparator = NO;
      fractionalDigits = 0;
      editing = YES;
    }
  if (!decimalSeparator)
    {
      decimalSeparator = YES;
      fractionalDigits = 0;
      [self updateDisplay];
    }
}
-(void) operation: (id)sender
{
  if (operation == none)
    {
      result = enteredNumber;
      enteredNumber = 0;
      decimalSeparator = NO;
      fractionalDigits = 0;
      operation = [sender tag];
    }
  else
    {	 
      [self equal: nil];
      [self operation: sender];
    }
}
-(void) squareRoot: (id)sender
{
  if (operation == none)
    {
      result = sqrt (enteredNumber);
      enteredNumber = result;
      fractionalDigits = 7;
      
      if (ceil(result) != result)
	decimalSeparator = YES;
      else
	decimalSeparator = NO;
      
      [self updateDisplay];

      editing = NO;
      operation = none;  
    }
  else
    {	 
      [self equal: nil];
      [self squareRoot: sender];
    }
} 
-(void) error
{
  result = 0;
  enteredNumber = 0;
  operation = none;
  fractionalDigits = 0;
  decimalSeparator = NO;
  editing = YES;
  [textField setStringValue: @"Error"];
}
@end

