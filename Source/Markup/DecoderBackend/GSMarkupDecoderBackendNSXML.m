/* -*-objc-*-
   GSMarkupDecoderBackendNSXML.m
   A NSXML (new-style Foundation XML parser) XML backend for Renaissance.

   Copyright (C) 2008 Free Software Foundation, Inc.

   Author: Nicola Pero <nicola.pero@meta-innovation.com>
   Date: March 2008

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
 * This file implements the NSXML-based backend.
 * To be used with gnustep-base's or Apple Mac OS X's NSXML support.
 */

#include <Foundation/Foundation.h>

/* The private subclass we actually use.  */
@interface GSMarkupDecoderBackendNSXML : GSMarkupDecoderBackend
{
  NSXMLParser *_parser;
  GSMarkupDecoder *_decoder;
}
- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder;
@end

@implementation GSMarkupDecoderBackendNSXML
- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder
{
  /* The decoder is RETAINing us, we should not RETAIN it.  */
  _decoder = decoder;

  ASSIGN (_parser, [[NSXMLParser alloc] initWithData: data]);
  [_parser setDelegate: self];
  [_parser setShouldProcessNamespaces: NO];
  [_parser setShouldReportNamespacePrefixes: NO];
  [_parser setShouldResolveExternalEntities: NO];

  return self;
}

- (void) dealloc
{
  RELEASE (_parser);
  [super dealloc];
}

- (void) parse
{
  [_parser parse];
}

- (void) parser: (NSXMLParser *)parser
didStartElement: (NSString *)elementName 
   namespaceURI: (NSString *)unused
  qualifiedName: (NSString *)unused2
     attributes: (NSDictionary *)elementAttributes
{
  [_decoder foundStartElement: elementName
	    withAttributes: elementAttributes];
}

- (void) parser: (NSXMLParser *)parser
  didEndElement: (NSString *)elementName
   namespaceURI: (NSString *)unused
  qualifiedName: (NSString *)unused2
{
  [_decoder foundEndElement: elementName];
}

- (void) parser: (NSXMLParser *)parser
parseErrorOccurred: (NSError *)e
{
  NSLog (@"XML DecoderBackend Fatal Error: %@, col: %d, line: %d", 
	 e, [parser columnNumber], [parser lineNumber]);
}

- (void) parser: (NSXMLParser *)parser
foundCharacters: (NSString *)characters
{
  [_decoder foundFreeString: characters];
}
@end

GSMarkupDecoderBackend *
GSMarkupDecoderBackendForReadingFromData (NSData *data, 
					  GSMarkupDecoder *decoder)
{
  GSMarkupDecoderBackendNSXML *b;
  
  b = [[GSMarkupDecoderBackendNSXML alloc] initForReadingFromData: data
					   withDecoder: decoder];
  AUTORELEASE (b);
  
  return b;  
}

