/* -*-objc-*-
   GSVBox.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: May-November 2002

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

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSNotification.h>
#endif

#include "GSVBox.h"
#include "GSAutoLayoutManager.h"
#include "GSAutoLayoutStandardManager.h"
#include "GSAutoLayoutProportionalManager.h"
#include "GSAutoLayoutDefaults.h"

/* This is basically a struct which can be stored into a NSArray - all
 * ivars (except setting _view and _column, which are set when the
 * info is created and destroyed when the info is destroyed) accessed
 * directly.  */
@interface GSVBoxViewInfo : NSObject
{
@public
  NSView *_view;

  /* The view minimum size.  When the view is first added, its size
   * is automatically used as the view minimum size.  You can change
   * the minimum size later on programmatically by specifying a new
   * minimum size, or by asking the autolayout view to update
   * itself, in which case the autolayout view examines all views,
   * and if any view has a size which is different from the size it
   * is supposed to have, the new size is used as the view's minimum
   * size.  */
  NSSize _minimumSize;

  /* Expand/Alignment in the horizontal direction.  */
  GSAutoLayoutAlignment _hAlignment;

  /* Expands/Alignment in the vertical direction.  */
  GSAutoLayoutAlignment _vAlignment;
    
  /* A horizontal border.  */
  float _hBorder;
  
  /* A vertical border.  */
  float _vBorder;

  /* For views spanning multiple units.  */
  float _span;

  /* The autolayout _vManager id of this column.  */
  id _column;
}
@end

@implementation GSVBoxViewInfo
- (id) initWithView: (NSView *)aView
	     column: (id)aColumn
{
  ASSIGN (_view, aView);
  ASSIGN (_column, aColumn);
  return self;
}

- (void) dealloc
{
  RELEASE (_column);  
  RELEASE (_view);
  [super dealloc];
}
@end

@implementation GSVBox
- (id) init
{
  GSAutoLayoutManager *manager;

  self = [super initWithFrame: NSZeroRect];
  /* Turn off traditional OpenStep subview autoresizing.  */
  [self setAutoresizesSubviews: NO];
  /* By default we are resizable in width and height ... in case we
   * are placed top-level in the window: we want to receive all
   * resizing of the window around us.  */
  [self setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];

  _viewInfo = [NSMutableArray new];

  /* The horizontal layout manager is by default a standard one,
   * but could be changed.  */
  manager = [GSAutoLayoutStandardManager new];
  [self setAutoLayoutManager: manager];
  RELEASE (manager);

  /* The vertical layout manager is always a standard layout manager
   * and can't be changed (pointless to change it anyway!) */
  _hManager = [GSAutoLayoutStandardManager new];
  
  [[NSNotificationCenter defaultCenter] 
    addObserver: self
    selector: @selector(autoLayoutManagerChangedHLayout:)
    name: GSAutoLayoutManagerChangedLayoutNotification
    object: _hManager];

  return self;
}

- (void) dealloc
{
  RELEASE (_hManager);
  RELEASE (_vManager);
  RELEASE (_viewInfo);
  RELEASE (_line);
  [super dealloc];
}

- (void) setBoxType: (GSAutoLayoutBoxType)type
{
  if (type != [self boxType])
    {
      GSAutoLayoutManager *manager = nil;

      if (type == GSAutoLayoutProportionalBox)
	{
	  manager = [GSAutoLayoutProportionalManager new];
	}
      else
	{
	  manager = [GSAutoLayoutStandardManager new];
	}

      [self setAutoLayoutManager: manager];
      RELEASE (manager);
    }
}

- (GSAutoLayoutBoxType) boxType
{
  if ([_hManager isKindOfClass: [GSAutoLayoutProportionalManager class]])
    {
      return GSAutoLayoutProportionalBox;
    }
  else
    {
      return GSAutoLayoutStandardBox;
    }
}

- (void) setAutoLayoutManager: (GSAutoLayoutManager *)aLayoutManager
{
  /* NB: [_viewInfo count] > 0 not implemented yet.  */
  ASSIGN (_vManager, aLayoutManager);

  _line = [_vManager addLine];
  RETAIN (_line);
  
  [[NSNotificationCenter defaultCenter] 
    addObserver: self
    selector: @selector(autoLayoutManagerChangedVLayout:)
    name: GSAutoLayoutManagerChangedLayoutNotification
    object: _vManager];
}

- (GSAutoLayoutManager *)autoLayoutManager
{
  return _vManager;
}

/* Private method to retrieve the info for a view.  */
- (GSVBoxViewInfo *) infoForView: (NSView *)aView
{
  int i, count = [_viewInfo count];

  for (i = 0; i < count; i++)
    {
      GSVBoxViewInfo *info = [_viewInfo objectAtIndex: i];

      if (info->_view == aView)
	{
	  return info;
	}
    }
  return nil;
}

/* Private methods to push layout info to layout managers.  */
- (void) pushToHManagerInfoForViewAtIndex: (int)i
{
  GSVBoxViewInfo *info = [_viewInfo objectAtIndex: i];

  [_hManager setMinimumLength: (info->_minimumSize).width
	     alignment: info->_hAlignment
	     minBorder: info->_hBorder
	     maxBorder: info->_hBorder
	     span: 1
	     ofSegmentAtIndex: 0
	     inLine: info->_column];

  [_hManager updateLayout];
}

- (void) pushToVManagerInfoForViewAtIndex: (int)i
{
  GSVBoxViewInfo *info = [_viewInfo objectAtIndex: i];

  [_vManager setMinimumLength: (info->_minimumSize).height
	     alignment: info->_vAlignment
	     minBorder: info->_vBorder
	     maxBorder: info->_vBorder
	     span: info->_span
	     ofSegmentAtIndex: i
	     inLine: _line];

  [_vManager updateLayout];
}

- (void) addView: (NSView *)aView
{
  int count = [_viewInfo count];
  GSVBoxViewInfo *info;
  id column = [_hManager addLine];

  info = [[GSVBoxViewInfo alloc] initWithView: aView  column: column];  
  info->_minimumSize = [aView frame].size;
  info->_hAlignment = [aView autolayoutDefaultHorizontalAlignment];
  info->_vAlignment = [aView autolayoutDefaultVerticalAlignment];
  info->_hBorder = [aView autolayoutDefaultHorizontalBorder];
  info->_vBorder = [aView autolayoutDefaultVerticalBorder];
  info->_span = 1;

  if (info->_hAlignment == GSAutoLayoutExpand)
    {
      _hExpand = YES;
    }
  if (info->_hAlignment == GSAutoLayoutWeakExpand)
    {
      _hWeakExpand = YES;
    }

  if (info->_vAlignment == GSAutoLayoutExpand)
    {
      _vExpand = YES;
    }
  if (info->_vAlignment == GSAutoLayoutWeakExpand)
    {
      _vWeakExpand = YES;
    }

  [_viewInfo addObject: info];
  RELEASE (info);
  [self addSubview: aView];
  
  /* First, vertical layout.  */
  [_hManager insertNewSegmentAtIndex: 0
	     inLine: column];
  
  [self pushToHManagerInfoForViewAtIndex: count];

  /* And then, horizontal layout.  */
  [_vManager insertNewSegmentAtIndex: count
	     inLine: _line];

  [self pushToVManagerInfoForViewAtIndex: count];
}

- (void) autoLayoutManagerChangedVLayout: (NSNotification *)notification
{
  float newHeight;
  int i, count;

  if ([notification object] != _vManager)
    {
      return;
    }
  
  newHeight = [_vManager lineLength];

  [super setFrameSize: NSMakeSize (([self frame]).size.width, newHeight)];

  count = [_viewInfo count];

  for (i = 0; i < count; i++)
    {
      GSAutoLayoutSegmentLayout s;
      GSVBoxViewInfo *info;
      NSRect newFrame;

      info = [_viewInfo objectAtIndex: i];

      s = [_vManager layoutOfSegmentAtIndex: i  inLine: _line];

      newFrame = [info->_view frame];
      newFrame.origin.y = s.position;
      newFrame.size.height = s.length;
      
      [info->_view setFrame: newFrame];
    }
}


- (void) autoLayoutManagerChangedHLayout: (NSNotification *)notification
{
  float newWidth;
  int i, count;

  if ([notification object] != _hManager)
    {
      return;
    }
  
  newWidth = [_hManager lineLength];

  [super setFrameSize: NSMakeSize (newWidth, ([self frame].size).height)];

  count = [_viewInfo count];

  for (i = 0; i < count; i++)
    {
      GSAutoLayoutSegmentLayout s;
      GSVBoxViewInfo *info;
      NSRect newFrame;

      info = [_viewInfo objectAtIndex: i];

      s = [_hManager layoutOfSegmentAtIndex: 0  inLine: info->_column];

      newFrame = [info->_view frame];
      newFrame.origin.x = s.position;
      newFrame.size.width = s.length;

      [info->_view setFrame: newFrame];
    }
}

- (int) numberOfViews
{
  return [_viewInfo count];
}

- (void) setFrame: (NSRect)frame
{
  if (NSEqualRects ([self frame], frame))
    {
      return;
    }

  [super setFrame: frame];
  
  if ([_viewInfo count] > 0)
    {
      GSVBoxViewInfo *info;
      info = [_viewInfo objectAtIndex: 0];
      [_hManager forceLength: frame.size.width  ofLine: info->_column];
      [_hManager updateLayout];
    }
  else
    {
      /* ... ? ... we need to save the forced height somewhere ... but
       * how do you remove the forcing afterwards ? */
    }

  [_vManager forceLength: frame.size.height  ofLine: _line];
  [_vManager updateLayout];
}

- (void) setMinimumSize: (NSSize)aSize  forView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  int index = [_viewInfo indexOfObject: info];
  
  info->_minimumSize = aSize;
  
  [self pushToHManagerInfoForViewAtIndex: index];
  [self pushToVManagerInfoForViewAtIndex: index];
}

- (NSSize) minimumSizeForView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  return info->_minimumSize;
}


- (void) setHorizontalAlignment: (GSAutoLayoutAlignment)flag  
			forView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  int index = [_viewInfo indexOfObject: info];
  int i, count;
  
  info->_hAlignment = flag;

  /* Recompute the _hExpand and _hWeakExpand flags.  */
  _hExpand = NO;
  _hWeakExpand = NO;

  count = [_viewInfo count];

  for (i = 0; i < count; i++)
    {
      info = [_viewInfo objectAtIndex: i];
  
      if (info->_hAlignment == GSAutoLayoutExpand)
	{
	  _hExpand = YES;
	}
      if (info->_hAlignment == GSAutoLayoutWeakExpand)
	{
	  _hWeakExpand = YES;
	}
    }
  
  [self pushToHManagerInfoForViewAtIndex: index];
}

- (GSAutoLayoutAlignment) horizontalAlignmentForView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  return info->_hAlignment;
}


- (void) setVerticalAlignment: (GSAutoLayoutAlignment)flag  
		      forView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  int index = [_viewInfo indexOfObject: info];
  int i, count;
  
  info->_vAlignment = flag;

  /* Recompute the _vExpand and _vWeakExpand flags.  */
  _vExpand = NO;
  _vWeakExpand = NO;

  count = [_viewInfo count];

  for (i = 0; i < count; i++)
    {
      info = [_viewInfo objectAtIndex: i];
  
      if (info->_vAlignment == GSAutoLayoutExpand)
	{
	  _vExpand = YES;
	}
      if (info->_vAlignment == GSAutoLayoutWeakExpand)
	{
	  _vWeakExpand = YES;
	}
    }
  
  [self pushToVManagerInfoForViewAtIndex: index];
}

- (GSAutoLayoutAlignment) verticalAlignmentForView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  return info->_vAlignment;
}

- (void) setHorizontalBorder: (float)border  forView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  int index = [_viewInfo indexOfObject: info];
  
  info->_hBorder = border;
  
  [self pushToHManagerInfoForViewAtIndex: index];
} 

- (float) horizontalBorderForView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  return info->_hBorder;
}

- (void) setVerticalBorder: (float)border  forView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  int index = [_viewInfo indexOfObject: info];

  info->_vBorder = border;

  [self pushToVManagerInfoForViewAtIndex: index];
}

- (float) verticalBorderForView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  return info->_vBorder;
}

- (void) setSpan: (float)span  
	 forView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  int index = [_viewInfo indexOfObject: info];

  info->_span = span;
  [self pushToVManagerInfoForViewAtIndex: index];
}

- (float) spanForView: (NSView *)aView
{
  GSVBoxViewInfo *info = [self infoForView: aView];
  return info->_span;
}

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  if (_hExpand)
    {
      return GSAutoLayoutExpand;
    }
  else if (_hWeakExpand)
    {
      return GSAutoLayoutWeakExpand;
    }
  else
    {
      return GSAutoLayoutAlignCenter;
    }
}

- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{
  if (_vExpand)
    {
      return GSAutoLayoutExpand;
    }
  else if (_vWeakExpand)
    {
      return GSAutoLayoutWeakExpand;
    }
  else
    {
      return GSAutoLayoutAlignCenter;
    }
}

- (float) autolayoutDefaultHorizontalBorder
{
  return 0;
}

- (float) autolayoutDefaultVerticalBorder
{
  return 0;
}

- (void) sizeToFitContent
{
  [self setFrameSize: [self minimumSizeForContent]];
}

- (NSSize) minimumSizeForContent
{
  /* Get it from the autolayout managers.  */
  NSSize minimum;
  minimum.height = [_vManager minimumLineLength];
  minimum.width = [_hManager minimumLineLength];

  return minimum;
}
@end

