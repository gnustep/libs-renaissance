/*
 *  NSTextViewAdd.m: Trivial Text View Additions
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

#include "NSTextViewAdd.h"
#include <Renaissance/Renaissance.h>

static NSFont *normal_ = nil;
static NSFont *bold_ = nil;

static void setup (void)
{
  if (normal_ == nil)
    {
      ASSIGN (normal_, [NSFont userFixedPitchFontOfSize: 0]);
      ASSIGN (bold_, [NSFont boldSystemFontOfSize: 0]);
    }
}

@implementation NSTextView (Add)

-(void) resetString
{
  NSTextStorage *storage = [self textStorage];
  NSRange all = NSMakeRange (0, [storage length]);
  
  [storage beginEditing];
  [storage replaceCharactersInRange: all  withString: @""];
  [storage endEditing];
}

-(void) appendString: (NSString *)s
{
  if (s != nil  &&  ![s isEqualToString: @""])
    {
      NSTextStorage *storage = [self textStorage];
      unsigned end = [storage length];
      NSRange endRange = NSMakeRange (end, 0);
      NSRange stringRange = NSMakeRange (end, [s length]);
      
      [storage beginEditing];
      [storage replaceCharactersInRange: endRange  withString: s];
      setup ();
      [storage addAttribute: NSFontAttributeName
	       value: normal_
	       range: stringRange];
      [storage endEditing];
    }
}

-(void) appendBoldString: (NSString *)s
{
  /* First we check that the last character in the text is a newline. 
     If it isn't, we append a newline to it before the bold string */
  if ([[self string] hasSuffix: @"\n"] == NO)
    {
      [self appendString: @"\n"];
    }
  
  if (s != nil  &&  ![s isEqualToString: @""])
    {
      NSTextStorage *storage = [self textStorage];
      unsigned end = [storage length];
      NSRange endRange = NSMakeRange (end, 0);
      NSRange stringRange = NSMakeRange (end, [s length]);
      
      [storage beginEditing];
      [storage replaceCharactersInRange: endRange  withString: s];
      setup ();
      [storage addAttribute: NSFontAttributeName
	       value: bold_
	       range: stringRange];
      [storage endEditing];
    }
}
@end

