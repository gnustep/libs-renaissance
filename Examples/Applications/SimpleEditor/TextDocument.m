/*
 *  TextDocument.m: A mini sample GNUstep Renaissance document class
 *
 *  Copyright (c) 2003 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: January 2003
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

#include "TextDocument.h"

@implementation TextDocument
- (NSString *) windowNibName
{
  return @"TextDocument";
}

- (NSData *) dataRepresentationOfType: (NSString *)type
{
  return [[textView string] 
	   dataUsingEncoding: [NSString defaultCStringEncoding]];
}


- (BOOL) loadDataRepresentation: (NSData *)data
			 ofType: (NSString *)type
{
  text = [[NSString alloc] initWithData: data
			   encoding: [NSString defaultCStringEncoding]];
  if (text == nil)
    {
      return NO;
    }
  
  return YES;
}

- (void) windowControllerDidLoadNib: (NSWindowController *)controller
{
  [super windowControllerDidLoadNib: controller];
  
  if (text != nil)
    {
      [textView setString: text];
      DESTROY (text);
    }
}

- (void) dealloc
{
  DESTROY (textView);
  DESTROY (text);
  [super dealloc];
}

@end
