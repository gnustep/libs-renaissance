/* -*-objc-*-
   GSAutoLayoutProportionalManager.m

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
#include <AutoLayoutCommonInclude.h>
#include "GSAutoLayoutProportionalManager.h"
#include "GSAutoLayoutManagerPrivate.h"

#define min(X, Y)  ((X) < (Y) ? (X) : (Y))
#define max(X, Y)  ((X) < (Y) ? (Y) : (X))

@implementation GSAutoLayoutProportionalManager

- (BOOL) internalUpdateMinimumLayout
{
  /* Determine the minimum grid unit.  */
  NSEnumerator *e = [_lines objectEnumerator];
  GSAutoLayoutManagerLine *line;
  float minimumGridUnit = 0;
  float minimumLineLength = 0;
  
  while ((line = [e nextObject]) != nil) 
    {
      NSEnumerator *f = [line->_segments objectEnumerator];
      GSAutoLayoutManagerSegment *segment;
      
      while ((segment = [f nextObject]) != nil)
	{
	  float segmentMinGridUnit;
	  float segmentMinLength;
	  
	  segmentMinLength = segment->_minBorder 
	    + segment->_minimumContentsLength + segment->_maxBorder;
	  
	  segmentMinGridUnit = segmentMinLength / (segment->_span);
	  minimumGridUnit = max(segmentMinGridUnit, minimumGridUnit);
	}
    }

  _minimumGridUnit = minimumGridUnit;
  
  /* Now do the minimum layout.  */
  e = [_lines objectEnumerator];

  while ((line = [e nextObject]) != nil) 
    {
      NSEnumerator *f = [line->_segments objectEnumerator];
      GSAutoLayoutManagerSegment *segment;
      float lineLength = 0;

      while ((segment = [f nextObject]) != nil)
	{
	  float l = (segment->_span) * _minimumGridUnit;

	  (segment->_minimumLayout).position = lineLength;
	  (segment->_minimumLayout).length = l;

	  lineLength += l;
	}
      minimumLineLength = max(lineLength, minimumLineLength);
    }

  _minimumLength = minimumLineLength;

  /* TODO - really check if something changed or not and return NO if
   * not.  */
  return YES;
}


/*
 * The layout is determined by computing the number of grid units in a
 * line (got by dividing the _minimumLength by the _minimumGridUnit).
 * The _length is divided by this number to get the _gridUnit.
 * Layout is computed basing on this _gridUnit - all segments have their
 * layout computed by laying them out one after the other one, and sizing
 * them to cover `span' grid units each.
 */
- (BOOL) internalUpdateLayout
{
  /* Compute the new gridUnit.  */
  NSEnumerator *e;
  GSAutoLayoutManagerLine *line;
  float gridUnit = (_length * _minimumGridUnit) / _minimumLength;

  _gridUnit = gridUnit;
  
  /* Now do the layout.  */
  e = [_lines objectEnumerator];

  while ((line = [e nextObject]) != nil) 
    {
      NSEnumerator *f = [line->_segments objectEnumerator];
      GSAutoLayoutManagerSegment *segment;
      float lineLength = 0;

      while ((segment = [f nextObject]) != nil)
	{
	  float l = (segment->_span) * _gridUnit;

	  (segment->_layout).position = lineLength;
	  (segment->_layout).length = l;

	  segment->_contentsLayout = segment->_layout;
	  (segment->_contentsLayout).position += segment->_minBorder;
	  (segment->_contentsLayout).length -= (segment->_minBorder 
						+ segment->_maxBorder);
	  lineLength += l;
	}
    }

  /* TODO - only return YES if something changed in the layout ! */
  return YES;
}


@end

