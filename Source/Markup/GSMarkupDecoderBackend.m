/* -*-objc-*-
   GSMarkupDecoderBackend.m

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

#include <GSMarkupDecoderBackend.h>
#include <GSMarkupDecoder.h>

/*
 * This file contains different implementations for the different
 * platforms.  Only one of them is actually used.  They are all in a
 * single file which is always compiled so that it's easier to import
 * the source code into alien project building systems.  The backend
 * to use is chosen in GSMarkupDecoderBackend.h.
 */

/*
 * The GSXML-based backend.
 * To be used with gnustep-base's GSXML support.
 */
#ifdef GSMARKUP_GSXML_BACKEND

#include <Foundation/NSData.h>
#include <Foundation/GSXML.h>

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

- (int) isStandalone
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
  NSString *trimmed = [name stringByTrimmingSpaces];
  
  if (![trimmed isEqualToString: @""])
    {
      [decoder foundFreeString: trimmed];
    }
}

- (void) ignoreWhitespace: (NSString*) ch
{}

- (void) processInstruction: (NSString*)targetName  data: (NSString*)PIdata
{}

- (void) comment: (NSString*) value
{}

- (void) cdataBlock: (NSString*)value
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
	       type: (int)type
	     public: (NSString*)publicId
	     system: (NSString*)systemId
	    content: (NSString*)content
{}

- (void) attributeDecl: (NSString*)nameElement
	 nameAttribute: (NSString*)name
	    entityType: (int)type
	  typeDefValue: (int)defType
	  defaultValue: (NSString*)value
{}

- (void) elementDecl: (NSString*)name
		type: (int)type
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
       colNumber: (int)colNumber
      lineNumber: (int)lineNumber
{
  NSLog (@"XML DecoderBackend Warning: %@, col: %d, line: %d", 
	 e, colNumber, lineNumber);
}

- (void) error: (NSString*)e
     colNumber: (int)colNumber
    lineNumber: (int)lineNumber
{
  NSLog (@"XML DecoderBackend Error: %@, col: %d, line: %d", 
	 e, colNumber, lineNumber);
}

- (void) fatalError: (NSString*)e
       colNumber: (int)colNumber
      lineNumber: (int)lineNumber
{
  NSLog (@"XML DecoderBackend Fatal Error: %@, col: %d, line: %d", 
	 e, colNumber, lineNumber);
}

- (int) hasInternalSubset
{
  return 0;
}

- (BOOL) internalSubset: (NSString*)name
	     externalID: (NSString*)externalID
	       systemID: (NSString*)systemID
{
  return NO;
}

- (int) hasExternalSubset
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

@implementation GSMarkupDecoderBackend

+ (id) backendForReadingFromData: (NSData *)data
		     withDecoder: (GSMarkupDecoder *)decoder
{
  GSMarkupDecoderBackend *b;
  
  b = [[self alloc] initForReadingFromData: data  withDecoder: decoder];
  AUTORELEASE (b);

  return b;
}

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

#else

# ifdef GSMARKUP_CFXML_BACKEND

# include <CoreFoundation/CFXMLNode.h>
# include <CoreFoundation/CFXMLParser.h>

static void *GSMarkupCreateStructure
(CFXMLParserRef parser, CFXMLNodeRef node, void *info)
{
  GSMarkupDecoder *decoder = info;
  
  switch (CFXMLNodeGetTypeCode (node))
    {
    case kCFXMLNodeTypeElement:
      {
        NSString *name = (NSString *)(CFXMLNodeGetString (node));
        NSDictionary *attributes;
        attributes 
	  = (NSDictionary *)
	  (((CFXMLElementInfo *)(CFXMLNodeGetInfoPtr (node)))->attributes);
    
	
        /* This stuff must be copied (see doc, apparently this stuff
         * can't be simply retained because the library is changing it
         * in some weird way for efficiency).
         */
        name = AUTORELEASE ([name copy]);
        attributes = AUTORELEASE ([attributes copy]);
        [decoder foundStartElement: name  withAttributes: attributes];
        return name;
      }
    case kCFXMLNodeTypeText:
      {
        NSString *text = (NSString *)(CFXMLNodeGetString (node));
        text = [text stringByTrimmingCharactersInSet:
		       [NSCharacterSet whitespaceCharacterSet]];
	
        if (![text isEqualToString: @""])
	  {
	    [decoder foundFreeString: text];
	  }
        return NULL;
      }
    case kCFXMLNodeTypeDocument:
    case kCFXMLNodeTypeCDATASection:
    case kCFXMLNodeTypeProcessingInstruction:
    case kCFXMLNodeTypeComment:
    case kCFXMLNodeTypeEntityReference:
    case kCFXMLNodeTypeDocumentType:
    case kCFXMLNodeTypeWhitespace:
    default:
      break;
    }
  
  return NULL;
}

static void GSMarkupAddChild
(CFXMLParserRef parser, void *parent,
void *child, void *info)
{}

static void GSMarkupEndStructure
(CFXMLParserRef parser, void *xmlType, void *info)
{
  NSString *name = (NSString *)xmlType;
  GSMarkupDecoder *decoder = info;

 [decoder foundEndElement: name];
}

static CFDataRef GSMarkupResolveEntity
(CFXMLParserRef parser, CFXMLExternalID *extID, void *info)
{
  /* We want entities to be never resolved */
  return NULL;
}

Boolean GSMarkupHandleError
(CFXMLParserRef parser, CFXMLParserStatusCode error, void *info)
{
  NSString *description = (NSString *)
    (CFXMLParserCopyErrorDescription (parser));
  int lineNumber = (int)CFXMLParserGetLineNumber (parser);
  int location = (int)CFXMLParserGetLocation (parser);
  
  NSLog (@"XML DecoderBackend Fatal Error: %@, line: %d, location: %d",
         description, lineNumber, location);
  
  RELEASE (description);
  return FALSE;
}

@implementation GSMarkupDecoderBackend

+ (id) backendForReadingFromData: (NSData *)data
		     withDecoder: (GSMarkupDecoder *)decoder
{
  GSMarkupDecoderBackend *b;
  
  b = [[self alloc] initForReadingFromData: data  withDecoder: decoder];
  AUTORELEASE (b);

  return b;
}

- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder
{
  CFXMLParserCallBacks GSMarkupCallbacks = {0, GSMarkupCreateStructure,
					    GSMarkupAddChild, 
					    GSMarkupEndStructure, 
					    GSMarkupResolveEntity,
					    GSMarkupHandleError};
  /* We do not retain the decoder pointer here in the assumption that
   * decoder is owning us.  */
  CFXMLParserContext GSMarkupParserContext = {0, decoder, NULL, NULL, NULL};

  parser = CFXMLParserCreate (kCFAllocatorDefault, (CFDataRef)(data), NULL,
                              (kCFXMLParserSkipMetaData 
			       & kCFXMLParserReplacePhysicalEntities 
			       & kCFXMLParserSkipWhitespace),
                              kCFXMLNodeCurrentVersion,
                              &GSMarkupCallbacks,
                              &GSMarkupParserContext);
  return self;
}

- (void) dealloc
{
  CFRelease (parser);
  parser = NULL;
  [super dealloc];
}

- (void) parse
{
  /* NB: in theory, we need to lock the parsing, because a single
     parsing can be done at a time (see CFXML doc).  This should not
     be a problem for now. :-) */
  CFXMLParserParse (parser);
}

@end

# endif /* GSMARKUP_CFXML_BACKEND */

#endif
