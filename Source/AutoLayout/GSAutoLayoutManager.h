/* -*-objc-*-
   GSAutoLayoutManager.h

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

#ifndef _GNUstep_H_GSAutoLayoutManager
#define _GNUstep_H_GSAutoLayoutManager

#ifndef GNUSTEP
# include <Foundation/Foundation.h>
# include <AppKit/AppKit.h>
# include "GNUstep.h"
#else
# include <Foundation/NSObject.h>
#endif

#include "GSAutoLayoutDefaults.h"

/* This design is old and could be changed.  */

/*
 * There are potentially infinite ways in which you may want to
 * arrange your objects in a window. :-)
 *
 * Renaissance/AutoLayout provides a few classes which should allow
 * you to autolayout your objects, with a small effort, in
 * most standard cases.
 *
 * The basic intelligent objects in these classes are the
 * GSAutoLayoutManager objects.
 *
 * There are two main subclasses, GSAutoLayoutStandardManager and
 * GSAutoLayoutProportionalManager.  You are not supposed to create
 * other subclasses, and only rarely to interact with them directly -
 * autolayout managers are mainly used internally by the user-level
 * objects (boxes and grids).
 *
 * A single GSAutoLayoutManager performs the basic autolayout
 * operations on a line.  Basically, it manages a line, and decides
 * how to break the line into segments, or how to line up segments in
 * order to build up the line.  Additionally, the autolayout manager
 * can manage multiple lines at the same time, and break those lines
 * in segments (/build those lines from segments) in such a way that
 * the resulting layout for the different lines are related between
 * them: at minimum, all the lines must be of the same total size;
 * additional relations between the layout of the lines, depending on
 * mutable conditions, can be implemented by subclasses.
 * [To understand the requirement of supporting multiple lines, think
 * of a table.  Each row in the table is a line to be broken in
 * columns - the segments; and all rows in the table must be the same
 * total size, and must be broken in segments in a similar way - in
 * this framework they would share the same autolayout manager)].
 *
 * Finally, when an autolayout manager has made the layout with
 * segments, in each segment it aligns the `segment content' according
 * to the border and alignment which was specified for that segment.
 *
 * We consider all this the primitive autolayout operation, at least for
 * our boxes and grids.
 *
 * GSAutoLayoutManager is an abstract class; its concrete subclasses
 * provide different strategies of implementing this primitive
 * autolayout operation (eg, GSAutoLayoutStandardManager breaks the
 * line into segments of unrelated size - while
 * GSAutoLayoutProportionalManager breaks the line into segments of
 * equal (or proportional) size).
 *
 * To manage lines autolayout, a GSAutoLayoutManager needs some
 * information about what is to be displayed in the lines.  Clients
 * (usually box and grid objects) register themselves with the
 * GSAutoLayoutManager.  A client can register a line, and is given
 * back an id, which uniquely identify that line.  The client can then
 * update the autolayout manager information about that line (and the
 * segments contained in that line) at any time.  Whenever asked, the
 * autolayout manager performs full layout depending on the
 * information it has on the lines and segments.  When the autolayout
 * manager changes the layout of the lines, it posts a
 * GSAutoLayoutManagerChangedLayout notification, which the clients
 * should observe.  Once a client is informed that the layout has
 * changed, the client can request to the autolayout manager
 * information about the new way its line has been broken into
 * segments.
 *
 * This design is extremely general, but it's not extremely efficient.
 * Efficiency was not considered relevant, since in normal conditions
 * real window layouts are composed of a few elements (a box normally
 * does not contain more than 10 elements).
 *
 * The GSAutoLayoutManager uses the following information on each
 * segment contained in a line:
 *
 *  - each segment on a line is identified by an integer, starting
 *  from 0 and going up.  The only importance of this integer is to
 *  allow the clients and the autolayout manager to have a way of
 *  identifying segments on a line, and to specify the sequence of
 *  segments on the line - segment 0 is always before segment 1 on the
 *  line etc.  Please note that there is no relationship between the
 *  numbers used in one line and on the other one (that is, you should
 *  not expect segment 4 on one line to be aligned with segment 4 on
 *  another line).  This number is really an internal identifier used
 *  between the client and the autolayout manager.
 *
 *  - the left and right border of the segment.  These are used so that
 *  there can be some space around the segment content.
 *
 *  - the minimum size of the segment content.
 *
 *  - the minimum size of the segment - this is computed by summing up
 *  the left border, the right border, and the minimum size of the
 *  segment content.  The GSAutoLayoutManager, no matter what
 *  algorithm uses to break the line into segments, should never make
 *  a segment shorter than this size.
 *
 *  - the alignment type for the segment content.  This might either
 *  be expand, or not expand (in which case there are three variants,
 *  center, min, and max).  We first discuss the expand flag.  0 means
 *  the segment prefers to stay of its minimum size and not to be
 *  expanded, while 1 means the segment likes to be expanded (0 is
 *  used by views where the minimum size already displays all
 *  available information so there is no point in making the view
 *  bigger; 1 is used by views where the minimum size is enough to
 *  display some information, but making the view bigger displays more
 *  information - so it's good).  This flag must be honoured if it's
 *  1: ie, the autolayout manager should, whenever possible, try to
 *  expand segments which have the expand flag set to 1.  The
 *  behaviour when the expand flag is 0 depends on the specific
 *  autolayout manager.  The GSAutoLayoutProportionalManager always
 *  expands all segments, thus ignoring the flag; the
 *  GSAutoLayoutStandardManager always expands if possible segments
 *  with an expand flag of 1, but can't guarantee that segments with
 *  an expand flag of 0 won't be expanded too (if they are lined up
 *  with segments with an expand flag of 1 in another line, they will
 *  be expanded too).
 *  If the alignment type is not expand (that is, expand is 0), then
 *  it might either be min, max or center - this is how the segment
 *  contents are to be aligned inside the segment (after the border
 *  have been taken into accounts).  GSAutoLayoutProportionalManager
 *  always expands everything and so ignores this alignment type;
 *  GSAutoLayoutStandardManager instead tries to honour it - if a
 *  segment is made bigger than its minimum size, the alignment type
 *  is always honoured when placing the segment contents inside the
 *  segment.
 *
 *  - a span (an integer) for the segment.  The default is 1.  This is
 *  is only used when multiple lines are being laid out, in which case
 *  it is the number of columns (assuming eg it's laying out in the
 *  horizontal direction) that the segment takes up.  If there is a
 *  single line, it's basically ignored.
 *
 *  - a proportion (a float) for the segment.  The default is 1.  A
 *  GSAutoLayoutProportionalManager interprets it as a scaling of the
 *  number of basic units that the segment takes up.  Eg, a segment
 *  with proportion=2 would automatically have double the size of one
 *  with proportions=1 but still span the same number of columns.  In
 *  general, a segment takes up (span * proportion) units.  The
 *  standard manager currently ignores it.
 */

/* This struct is used to store and return layout information for a
 * segment.  */
typedef struct 
{
  float position;
  float length;
} GSAutoLayoutSegmentLayout;

@class NSMutableSet;

@interface GSAutoLayoutManager : NSObject
{
  /* The GSAutoLayoutManagerLine objects, which store the autolayout
   * information.  */
  NSMutableSet *_lines;

  /* The minimum length of the lines.  */
  float _minimumLength;

  /* The current length of the lines.  */
  float _length;

  /* If we need to recompute the minimum layout.  Set to YES when
   * a segment's attribute changes.  */
  BOOL _needsUpdateMinimumLayout;

  /* If we need to recompute the layout.  Set to YES when a line's
   * forced length is changed.  */
  BOOL _needsUpdateLayout;
}

/* There are two types of layout an autolayout manager should be able
 * to perform.  
 *
 * The first is bottom-to-top autolayout, that is, building lines from
 * the composing segments.  In this type of autolayout, the autolayout
 * manager starts by basically setting all segments to their minimum
 * size, and then adjusting this layout (by enlarging segments) to
 * meet the constrains (lines of the same length, and other constrains
 * imposed by the segment flags and segment relationships).  The
 * resulting layout is the layout of minimum length which still
 * satisfies all constrains (segments are >= their minimum length, all
 * lines are of the same size, etc).  This layout is the starting
 * point of all layout changes - all layout changes are always
 * relative to this minimum layout.  The autolayout manager
 * automatically and always computes and keeps updated this layout
 * every time a layout change occurs, because this ideal minimum
 * layout is needed as a reference to actually build the actual
 * layout.  When you first display objects in a window, everything
 * is/should normally be displayed by default in this layout, unless a
 * frame change is later performed at the user request.  Whenever you
 * change the attributes of some of the segments (its expand flag, or
 * its minimum length, or its span or proportion), this minimum autolayout
 * is automatically recomputed as soon as you invoke -updateLayout.
 *
 * The second is top-to-bottom autolayout, that is, breaking lines in
 * segments.  This type of autolayout is needed when the user acts on
 * the window in some way, and this action modifies the layout
 * (typically by enlarging or reducing the window size, or by moving a
 * splitview divider bar, or similar).  In this type of autolayout,
 * the autolayout manager is informed that the length of one (or more)
 * of its lines has been forced to be a certain fixed amount
 * (different than the minimum length).  The autolayout manager starts
 * by considering the forced lengths of the lines, and searching for
 * the minimum forced length; it makes all lines of that length -
 * unless that would be less than the minimum line lenght, in which
 * case the autolayout manager will simply adopt the minimum length
 * layout, refusing to resize the lines it is managing below their
 * minimum length - knowing that this means that part of the lines
 * will be clipped in the window.  The autolayout manager then
 * computes the difference between the actual line length and the
 * minimum line lenght, and decides how to share the difference in
 * length between the different segments.
 *
 * To cause autolayout to be performed/updated, you call
 * -updateLayout.  When this method is called, the layout manager
 * first calls -internalUpdateMinimumLayout to recompute its minimum
 * layout (if any attribute of any segment changed); then, if the
 * minimum layout changed, or some other thing requiring the layout to
 * be updated happened, the layout manager computes the new line
 * length taking into account forced line lengths.  It computes the
 * minimum forced line length of all the lines.  If the forced length
 * is less than the minimum length, the autolayout manager sets the
 * line length to _length, but actually uses the minimum layout as the
 * layout of views - which means some views are likely going out the
 * line! normally that simply results in clipping of them.  It then
 * calls -internalUpdateLayout to update the layout.  If
 * -internalUpdateLayout returns YES, it posts an
 * GSAutoLayoutManagerChangedLayoutNotification.
 *
 * You should call this method after you have sent to the autolayout
 * manager all updated or new information about the layout you have.
 * In a typical session, you first update the layout information by
 * calling many times methods adding/removing/modifying segments/lines
 * and/or forcing lines to be of certain lengths, then finally you
 * perform new layout by calling -updateLayout.
 */
- (void) updateLayout;

/* Subclasses should override this method to update the minimum
 * layout.  This method is called when the superclass has determined
 * that there is a need to update the minimum layout.  The subclass
 * should recompute the minimum layout from scratch starting from the
 * segments and from the segments info (the forced line lengths should
 * be ignored).  The results of this minimum layout should be stored
 * in the _minimumLayout ivar for segments, and in the global
 * _minimumLength ivar for the global minimum length of lines.  This
 * method should return YES if there was a change in the minimum
 * layout, and NO if at the end of the recomputation, the minimum
 * layout was found to be the same.  Returning NO in certain cases
 * prevents further useless computations to be done, but it is only
 * for efficiency - it's safe to always return YES.
 */
- (BOOL) internalUpdateMinimumLayout;

/* Subclasses should override this method to update the layout.  This
 * method is called when the superclass has determined that there is a
 * need to update the layout, and after the minimum layout has been
 * updated if there is a need to, and the new _length that the lines
 * must have has been computed.  This method is only called if this
 * _length is bigger than the _minimumLength.  The subclass should
 * decide how to distribute the difference between the _length and the
 * _minimumLength in each line between the various segments.  This
 * method should return YES if there was a change in the layout, and
 * NO if at the end of the recomputation, the layout was found to be
 * the same.  Returning NO prevents the notification for changed layout
 * to be sent to clients, so it's better to return NO if we can determine
 * that no layout change was done.  */
- (BOOL) internalUpdateLayout;


/* NB: All the GSAutoLayoutManager methods DO NOT CAUSE ANY AUTOLAYOUT
 * UNTIL YOU CALL -updateLayout.  */

/* Add a new line to the autolayout manager.  The returned id is an
 * identifier for that line used in all subsequent communications with
 * the layout manager.  The line is created with no segments inside.
 */
- (id) addLine;

/* Remove a line from the autolayout manager.  */
- (void) removeLine: (id)line;

/* Force the lenght of a line.  Normally called to inform the autolayout
 * manager of a resizing operated by outside.  Use length < 0 to remove
 * a forcing on a line.  */
- (void) forceLength: (float)length
	      ofLine: (id)line;

/* Insert a new segment in a line.  The segment is inserted at the
 * specified index; all following segments are automatically shifted (the
 * segment numbers of those segments will change too).  */
- (void) insertNewSegmentAtIndex: (int)segment
			  inLine: (id)line;

/* Remove a segment from a line.  All segments following this one will
 * be automatically be shifted (the segment number will change
 * too).  */
- (void) removeSegmentAtIndex: (int)segment
		       inLine: (id)line;

/* Return the number of segments in that line.  */
- (unsigned int) segmentCountInLine: (id)line;

/* Set/read the various autolayout information for segments in a line.  */
- (void) setMinimumLength: (float)min
		alignment: (GSAutoLayoutAlignment)flag
		minBorder: (float)minBorder
		maxBorder: (float)maxBorder
		     span: (int)span
	       proportion: (float)proportion
	 ofSegmentAtIndex: (int)segment
		   inLine: (id)line;

- (float) minimumLengthOfSegmentAtIndex: (int)segment
				 inLine: (id)line;

- (GSAutoLayoutAlignment) alignmentOfSegmentAtIndex: (int)segment
					     inLine: (id)line;

- (int) spanOfSegmentAtIndex: (int)segment
		      inLine: (id)line;

- (float) proportionOfSegmentAtIndex: (int)segment
			      inLine: (id)line;

- (float) minBorderOfSegmentAtIndex: (int)segment
			     inLine: (id)line;

- (float) maxBorderOfSegmentAtIndex: (int)segment
			     inLine: (id)line;

/* Read the result of autolayout for a line.  The clients should use
 * these methods to get the new layout when they receive the
 * GSAutoLayoutManagerChangedLayoutNotification.  */
- (float) lineLength;

/* This returns the final layout of the segment *contents*.  */
- (GSAutoLayoutSegmentLayout) layoutOfSegmentAtIndex: (int)segment
					      inLine: (id)line;

/* The minimum length of a line in the minimum autolayout.  Useful for
 * implementing -minimumSizeForContent.  */
- (float) minimumLineLength;
@end

extern NSString *GSAutoLayoutManagerChangedLayoutNotification;

#endif 
