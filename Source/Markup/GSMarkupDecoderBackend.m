/* -*-objc-*-
   GSMarkupDecoderBackend.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Nicola Pero <n.pero@mi.flashnet.it>
   Date: March 2002, November 2002

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
#include <MarkupCommonInclude.h>
#include "GSMarkupDecoderBackend.h"
#include "GSMarkupDecoder.h"

/*
 * This file includes different implementations for the different
 * platforms.  Only one of them is actually used.  The backend to use
 * is chosen in GSMarkupDecoderBackend.h.
 */

@implementation GSMarkupDecoderBackend
- (void) parse
{
  /* Implemented in the subclass.  */
  return;
}
@end

#ifdef GSMARKUP_NSXML_BACKEND
# include "DecoderBackend/GSMarkupDecoderBackendNSXML.m"
#else
# ifdef GSMARKUP_GSXML_BACKEND
#  include "DecoderBackend/GSMarkupDecoderBackendGSXML.m"
# else
#  ifdef GSMARKUP_CFXML_BACKEND
#   include "DecoderBackend/GSMarkupDecoderBackendCFXML.m"
#  else
#   ifdef GSMARKUP_LIBXML_BACKEND
#    include "DecoderBackend/GSMarkupDecoderBackendLibXML.m"
#   endif
#  endif
# endif
#endif
