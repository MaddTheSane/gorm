/* OCHeaderParser.h
 *
 * Copyright (C) 1999 Free Software Foundation, Inc.
 *
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	1999, 2002
 *
 * This file is part of GNUstep.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <Foundation/NSObject.h>

#ifndef INCLUDED_OCIVar_h
#define INCLUDED_OCIVar_h

@class NSMutableArray, NSString;

@interface OCIVar : NSObject
{
  NSString              *name;
  BOOL                  isOutlet;
  NSString              *ivarString;
}

- (instancetype) initWithString: (NSString *)string;
@property (copy) NSString *name;
@property BOOL isOutlet;
- (void) parse;
@end

#endif
