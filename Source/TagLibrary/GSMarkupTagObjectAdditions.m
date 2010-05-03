/* -*-objc-*-
   GSMarkupTagObject.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March 2002

   This file is part of GNUstep Renaissance

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with this library; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/ 
#include <TagCommonInclude.h>
#include "GSMarkupTagObjectAdditions.h"


#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSDictionary.h>
# include <Foundation/NSInvocation.h>
# include <AppKit/NSColor.h>
# include <AppKit/NSFont.h>
#endif

/* Used to read a XX hex value when parsing colors in RRGGBB(AA)
 * format.  */
static CGFloat hexValueFromUnichars (unichar a, unichar b) 
{
  CGFloat result = 0;

  switch (a)
    {
    case '0': result += 0x00; break;
    case '1': result += 0x10; break;
    case '2': result += 0x20; break;
    case '3': result += 0x30; break;
    case '4': result += 0x40; break;
    case '5': result += 0x50; break;
    case '6': result += 0x60; break;
    case '7': result += 0x70; break;
    case '8': result += 0x80; break;
    case '9': result += 0x90; break;
    case 'A': 
    case 'a': result += 0xA0; break;
    case 'B': 
    case 'b': result += 0xB0; break;
    case 'C': 
    case 'c': result += 0xC0; break;
    case 'D':
    case 'd': result += 0xD0; break;
    case 'E': 
    case 'e': result += 0xE0; break;
    case 'F': 
    case 'f': result += 0xF0; break;
    default: return -1;
    }

  switch (b)
    {
    case '0': result += 0x0; break;
    case '1': result += 0x1; break;
    case '2': result += 0x2; break;
    case '3': result += 0x3; break;
    case '4': result += 0x4; break;
    case '5': result += 0x5; break;
    case '6': result += 0x6; break;
    case '7': result += 0x7; break;
    case '8': result += 0x8; break;
    case '9': result += 0x9; break;
    case 'A': 
    case 'a': result += 0xA; break;
    case 'B': 
    case 'b': result += 0xB; break;
    case 'C': 
    case 'c': result += 0xC; break;
    case 'D':
    case 'd': result += 0xD; break;
    case 'E': 
    case 'e': result += 0xE; break;
    case 'F': 
    case 'f': result += 0xF; break;
    default: return -1;
    }

  return (result / 255.);
}

/* The argument type is only used on systems without a working
 * NSInvocation.  */
static NSFont *getFontWithSelectorSize (SEL selector, NSString *type, CGFloat size)
{
#if 1 /* Working NSInvocation.  */
  NSMethodSignature *ms;
  NSInvocation *i;
  Class nsfont = [NSFont class];
  NSFont *result;

  ms = [nsfont methodSignatureForSelector: selector];
  i = [NSInvocation invocationWithMethodSignature: ms];
  [i setSelector: selector];
  [i setTarget: nsfont];
  [i setArgument: &size  atIndex: 2];
  [i invoke];
  [i getReturnValue: &result];
  return result;
#else /* For systems where NSInvocation is not working ... hardcoded
      * ugly invocations.  */
  switch ([type length])
    {
    case 4:
      if ([type isEqualToString: @"user"])
	{
	  return [NSFont userFontOfSize: size];
	}
      else if ([type isEqualToString: @"menu"])
	{
	  return [NSFont menuFontOfSize: size];
	}
      break;
    case 5:
      if ([type isEqualToString: @"label"])
	{
	  return [NSFont labelFontOfSize: size];
	}
      break;
    case 6:
      if ([type isEqualToString: @"system"])
	{
	  return [NSFont systemFontOfSize: size];
	}
      break;
    case 7:
      if ([type isEqualToString: @"message"])
	{
	  return [NSFont messageFontOfSize: size];
	}
      else if ([type isEqualToString: @"palette"])
	{
	  return [NSFont paletteFontOfSize: size];
	}
      break;
    case 8:
      if ([type isEqualToString: @"titleBar"])
	{
	  return [NSFont titleBarFontOfSize: size];
	}
      else if ([type isEqualToString: @"toolTips"])
	{
	  return [NSFont toolTipsFontOfSize: size];
	}
      break;
    case 10:
      if ([type isEqualToString: @"boldSystem"])
	{
	  return [NSFont boldSystemFontOfSize: size];
	}
      break;
    case 14:
      if ([type isEqualToString: @"userFixedPitch"])
	{
	  return [NSFont userFixedPitchFontOfSize: size];
	}
      break;
    }

  return [NSFont labelFontOfSize: size];
#endif
}



@implementation GSMarkupTagObject (TagLibraryAdditions)

- (NSColor *) colorValueForAttribute: (NSString *)attribute
{
  NSString *value = [_attributes objectForKey: attribute];

  if (value == nil)
    {
      return nil;
    }

  /* Try [NSColor +valueColor].  */
  {
    NSString *name = [NSString stringWithFormat: @"%@Color", value];
    SEL selector = NSSelectorFromString (name);

    if (selector != NULL  && [NSColor respondsToSelector: selector])
      {
	return [NSColor performSelector: selector];
      }
  }
  
  /* Try RRGGBB or RRGGBBAA format.  */
  if ([value length] == 6  ||  [value length] == 8)
    {
      CGFloat r, g, b, a;

      r = hexValueFromUnichars ([value characterAtIndex: 0],
				[value characterAtIndex: 1]);
      if (r == -1)
	{
	  return nil;
	}
      g = hexValueFromUnichars ([value characterAtIndex: 2],
				[value characterAtIndex: 3]);
      if (g == -1)
	{
	  return nil;
	}
      b = hexValueFromUnichars ([value characterAtIndex: 4],
				[value characterAtIndex: 5]);
      if (b == -1)
	{
	  return nil;
	}
      
      if ([value length] == 8)
	{
	  a = hexValueFromUnichars ([value characterAtIndex: 6],
				    [value characterAtIndex: 7]);
	  if (a == -1)
	    {
	      return nil;
	    }
	}
      else
	{
	  a = 1.0;
	}

      return [NSColor colorWithCalibratedRed: r
		      green: g
		      blue: b
		      alpha: a];
    }

  return nil;
}

- (NSFont *) fontValueForAttribute: (NSString *)attribute
{
  NSString *value = [_attributes objectForKey: attribute];
  CGFloat pointSizeChange = 1;
  BOOL pointSizeChanged = NO;
  SEL selector;
  NSString *type;

  if (value == nil)
    {
      return nil;
    }

#if 1
  selector = @selector(labelFontOfSize:);
  type = @"label";
#else /* OPENSTEP doesn't have labelFontOfSize: */
  selector = @selector(systemFontOfSize:);
  type = @"system";
#endif

  {
    NSArray *a = [value componentsSeparatedByString: @" "];
    int i, count = [a count];
    
    for (i = 0; i < count; i++)
      {
	NSString *token = [a objectAtIndex: i];
	BOOL found = NO;

	switch ([token length])
	  {
	  case 3:
	    {
	      if ([token isEqualToString: @"big"])
		{
		  pointSizeChange = 1.25;
		  found = YES;
		}
	      else if ([token isEqualToString: @"Big"])
		{
		  pointSizeChange = 1.5;
		  found = YES;
		}
	      break;
	    }
	  case 4:
	    {
	      if ([token isEqualToString: @"huge"])
		{
		  pointSizeChange = 2;
		  found = YES;
		}
	      else if ([token isEqualToString: @"Huge"])
		{
		  pointSizeChange = 3;
		  found = YES;
		}
	      else if ([token isEqualToString: @"tiny"])
		{
		  pointSizeChange = 0.5;
		  found = YES;
		}
	      else if ([token isEqualToString: @"Tiny"])
		{
		  pointSizeChange = 0.334;
		  found = YES;
		}

	      break;
	    }
	  case 5:
	    {
	      if ([token isEqualToString: @"small"])
		{
		  pointSizeChange = 0.80;
		  found = YES;
		}
	      else if ([token isEqualToString: @"Small"])
		{
		  pointSizeChange = 0.667;
		  found = YES;
		}
	      break;
	    }
	  case 6:
	    {
	      if ([token isEqualToString: @"medium"])
		{
		  pointSizeChange = 1;
		  found = YES;
		}
	      break;
	    }
	  }

	if (found)
	  {
	    pointSizeChanged = YES;
	  }
	

	if (! found)
	  {
	    NSString *name;
	    SEL s;

	    name = [NSString stringWithFormat: @"%@FontOfSize:", token];
	    s = NSSelectorFromString (name);
	    
	    if (s != NULL  && [NSFont respondsToSelector: s])
	      {
		selector = s;
		type = token;
		found = YES;
	      }
	  }
	if (! found)
  {
    CGFloat g = [token floatValue];
    if (g > 0)
    {
      pointSizeChange = g;
      pointSizeChanged = YES;
    }
  }
      }
  }
  
  /* Get the font.  */
  {
    NSFont *f;
    
    f = getFontWithSelectorSize (selector, type, 0);
    
    if (pointSizeChanged)
    {
      CGFloat pointSize = [f pointSize];
      
      pointSize = pointSize * pointSizeChange;
      
      f = getFontWithSelectorSize (selector, type, pointSize);
    }
    
    return f;
  }
  
}

- (int) integerMaskValueForAttribute: (NSString *)attribute
	    withMaskValuesDictionary: (NSDictionary *)dictionary
{
  NSString *value = [_attributes objectForKey: attribute];
  int integerMask = 0;

  if (value == nil)
    {
      return 0;
    }

  {
    NSArray *a = [value componentsSeparatedByString: @"|"];
    int i, count = [a count];
    
    for (i = 0; i < count; i++)
      {
	NSString *token = [a objectAtIndex: i];
	NSNumber *tokenValue = nil;

	token = [token stringByTrimmingCharactersInSet: 
			 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	tokenValue = [dictionary objectForKey: token];

	if (tokenValue == nil)
	  {
	    NSLog (@"Warning: <%@> has unknown value '%@' for attribute '%@'.  Ignored.",
		   [[self class] tagName], token, attribute);
	  }
	else
	  {
	    integerMask |= [tokenValue intValue];
	  }
      }
  }

  return integerMask;
}

@end

