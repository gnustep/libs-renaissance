/* -*-objc-*-
   GSMarkupCoding.h

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

#ifndef _GNUstep_H_GSMarkupCoding
#define _GNUstep_H_GSMarkupCoding

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSObject.h>
#endif

@class NSArray;
@class NSDictionary;

/* The more general protocol interface ... objects implementing this
 * interface can be encoded/decoded from XML files using our XML
 * encoder/decoder.
 *
 * The coding/decoding is just the technique we use to implement an
 * XML parser/XML generator which reads our GSMarkup format.  For each tag
 * in the GSMarkup format (the format is flexible) there must be a class
 * able to read/write that tag.  When we parse the GSMarkup file, we
 * produce a parse tree of objects obtained by decoding the objects
 * from the XML; to generate GSMarkup output, we create a parse tree of
 * objects, then encode the objects.
 *
 * You should really think to this as an OO way of implementing an
 * extensible and powerful XML parser/generator -- not as a way to
 * encode/decode generic objects to disk, because this does *not*
 * encode/decode generic objects to disk.  This encode/decode objects
 * representing tags.  If your XML format is well designed, you can
 * map the web of tags in an XML file into a useful web of objects.
 * This is what we want to do with .gsmarkup files, in which we map
 * tags to 'logic' objects (as opposed to 'platform' objects), which
 * contain the logic of the gui interface and are able to instantiate
 * and manage a corresponding web of platform objects representing the
 * actual interface.  We can't encode/decode the platform objects
 * because they contain different information than the one we want to
 * encode/decode ... they contain a lot of information we don't need
 * and don't want (such as platform specific graphical details), and
 * from time to time they miss some information we need and want
 * (information which describes the logic of how to generate the
 * objects rather than the actual objects which were generated on that
 * platform).
 */
@protocol GSMarkupCoding <NSObject>

/* This is used when encoding to decide which tag to use for this
 * class.  */
+ (NSString *) tagName;

/* This is used to create the object from an XML tag, with the
 * specified attributes, and the specified content (an array of other
 * objects which have been decoded from the XML content of the
 * tag).  This method is used when decoding.  */
- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content;

/* This returns the attributes to use for generating XML.  Should
 * return a dictionary mapping strings to strings.  The key 'id' is
 * not allowed in this dictionary; values should normally be strings
 * not beginning with hash (#).  FIXME: values which are objects, and
 * are replaced by the object's name in the name table might be
 * allowed ...  This method is used when coding.
 */
- (NSDictionary *) attributes;

/* This return an array of objects conforming to the GSMarkupCoding
 * protocol, which are encoded in the order inside the XML start/end
 * tags for this object.  Typically, subviews or other objects which
 * logically are inside this object are stored in here.  This method
 * is used when coding.  */
- (NSArray *) content;
@end

#endif /* _GNUstep_H_GSMarkupCoding */
