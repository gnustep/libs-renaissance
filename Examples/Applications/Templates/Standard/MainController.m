/*
 * This file is part of Renaissance's Template Standard Application.
 * You can use it as a starting point for your own programs, no matter
 * what their copyright is.  You can remove this notice and replace it
 * with your own.  This file is in the public domain.
 */

#include "MainController.h"
#include <Renaissance/Renaissance.h>

@implementation MainController

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification
{
  [NSBundle loadGSMarkupNamed: @"MainWindow"  owner: self];  
}


/* Your methods go in here.  */

@end

