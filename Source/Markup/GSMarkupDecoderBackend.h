/* -*-objc-*-
   GSMarkupDecoderBackend.h

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

#ifndef _GNUstep_H_GSMarkupDecoderBackend
#define _GNUstep_H_GSMarkupDecoderBackend

/* This class specifically mediates between the GSMarkupDecoder and
 * the backend SAX parser.  At the moment we have support for two
 * separate backends: a GSXML (gnustep-base's XML package) backend,
 * and a CFXML (CoreFoundation's XML services) backend.  Adding a
 * different backend SAX parser should be a matter of
 * modifying/reimplementing this class - no need to touch the more
 * high level classes.  This class basically builds and manages the
 * backend SAX parser, and creates a backend-specific SAX handler
 * which receives the calls from the backend SAX parser, in the way
 * specific to this backend parser.  The backend SAX handler
 * interprets the calls, and reissues them to the GSMarkupDecoder in
 * the normalized form expected by it.  
 */

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
/* Use Apple OSX's CoreFoundation XML backend.  */
# define GSMARKUP_CFXML_BACKEND
#else
# include <Foundation/NSObject.h>
/* Use gnustep-base's GSXML backend.  */
# define GSMARKUP_GSXML_BACKEND
#endif

@class NSObject;
@class NSData;
@class GSMarkupDecoder;
#ifdef GSMARKUP_GSXML_BACKEND
@class GSXMLParser;
#else
# ifdef GSMARKUP_CFXML_BACKEND
# include <CoreFoundation/CFXMLParser.h>
# endif
#endif

@interface GSMarkupDecoderBackend : NSObject
{
#ifdef GSMARKUP_GSXML_BACKEND
  GSXMLParser *parser;
#else
# ifdef GSMARKUP_CFXML_BACKEND
  CFXMLParserRef parser;  
# endif
#endif
}

/* The backend class should implement the following methods to setup
 * and start the parsing.  When parsing is going on, the
 * platform-specific SAX parser will call private callbacks in the
 * backend class implementation, which should be normalized/filtered
 * by the backend class implementation, and handed over to
 * GSMarkupDecoder, by calling the few methods described in
 * GSMarkupDecoder.h for this purpose.
 */

+ (id) backendForReadingFromData: (NSData *)data
		     withDecoder: (GSMarkupDecoder *)decoder;

- (id) initForReadingFromData: (NSData *)data
		  withDecoder: (GSMarkupDecoder *)decoder;

- (void) parse;
@end

#endif /* _GNUstep_H_GSMarkupDecoderBackend */
