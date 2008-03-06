/* -*-objc-*-
   GSAutoLayoutStandardManager.m

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
#include "GSAutoLayoutStandardManager.h"
#include "GSAutoLayoutManagerPrivate.h"

/* for ceil */
#include <math.h>

#define min(X, Y)  ((X) < (Y) ? (X) : (Y))
#define max(X, Y)  ((X) < (Y) ? (Y) : (X))

@interface GSAutoLayoutManagerColumn : NSObject
{
@public
  BOOL _expand;
  float _minimumLength;
  float _length;
}
@end

@implementation GSAutoLayoutManagerColumn
@end

@implementation GSAutoLayoutStandardManager

- (id) init
{
  _columns = [NSMutableArray new];
  return [super init];
}

- (void) dealloc
{
  RELEASE (_columns);
  [super dealloc];
}

- (BOOL) internalUpdateMinimumLayout
{
  /* Determine the number of columns.  */
  NSEnumerator *e = [_lines objectEnumerator];
  GSAutoLayoutManagerLine *line;
  int i, numberOfColumns = 0;
  /* Arrays holding the lines/segments with _span != 1, so that we can
   * later on manage them.  */
  NSMutableArray *specialSegments = AUTORELEASE ([NSMutableArray new]);
  NSMutableArray *specialSegmentIndexes = AUTORELEASE ([NSMutableArray new]);

  [_columns removeAllObjects];
  
  while ((line = [e nextObject]) != nil) 
    {
      int columns = 0;
      int count = [line->_segments count];

      for (i = 0; i < count; i++)
	{
	  GSAutoLayoutManagerSegment *segment;

	  segment = [line->_segments objectAtIndex: i];
	  if (segment->_span > 1)
	    {
	      [specialSegments addObject: segment];
	      [specialSegmentIndexes addObject: 
				       [NSNumber numberWithInt: columns]];
	    }
	  columns += segment->_span;
	}
      numberOfColumns = max(columns, numberOfColumns);
    }

  for (i = 0; i < numberOfColumns; i++)
    {
      GSAutoLayoutManagerColumn *c = [GSAutoLayoutManagerColumn new];
      [_columns addObject: c];
      RELEASE (c);
    }
  
  /* Now determine the minimum length of each column, ignoring
   * special segments.  */
  e = [_lines objectEnumerator];
  
  while ((line = [e nextObject]) != nil) 
    {
      int j, count = [line->_segments count];

      /* i holds the segment number, and j the column number.
       * If the segment always span a single column, i == j;
       * otherwise, j can be bigger than i.  */
      for (i = j = 0; i < count; i++)
	{
	  GSAutoLayoutManagerSegment *segment;

	  segment = [line->_segments objectAtIndex: i];

	  if (segment->_span > 1)
	    {
	      /* ignore.  */
	    }
	  else
	    {
	      GSAutoLayoutManagerColumn *column;
	      float minSegmentLength;
	      
	      minSegmentLength = segment->_minBorder 
		+ segment->_minimumContentsLength 
		+ segment->_maxBorder;

	      column = [_columns objectAtIndex: j];
	      column->_minimumLength = max(column->_minimumLength, 
					   minSegmentLength);
	      if (segment->_alignment == GSAutoLayoutExpand
		  || segment->_alignment == GSAutoLayoutWeakExpand)
		{
		  column->_expand = YES;
		}
	    }

	  j += segment->_span;
	}
    }

  /* Now take into account special segments.  */
  {
    int count = [specialSegments count];

    for (i = 0; i < count; i++)
      {
	GSAutoLayoutManagerSegment *segment;
	int j, index;
	float length = 0;
	int columnsWhichExpand = 0;
	float segmentMinimumLength;

	segment = [specialSegments objectAtIndex: i];
	index = [(NSNumber *)[specialSegmentIndexes objectAtIndex: i] 
			     intValue];

	segmentMinimumLength = segment->_minBorder 
	  + segment->_minimumContentsLength + segment->_maxBorder;
	
	/* Compute the total length of the columns spanned by this
	 * segment.  */
	for (j = 0; j < segment->_span; j++)
	  {
	    GSAutoLayoutManagerColumn *column;

	    column = [_columns objectAtIndex: index + j];
	    length += column->_minimumLength;
	    if (column->_expand)
	      {
		columnsWhichExpand++;
	      }
	  }

	/* If it's not enough to display the segment, expand the
	 * columns.  */
	if (length < segmentMinimumLength)
	  {
	    /* If some columns are marked as expanding, expand them rather
	     * than the columns not marked as expanding.  */
	    if (columnsWhichExpand > 0)
	      {
		float enlargeBy = (segmentMinimumLength - length) 
		  / columnsWhichExpand;

		for (j = 0; j < segment->_span; j++)
		  {
		    GSAutoLayoutManagerColumn *column;
		   
		    column = [_columns objectAtIndex: index + j];
		    if (column->_expand)
		      {
			column->_minimumLength += enlargeBy;
		      }
		  }
	      }
	    else
	      {
		/* Else expands all columns of the same amount to
		 * distribute the ugliness on all columns.  */
		float enlargeBy = (segmentMinimumLength - length) 
		  / segment->_span;

		for (j = 0; j < segment->_span; j++)
		  {
		    GSAutoLayoutManagerColumn *column;
		    
		    column = [_columns objectAtIndex: index + j];
		    column->_minimumLength += enlargeBy;
		  }
	      }
	  }

	/* If the segment needs to expand, but unfortunately no column
	 * expands ... */
	if ((segment->_alignment == GSAutoLayoutExpand
	     || segment->_alignment == GSAutoLayoutWeakExpand)
	    &&  columnsWhichExpand == 0)
	  {
	    /* Then mark all columns as expanding to distribute the
	     * ugliness between all the columns.  */
	    for (j = 0; j < segment->_span; j++)
	      {
		GSAutoLayoutManagerColumn *column;
		
		column = [_columns objectAtIndex: index + j];
		column->_expand = YES;
	      }
	  }
      }
  }
  
  /* Now do the minimum layout.  */
  _minimumLength = 0;

  e = [_lines objectEnumerator];
  
  while ((line = [e nextObject]) != nil) 
    {
      int j, count = [line->_segments count];
      float lineLength = 0;

      /* i holds the segment number, and j the column number.  */
      for (i = j = 0; i < count; i++)
	{
	  GSAutoLayoutManagerSegment *segment;
	  int startColumn = j;

	  segment = [line->_segments objectAtIndex: i];

	  (segment->_minimumLayout).position = lineLength;
	  (segment->_minimumLayout).length = 0;

	  for (; j < startColumn + segment->_span; j++)
	    {
	      GSAutoLayoutManagerColumn *column;
	      
	      column = [_columns objectAtIndex: j];
	      
	      (segment->_minimumLayout).length += column->_minimumLength;
	    }
	  
	  lineLength += (segment->_minimumLayout).length;

	  /* We do not need to layout segment contents inside the
	     segment in the minimum layout ... it's not needed.  */
	}
      _minimumLength = max(lineLength, _minimumLength);
    }

  /* Cache the number of expanding columns.  */
  _numberOfExpandingColumns = 0;

  for (i = 0; i < numberOfColumns; i++)
    {
      GSAutoLayoutManagerColumn *column = [_columns objectAtIndex: i];
      
      if (column->_expand)
	{
	  _numberOfExpandingColumns++;
	}
    }
  
  /* TODO - really check if something changed or not and return NO if
   * not.  */
  return YES;
}


- (BOOL) internalUpdateLayout
{
  NSEnumerator *e;
  GSAutoLayoutManagerLine *line;
  float enlargeBy;
  int i, numberOfColumns = [_columns count];

  if (_length < _minimumLength)
    {
      /* We are being constrained below our minimum size ... adopt the
       * minimum layout for views.  */
      enlargeBy = 0;
    }
  else
    {
      if (_numberOfExpandingColumns == 0)
	{
	  enlargeBy = 0;
	}
      else
	{
	  enlargeBy = (_length - _minimumLength) / _numberOfExpandingColumns;
	}
    }

  for (i = 0; i < numberOfColumns; i++)
    {
      GSAutoLayoutManagerColumn *column = [_columns objectAtIndex: i];
      
      if (column->_expand)
	{
	  column->_length = column->_minimumLength + enlargeBy;
	}
      else
	{
	  column->_length = column->_minimumLength;	  
	}
    }

  /* Now do the layout.  */
  e = [_lines objectEnumerator];
  
  while ((line = [e nextObject]) != nil) 
    {
      int j, count = [line->_segments count];
      float lineLength = 0;

      /* i holds the segment number, and j the column number.  */
      for (i = j = 0; i < count; i++)
	{
	  GSAutoLayoutManagerSegment *segment;
	  int startColumn = j;
	  GSAutoLayoutSegmentLayout s;

	  segment = [line->_segments objectAtIndex: i];

	  (segment->_layout).position = lineLength;
	  (segment->_layout).length = 0;

	  for (; j < startColumn + segment->_span; j++)
	    {
	      GSAutoLayoutManagerColumn *column;
	      
	      column = [_columns objectAtIndex: j];
	      
	      (segment->_layout).length += column->_length;
	    }
	  
	  lineLength += (segment->_layout).length;

	  /* Now place the segment contents inside the segment.  */
	  
	  /* First, start with the segment, then remove the fixed
	   * borders.  */
	  s = segment->_layout;
	  
	  s.position += segment->_minBorder;
	  s.length -= segment->_minBorder + segment->_maxBorder;

	  /* Now, align the segment contents in the resulting space.  */
	  switch (segment->_alignment)
	    {
	    case GSAutoLayoutExpand:
      	    case GSAutoLayoutWeakExpand:
	      break;
	    case GSAutoLayoutAlignMin:
	      s.length = segment->_minimumContentsLength;
	      break;
	    case GSAutoLayoutAlignMax:
	      s.position += s.length - segment->_minimumContentsLength;
	      s.length = segment->_minimumContentsLength;
	      break;
	    case GSAutoLayoutAlignCenter:
	    default:
	      s.position += ((s.length - segment->_minimumContentsLength) / 2);
	      s.length = segment->_minimumContentsLength;
	      break;
	    }
	  /* Save the results of our computations.  */
	  segment->_contentsLayout = s;
	}
    }

  /* TODO - only return YES if something changed in the layout ! */
  /* Idea - the superclass could check ?  */
  return YES;
}

@end

