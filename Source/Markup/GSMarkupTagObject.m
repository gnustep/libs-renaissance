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

#include "GSMarkupTagObject.h"
#include "GSMarkupAwaker.h"
#include "GSMarkupLocalizer.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSBundle.h>
# include <Foundation/NSDictionary.h>
# include <Foundation/NSInvocation.h>
#endif

/*
 * Private function to check that 'aClass' is the same, or a subclass,
 * of 'aPotentialSuperClass'.  Return YES if so, and NO if not.
 */
static BOOL isClassSubclassOfClass (Class aClass,
				    Class aPotentialSuperClass)
{
  if (aClass == aPotentialSuperClass)
    {
      return YES;
    }
  else
    {
      while (aClass != Nil)
        {
          aClass = [aClass superclass];
	  
          if (aClass == aPotentialSuperClass)
            {
              return YES;
            }
        } 
      return NO;
    }
}

@implementation GSMarkupTagObject

+ (NSString *) tagName
{
  return nil;
}

- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content
{
  ASSIGN (_attributes, attributes);
  ASSIGN (_content, content);
  return self;
}

- (void) dealloc
{
  RELEASE (_attributes);
  RELEASE (_content);
  RELEASE (_platformObject);
  RELEASE (_localizer);
  RELEASE (_awaker);
  [super dealloc];
}

- (NSDictionary *) attributes
{
  return _attributes;
}

- (NSArray *) content
{
  return _content;
}

- (NSArray *) localizableStrings
{
  NSMutableArray *a = [NSMutableArray array];
  NSArray *att;
  int i, count;

  /* First, extract localizable strings from content.  */
  count = [_content count];
  
  for (i = 0; i < count; i++)
    {
      GSMarkupTagObject *o = [_content objectAtIndex: i];

      if ([o isKindOfClass: [GSMarkupTagObject class]])
	{
	  NSArray *k = [o localizableStrings];
	  if (k != nil)
	    {
	      [a addObjectsFromArray: k];
	    }
	}
      else if ([o isKindOfClass: [NSString class]])
	{
	  [a addObject: o];
	}
    }

  /* Then, extract localizable strings from attributes.  */
  att = [[self class] localizableAttributes];

  count = [att count];
  
  for (i = 0; i < count; i++)
    {
      NSString *attribute = [att objectAtIndex: i];
      NSString *value = [_attributes objectForKey: attribute];
      if (value != nil)
      {
	[a addObject: value];
      }
    }
  
  return a;
}

+ (NSArray *) localizableAttributes
{
  return nil;
}

- (void) setAwaker: (GSMarkupAwaker *)awaker
{
  int i, count;

  ASSIGN (_awaker, awaker);

  count = [_content count];
  
  for (i = 0; i < count; i++)
    {
      GSMarkupTagObject *o = [_content objectAtIndex: i];
      
      if ([o isKindOfClass: [GSMarkupTagObject class]])
	{
	  [o setAwaker: awaker];
	}
    }
}

- (void) setPlatformObject: (id)object
{
  if (_platformObject == object)
    {
      return;
    }

  if (_platformObject != nil)
    {
      /* The following will do nothing if _awaker is nil.  */
      [_awaker deregisterObject: _platformObject];
    }

  ASSIGN (_platformObject, object);

  if (object != nil)
    {
      /* The following will do nothing if _awaker is nil.  */
      [_awaker registerObject: object];
    }
}

- (id) platformObject
{
  if (_platformObject == nil)
    {
      /* Build the object.  */
      [self platformObjectAlloc];
      [self platformObjectInit];
      [self platformObjectAfterInit];
    }

  /* We own the object we return ... it is released when we are
   * deallocated.  The caller should RETAIN it if it wants it to
   * survive our deallocation.  */
  return _platformObject;
}

- (void) platformObjectAlloc
{
  Class selfClass = [self class];
  Class class = [selfClass defaultPlatformObjectClass];

  if ([selfClass useInstanceOfAttribute])
    {
      NSString *className = [_attributes objectForKey: @"instanceOf"];
      
      if (className != nil)
	{
	  Class nonStandardClass = NSClassFromString (className);
	  
	  if (nonStandardClass != Nil)
	    {
	      if (isClassSubclassOfClass (nonStandardClass, class))
		{
		  class = nonStandardClass;
		}
	    }
	}
    }

  [self setPlatformObject: AUTORELEASE ([class alloc])];
}

+ (Class) defaultPlatformObjectClass
{
  return Nil;
}

+ (BOOL) useInstanceOfAttribute
{
  return NO;
}

- (void) platformObjectInit
{
  [self setPlatformObject: [_platformObject init]];
}

- (void) platformObjectAfterInit
{

}

- (NSString *) description
{
  return [NSString stringWithFormat: 
		     @"%@[attributes %@/content %@/platformObject %@]",
		NSStringFromClass ([self class]),
		[_attributes description],
		[_content description],
		   _platformObject];
}

- (int) boolValueForAttribute: (NSString *)attribute
{
  NSString *value = [_attributes objectForKey: attribute];

  if (value == nil)
    {
      return -1;
    }

  switch ([value length])
    {
    case 1:
      {
	unichar a = [value characterAtIndex: 0];
	switch (a)
	  {
	  case 'y':
	  case 'Y':
	    return 1;

	  case 'n':
	  case 'N':
	    return 0;
	  }

	return -1;
      }
    case 2:
      {
	unichar a = [value characterAtIndex: 0];
	if (a == 'n'  ||  a == 'N')
	  {
	    unichar b = [value characterAtIndex: 1];
	    if (b == 'o'  ||  b == 'O')
	      {
		return 0;
	      }
	  }
	
	return -1;
      }
    case 3:
      {
	unichar a = [value characterAtIndex: 0];
	if (a == 'y'  ||  a == 'Y')
	  {
	    unichar b = [value characterAtIndex: 1];
	    if (b == 'e'  ||  b == 'E')
	      {
		unichar c = [value characterAtIndex: 2];
		if (c == 's'  ||  c == 'S')
		  {
		    return 1;
		  }
	      }
	  }

	return -1;
      }
    }

  return -1;
}

- (void) setLocalizer: (GSMarkupLocalizer *)localizer
{
  int i, count;

  ASSIGN (_localizer, localizer);

  count = [_content count];
  
  for (i = 0; i < count; i++)
    {
      GSMarkupTagObject *o = [_content objectAtIndex: i];
      
      if ([o isKindOfClass: [GSMarkupTagObject class]])
	{
	  [o setLocalizer: localizer];
	}
    }
}

- (NSString *) localizedStringValueForAttribute: (NSString *)attribute
{
  NSString *value = [_attributes objectForKey: attribute];

  if (value == nil)
    {
      return nil;
    }
  else
    {
      return [_localizer localizeString: value];
    }
}

@end

