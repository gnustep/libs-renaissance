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
 * the backend SAX parser.  At the moment we have support for three
 * separate backends: a GSXML (gnustep-base's XML package) backend, a
 * CFXML (CoreFoundation's XML services) backend, and a pure libxml2
 * (GNOME XML library) backed.  To implement a backend you basically
 * need to implement is basically a new subclass of
 * GSMarkupDecoderBackend: no need to touch the more high level
 * classes.  This class basically builds and manages the backend SAX
 * parser, and creates a backend-specific SAX handler which receives
 * the calls from the backend SAX parser, in the way specific to this
 * backend parser.  The backend SAX handler interprets the calls, and
 * reissues them to the GSMarkupDecoder in the normalized form
 * expected by it.
 */

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include "GNUstep.h"
/* On Apple Mac OSX, use CoreFoundation XML backend.  */
# define GSMARKUP_CFXML_BACKEND
#else
# include <Foundation/NSObject.h>
/* On GNUstep, use gnustep-base's GSXML backend.  */
# define GSMARKUP_GSXML_BACKEND
#endif

/* The libxml2 backend will be used on OpenStep 4.x; if you want to
 * use it on GNUstep or Apple Mac OS X, uncomment the following lines
 * (you might then need to add manually the proper include/library
 * flags if you installed libxml2 in a custom location, which is why
 * it's simpler to use CFXML or GSXML).  */

/*
#undef GSMARKUP_CFXML_BACKEND
#undef GSMARKUP_GSXML_BACKEND
#define GSMARKUP_LIBXML_BACKEND
*/

/* The backend object is created by calling the function
 * GSMarkupDecoderBackendForReadingFromData, which each backend
 * implementation implements to return an object of its own
 * GSMarkupDecoderBackend subclass.  The return object should be ready
 * to start parsing when its 'parse' method is called.  During
 * parsing, the platform-specific SAX parser will likely call private
 * callbacks in the backend class implementation, which should be
 * normalized/filtered by the backend class implementation, and handed
 * over to GSMarkupDecoder, by calling the few methods described in
 * GSMarkupDecoder.h for this purpose.
 */

@class NSObject;
@class NSData;
@class GSMarkupDecoder;

@interface GSMarkupDecoderBackend : NSObject
/* The following method will do the parsing; the actual implementation
 * is in the private subclass.
 */
- (void) parse;
@end

/* The following creates a GSMarkupDecoderBackend object (or more
 * likely an object of a private subclass), ready to parse `data' and
 * to send normalized SAX calls to `decoder'.  Each concrete backend
 * implementation will implement it differently, to return an object
 * of a different subclass of GSMarkupDecoderBackend.
 */
GSMarkupDecoderBackend *
GSMarkupDecoderBackendForReadingFromData (NSData *data, 
					  GSMarkupDecoder *decoder);

#endif /* _GNUstep_H_GSMarkupDecoderBackend */
