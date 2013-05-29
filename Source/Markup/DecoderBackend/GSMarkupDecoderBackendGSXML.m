/* -*-objc-*-
   GSMarkupDecoderBackendGSXML.m
   A GSXML (GNUstep XML) XML backend for Renaissance.

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March 2002, November 2002

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

/*
 * This file implements the GSXML-based backend.
 * To be used with gnustep-base's GSXML support.
 */

#include <Foundation/NSData.h>
#include <GNUstepBase/GSXML.h>

@interface GSMarkupSAXHandler : GSSAXHandler
{
  GSMarkupDecoder *decoder;
}
- (id) initWithDecoder: (GSMarkupDecoder *)d;
@end

@implementation GSMarkupSAXHandler : GSSAXHandler
- (id) initWithDecoder: (GSMarkupDecoder *)d
{
  /* The decoder is RETAINing us, we should not RETAIN it.  */
  decoder = d;
  return [super init];
}

/* Most of the following stuff is included just to make sure you
 * understand we parse and ignore all the complicated XML crap, and
 * only read simple XML tags (start tag, end tag) with their
 * attributes, and their contents (plain characters or other
 * tags).  */
- (void) startDocument
{}

- (void) endDocument
{}

- (NSInteger) isStandalone
{
  return 1;
}

- (void) startElement: (NSString*)elementName
	   attributes: (NSMutableDictionary*)elementAttributes
{
  [decoder foundStartElement: elementName
	   withAttributes: elementAttributes];
}

- (void) endElement: (NSString*) elementName
{
  [decoder foundEndElement: elementName];
}

- (void) attribute: (NSString*) name value: (NSString*)value
{}

- (void) characters: (NSString*) name
{
  [decoder foundFreeString: name];
}

- (void) ignoreWhitespace: (NSString*) ch
{}

- (void) processInstruction: (NSString*)targetName  data: (NSString*)PIdata
{}

- (void) comment: (NSString*) value
{}

- (void) cdataBlock: (NSData*)value
{}

- (NSString*) loadEntity: (NSString*)publicId
		      at: (NSString*)location
{
  return nil;
}

- (void) namespaceDecl: (NSString*)name
		  href: (NSString*)href
		prefix: (NSString*)prefix
{}

- (void) notationDecl: (NSString*)name
	       public: (NSString*)publicId
	       system: (NSString*)systemId
{}

- (void) entityDecl: (NSString*)name
	       type: (NSInteger)type
	     public: (NSString*)publicId
	     system: (NSString*)systemId
	    content: (NSString*)content
{}

- (void) attributeDecl: (NSString*)nameElement
	 nameAttribute: (NSString*)name
	    entityType: (NSInteger)type
	  typeDefValue: (NSInteger)defType
	  defaultValue: (NSString*)value
{}

- (void) elementDecl: (NSString*)name
		type: (NSInteger)type
{}

- (void) unparsedEntityDecl: (NSString*)name
	       publicEntity: (NSString*)publicId
	       systemEntity: (NSString*)systemId
	       notationName: (NSString*)notation
{}

- (void) reference: (NSString*) name
{}

- (void) globalNamespace: (NSString*)name
		    href: (NSString*)href
		  prefix: (NSString*)prefix
{}

- (void) warning: (NSString*)e
       colNumber: (NSInteger)colNumber
      lineNumber: (NSInteger)lineNumber
{
  NSLog (@"XML DecoderBackend Warning: %@, col: %"PRIiPTR", line: %"PRIiPTR, 
	 e, colNumber, lineNumber);
}

- (void) error: (NSString*)e
     colNumber: (NSInteger)colNumber
    lineNumber: (NSInteger)lineNumber
{
  NSLog (@"XML DecoderBackend Error: %@, col: %"PRIiPTR", line: %"PRIiPTR, 
	 e, colNumber, lineNumber);
}

- (void) fatalError: (NSString*)e
       colNumber: (NSInteger)colNumber
      lineNumber: (NSInteger)lineNumber
{
  NSLog (@"XML DecoderBackend Fatal Error: %@, col: %"PRIiPTR", line: %"PRIiPTR, 
	 e, colNumber, lineNumber);
}

- (NSInteger) hasInternalSubset
{
  return 0;
}

- (BOOL) internalSubset: (NSString*)name
	     externalID: (NSString*)externalID
	       systemID: (NSString*)systemID
{
  return NO;
}

- (NSInteger) hasExternalSubset
{
  return 0;
}

- (BOOL) externalSubset: (NSString*)name
	     externalID: (NSString*)externalID
	       systemID: (NSString*)systemID
{
  return NO;
}

- (void*) getEntity: (NSString*)name
{
  return 0;
}

- (void*) getParameterEntity: (NSString*)name
{
  return 0;
}
@end

/* The private subclass we actually use.  */
@interface GSMarkupDecoderBackendGSXML : GSMarkupDecoderBackend
{
  GSXMLParser *parser;
}
- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder;
@end

@implementation GSMarkupDecoderBackendGSXML
- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder
{
  GSMarkupSAXHandler *handler;
  
  handler = [[GSMarkupSAXHandler alloc] initWithDecoder: decoder];
  
  ASSIGN (parser, [GSXMLParser parserWithSAXHandler: handler
					   withData: data]);
  RELEASE (handler);
  [parser doValidityChecking: NO];
  [parser getWarnings: YES];
  [parser substituteEntities: YES];
  return self;
}

- (void) dealloc
{
  RELEASE (parser);
  [super dealloc];
}

- (void) parse
{
  [parser parse];
}

@end

GSMarkupDecoderBackend *
GSMarkupDecoderBackendForReadingFromData (NSData *data, 
					  GSMarkupDecoder *decoder)
{
  GSMarkupDecoderBackendGSXML *b;
  
  b = [[GSMarkupDecoderBackendGSXML alloc] initForReadingFromData: data
					   withDecoder: decoder];
  AUTORELEASE (b);
  
  return b;  
}

