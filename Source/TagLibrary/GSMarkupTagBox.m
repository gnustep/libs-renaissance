/* -*-objc-*-
   GSMarkupTagBox.m

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
#include <TagCommonInclude.h>
#include "GSMarkupTagBox.h"
#include "GSAutoLayoutDefaults.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSString.h>
# include <AppKit/NSBox.h>
#endif

/* We need this intermediate class so that we can ignore the sizeToFit
 * calls made by the NSBox to its content view ... */
@interface GSMarkupBoxContentView : NSView
- (void) sizeToFit;
@end

@implementation GSMarkupBoxContentView

- (NSView *)firstSubview
{
  NSArray *subviews = [self subviews];

  if (subviews != nil  &&  [subviews count] > 0)
    {
      return [subviews objectAtIndex: 0];  
    }
  else
    {
      return nil;
    }
}

/* This is only used when setting up the thing at startup, and never
 * afterwards.  */
- (void) sizeToFit
{
  NSView *firstSubview = [self firstSubview];

  [self setAutoresizesSubviews: NO];
  
  if (firstSubview)
    {
      [self setFrameSize: [firstSubview frame].size];
    }
  else
    {
      [self setFrameSize: NSMakeSize (50, 50)];
    }

  [self setAutoresizesSubviews: YES];
}

/* Use the autolayout defaults of the first subview.  */
- (GSAutoLayoutAlignment) autoLayoutDefaultVerticalAlignment
{
  NSView *firstSubview = [self firstSubview];

  if (firstSubview)
    {
      return [firstSubview autoLayoutDefaultVerticalAlignment];
    }
  else
    {
      return [super autoLayoutDefaultVerticalAlignment];
    }
}

- (GSAutoLayoutAlignment) autoLayoutDefaultHorizontalAlignment
{
  NSView *firstSubview = [self firstSubview];

  if (firstSubview)
    {
      return [firstSubview autoLayoutDefaultHorizontalAlignment];
    }
  else
    {
      return [super autoLayoutDefaultHorizontalAlignment];
    }
}

@end

@implementation GSMarkupTagBox

+ (NSString *) tagName
{
  return @"box";
}

+ (Class) platformObjectClass
{
  return [NSBox class];
}

- (id) initPlatformObject: (id)platformObject
{
  platformObject = [platformObject init];

  /* title */
  {
    NSString *title = [self localizedStringValueForAttribute: @"title"];

    if (title == nil)
      {
	/* Set the title even if nil ... to remove the default 'Title'
	 * label! */
	/* Mac OS X barfs on nil title  */
	[platformObject setTitle: @""];
	/* Make sure to remove it completely if nil.  */
	[platformObject setTitlePosition: NSNoTitle];
      }
    else
      {
	[platformObject setTitle: title];
      }
  }

  /* titleFont (we recommed not to use this unless strictly needed) */
  {
    NSFont *f = [self fontValueForAttribute: @"titleFont"];
    if (f != nil)
      {
	[platformObject setTitleFont: f];
      }
  }

  /* titlePosition (we recommed not to use this unless strictly needed) */
  {
    NSString *titlePosition = [_attributes objectForKey: @"titlePosition"];

    if (titlePosition != nil)
      {
	if ([titlePosition isEqualToString: @"noTitle"])
	  {
	    [platformObject setTitlePosition: NSNoTitle];
	  }
	else if ([titlePosition isEqualToString: @"aboveTop"])
	  {
	    [platformObject setTitlePosition: NSAboveTop];
	  }
	else if ([titlePosition isEqualToString: @"atTop"])
	  {
	    [platformObject setTitlePosition: NSAtTop];
	  }
	else if ([titlePosition isEqualToString: @"belowTop"])
	  {
	    [platformObject setTitlePosition: NSBelowTop];
	  }
	else if ([titlePosition isEqualToString: @"aboveBottom"])
	  {
	    [platformObject setTitlePosition: NSAboveBottom];
	  }
	else if ([titlePosition isEqualToString: @"atBottom"])
	  {
	    [platformObject setTitlePosition: NSAtBottom];
	  }
	else if ([titlePosition isEqualToString: @"belowBottom"])
	  {
	    [platformObject setTitlePosition: NSBelowBottom];
	  }
	else
	  {
	    NSLog (@"Warning: Unrecognized value '%@' for box titlePosition attribute.  Ignored.", titlePosition);
	  }
      }    
  }

  /* borderType (we recommed not to use this unless strictly needed) */
  {
    NSString *borderType = [_attributes objectForKey: @"borderType"];

    if (borderType != nil)
      {
	if ([borderType isEqualToString: @"noBorder"])
	  {
	    [platformObject setBorderType: NSNoBorder];
	  }
	else if ([borderType isEqualToString: @"lineBorder"])
	  {
	    [platformObject setBorderType: NSLineBorder];
	  }
	else if ([borderType isEqualToString: @"bezelBorder"])
	  {
	    [platformObject setBorderType: NSBezelBorder];
	  }
	else if ([borderType isEqualToString: @"grooveBorder"])
	  {
	    [platformObject setBorderType: NSGrooveBorder];
	  }
	else
	  {
	    NSLog (@"Warning: Unrecognized value '%@' for box borderType attribute.  Ignored.", borderType);
	  }
      }
    else
      {
	/* Check for the obsolete hasBorder flag.  */
	if ([self boolValueForAttribute: @"hasBorder"] == 0)
	  {
	    [platformObject setBorderType: NSNoBorder];
	    
	    NSLog (@"The box 'hasBorder' attribute has been replaced by 'borderType'.  Please update your gsmarkup files");
	  }
      }
  }

  /* Content view.  */
  if (_content != nil  &&  [_content count] > 0)
    {
      NSView *subview = [(GSMarkupTagObject *)[_content objectAtIndex: 0] 
					  platformObject];
      if ([subview isKindOfClass: [NSView class]])
	{
	  GSMarkupBoxContentView *v;

	  v = [GSMarkupBoxContentView new];
	  [v setAutoresizesSubviews: YES];
	  [(NSBox *)platformObject setContentView: v];
	  RELEASE (v);

	  [v addSubview: subview];
	}
    }

  return platformObject;
}

+ (NSArray *) localizableAttributes
{
  return [[GSMarkupTagView localizableAttributes] arrayByAddingObject: @"title"];
}

/*
 * NSBox is special because it's a container outside our control :-(
 *
 * Standard boxes/containers under our control keep track of the
 * autolayout flags of the views they enclose, and can compute their
 * own autolayout flags (used by other boxes/containers enclosing
 * them) from those.  When they are added to an enclosing window /
 * box, the autolayout flags they compute are used.
 *
 * NSBox can not keep track of the autolayout flags of the view it
 * encloses, but we still want to fake the correct behaviour, so that
 * for example if you put something which expands in an NSBox, the
 * NSBox will expand; if you put something which does not expand, the
 * NSBox will not expand.
 *
 * In practice, if you put an NSBox in a container, the NSBox will
 * first be asked to compute default autolayout flags.  That requests
 * is managed by NSBox's default autolayout stuff, and by our
 * GSMarkupBoxContentView class above; it will compute correct
 * autolayout flags unless the NSBox, or its content, have manual
 * hardcoded hexpand/vexpand flags set.
 *
 * The library still gives us a chance to manage that case by calling
 * the following method asking if manual flags are set.  In that case,
 * we examine the NSBox's manually hardcoded flags (like super does),
 * and then the content's manually hardcoded flags if any.
 */
- (int) gsAutoLayoutVAlignment
{
  /* If an align flag was manually specified by the user, return it.  */
  int flag = [super gsAutoLayoutVAlignment];
  
  if (flag != 255)
    {
      return flag;
    }

  /* Else, check if the content has a flag which was manually
   * specified by the user.  If so, that should override the default
   * computations. */
  if ([_content count] > 0)
    {
      GSMarkupTagObject *view = (GSMarkupTagObject *)[_content objectAtIndex: 0];
      
      if ([view isKindOfClass: [GSMarkupTagView class]])
	{
	  flag = [(GSMarkupTagView *)view gsAutoLayoutVAlignment];
	  
	  if (flag != 255)
	    {
	      if (flag == GSAutoLayoutExpand  ||  flag == GSAutoLayoutWeakExpand)
		{
		  return flag;
		}
	      else
		{
		  /* If the content does not expand, we center
		   * ourselves by default.  */
		  return GSAutoLayoutAlignCenter;
		}
	    }
	}
    }
  
  /* Else, return 255.  That will cause the autolayout default to be
   * used.  
   */
  return 255;
}

- (int) gsAutoLayoutHAlignment
{
  /* If an align flag was manually specified by the user, return it.  */
  int flag = [super gsAutoLayoutHAlignment];
  
  if (flag != 255)
    {
      return flag;
    }

  /* Else, check if the content has a flag which was manually
   * specified by the user.  If so, that should override the default
   * computations. */
  if ([_content count] > 0)
    {
      GSMarkupTagObject *view = (GSMarkupTagObject *)[_content objectAtIndex: 0];
      
      if ([view isKindOfClass: [GSMarkupTagView class]])
	{
	  flag = [(GSMarkupTagView *)view gsAutoLayoutHAlignment];
	  
	  if (flag != 255)
	    {
	      if (flag == GSAutoLayoutExpand  ||  flag == GSAutoLayoutWeakExpand)
		{
		  return flag;
		}
	      else
		{
		  /* If the content does not expand, we center
		   * ourselves by default.  */
		  return GSAutoLayoutAlignCenter;
		}
	    }
	}
    }
  
  /* Else, return 255.  That will cause the autolayout default to be
   * used.  */
  return 255;
}


@end
