/* -*-objc-*-
   Renaissance.h - main public header for GNUstep Renaissance

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: November 2002

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

#ifndef _GNUstep_H_Renaissance
#define _GNUstep_H_Renaissance

/* End-user applications typically need access to only a few
 * Renaissance headers.  This header file includes them.
 *
 * If you need access to Renaissance advanced stuff (markup tags and
 * objects - typically to create new tags, patch existing ones, or
 * implement a visual builder for Renaissance), you need to include
 * Renaissance/Markup.h.
 */

/* GNUstep compatibility macros */
#ifndef GNUSTEP
# include "GNUstep.h"
#endif

/* AutoLayout */
#include "GSAutoLayoutDefaults.h"
#include "NSViewSize.h"

/* Markup end-user functions */
#include "GSMarkupBundleAdditions.h"

#endif /* _GNUstep_H_Renaissance */
