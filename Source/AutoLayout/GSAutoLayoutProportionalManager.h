/* -*-objc-*-
   GSAutoLayoutProportionalManager.h

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

#ifndef _GNUstep_H_GSAutoLayoutProportionalManager
#define _GNUstep_H_GSAutoLayoutProportionalManager

#include "GSAutoLayoutManager.h"

/*
 * GSAutoLayoutProportionalManager objects are layout managers which
 * layout segments over an invisible grid.  The distance between two
 * grid lines is called the 'grid unit'.  Each segment is required to
 * cover 'unit' grid units; the grid unit must be big enough that all
 * segments display their `minimum length'.  The alignment flags of
 * segments are ignored ... because all segments are always expanded.
 * The borders of segments are instead used - when the segment
 * contents are laid out inside a segment, it takes up all space
 * except for the borders.  All lines must contain the same number of
 * grid units.  If the segments in a line sum up to use less grid
 * units than the segments in another line, those grid units are left
 * blank (the idea being that you can then add an element at the end
 * of one line, but not the other ones ... the other ones will still
 * be bigger, but display blank there).
 */
@interface GSAutoLayoutProportionalManager : GSAutoLayoutManager
{
  float _minimumGridUnit;
  
  float _gridUnit;
}

/*
 * The minimum layout is determined by determining the minimum grid
 * unit necessary to display all segments.  For each segment, the
 * minimum grid unit necessary to display that segment is obtained by
 * dividing the minimum length of the segment for the span of the
 * segment (which is the number of grid units the segment should
 * span).  The maximum of all these numbers is the minimum grid unit
 * needed to display everything comfortably.  Once the minimum grid
 * unit has been determined, the segments are laid out one after the
 * other (on each line), to take up a size given by multiplying the
 * minimum grid unit for the span of that segment.
 * The length of each line is computed; the maximum of these lengths
 * is used as the minimum line length.
 * The segment contents are laid out in segments to take all available
 * space in the segments, except for the border.
 */
- (BOOL) internalUpdateMinimumLayout;

/*
 * The layout is determined by computing the number of grid units in a
 * line (got by dividing the _minimumLength by the _minimumGridUnit).
 * The _length is divided by this number to get the _gridUnit.
 * Layout is computed basing on this _gridUnit - all segments have their
 * layout computed by laying them out one after the other one, and sizing
 * them to cover `span' grid units each.
 * The segment contents are laid out in segments to take all available
 * space in the segments, except for the border.
 */
- (BOOL) internalUpdateLayout;

@end

#endif 
