/* -*-objc-*-
   GSMarkupDecoder.h

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

#ifndef _GNUstep_H_GSMarkupDecoder
#define _GNUstep_H_GSMarkupDecoder

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSObject.h>
#endif

@class NSMutableDictionary;
@class NSString;
@class GSMarkupDecoderBackend;
@class NSMutableArray;

@interface GSMarkupDecoder : NSObject
{
  /* The backend parser.  */
  GSMarkupDecoderBackend *_backend;

  /* If we are inside an <objects> section.  */
  BOOL _isInsideObjects;

  /* If we are inside a <connectors> section.  */
  BOOL _isInsideConnectors;

  /* The stack of pending open tags.  Each time we find a start tag,
   * we add the tag to the stack.  We save the attribute dictionary
   * and any children tag in the tag object.  Each time we find a
   * closing tag, we remove the tag from the stack, process it, and
   * add the resulting decoded objects to the content of the parent
   * tag, or to the objects or connectors arrays if the stack is
   * empty.  */
  NSMutableArray *_stack;

  /* The objects which we have decoded.  */
  NSMutableArray *_objects;
  
  /* The connectors which we have decoded.  Connectors are object which
   * represent connections between other objects (between the decoded
   * objects and other objects in the application as well).  */
  NSMutableArray *_connectors;
  
  /* The name table which we have decoded, mapping id names to
   * objects.  This is used because the connectors refer to objects by
   * name.  This table maps names to objects in the objects array.
   * The application might supply additional objects with additional
   * names not found in this nameTable - to allow connecting decoded
   * objects to/from other objects in the application.  */
  NSMutableDictionary *_nameTable;

  /* A number starting from 0, used when generating internal idNames
   * used to connect objects which don't have a name in the file but
   * are to be connected using implicit outlets.  This number is
   * increased by 1 for each generated internal idName, to make sure
   * we never generate the same idNames twice.  */
  int _idNameCount;

  /* Instance specific mapping from tag names to classes inside
   * <objects>; normally empty, can be modified by calling
   * setObjectClassForTagName:.
   */
  NSMutableDictionary *_tagNameToObjectClass;

  /* Instance specific mapping from tag names to classes inside
   * <connectors>; normally empty, can be modified by calling
   * setConnectorClassForTagName:.
   */
  NSMutableDictionary *_tagNameToConnectorClass;
  
}

+ (id) decoderWithContentsOfFile: (NSString *)file;

- (id) initWithContentsOfFile: (NSString *)file;

- (id) initWithData: (NSData*)data;

- (void) parse;

/* The SAX-like callbacks.  Called by the backend parser when
 * stuff is parsed.  */

 /* Called when a start tag is found.  */
- (void) foundStartElement: (NSString*)elementName
	    withAttributes: (NSDictionary*)elementAttributes;

/* Called when an end tag is found.  */
- (void) foundEndElement: (NSString*) elementName;

/* Called when some free text is found.  name should have been already
 * trimmed (and merged with previous or following strings etc) by the
 * backend; name should not be empty (the backend should simply not
 * bother us with empty stuff).  */
- (void) foundFreeString: (NSString*) name;

/* Methods composing mostly an internal API.  */
- (void) error: (NSString *)problem;

- (void) warning: (NSString *)problem;

/* Return the class to be used to decode the tag with name tagName
 * found inside the <objects> section.  Return Nil if no appropriate
 * class is found, in which case the tag is ignored.  
 *
 * The default implementation looks up classes using on the following
 * algorithm: Suppose that tagName is 'button'.  We first try the
 * instance specific mapping table.  If nothing is found, we try the
 * following classes in the order:
 *
 * GSMarkupButtonTag
 *
 * GSMarkupTagButton
 * 
 * GSButtonTag
 *
 * GSTagButton
 *
 * ButtonTag
 *
 * TagButton
 *
 * Subclass it and override in the subclass to use a different
 * algorithm.
 */
- (Class) objectClassForTagName: (NSString *)tagName;

/* Return the class to be used to decode the tag with name tagName
 * found inside the <connectors> section.  Return Nil if no
 * appropriate class is found, in which case the tag is ignored.  
 * The default implementation looks up classes using the following
 * algorithm: we first try the instance specific mapping table.  If
 * nothing is found, 'action' and 'control' are mapped to
 * GSMarkupControlConnector; 'connector' and 'outlet' are mapped to
 * GSMarkupOutletConnector.
 *
 * If still not found, say that the tagName is 'other'.  We search the
 * following classe:
 *
 * GSMarkupOtherConnector
 *
 * GSMarkupConnectorOther
 *
 * GSOtherConnector
 *
 * GSConnectorOther
 *
 * OtherConnector
 *
 * ConnectorOther
 *
 * If still not found, we return Nil.
 */
- (Class) connectorClassForTagName: (NSString *)tagName;

/* Hardcode a mapping from tagName --> class for tags found inside
 * <objects>.  This overrides any other algorithm.  */
- (void) setObjectClass: (NSString *)className
	     forTagName: (NSString *)tagName;

/* Hardcode a mapping from tagName --> class for tags found inside
 * <connectors>.  This overrides any other algorithm.  */
- (void) setConnectorClass: (NSString *)className
		forTagName: (NSString *)tagName;

/* To be called at the end of parsing - return the objects array.  */
- (NSArray *) objects;

/* To be called at the end of parsing - return the connectors array.  */
- (NSArray *) connectors;

/* To be called at the end of parsing - return the name table.  */
- (NSDictionary *) nameTable;

@end

#endif /* _GNUstep_H_GSMarkupDecoder */
