/* -*-objc-*-
   GSAutoLayoutViewDefaults.m

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

#include "GSAutoLayoutDefaults.h"

@implementation NSView (AutoLayoutDefaults)

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  return GSAutoLayoutAlignCenter;
}

- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{
  return GSAutoLayoutAlignCenter;
}

- (float) autolayoutDefaultHorizontalBorder
{
  return 4;
}

- (float) autolayoutDefaultVerticalBorder
{
  return 4;
}

@end

#ifdef GNUSTEP
# include <AppKit/NSTextField.h>
#endif

@implementation NSTextField (AutoLayoutDefaults)

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  if ([self isBezeled]  ||  [self isEditable])
    {
      return GSAutoLayoutExpand;
    }
  
  return GSAutoLayoutAlignCenter;
}

@end

#ifdef GNUSTEP
# include <AppKit/NSForm.h>
#endif

@implementation NSForm (AutoLayoutDefaults)

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  return GSAutoLayoutExpand;
}

@end

#ifdef GNUSTEP
# include <AppKit/NSTextView.h>
#endif

@implementation NSTextView (AutoLayoutDefaults)

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  return GSAutoLayoutExpand;
}

- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{
  return GSAutoLayoutExpand;
}

@end

#ifdef GNUSTEP
# include <AppKit/NSScrollView.h>
#endif

@implementation NSScrollView (AutoLayoutDefaults)

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  return GSAutoLayoutExpand;
}

- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{
  return GSAutoLayoutExpand;
}

@end

#ifdef GNUSTEP
# include <AppKit/NSBox.h>
#endif

@implementation NSBox (AutoLayoutDefaults)

- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{
  NSView *contentView = [self contentView];
  GSAutoLayoutAlignment flag;
  flag = [contentView autolayoutDefaultHorizontalAlignment];

  if (flag == GSAutoLayoutExpand  ||  flag == GSAutoLayoutWeakExpand)
    {
      return flag;
    }

  return GSAutoLayoutAlignCenter;
}

- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{
  NSView *contentView = [self contentView];
  GSAutoLayoutAlignment flag;
  flag = [contentView autolayoutDefaultVerticalAlignment];

  if (flag == GSAutoLayoutExpand  ||  flag == GSAutoLayoutWeakExpand)
    {
      return flag;
    }

  return GSAutoLayoutAlignCenter;
}

@end
