/* -*-objc-*-
   GSMarkupConnector.h

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

#ifndef _GNUstep_H_GSMarkupConnector
#define _GNUstep_H_GSMarkupConnector

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSObject.h>
#endif

#include <GSMarkupCoding.h>

@class NSString;

/* The root class of our GSMarkup connector objects.  Our connector
 * objects store reference to objects using their id names.  _source
 * and _target are the objects to connect, and _label is a string
 * specifying how to perform the connection (_label has a different
 * meaning in different subclasses).  Connectors can establish the
 * connection once you give them a nameTable dictionary which the
 * connector can use to map _source and _target id names into the
 * actual source and target objects to connect.  Connectors can be
 * encoded/decode as XML, they implement GSMarkupCoding.  Please note that
 * normally they get a special treatment anyway, and are
 * encoded/decoded either in the special <connectors> section, or
 * implicitly when they are created/saved as links from one object to
 * another inside the attributes of objects.  */
@interface GSMarkupConnector : NSObject <GSMarkupCoding>
{
  NSString *_source;
  NSString *_target;
  NSString *_label;
}
- (id) initWithSource: (NSString *)source
	       target: (NSString *)target
		label: (NSString *)label;

- (void) setSource: (NSString *)source;
- (NSString *) source;

- (void) setTarget: (NSString *)source;
- (NSString *) target;

- (void) setLabel: (NSString *)source;
- (NSString *) label;

- (void) establishConnectionUsingNameTable: (NSDictionary *)nameTable;

+ (NSString *) tagName;

- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content;
- (NSDictionary *) attributes;
- (NSArray *) content;
@end

@interface GSMarkupControlConnector : GSMarkupConnector
@end

@interface GSMarkupOutletConnector : GSMarkupConnector
@end

#endif /* _GNUstep_H_GSMarkupConnector */
