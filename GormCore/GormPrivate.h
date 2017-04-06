/* GormPrivate.h
 *
 * Copyright (C) 1999, 2003 Free Software Foundation, Inc.
 *
 * Author:	Richard Frith-Macdonald <richard@brainstrom.co.uk>
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	1999, 2003
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
 */

#ifndef INCLUDED_GormPrivate_h
#define INCLUDED_GormPrivate_h

#import <GormLib/IBApplicationAdditions.h>
#import <GormLib/IBInspector.h>
#import <GormLib/IBViewAdditions.h>
#import <GormCore/GormFilesOwner.h>
#import <GormCore/GormDocument.h>
#import <GormCore/GormInspectorsManager.h>
#import <GormCore/GormClassManager.h>
#import <GormCore/GormPalettesManager.h>
#import <GormCore/GormProtocol.h>
#import <GormCore/GormClassEditor.h>
#import <GNUstepGUI/GSGormLoading.h>
#import <GormCore/PrivateCocoaClasses.h>

extern NSString *GormLinkPboardType;
extern NSString *GormToggleGuidelineNotification;
extern NSString *GormDidModifyClassNotification;
extern NSString *GormDidAddClassNotification;
extern NSString *GormDidDeleteClassNotification;
extern NSString *GormWillDetachObjectFromDocumentNotification;
extern NSString *GormResizeCellNotification;

@class	GormDocument;
@class	GormInspectorsManager;
@class	GormPalettesManager;

// templates
@interface GSNibItem (GormAdditions)
- (id) initWithClassName: (NSString*)className;
- (id) initWithClassName: (NSString*)className frame: (NSRect)frame;
- (NSString*) className;
@end

@interface GSClassSwapper (GormCustomClassAdditions)
+ (void) setIsInInterfaceBuilder: (BOOL)flag;
- (BOOL) isInInterfaceBuilder;
@end

@interface NSClassSwapper (GormCustomClassAdditions)
+ (void) setIsInInterfaceBuilder: (BOOL)flag;
- (BOOL) isInInterfaceBuilder;
@end

@interface GormObjectProxy : GSNibItem 
/*
 * Use a GormObjectProxy in Gorm, but encode a GSNibItem in the archive.
 * This is done so that we can provide our own decoding method
 * (GSNibItem tries to morph into the actual class)
 */
- (void) setClassName: (NSString *)className;
@end

@interface GormClassProxy : NSObject
{
  NSString *name;
  NSInteger t;
}

- (id)initWithClassName: (NSString*)n;
- (NSString*) className;
- (NSString*) inspectorClassName;
- (NSString*) connectInspectorClassName;
- (NSString*) sizeInspectorClassName;
@end

/*
 * NSDateFormatter and NSNumberFormatter extensions
 * for Gorm Formatters used in the Data Palette
 */

@interface NSDateFormatter (GormAdditions)

+ (NSInteger) formatCount;
+ (NSString *) formatAtIndex: (NSInteger)index;
+ (NSInteger) indexOfFormat: (NSString *) format;
+ (NSString *) defaultFormat;
+ (id) defaultFormatValue;

@end

@interface NSNumberFormatter (GormAdditions)

+ (NSInteger) formatCount;
+ (NSString *) formatAtIndex: (NSInteger)index;
+ (NSString *) positiveFormatAtIndex: (NSInteger)index;
+ (NSString *) zeroFormatAtIndex: (NSInteger)index;
+ (NSString *) negativeFormatAtIndex: (NSInteger)index;
+ (NSDecimalNumber *) positiveValueAtIndex: (NSInteger)index;
+ (NSDecimalNumber *) negativeValueAtIndex: (NSInteger)index;
+ (NSInteger) indexOfFormat: (NSString *)format;
+ (NSString *) defaultFormat;
+ (id) defaultFormatValue;
- (NSString *) zeroFormat;

@end

@interface NSObject (GormAdditions)
- (id) allocSubstitute;
- (NSImage *) imageForViewer;
@end

@interface IBResourceManager (GormAdditions)
+ (void) registerForAllPboardTypes: (id)editor
                        inDocument: (id)document;
@end

#endif
