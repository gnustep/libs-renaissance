/* -*-objc-*-
   GSMarkupDecoderBackendCFXML.m
   A CFXML (CoreFoundation XML) XML backend for Renaissance.

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

#include <CoreFoundation/CFXMLNode.h>
#include <CoreFoundation/CFXMLParser.h>

/* Important: this backend does not support replacement of entities
 * such as &lt;.  You should use the NSXML backend instead.
 */

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
	/* Copy, as the CFXML library will reuse the string.  */
	text = AUTORELEASE ([text copy]);
	[decoder foundFreeString: text];

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

@interface GSMarkupDecoderBackendCFXML : GSMarkupDecoderBackend
{
  CFXMLParserRef parser;
}
- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder;
@end

@implementation GSMarkupDecoderBackendCFXML

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

GSMarkupDecoderBackend *
GSMarkupDecoderBackendForReadingFromData (NSData *data, 
					  GSMarkupDecoder *decoder)
{
  GSMarkupDecoderBackendCFXML *b;
  
  b = [[GSMarkupDecoderBackendCFXML alloc] initForReadingFromData: data
					   withDecoder: decoder];
  AUTORELEASE (b);
  
  return b;  
}

