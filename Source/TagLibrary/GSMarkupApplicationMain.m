/* -*-objc-*-
   GSMarkupApplicationMain.m

   Copyright (C) 2002 Free Software Foundation, Inc.

   Author: Pete French <pete@twisted.org.uk>
   Date: July 2003

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
#include <TagCommonInclude.h>
#include "GSMarkupApplicationMain.h"
#include "GSMarkupBundleAdditions.h"
#include <AppKit/AppKit.h>
#ifndef GNUSTEP
# include "GNUstep.h"
#endif


int
GSMarkupApplicationMain (int argc, const char **argv)
{
  CREATE_AUTORELEASE_POOL (pool);
  NSApplication *sharedApp = [NSApplication sharedApplication];
  NSBundle *mainBundle;
  NSString *mainMarkupFile;

  mainBundle = [NSBundle mainBundle];
  mainMarkupFile = [[mainBundle infoDictionary] objectForKey: 
						  @"GSMainMarkupFile"];
  
  if ((mainMarkupFile != nil) 
      && ([mainMarkupFile isEqual: @""] == NO))
    {
      NSDictionary *table;
      
      table = [NSDictionary dictionaryWithObject: sharedApp
			    forKey: @"NSOwner"];
      
      if([mainBundle loadGSMarkupFile: mainMarkupFile
		     externalNameTable: table
		     withZone: [sharedApp zone]] == NO)
        {
          NSLog (@"Cannot load the main markup file '%@'", mainMarkupFile);
        }
    }
  
  RELEASE (pool);
  return NSApplicationMain (argc, argv);
}
