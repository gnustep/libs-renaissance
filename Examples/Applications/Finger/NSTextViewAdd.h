/*
 *  NSTextViewAdd.h: Trivial additions to NSTextView
 *
 *  Copyright (c) 2000-2002 Free Software Foundation, Inc.
 *  
 *  Author: Nicola Pero
 *  Date: February 2000, December 2002
 *
 *  This sample program is part of GNUstep.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _TRIVIAL_TEXT_VIEW_H
#define _TRIVIAL_TEXT_VIEW_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

/*
 * This object displays uneditable, unselectable attributed text.
 */
@interface NSTextView (Add)
-(void) resetString;
-(void) appendString: (NSString *)s;
-(void) appendBoldString: (NSString *)s;
@end

#endif /* _TRIVIAL_TEXT_VIEW_H */
