/* -*-objc-*-
   GSMarkupCoder.h

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

#ifndef _GNUstep_H_GSMarkupCoder
#define _GNUstep_H_GSMarkupCoder

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSObject.h>
#endif

#include "GSMarkupCoding.h"

@class NSArray;
@class NSData;
@class NSMutableArray;
@class NSMutableString;
@class GSMarkupConnector;
@class NSMutableDictionary;

@interface GSMarkupCoder : NSObject
{
  /* The objects to encode.  */
  NSArray *_objects;

  /* The connectors still to encode.  While encoding objects,
   * we encode some connectors inside the objects.  All these
   * connectors are removed from here, which is why this is
   * a mutable array.  */
  NSMutableArray *_connectors;

  /* The name table.  Used only to encode connectors inside
   * objects.  */
  NSDictionary *_nameTable;

  /* The XML output.  We assume little files so we do not optimize
   * for that - we just dump the whole file into _output, then write
   * _output to disk.  */
  NSMutableString *_output;

  /* The current indentation level in the XML output file.  Opening a
   * tag adds 2 to indentation; closing one removes 2.  */
  int _indentation;

  /* Instance specific mapping from classes to tag names <objects>;
   * normally empty, can be modified by calling
   * setTagName:forObjectClass:
   */
  NSMutableDictionary *_objectClassToTagName;

  /* Instance specific mapping from classes to tag names inside
   * <connectors>; normally empty, can be modified by calling
   * setTagName:forConnectorClass:
   */
  NSMutableDictionary *_connectorClassToTagName;
}


+ (void) encodeObjects: (NSArray *)objects
	    connectors: (NSArray *)connectors
	     nameTable: (NSDictionary *)nameTable
		toFile: (NSString *)file;

+ (NSData *) encodeObjects: (NSArray *)objects
	        connectors: (NSArray *)connectors
         	 nameTable: (NSDictionary *)nameTable;

- (id) initWithObjects: (NSArray *)objects
	    connectors: (NSArray *)connectors
	     nameTable: (NSDictionary *)nameTable;

- (NSData*) encode;

- (BOOL) encodeToFile: (NSString *)file;

/* Output an _indentation number of spaces (called before outputting
 * a tag definition.  */
- (void) indent;

- (void) encodeObject: (id <GSMarkupCoding>)object;

- (void) encodeConnector: (GSMarkupConnector *)connector;

/* First looks in the instance hardcoded tables, then tries to extract
 * the tagName from the class by calling [class tagName].
 */
- (NSString *) tagNameForObjectClass: (Class)c;

- (NSString *) tagNameForConnectorClass: (Class)c;

- (void) setTagName: (NSString *)tagName
     forObjectClass: (NSString *)className;

- (void) setTagName: (NSString *)tagName
  forConnectorClass: (NSString *)className;

@end

#endif /* _GNUstep_H_GSMarkupCoder */
