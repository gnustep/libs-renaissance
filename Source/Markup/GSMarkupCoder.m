/* -*-objc-*-
   GSMarkupCoder.m

   Copyright (C) 2002, 2003 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March 2002, July 2003

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

#include "GSMarkupCoder.h"
#include "GSMarkupConnector.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSCharacterSet.h>
# include <Foundation/NSData.h>
#endif

/*
 * Return the same string after replacing special chars with their
 * entities - in practice, after replacing:
 * & with &amp;
 * ' with &apos;
 * " with &quot;
 * < with &lt;
 * > with &gt; 
 */
static void
_GSMarkupAppendXMLEscapedString (NSMutableString *mutable, NSString *original)
{
  static NSCharacterSet	*specials = nil;
  NSRange		r;

  if (specials == nil)
    {
      specials = [NSCharacterSet characterSetWithCharactersInString: @"<>&'\""];
      RETAIN(specials);
    }

  r = [original rangeOfCharacterFromSet: specials];
  if (r.length > 0)
    {
      unsigned	length = [original length];
      unsigned	lastSpecialChar = -1;

      while (r.length > 0)
	{
	  unsigned	i = r.location;

	  if (lastSpecialChar + 1 < i)
	    {
	      r = NSMakeRange(lastSpecialChar+1, i-(lastSpecialChar+1));
	      [mutable appendString: [original substringWithRange: r]];
	    }
	  switch ([original characterAtIndex: i])
	    {
	      case '\'': [mutable appendString: @"&apos;"]; break;
	      case '\"': [mutable appendString: @"&quot;"]; break;
	      case '<': [mutable appendString: @"&lt;"]; break;
	      case '>': [mutable appendString: @"&gt;"]; break;
	      case '&': [mutable appendString: @"&amp;"]; break;
	    }
	  lastSpecialChar = i++;
	  r = [original rangeOfCharacterFromSet: specials
					options: NSLiteralSearch
					  range: NSMakeRange(i, length - i)];
	}
      if (lastSpecialChar + 1 < length)
	{
	  r = NSMakeRange (lastSpecialChar+1, length - (lastSpecialChar+1));
	  [mutable appendString: [original substringWithRange: r]];
	}
    }
  else
    {
      [mutable appendString: original];
    }
}

@implementation GSMarkupCoder

+ (void) encodeObjects: (NSArray *)objects
	    connectors: (NSArray *)connectors
	     nameTable: (NSDictionary *)nameTable
		toFile: (NSString *)file
{
  GSMarkupCoder *coder;
  
  coder = [[self alloc] initWithObjects: objects
			connectors: connectors
			nameTable: nameTable];
  [coder encodeToFile: file];
 
  RELEASE (coder);
}

+ (NSData *) encodeObjects: (NSArray *)objects
	        connectors: (NSArray *)connectors
      	         nameTable: (NSDictionary *)nameTable
{
  GSMarkupCoder *coder;
  NSData *result;

  coder = [[self alloc] initWithObjects: objects
			connectors: connectors
			nameTable: nameTable];
  result = [coder encode];
  RETAIN (result);

  RELEASE (coder);
  AUTORELEASE (result);
  return result;
}

- (id) initWithObjects: (NSArray *)objects
	    connectors: (NSArray *)connectors
	     nameTable: (NSDictionary *)nameTable
{
  NSMutableArray *connectorsCopy;
  
  ASSIGN (_objects, objects);

  /* Copy the connectors array since we need to modify it.  */
  connectorsCopy = [connectors mutableCopy];
  ASSIGN (_connectors, connectorsCopy);
  RELEASE (connectorsCopy);

  ASSIGN (_nameTable, nameTable);

  ASSIGN (_objectClassToTagName, [NSMutableDictionary dictionary]);
  ASSIGN (_connectorClassToTagName, [NSMutableDictionary dictionary]);

  return self;
}

- (void) dealloc
{
  RELEASE (_objects);
  RELEASE (_connectors);
  RELEASE (_nameTable);
  RELEASE (_objectClassToTagName);
  RELEASE (_connectorClassToTagName);
  [super dealloc];
}

- (NSData*) encode
{
  int		i;
  int		count;
  NSData	*data;

  ASSIGN (_output, [NSMutableString string]);

  /* XML preamble.  */
  [_output appendString:
    @"<?xml version=\"1.0\"?>\n<!DOCTYPE gsmarkup>\n<gsmarkup>\n\n"];

  /* <objects> section.  */
  [_output appendString: @"<objects>\n"];

  count = [_objects count];

  for (i = 0; i < count; i++)
    {
      [self encodeObject: [_objects objectAtIndex: i]];
    }
  
  [_output appendString: @"</objects>\n\n"];
  
  /* <connectors> section.  */
  [_output appendString: @"<connectors>\n"];

  count = [_connectors count];

  for (i = 0; i < count; i++)
    {
      [self encodeConnector: [_connectors objectAtIndex: i]];
    }

  [_output appendString: @"</connectors>\n\n"];
  
  /* XML postamble.  */
  [_output appendString: @"</gsmarkup>\n"];
 
  data = [_output dataUsingEncoding: NSUTF8StringEncoding];
  DESTROY (_output);
  return data;
}

- (BOOL) encodeToFile: (NSString *)file
{
  NSData	*d = [self encode];

  return [d writeToFile: file atomically: YES];
}

- (void) indent
{
  int i;
  
  for (i = 0; i < _indentation; i++)
    {
      [_output appendString: @" "];
    }  
}

- (void) encodeObject: (id <GSMarkupCoding>)object
{
  NSMutableDictionary *attributes;
  NSString *tagName;
  NSArray *content;
  
  tagName = [self tagNameForObjectClass: [object class]];

  if ([object attributes] != nil)
    {
      NSEnumerator	*enumerator;
      NSString		*key;

      attributes = [[object attributes] mutableCopy];

      /*
       * If there are existing attributes with a leading '#',
       * we must escape them so they are not decoded as references.
       */
      enumerator = [attributes keyEnumerator];
      while ((key = [enumerator nextObject]) != nil)
	{
	  NSString	*value = [attributes objectForKey: key];

	  if ([value hasPrefix: @"#"])
	    {
	      [attributes setObject: [@"#" stringByAppendingString: value]
			     forKey: key];
	    }
	}
    }
  else
    {
      attributes = [NSMutableDictionary new];
    }
  
  {
    NSArray *keys;

    keys = [_nameTable allKeysForObject: object];
    if (keys != nil  &&  [keys count] > 0)
      {
	int i;
	NSString *idName = [keys objectAtIndex: 0];

	[attributes setObject: idName  forKey: @"id"];
    
	/* Now search the connectors for outlet connectors having this
	 * object as the source.  */
	for (i = [_connectors count] - 1; i > -1; i--)
	  {
	    /* We cast it to GSMarkupOneToOneConnector.  Next we'll
	     * manually check that the cast was justified.
	     */
	    GSMarkupOneToOneConnector *connector 
	      = [_connectors objectAtIndex: i];
	    
	    if ([connector isKindOfClass: [GSMarkupOutletConnector class]])
	      {
		NSString *source = [connector source];
		
		if ([source isEqualToString: idName])
		  {
		    /* Found!  Encode this into the object itself!  */
		    [attributes setObject: 
				  [NSString stringWithFormat: @"#%@", 
					    [connector target]]
				forKey: [connector label]];
		    /* No longer need to encode this separately.  */
		    [_connectors removeObjectAtIndex: i];
		  }
	      }
	    else if ([connector isKindOfClass:
				  [GSMarkupControlConnector class]])
	      {
		NSString *source = [connector source];
		
		if ([source isEqualToString: idName])
		  {
		    /* Found!  Encode this into the object itself!  */
		    [attributes setObject: 
				  [NSString stringWithFormat: @"#%@", 
					    [connector target]]
				forKey: @"target"];
		    [attributes setObject: [connector label]
				forKey: @"action"];

		    /* No longer need to encode this separately.  */
		    [_connectors removeObjectAtIndex: i];
		  }
	      }
	  }
      }
  }
  
  /* Now build the start tag.  */
  _indentation += 2;
  [self indent];
  [_output appendString: @"<"];
  [_output appendString: tagName];
  
  {
    NSEnumerator *e = [attributes keyEnumerator];
    NSString *key;
    
    while ((key = [e nextObject]) != nil)
      {
	NSString *value = [attributes objectForKey: key];
	
	[_output appendString: @" "];
	_GSMarkupAppendXMLEscapedString (_output, key);
	[_output appendString: @"=\""];
	_GSMarkupAppendXMLEscapedString (_output, value);
	[_output appendString: @"\""];
      }
    /* Do not close the start tag yet ... if there is no content, we
     * want to produce a start/close tag, such as <button />  */
  }

  RELEASE (attributes);

  /* Now encode the content.  */
  content = [object content];

  if (content != nil  &&  [content count] > 0)
    {
      int i, count = [content count];
      
      [_output appendString: @">\n"];

      for (i = 0; i < count; i++)
	{
	  [self encodeObject: [content objectAtIndex: i]];
	}
      
      /* Now build the end tag.  */
      [self indent];
      [_output appendString: @"</"];
      [_output appendString: tagName];
      [_output appendString: @">\n"];
    }
  else
    {
      [_output appendString: @" />\n"];
    }
  _indentation -= 2;
}

- (void) encodeConnector: (GSMarkupConnector *)connector
{
  NSDictionary *attributes;
  NSArray *content;
  NSString *tagName;
  
  tagName = [self tagNameForConnectorClass: [connector class]];

  attributes = [connector attributes];
  
  /* Now build the tag head.  */
  _indentation += 2;
  [self indent];
  [_output appendString: @"<"];
  [_output appendString: tagName];
  
  /* Now output the attributes.  */
  {
    NSEnumerator *e = [attributes keyEnumerator];
    NSString *key;
    
    while ((key = [e nextObject]) != nil)
      {
	NSString *value = [attributes objectForKey: key];
	
	/* FIXME - escape the output strings! */
	[_output appendString: @" "];
	_GSMarkupAppendXMLEscapedString (_output, key);
	[_output appendString: @"=\""];
	_GSMarkupAppendXMLEscapedString (_output, value);
	[_output appendString: @"\""];
      }
  }

  /* Now encode the content.  */
  content = [connector content];

  if (content != nil  &&  [content count] > 0)
    {
      int i, count = [content count];
      
      [_output appendString: @">\n"];

      for (i = 0; i < count; i++)
	{
	  [self encodeConnector: [content objectAtIndex: i]];
	}
      
      /* Now build the end tag.  */
      [self indent];
      [_output appendString: @"</"];
      [_output appendString: tagName];
      [_output appendString: @">\n"];
    }
  else
    {
      [_output appendString: @" />\n"];
    }

  _indentation -= 2;
}

- (NSString *) tagNameForObjectClass: (Class)c
{
  NSString *className = NSStringFromClass (c);
  NSString *tagName;
  
  tagName = [_objectClassToTagName objectForKey: className];
  if (tagName != nil)
    {
      return tagName;
    }

  if ([c respondsToSelector: @selector(tagName)])
    {
      return [c tagName];
    }

  return @"tag";
}

- (NSString *) tagNameForConnectorClass: (Class)c
{
  NSString *className = NSStringFromClass (c);
  NSString *tagName;
  
  tagName = [_connectorClassToTagName objectForKey: className];
  if (tagName != nil)
    {
      return tagName;
    }

  if ([c respondsToSelector: @selector(tagName)])
    {
      return [c tagName];
    }

  /* Else, encode it as an outlet.  */
  return @"outlet";
}

- (void) setTagName: (NSString *)tagName
     forObjectClass: (NSString *)className
{
  [_objectClassToTagName setObject: tagName  forKey: className];
}


- (void) setTagName: (NSString *)tagName
  forConnectorClass: (NSString *)className
{
  [_connectorClassToTagName setObject: tagName  forKey: className];
}

@end


