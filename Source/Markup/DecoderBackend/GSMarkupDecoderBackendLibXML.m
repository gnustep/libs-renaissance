/* -*-objc-*-
   GSMarkupDecoderBackendLibXML.m
   A libxml (GNOME XML library) XML backend for Renaissance.

   Copyright (C) 2003 Free Software Foundation, Inc.

   Author: Pete French
   Date: January 2003
   Modifications by: Nicola Pero.
   
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
 * This file implements the libxml-based backend.
 * To be used with libxml.
 */

#ifdef GNUSTEP
# include <Foundation/NSData.h>
# include <Foundation/NSDictionary.h>
# include <Foundation/NSString.h>
#else
# include <Foundation/Foundation.h>
#endif

#include <libxml/SAX.h>
#include <libxml/parser.h>

/*
 * This implementation uses the libxml2 library directly. It is
 * designed for use on systems with no native Objective-C XML parser,
 * such as the original OpenStep implementations. As such it also
 * takes great care to only use the OpenStep methods available on the
 * older systems, so that it is as portable as possible.
 *
 * -Pete French. 12/02/2003
 */

/*
 * This function returns an autorelease NSString from the UTF-8 data
 * passed to it. We need this function as the handy UTF-8 methods
 * provided by OSX were not present in the original OpenStep spec, on
 * which this code is intended to run.
 */
 
static NSString *
stringFromUTF8 (const char *utf8)
{
  NSData *unicodeData = [[NSData alloc] initWithBytes: utf8
					length: strlen (utf8)];
  NSString *theString = [[NSString alloc] initWithData: unicodeData
					  encoding: NSUTF8StringEncoding];
  RELEASE (unicodeData);
  AUTORELEASE (theString);
  return theString;
}

/*
 * These are the parsing functions, based on the set for
 * GSMarkupSAXHandler supplied in GSMarkupDecoderBackendGSXML.
 */

static int
saxIsStandalone (void *ctx)
{
  return 1;
}
 
static void
saxStartElement (void *ctx, const xmlChar *name, const xmlChar **atts)
{
  GSMarkupDecoder *decoder = (GSMarkupDecoder*)ctx;
  NSMutableDictionary *theAttributes = [NSMutableDictionary new];
  
  while (atts && *atts)
    {
      const char *attName, *attValue;
      
      /* get the name and value, break on odd number */
      attName = *atts;
      atts++;
      if (!*atts)
	break;
      attValue = *atts;
      atts++;
      
      /* convert to strings and set */
      [theAttributes setObject: stringFromUTF8 (attValue)
		     forKey: stringFromUTF8 (attName)];
    }
  
  [decoder foundStartElement: stringFromUTF8 (name)
	   withAttributes: theAttributes];
  RELEASE (theAttributes);
}
 
static void
saxEndElement (void *ctx, const xmlChar *name)
{
  GSMarkupDecoder *decoder = (GSMarkupDecoder*)ctx;
  [decoder foundEndElement: stringFromUTF8 (name)];
}

static void
saxCharacters (void *ctx, const xmlChar *ch, int len)
{
  GSMarkupDecoder *decoder = (GSMarkupDecoder*)ctx;
  NSData *unicodeData = [[NSData alloc] initWithBytes: ch
					length: len];
  NSString *theString = [[NSString alloc] initWithData: unicodeData
					  encoding: NSUTF8StringEncoding];
  RELEASE (unicodeData);
  AUTORELEASE(theString);
  [decoder foundFreeString: theString];
}

static int
saxHasInternalSubset (void *ctx)
{
  return 0;
}
 
static int
saxHasExternalSubset (void *ctx)
{
  return 0;
}

static void
saxWarning (void *ctx, const char *msg, ...)
{
  NSString *theString;
  va_list ap;
  
  va_start (ap, msg);
  theString = [[NSString alloc] initWithFormat: stringFromUTF8 (msg)
				arguments: ap];
  NSLog (@"XML DecoderBackend Warning: %@", theString);
  RELEASE (theString);
}

static void
saxError (void *ctx, const char *msg, ...)
{
  NSString *theString;
  va_list ap;
  
  va_start (ap, msg);
  theString = [[NSString alloc] initWithFormat: stringFromUTF8 (msg)
				arguments: ap];
  NSLog (@"XML DecoderBackend Error: %@", theString);
  RELEASE (theString);
}
 
static void
saxFatalError (void *ctx, const char *msg, ...)
{
  NSString *theString;
  va_list ap;
  
  va_start (ap, msg);
  theString = [[NSString alloc] initWithFormat: stringFromUTF8 (msg)
				arguments: ap];
  NSLog (@"XML DecoderBackend Fatal Error: %@", theString);
  RELEASE (theString);
}
 

/* The private subclass we actually use.  */
@interface GSMarkupDecoderBackendLibXML : GSMarkupDecoderBackend
{
  NSData *theData;
  GSMarkupDecoder *theDecoder;
}
- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder;
@end

@implementation GSMarkupDecoderBackendLibXML
- (id) initForReadingFromData: (NSData *)data
 		  withDecoder: (GSMarkupDecoder *)decoder
{
  ASSIGN (theData, data);
  theDecoder = decoder;	/* assume we do not need to retain it */
  return self;
}
 
- (void)dealloc
{
  RELEASE (theData);
  [super dealloc];
}

/*
 * All the heavy work is done here. We set up the SAX structure with
 * appropriate callback functions, the parse with the decoder as the
 * user data. This will allow method calls on the object from within
 * the handling functions.
 */
- (void)parse
{
  xmlParserCtxtPtr ctxt;
  xmlSAXHandler theHandler = { NULL };	/* all NULL initially */
  int value;
  
  /* setup the callbacks */
  theHandler.isStandalone = saxIsStandalone;
  theHandler.startElement = saxStartElement;
  theHandler.endElement = saxEndElement;
  theHandler.characters = saxCharacters;
  theHandler.hasInternalSubset = saxHasInternalSubset;
  theHandler.hasExternalSubset = saxHasExternalSubset;
  theHandler.warning = saxWarning;
  theHandler.error = saxError;
  theHandler.fatalError = saxFatalError;

  ctxt = xmlCreatePushParserCtxt (&theHandler, (void *)theDecoder,
				  [theData bytes], [theData length],
				  NULL);
  if (ctxt == NULL)
    {
      NSLog (@"Failed to create xmlParserCtxt");
      return;
    }

  /* Make sure the features we want are set.  */
  value = 0;
  xmlSetFeature (ctxt, "validity checking", (void *)&value);
  value = 1;
  xmlSetFeature (ctxt, "get warnings", (void *)&value);
  value = 1;
  xmlSetFeature (ctxt, "substitute entities", (void *)&value);

  xmlParseDocument (ctxt);
  xmlFreeParserCtxt (ctxt);
}

@end

GSMarkupDecoderBackend *
GSMarkupDecoderBackendForReadingFromData (NSData *data, 
					  GSMarkupDecoder *decoder)
{
  GSMarkupDecoderBackendLibXML *b;
  
  b = [[GSMarkupDecoderBackendLibXML alloc] initForReadingFromData: data
					    withDecoder: decoder];
  AUTORELEASE (b);
  
  return b;  
}

