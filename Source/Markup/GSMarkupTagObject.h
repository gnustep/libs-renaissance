/* -*-objc-*-
   GSMarkupObject.h

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

#ifndef _GNUstep_H_GSMarkupTagObject
#define _GNUstep_H_GSMarkupTagObject

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSObject.h>
#endif

#include <GSMarkupCoding.h>

@class NSArray;
@class NSBundle;
@class NSDictionary;

@class GSMarkupLocalizer;

/* The root class of our GSMarkupTag objects.  */
@interface GSMarkupTagObject : NSObject <GSMarkupCoding>
{
  NSDictionary *_attributes;
  NSArray *_content;
  id _platformObject;

  /* The following is used, if not nil, to translate localizable
   * strings when creating the platform objects.  */
  GSMarkupLocalizer *_localizer;
}
- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content;

- (NSDictionary *) attributes;

- (NSArray *) content;

/* Set the localizer of this object and all tag objects contained in
 * it.  */
- (void) setLocalizer: (GSMarkupLocalizer *)localizer;

/* Return a list of localizable strings for this object (and all
 * objects contained into it).  Might return nil if no localizable
 * string is available.  The default implementation loops on all
 * objects in the content, and adds them to the array if they are
 * strings, or calls localizableStrings if they are GSMarkupTagObject
 * objects, merging the result into the array.  It then calls the
 * +localizableAttributes method of the class (so that subclasses can
 * override it to return a list of attributes which take as value
 * localizable strings), and gets the value of each of the attributes,
 * and if not nil, adds it to the array.
 *
 * Subclasses normally want to override +localizableAttributes unless
 * they need something really special in which case they can override
 * it completely.
 */
- (NSArray *) localizableStrings;

/* Return an array of localizable attributes for this class, or nil if
 * there are none.  GSMarkupTagObject -localizableStrings implementation
 * automatically uses this list to get the localizable strings from
 * the attributes.  The default implementation returns nil.  */
+ (NSArray *) localizableAttributes;

/* The following method should return: self for normal objects which
 * are encoded/decode normally; a platform object for logic objects
 * which can manage a platform object; nil for logic objects which are
 * just auxiliary objects of a parent logic object and do not actually
 * manage a platform object themselves alone (FIXME this last one).
 *
 * This method should create the platform object the first time it is
 * accessed, and reuse it afterwards.
 *
 * The default implementation when it's called for the first time
 * calls [self platformObjectAlloc] to get a platform object instance
 * (subclasses should override that one to alloc a platform object of
 * the correct class), then calls [self platformObjectInit], which
 * should call the appropriate initXXX: method of _platformObject
 * using the appropriate attributes from the attributes dictionary,
 * then set up the _platformObject with attributes and content, and
 * finally calls [self platformObjectAfterInit] for special
 * initialization (such as autosizing of gui objects) which should be
 * done at the end of the initialization process (subclasses should
 * override the platformObjectInit method to call the appropriate
 * initXXX: method and use the appropriate attributes - for example a
 * window would use resizable=YES|NO etc in the init).
 */
- (id) platformObject;

/*
 * Must be implemented by subclasses to alloc a platform object of
 * the appropriate class, and set _platformObject to it (by using =,
 * not ASSIGN).
 *
 * The default implementation sets _platformObject to nil.
 */
- (void) platformObjectAlloc;

/*
 * Should init the platform object now stored in the _platformObject
 * ivar, using the attributes found in the _attributes dictionary, and
 * the _content array.  Subclasses might override if they need.
 *
 * The default implementation simply does _platformObject =
 * [_platformObject init];
 */
- (void) platformObjectInit;

/*
 * This is called immediately after platformObjectInit.  It can be
 * used to complete initialization of the object.  It is typically
 * used for example by views - views need to size themselves to
 * contents - this must be done *after* they have been init and all
 * the content has been set up.  We need a separate method for this
 * because when overriding platformObjectInit you must call super's
 * implementation before the subclass' implementation (if you want to
 * call super's implementation).  platformObjectAfterInit is
 * subclassed in a different way ... you should call super's
 * implementation after the subclass' implementation (so that for
 * example the view size to contents is executed last!).  The
 * default implementation is empty.
 */
- (void) platformObjectAfterInit;

/* Dynamically changing the attributes is not yet implemented - will
 * be required by GUI builders such as Gorm and will likely require
 * some sort of CAREFULLY DESIGNED extension/modification of the
 * API.  */

/* Handy method.  Returns 0 if the attribute is NO (case insensitive
 * compare), 1 if the attribute is YES (case insensitive compare), -1
 * if the attribute is not defined.  
 *
 * Accepts 'y', 'Y', 'yes', 'YES', 'Yes', 'yEs', 'yeS', 'YEs', 'YeS', 'yES',
 * as 1.
 *
 * Accepts 'n', 'N', 'no', 'NO', 'No', nO' as 0.
 *
 * Returns -1 in all other cases (including if the attribute is not known).
 */
- (int) boolValueForAttribute: (NSString *)attribute;

/*
 * Handy method.  If there is a value for attribute, retrieves it,
 * then localize it using the localizer.  Otherwise, it returns nil.
 */
- (NSString *) localizedStringValueForAttribute: (NSString *)attribute;

@end

#endif /* _GNUstep_H_GSMarkupTagObject */
