/* -*-objc-*-
   GSAutoLayoutManagerPrivate.h

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

#ifndef _GNUstep_H_GSAutoLayoutManagerPrivate
#define _GNUstep_H_GSAutoLayoutManagerPrivate


/* This is a separate header file than GSAutoLayoutManager because
 * these classes are to be used by GSAutoLayoutManager and its
 * subclasses, but not by end-user applications.  */
#include "GSAutoLayoutManager.h"

/* The ivars in these classes are public, because subclasses of
 * GSAutoLayoutManager need to access them.  The classes are trivial -
 * they contain nearly no code and we access all instance variables
 * directly from the GSAutoLayoutManager for performance reasons.
 * They are basically structs which can be stored in ObjC arrays
 * :-) */
@interface GSAutoLayoutManagerSegment : NSObject
{
  /* All the ivars are public, we set/read them directly.  */
@public

  /* The minimum length of the segment contents.  */
  float _minimumContentsLength;

  /* The min border of the segment.  */
  float _minBorder;
  
  /* The max border of the segment.  */
  float _maxBorder;

  /* 0 if the segment should be expanded when possible, because that
   * would show additional information; > 0 if there is no additional
   * information to show, and so the segment looks only uglier when
   * expanded, and it's better not to expand it; in case > 0, then the
   * value can be 1, 2, 3, 4 meaning if in case the segment really
   * must be expanded, to expand it, or how to align the segment
   * contents inside the segment, if left, center, or right.  Because
   * 0 is determined by a functional reason, while > 0 by an
   * aesthetical reason, 0 should be strictly honoured, at the expense
   * of not always honouring > 0.
   */
  GSAutoLayoutAlignment _alignment;

  /* This number holds either the number of columns in the line
   * that the segment takes up (for standard layout managers),
   * or the number of grid units that the segment takes up (for 
   * proportioned layout managers).  Typically used to interact
   * with other segments and lines.  */
  float _span;

  /* The layout of the segment once minimum layout is done.  */
  GSAutoLayoutSegmentLayout _minimumLayout;

  /* The layout of the segment once layout is done.  */
  GSAutoLayoutSegmentLayout _layout;

  /* The layout of the segment contents once layout is done.  This is
   * the final computation result which we serve to clients.  */
  GSAutoLayoutSegmentLayout _contentsLayout;
}
@end

@class NSMutableArray;

@interface GSAutoLayoutManagerLine : NSObject
{
@public
  /* The forced length of the line, or < 0 if none.  */
  float _forcedLength;

  /* An array of GSAutoLayoutManagerSegment (or a subclass) objects.
   * Created/destroyed when the object is created/destroyed, but for
   * the rest managed directly by the GSAutoLayoutManager.  */
  NSMutableArray *_segments;
}
@end

#endif 
