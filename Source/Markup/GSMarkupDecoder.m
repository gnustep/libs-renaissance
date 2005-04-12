/* -*-objc-*-
   GSMarkupDecoder.m

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

#include "GSMarkupDecoder.h"
#include "GSMarkupDecoderBackend.h"
#include "GSMarkupCoding.h"
#include "GSMarkupConnector.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSCharacterSet.h>
# include <Foundation/NSData.h>
# include <Foundation/NSDictionary.h>
# include <Foundation/NSString.h>
#endif

static NSCharacterSet *whitespaceAndNewline = nil;

/* Auxiliary function returning a string where the first character has
 * been made uppercase, all other characters are unchanged.  */
@interface NSString (CapitalizedString)
- (NSString *) stringByUppercasingFirstCharacter;

/* Collapses all sequences of whitespaces, newlines and tabs in the
 * string to a single space.  Trims whitespaces from the string at the
 * beginning and at the end of it.
 */
- (NSString *) stringByStrippingWhitespaces;
@end

@implementation NSString (CapitalizedString)
- (NSString *) stringByUppercasingFirstCharacter
{
  unsigned length = [self length];

  if (length < 1)
    {
      return self;
    }
  else
    {
      NSString *s;
      /* Get the first character.  */
      unichar c = [self characterAtIndex: 0];

      /* If it's not lowercase ... */
      if (c < 'a'  ||  c > 'z')
	{
	  /* then no need to uppercase.  */
	  return self;
	}
      
      /* Else, uppercase the first character.  */
      c = c + 'A' - 'a';
      
      s = [NSString stringWithCharacters: &c  length: 1];
      
      if (length == 1)
	{
	  return s;
	}
      else
	{
	  return [s stringByAppendingString: [self substringFromIndex: 1]];
	}
    }
}

- (NSString *) stringByStrippingWhitespaces
{
  NSString *s = [self stringByTrimmingCharactersInSet: whitespaceAndNewline];
  int length = [s length];
  if (length == 0)
    {
      return @"";
    }
  else
    {
      unichar *buffer = malloc (sizeof (unichar) * length);
      unichar *result = malloc (sizeof (unichar) * length);
      int i, j;
      BOOL lastCharWasASpace = NO;
      
      [s getCharacters: buffer];
      
      j = 0;
      for (i = 0; i < length; i++)
	{
	  if ([whitespaceAndNewline characterIsMember: buffer[i]])
	    {
	      if (lastCharWasASpace)
		{
		  /* Skip.  */
		  continue;
		}
	      else
		{
		  lastCharWasASpace = YES;
		  result[j] = ' ';
		  j++;
		}
	    }
	  else
	    {
	      lastCharWasASpace = NO;
	      result[j] = buffer[i];
	      j++;
	    }
	}
      
      if (j == 0)
	{
	  s = @"";
	}
      else
	{
	  s = [NSString stringWithCharacters: result  length: j];
	}
  
      free (buffer);
      free (result);
      
      return s;
    }
}

@end

/* This auxiliary class represents a tag found in the XML file.  */
@interface GSMarkupTag : NSObject
{
  NSString *name;
  NSDictionary *attributes;
  NSMutableArray *content;
}
- (id) initWithName: (NSString *)n
	 attributes: (NSDictionary *)a;

- (void) addObjectToContent: (id)c;

- (void) addStringToContent: (NSString *)c;

- (void) finalizeStrings;

- (NSString *)name;

- (NSDictionary *)attributes;

- (NSArray *)content;

@end

@implementation GSMarkupTag
- (id) initWithName: (NSString *)n
	 attributes: (NSDictionary *)a
{
  ASSIGN (name, n);
  ASSIGN (attributes, a);
  ASSIGN (content, [NSMutableArray array]);
  return self;
}

- (void) dealloc
{
  RELEASE (name);
  RELEASE (attributes);
  RELEASE (content);
  [super dealloc];
}

/**
 * This adds an object to the content array.
 */
- (void) addObjectToContent: (id)c
{
  [content addObject: c];
}

- (void) addStringToContent: (NSString *)c
{
  /* If content already contains a string, and if the new object is a string,
   * merge them together.  That can happen if there is a comment embedded
   * in the string - the XML parser will report the first part of the string,
   * then the comment (which we ignore), then the second part.  We need to
   * merge the first and second part together.
   */
  int count = [content count];
  
  if (count > 0)
    {
      NSObject *o = [content lastObject];
      
      if ([o isKindOfClass: [NSString class]])
	{
	  NSString *s = [NSString stringWithFormat: @"%@%@", o, c];

	  [content removeLastObject];
	  [content addObject: s];
	  return;
	}
    }

  /* Default case.  */
  [content addObject: c];
}

- (void) finalizeStrings
{
  int count = [content count];
  int i;
  
  for (i = count - 1; i >= 0; i--)
    {
      id c = [content objectAtIndex: i];
      
      if ([c isKindOfClass: [NSString class]])
	{
	  NSString *trimmed = [c stringByStrippingWhitespaces];
	  
	  if ([trimmed isEqualToString: @""])
	    {
	      [content removeObjectAtIndex: i];
	    }
	  else
	    {
	      [content replaceObjectAtIndex: i
		       withObject: trimmed];
	    }
	}
    }
}

- (NSString *)name
{
  return name;
}

- (NSDictionary *)attributes
{
  return attributes;
}

- (NSArray *)content
{
  return content;
}
@end

@interface GSMarkupDecoder (InternalAPI)
- (void) processParsedTag: (GSMarkupTag *)tag;
@end

@implementation GSMarkupDecoder

+ (void) initialize
{
  if (self == [GSMarkupDecoder class])
    {
      ASSIGN (whitespaceAndNewline,
	      [NSCharacterSet whitespaceAndNewlineCharacterSet]);
    }
  
}


+ (id) decoderWithContentsOfFile: (NSString *)file
{
  GSMarkupDecoder *decoder;

  decoder = [[self alloc] initWithContentsOfFile: file];
  AUTORELEASE (decoder);
  return decoder;
}

- (id) initWithContentsOfFile: (NSString *)file
{
  NSData	*d = [[NSData alloc] initWithContentsOfFile: file];

  self = [self initWithData: d];
  RELEASE(d);
  return self;
}

- (id) initWithData: (NSData *)data
{
  ASSIGN (_backend, GSMarkupDecoderBackendForReadingFromData (data, self));
  ASSIGN (_stack, [NSMutableArray array]);

  ASSIGN (_objects, [NSMutableArray array]);
  ASSIGN (_connectors, [NSMutableArray array]);
  ASSIGN (_nameTable, [NSMutableDictionary dictionary]);

  ASSIGN (_tagNameToObjectClass, [NSMutableDictionary dictionary]);
  ASSIGN (_tagNameToConnectorClass, [NSMutableDictionary dictionary]);

  return self;
}

- (void) dealloc
{
  RELEASE (_backend);
  RELEASE (_stack);
  RELEASE (_objects);
  RELEASE (_connectors);
  RELEASE (_nameTable);
  RELEASE (_tagNameToObjectClass);
  RELEASE (_tagNameToConnectorClass);
  [super dealloc];
}

- (void) parse
{  
  /* This call will cause the backend to parse the XML file, and
   * call our SAX-like callbacks.  */
  [_backend parse];
}

- (void) foundStartElement: (NSString*)elementName
	    withAttributes: (NSDictionary*)elementAttributes
{
  if ([elementName length] < 1)
    {
      return;
    }

  switch ([elementName characterAtIndex: 0])
    {
    case 'g':
      {
	if ([elementName isEqualToString: @"gsmarkup"])
	  {
	    /* Please note that the root tag is <gsmarkup>.  We simply
	     * ignore opening and closing <gsmarkup> tags for now.  Who
	     * cares, if the document is well-formed it makes no
	     * difference and frankly we are not interested in being
	     * picky about formats.  */
	    return;
	  }
	break;
      }
    case 'o':
      {
	if ([elementName isEqualToString: @"objects"])
	  {
	    if (_isInsideObjects)
	      {
		[self warning: @"<objects> tag inside another <objects> tag"];
		return;
	      }
	    if (_isInsideConnectors)
	      {
		[self warning: @"<objects> tag inside a <connectors> tag"];
		return;
	      }
	    _isInsideObjects = YES;
	    return;
	  }
	break;
      }
    case 'c':
      {
	if ([elementName isEqualToString: @"connectors"])
	  {
	    if (_isInsideObjects)
	      {
		[self warning: @"<connectors> tag inside an <objects> tag"];
		return;
	      }
	    if (_isInsideConnectors)
	      {
		[self error: 
			@"<connectors> tag inside another <connectors> tag"];
		return;
	      }
	    
	    _isInsideConnectors = YES;
	    return;
	  }
	break;
      }
    }

  if ((! _isInsideObjects)  &&  (! _isInsideConnectors))
    {
      /* Ignore the tags - might be a future expansion!  */
      NSString *s;
      s = [NSString stringWithFormat: 
		      @"<%@> tag outside <objects> or <connectors> !", 
		    elementName];
      [self warning: s];
      return;
    }  

  /* Now create a tag object, and put it in the parsing stack.  We
   * will process it when we find the end tag (at which point we also
   * know the content of the tag, which are needed).  */
  {
    GSMarkupTag *tag;
    
    tag = [[GSMarkupTag alloc] initWithName: elementName
			   attributes: elementAttributes];
    
    [_stack addObject: tag];
    RELEASE (tag);
  }
}


- (void) foundEndElement: (NSString*) elementName
{    
  if ([elementName length] < 1)
    {
      return;
    }

  switch ([elementName characterAtIndex: 0])
    {
    case 'g':
      {
	if ([elementName isEqualToString: @"gsmarkup"])
	  {
	    return;
	  }
	break;
      }
    case 'o':
      {
	if ([elementName isEqualToString: @"objects"])
	  {
	    if (_isInsideObjects)
	      {
		_isInsideObjects = NO;
		return;
	      }
	    else
	      {
		[self warning: @"</objects> without opening <objects>"];
		return;
	      }
	  }
	break;
      }
    case 'c':
      {
	if ([elementName isEqualToString: @"connectors"])
	  {
	    if (_isInsideConnectors)
	      {
		_isInsideConnectors = NO;
		return;
	      }
	    else
	      {
		[self warning: @"</connectors> without opening <connectors>"];
		return;
	      }
	  }
	break;
      }
    }

  if ((! _isInsideObjects)  &&  (! _isInsideConnectors))
    {
      /* Ignore.  */
      NSString *s;
      s = [NSString stringWithFormat: 
		      @"Closing </%@> outside <objects> and <connectors>",
		    elementName];
      [self warning: s];
      return;
    }

  /* The last tag on the stack must match this tag.  */
  {
    GSMarkupTag *lastOpenTag = (GSMarkupTag *)[_stack lastObject];
    
    if (![[lastOpenTag name] isEqualToString: elementName])
      {
	NSString *warning;

	/* Our current libxml2 based backend detects this error
	 * automatically, anyway the code is here for safety and for
	 * future less clever backends.  */
	warning = [NSString stringWithFormat: @"Syntax Error: expecting closing tag </%@> and got closing tag </%@> instead!", 
			    [lastOpenTag name], elementName];
	[self warning: warning];
	/* TODO: Here we ignore the error (libxml2 will abort anyway),
	 * but we might try recovering from this error ... it's much
	 * more likely for people to forget closing tags rather than
	 * starting tags.  So at this point we should assume one or
	 * more closing tags are missing - we look up in the stack
	 * till we find a starting tag matching this closing one.  If
	 * we don't find any, we assume the starting tag was forgotten
	 * instead, so we ignore this closing tag.  Otherwise (if we
	 * found a matching starting tag), we close tags in the stack
	 * going up till we find the starting tag matching this
	 * closing one, and close that one too.  */
	return;
      }

    /* Remove lastOpenTag from the stack, but RETAIN it since we are going
     * to work on it now.  */
    RETAIN (lastOpenTag);
    [_stack removeLastObject];

  
    /* Process the tag.  The code is in a separate method for no reason
     * but for breaking the code into little more manageable chunks.  */
    [self processParsedTag: lastOpenTag];
    
    RELEASE (lastOpenTag);
  }
} 

- (void) processParsedTag: (GSMarkupTag *)tag
{
  NSString *tagName = [tag name];
  Class tagClass;
  id <GSMarkupCoding> object;
  NSString *idName = nil;

  [tag finalizeStrings];
  
  if (_isInsideObjects)
    {
      tagClass = [self objectClassForTagName: tagName];
    }
  else
    {
      tagClass = [self connectorClassForTagName: tagName];
    }
  
  
  if (tagClass == Nil)
    {
      /* Unknown tag ... ignore for future compatibility, but issue
       * a warning anyway.  */
      NSString *s;
      s = [NSString stringWithFormat: @"Unknown tag <%@> - ignored", tagName];
      [self warning: s];
      return;
    }
  
  object = (id <GSMarkupCoding>) [tagClass alloc];
  
  if (object == nil)
    {
      NSString *s;
      s = [NSString stringWithFormat:
		      @"Could not alloc object from tag <%@> - ignored", 
		    tagName];
      [self warning: s];
      return;
    }

  /* Inside <objects> we turn on special machinery to store id names
   * of objects, and build up connections when we find
   * cross-references.  This machinery is useless and wrong inside
   * <connections>.  */
  if (_isInsideObjects)
    {
      NSMutableDictionary *attributes;

      /* Make a mutable copy of the attributes - we're going to mess
       * them up.  */
      attributes = [[tag attributes] mutableCopy];
      AUTORELEASE (attributes);
      ASSIGN (idName, [attributes objectForKey: @"id"]);
      if (idName != nil)
	{
	  [attributes removeObjectForKey: @"id"];
	  /* As a safeguard, if the id contains a dot (which it should
	   * not), ignore the dot, and everything after the dot.  */
	  {
	    NSRange r = [idName rangeOfString: @"."];
	    
	    if (r.location != NSNotFound)
	      {
		NSLog (@"Warning - id `%@' contains a dot!", idName);
		ASSIGN (idName, [idName substringToIndex: r.location]);
	      }
	  }
	}
      
      /* Now loop on the attributes, looking for attributes with a '#'
       * value - those attributes are automatically replaced by a
       * GSMarkupOutletConnector - the # value really is a link to another
       * object.  */
      {
	/* Don't use an enumerator because we want to modify the attributes
	 * along the way.  */
	NSArray *keys = [attributes allKeys];
	int i, count = [keys count];
	
	for (i = 0; i < count; i++)
	  {
	    NSString *key, *value;
	    
	    key = [keys objectAtIndex: i];
	    value = [attributes objectForKey: key];

	    if ([value hasPrefix: @"#"])
	      {
		if ([value hasPrefix: @"##"])
		  {
		    /* A leading doubled '#' is an escape sequence,
		     * so we must replace the value with a version in
		     * which the * escape character has been removed.
		     */
		    [attributes setObject: [value substringFromIndex: 1]
				   forKey: key];
		  }
		else
		  {
		    GSMarkupOutletConnector *outlet;

		    /* If we don't have an idName, invent one on
		     * purpose.  */
		    if (idName == nil)
		      {
			NSString *generatedIdName;
			
			generatedIdName = [NSString stringWithFormat: @"%@%d", 
						    tagName, _idNameCount];
			ASSIGN (idName, generatedIdName);
			_idNameCount++;
		      }
		    
		    /* We pass the value unchanged to the outlet.  If
		     * value contains a key value path using dots, those
		     * will be processed by the outlet when it is
		     * established.  */
		    outlet = [[GSMarkupOutletConnector alloc] 
			       initWithSource: idName
			       target: value
			       label: key];
		    [_connectors addObject: outlet];
		    RELEASE (outlet);
		    
		    /* Hide the attribute - it has been already processed.  */
		    [attributes removeObjectForKey: key];
		  }
	      }
	  }
      }
      object = [object initWithAttributes: attributes  content: [tag content]];
    }
  else
    {
      object = [object initWithAttributes: [tag attributes]  
		       content: [tag content]];
    }

  if (object == nil)
    {
      NSString *s;
      s = [NSString stringWithFormat:
		      @"Could not init object from tag <%@> - ignored", 
		    tagName];
      [self warning: s];
      TEST_RELEASE (idName);
      return;
    }
  
  if (idName != nil)
    {
      [_nameTable setObject: object  forKey: idName];
      RELEASE (idName);
    }
  
  if ([_stack count] > 0)
    {
      [(GSMarkupTag *)[_stack lastObject] addObjectToContent: object];
    }
  else
    {
      if (_isInsideObjects)
	{
	  [_objects addObject: object];
	}
      else if (_isInsideConnectors)
	{
	  [_connectors addObject: object];
	}
      else
	{
	  /* This would be very puzzling, since it should have been caught
	   * by the startElement: routine!  */
	  NSString *s;
	  s = [NSString stringWithFormat: 
			  @"End tag </%@> outside <objects> or <connectors>",
			tagName];
	  [self warning: s];
	}
    }
  
  RELEASE (object);
}


- (void) foundFreeString: (NSString*) name
{    
  /* The XML parser is expected to preserve all whitespaces, newlines
   * etc.  We will need to strip them all away!  */

  /* Free strings inside the contents are simply added as 
   * NSString objects to the content of the parent tag.  */
  if ([_stack count] > 0)
    {
      /* The object will store the string.  When the object is finalized,
       * it will strip all whitespaces, newlines in excess.
       */
      [(GSMarkupTag *)[_stack lastObject] addStringToContent: name];
    }
  else
    {
      /* This is Ok if the string is really empty.  */
      NSString *trimmed = [name stringByTrimmingCharactersInSet:
				  whitespaceAndNewline];

      if (![trimmed isEqualToString: @""])
	{
	  NSString *s;
	  
	  s = [NSString stringWithFormat: @"Free string '%@' outside a tag!",
			trimmed];
	  [self warning: s];
	}
    }
}

- (void) warning: (NSString *)problem
{
  NSLog (@"Warning: %@", problem);
}

- (void) error: (NSString *)problem
{
  NSLog (@"Error: %@", problem);
}

- (Class) objectClassForTagName: (NSString *)tagName
{
  NSString *capitalizedTagName;
  NSString *className;
  Class c;

  className = [_tagNameToObjectClass objectForKey: tagName];
  
  if (className != nil)
    {
      c = NSClassFromString (className);
      if (c != Nil)
	{
	  return c;
	}
    }

  capitalizedTagName = [tagName stringByUppercasingFirstCharacter];

  className = [NSString stringWithFormat: @"GSMarkup%@Tag", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"GSMarkupTag%@", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"GS%@Tag", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"GSTag%@", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"%@Tag", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"Tag%@", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  /* Not found ... ignore the tag.  */
  return Nil;
}

- (Class) connectorClassForTagName: (NSString *)tagName
{
  NSString *capitalizedTagName;
  NSString *className;
  Class c;

  className = [_tagNameToConnectorClass objectForKey: tagName];
  
  if (className != nil)
    {
      c = NSClassFromString (className);
      if (c != Nil)
	{
	  return c;
	}
    }

  switch ([tagName characterAtIndex: 0])
    {
    case 'c':
      if ([tagName isEqualToString: @"control"])
	{
	  return [GSMarkupControlConnector class];
	}
      break;
    case 'o':
      if ([tagName isEqualToString: @"outlet"])
	{
	  return [GSMarkupOutletConnector class];
	}
      break;
    }

  capitalizedTagName = [tagName stringByUppercasingFirstCharacter];

  className = [NSString stringWithFormat: @"GSMarkup%@Connector", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"GSMarkupConnector%@", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"GS%@Connector", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"GSConnector%@", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"%@Connector", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }

  className = [NSString stringWithFormat: @"Connector%@", capitalizedTagName];
  c = NSClassFromString (className);
  if (c != Nil)
    {
      return c;
    }


  /* Ignore the connector ! */
  return Nil;
}

- (void) setObjectClass: (NSString *)className
	     forTagName: (NSString *)tagName
{
  [_tagNameToObjectClass setObject: className  forKey: tagName];
}


- (void) setConnectorClass: (NSString *)className
		forTagName: (NSString *)tagName
{
  [_tagNameToConnectorClass setObject: className  forKey: tagName];
}


- (NSArray *) objects
{
  return _objects;
}

- (NSArray *) connectors
{
  return _connectors;
}

- (NSDictionary *) nameTable
{
  return _nameTable;
}

@end

