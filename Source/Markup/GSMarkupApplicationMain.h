/* -*-objc-*-
   GSMarkupApplicationMain.h

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

#ifndef _GNUstep_H_GSMarkupApplicationMain
#define _GNUstep_H_GSMarkupApplicationMain

/*
 * GSMarkupApplicationMain() is intended as a replacement for
 * NSApplicationMain() so that a main markup file is loaded at startup
 * as opposed to a main nib file.
 *
 * GSMarkupApplicationMain() is usually invoked in your main()
 * function; it gets the GSMainMarkupFile from the info dictionary in
 * the main bundle (this reads from the Info.plist file in the
 * application bundle), and loads it from the main bundle (with the
 * owner being the shared application object).  Then, it calls
 * NSApplicationMain().
 *
 * If you decide to use this function, your typical main() function
 * should look like the following:
 *
 * int main (int argc, const char **argv)
 * {
 *    return GSMarkupApplicationMain (argc, argv);
 * }
 *
 * You then add
 *
 *  xxx_MAIN_MARKUP_FILE = MainFile.gsmarkup
 *
 * to your GNUmakefile.  If you are not using gnustep-make, you should
 * set the key 'GSMarkupMainFile' in the application info dictionary
 * to the name of the markup file you want to be automatically loaded.
 *
 * Please note the parallel with NSApplicationMain() and loading the main
 * nib file in an application.
 */

/* TODO - exporting the function properly under Windows.  */
int GSMarkupApplicationMain (int argc, const char **argv);

#endif /* _GNUstep_H_GSMarkupApplicationMain */
