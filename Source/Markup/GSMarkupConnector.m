/* -*-objc-*-
   GSMarkupConnector.m

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

#import <AppKit/NSKeyValueBinding.h>
#include <MarkupCommonInclude.h>
#include "GSMarkupConnector.h"

@implementation GSMarkupConnector

- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content
{
  return self;
}

- (NSDictionary *) attributes
{
  return [NSDictionary dictionary];
}

- (NSArray *) content
{
  return nil;
}

+ (NSString *) tagName
{
  return nil;
}

- (void) establishConnectionUsingNameTable: (NSDictionary *)nameTable;
{
  /* Subclass responsibility ! */
}

+ (id) getObjectForIdString: (NSString *)idString
	     usingNameTable: (NSDictionary *)nameTable
{
  NSRange r = [idString rangeOfString: @"."];

  if (r.location == NSNotFound)
    {
      /* If there is no '.' in the idString, just look the string up
       * in the name table, and return the result.  */
      return [nameTable objectForKey: idString];
    }
  else
    {
      /* Else, the string up to the first '.' is the object name to
       * look up in the name table, while everything after the first
       * '.' is a key-value path.
       */
      NSString *objectName = [idString substringToIndex: r.location];
      NSString *keyValuePath = [idString substringFromIndex: NSMaxRange(r)];
      
      /* Extract the object with that name.  */
      id object = [nameTable objectForKey: objectName];
      
      /* Apply the specified key-value coding path.  */
      return [object valueForKeyPath: keyValuePath];
      
    }
}
@end

@implementation GSMarkupOneToOneConnector

- (id) initWithSource: (NSString *)source
	       target: (NSString *)target
		label: (NSString *)label
{
  /* Remove the # from the beginning of source and target if any.  */
  if ([source hasPrefix: @"#"])
    {
      source = [source substringFromIndex: 1];
    }
  ASSIGN (_source, source);

  if ([target hasPrefix: @"#"])
    {
      target = [target substringFromIndex: 1];
    }
  ASSIGN (_target, target);

  ASSIGN (_label, label);
  return self;
  
}

- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content
{
  return [self initWithSource: [attributes objectForKey: @"source"]
	       target: [attributes objectForKey: @"target"]
	       label: [attributes objectForKey: @"label"]];
}

- (NSDictionary *) attributes
{
  NSDictionary *d;
  NSString *source;
  NSString *target;

  /* Add # in front of source and target.  */
  source = [NSString stringWithFormat: @"#%@", _source];
  target = [NSString stringWithFormat: @"#%@", _target];
  
  d = [NSDictionary dictionaryWithObjectsAndKeys: source, @"source",
		    target, @"target", _label, @"label", nil];
  return d;
}

- (NSArray *) content
{
  return nil;
}

- (void) setSource: (NSString *)source
{
  ASSIGN (_source, source);
}

- (NSString *) source
{
  return _source;
}

- (void) setTarget: (NSString *)target
{
  ASSIGN (_target, target);
}

- (NSString *) target
{
  return _target;
}

- (void) setLabel: (NSString *)label
{
  ASSIGN (_label, label);
}

- (NSString *) label
{
  return _label;
}

- (NSString *) description
{
  return [NSString stringWithFormat: @"<%@ source=\"%@\" target=\"%@\" label=\"%@\">",
		   NSStringFromClass ([self class]),
		   _source, _target, _label];
}

@end

/* To prevent the compiler from complaining that setAction: is an
 * unknown selector.  */
@interface NSObject (ActionTarget)
- (void)setAction:(SEL)aSelector;
- (void)setTarget:(id)anObject;
@end

@implementation GSMarkupControlConnector

+ (NSString *) tagName
{
  return @"control";
}

- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content
{
  NSString *label;

  /* Recognize action as preferred to label.  */
  label = [attributes objectForKey: @"action"];
  if (label == nil)
    {
      label = [attributes objectForKey: @"label"];
    }    

  return [self initWithSource: [attributes objectForKey: @"source"]
	       target: [attributes objectForKey: @"target"]
	       label: label];
}

/* Generate action="selectAll:" rather than label="selectAll:"  */
- (NSDictionary *) attributes
{
  NSDictionary *d;
  NSString *source;
  NSString *target;

  /* Add # in front of source and target.  */
  source = [NSString stringWithFormat: @"#%@", _source];
  target = [NSString stringWithFormat: @"#%@", _target];
  
  d = [NSDictionary dictionaryWithObjectsAndKeys: source, @"source",
		    target, @"target", _label, @"action", nil];
  return d;
}

- (void) establishConnectionUsingNameTable: (NSDictionary *)nameTable;
{
  SEL action = NSSelectorFromString (_label);
  id source = [GSMarkupConnector getObjectForIdString: _source  
				 usingNameTable: nameTable];
  id target = [GSMarkupConnector getObjectForIdString: _target
				 usingNameTable: nameTable];

  [source setAction: action];
  [source setTarget: target];
}
@end

@implementation GSMarkupOutletConnector

+ (NSString *) tagName
{
  return @"outlet";
}

- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content
{
  NSString *label;
  
  /* Recognize key as preferred to label.  */
  label = [attributes objectForKey: @"key"];
  if (label == nil)
    {
      label = [attributes objectForKey: @"label"];
    }    

  return [self initWithSource: [attributes objectForKey: @"source"]
	       target: [attributes objectForKey: @"target"]
	       label: label];
}

- (void) establishConnectionUsingNameTable: (NSDictionary *)nameTable;
{
  id source = [GSMarkupConnector getObjectForIdString: _source 
				 usingNameTable: nameTable];
  id target = [GSMarkupConnector getObjectForIdString: _target
				 usingNameTable: nameTable];

  [source setValue: target  forKey: _label];
}

@end

/* TODO: This depends on bindings, which are available in gnustep-gui
   / AppKit, so it should be moved to TagLibrary ?  */
@implementation GSMarkupBindConnector

+ (NSString *) tagName
{
  return @"bind";
}

- (id) initWithSource: (NSString *)source
		label: (NSString *)label
	       target: (NSString *)target
		  key: (NSString *)key
{
  /* Remove the # from the beginning of source and target if any.  */
  if ([source hasPrefix: @"#"])
    {
      source = [source substringFromIndex: 1];
    }
  ASSIGN (_source, source);

  if ([target hasPrefix: @"#"])
    {
      target = [target substringFromIndex: 1];
    }
  ASSIGN (_target, target);

  ASSIGN (_label, label);
  ASSIGN (_key, key);
  return self;
  
}

- (id) initWithAttributes: (NSDictionary *)attributes
		  content: (NSArray *)content
{
  return [self initWithSource: [attributes objectForKey: @"source"]
	       label: [attributes objectForKey: @"label"]
	       target: [attributes objectForKey: @"target"]
	       key: [attributes objectForKey: @"key"]];
}

- (void) establishConnectionUsingNameTable: (NSDictionary *)nameTable;
{
  id source = [GSMarkupConnector getObjectForIdString: _source 
				 usingNameTable: nameTable];
  id target = [GSMarkupConnector getObjectForIdString: _target
				 usingNameTable: nameTable];

  [source bind: _label toObject: target withKeyPath: _key options: nil];
}

@end
