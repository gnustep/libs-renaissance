/* -*-objc-*-
   GSAutoLayoutManager.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: April 2002

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

#include "GSAutoLayoutManager.h"
#include "GSAutoLayoutManagerPrivate.h"

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
#else
# include <Foundation/NSArray.h>
# include <Foundation/NSEnumerator.h>
# include <Foundation/NSNotification.h>
# include <Foundation/NSSet.h>
# include <Foundation/NSString.h>
#endif

#define min(X, Y)  ((X) < (Y) ? (X) : (Y))
#define max(X, Y)  ((X) < (Y) ? (Y) : (X))

NSString *GSAutoLayoutManagerChangedLayoutNotification = @"GSAutoLayoutManagerChangedLayoutNotification";


/* This class is just a placeholder for segment information.  */
@implementation GSAutoLayoutManagerSegment
- (id) init
{
  _layout.position = 0;
  _layout.length = 0;
  _contentsLayout.position = 0;
  _contentsLayout.length = 0;
  
  _minimumLayout.position = 0;
  _minimumLayout.length = 0;
  return self;
}

@end

/* This class contains a little more logic - allocates the segment
 * array, frees it.  */
@implementation GSAutoLayoutManagerLine

- (id) init
{
  _segments = [NSMutableArray new];
  _forcedLength = -1;
  return self;
}

- (void) dealloc
{
  RELEASE (_segments);
  [super dealloc];
}

@end

/* The main class.  */
@implementation GSAutoLayoutManager

- (id) init
{
  _lines = [NSMutableSet new];
  return self;
}

- (void) dealloc
{
  RELEASE (_lines);
  [super dealloc];
}

- (void) updateLayout
{
  if (_needsUpdateMinimumLayout)
    {
      if ([self internalUpdateMinimumLayout])
	{
	  _needsUpdateLayout = YES;
	}

      _needsUpdateMinimumLayout = NO;
    }
  
  if (_needsUpdateLayout)
    {
      /* First, compute the forced _length.  */
      NSEnumerator *e = [_lines objectEnumerator];
      GSAutoLayoutManagerLine *line;
      _length = -1;

      while ((line = [e nextObject]) != nil) 
	{
	  float forcedLength = line->_forcedLength;
	  if (forcedLength < 0)
	    {
	      /* no forced length for this line - ignore */
	    }
	  else
	    {
	      if (_length < 0)
		{
		  /* First forcedLength we find - use it as it is.  */
		  _length = forcedLength;
		}
	      else
		{
		  /* A new forcedLength - use it only if less than what
		   * we already have.  */
		  _length = min (forcedLength, _length);
		}
	    }
	}

      /* If there is no forced length, use _minimumLength.  */
      if (_length < 0)
	{
	  _length = _minimumLength;
	}

      /* Please note that it is possible that _length <
       * _minimumLength; in which case, in internalUpdateLayout, we
       * use the minimum layout.  */

      if ([self internalUpdateLayout])
	{
	  /* Post the notification that the layout changed.  Clients
	   * should observe this notification, and update themselves
	   * as a consequence of layout changes when they get this
	   * notification.  */
	  [[NSNotificationCenter defaultCenter]
	    postNotificationName: GSAutoLayoutManagerChangedLayoutNotification
	    object: self
	    userInfo: nil];
	}
      
      _needsUpdateLayout = NO;
    }
}

- (BOOL) internalUpdateMinimumLayout
{
  /* Subclass responsibility.  */
  return NO;
}

- (BOOL) internalUpdateLayout
{
  /* Subclass responsibility.  */
  return NO;
}

- (id) addLine
{
  GSAutoLayoutManagerLine *line;

  line = [GSAutoLayoutManagerLine new];
  [_lines addObject: line];
  RELEASE (line);

  _needsUpdateMinimumLayout = YES;
  _needsUpdateLayout = YES;

  /* We are funny here ;-) ... we return the line itself as `an
   * identifier to identify that line which clients can use to
   * identify that line with the autolayout manager'.  This saves up
   * any lookup to find the line object.  Of course clients should
   * *NEVER* touch the line object we gave them - we might even change
   * our implementation and pass them something else - a real
   * identifier perhaps.  */
  return line;
}

- (void) removeLine: (id)line
{
  [_lines removeObject: line];
  _needsUpdateMinimumLayout = YES;
  _needsUpdateLayout = YES;
}

- (void) forceLength: (float)length
	      ofLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  if (l->_forcedLength != length)
    {
      _needsUpdateLayout = YES;
      l->_forcedLength = length;
    }
}

- (void) insertNewSegmentAtIndex: (int)segment
			  inLine: (id)line
{
  GSAutoLayoutManagerSegment *s;
  GSAutoLayoutManagerLine *l = line; 

  s = [GSAutoLayoutManagerSegment new];
  [l->_segments insertObject: s  atIndex: segment];
  RELEASE (s);

  _needsUpdateMinimumLayout = YES;
  _needsUpdateLayout = YES;
}

- (void) removeSegmentAtIndex: (int)segment
		       inLine: (id)line
{
  GSAutoLayoutManagerLine *l = line; 

  [l->_segments removeObjectAtIndex: segment];
  _needsUpdateMinimumLayout = YES;
  _needsUpdateLayout = YES;
}

- (unsigned int) segmentCountInLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  
  return [l->_segments count];
}


- (void) setMinimumLength: (float)min
		alignment: (GSAutoLayoutAlignment)flag
		minBorder: (float)minBorder
		maxBorder: (float)maxBorder
		     span: (float)span
	 ofSegmentAtIndex: (int)segment
		   inLine: (id)line;
{
  GSAutoLayoutManagerLine *l = line;
  GSAutoLayoutManagerSegment *s = [l->_segments objectAtIndex: segment];

  if (s->_minimumContentsLength != min)
    {
      s->_minimumContentsLength = min;
      _needsUpdateMinimumLayout = YES;
    }
  
  if (s->_alignment != flag)
    {
      s->_alignment = flag;
      _needsUpdateMinimumLayout = YES;
    }
  
  if (s->_minBorder != minBorder)
    {
      s->_minBorder = minBorder;
      _needsUpdateMinimumLayout = YES;
    }

  if (s->_maxBorder != maxBorder)
    {
      s->_maxBorder = maxBorder;
      _needsUpdateMinimumLayout = YES;
    }

  if (s->_span != span)
    {
      s->_span = span;
      _needsUpdateMinimumLayout = YES;
    }
}

- (float) minimumLengthOfSegmentAtIndex: (int)segment
				 inLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  GSAutoLayoutManagerSegment *s = [l->_segments objectAtIndex: segment];

  return s->_minimumContentsLength;
}


- (GSAutoLayoutAlignment) alignmentOfSegmentAtIndex: (int)segment
					     inLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  GSAutoLayoutManagerSegment *s = [l->_segments objectAtIndex: segment];

  return s->_alignment;  
}

- (float) minBorderOfSegmentAtIndex: (int)segment
			     inLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  GSAutoLayoutManagerSegment *s = [l->_segments objectAtIndex: segment];

  return s->_minBorder;  
}

- (float) maxBorderOfSegmentAtIndex: (int)segment
			     inLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  GSAutoLayoutManagerSegment *s = [l->_segments objectAtIndex: segment];

  return s->_maxBorder;  
}

- (float) spanOfSegmentAtIndex: (int)segment
			inLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  GSAutoLayoutManagerSegment *s = [l->_segments objectAtIndex: segment];

  return s->_span;  
}

- (float) lineLength
{
  return _length;
}


- (GSAutoLayoutSegmentLayout) layoutOfSegmentAtIndex: (int)segment
					      inLine: (id)line
{
  GSAutoLayoutManagerLine *l = line;
  GSAutoLayoutManagerSegment *s = [l->_segments objectAtIndex: segment];
  
  return s->_contentsLayout;
}

- (float) minimumLineLength
{
  return _minimumLength;
}

@end
