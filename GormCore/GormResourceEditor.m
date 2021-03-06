/* GormResourceEditor.m
 *
 * Copyright (C) 2002 Free Software Foundation, Inc.
 *
 * Author:	Gregory John Casamento <greg_casamento@yahoo.com>
 * Date:	2002
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

#import <AppKit/NSImage.h>
#import <GNUstepBase/GNUstep.h>
#include "GormDocument.h"
#include "GormPrivate.h"
#include "GormResourceEditor.h"
#include "GormFunctions.h"
#include "GormPalettesManager.h"
#include "GormResource.h"
#import <GNUstepBase/NSDebug+GNUstepBase.h>


@implementation	GormResourceEditor

- (BOOL) acceptsTypeFromArray: (NSArray*)types
{
  return [types containsObject: NSFilenamesPboardType];
}

- (NSArray *) fileTypes
{
  return nil;
}

- (NSArray *) pbTypes
{
  return nil;
}

/*
 *	Dragging source protocol implementation
 */
- (void) draggedImage: (NSImage*)i endedAt: (NSPoint)p deposited: (BOOL)f
{
}

- (unsigned int) draggingSourceOperationMaskForLocal: (BOOL)flag
{
  return NSDragOperationCopy;
}

- (id) placeHolderWithPath: (NSString *)string
{
  return nil; 
}

- (void) drawSelection
{
}

- (id<IBDocuments>) document
{
  return document;
}

- (void) handleNotification: (NSNotification*)aNotification
{
  NSString *name = [aNotification name];
  if([name isEqual: GormResizeCellNotification])
    {
      NSDebugLog(@"Recieved notification");
      [self setCellSize: defaultCellSize()];
    }
}

- (void) addSystemResources
{
  // NSMutableArray    *list = [NSMutableArray array];
  // do nothing... this is the parent class.
}

/*
 *	Initialisation 
 */
- (id) initWithObject: (id)anObject inDocument: (id<IBDocuments>)aDocument
{
  if ((self = [super initWithObject: anObject inDocument: aDocument]) != nil)
    {
      NSButtonCell	*proto;

      [self setAutosizesCells: NO];
      [self setCellSize: NSMakeSize(72,72)];
      [self setIntercellSpacing: NSMakeSize(8,8)];
      [self setAutoresizingMask: NSViewMinYMargin|NSViewWidthSizable];
      [self setMode: NSRadioModeMatrix];
      /*
       * Send mouse click actions to self, so we can handle selection.
       */
      [self setAction: @selector(changeSelection:)];
      [self setDoubleAction: @selector(raiseSelection:)];
      [self setTarget: self];

      objects = [[NSMutableArray alloc] init];
      proto = [[NSButtonCell alloc] init];
      [proto setBordered: NO];
      [proto setAlignment: NSTextAlignmentCenter];
      [proto setImagePosition: NSImageAbove];
      [proto setSelectable: NO];
      [proto setEditable: NO];
      [self setPrototype: proto];
      RELEASE(proto);

      // do not insert it if it's nil.
      if(anObject != nil)
	{
	  [self addObject: anObject];
	}

      // add any initial objects
      [self addSystemResources];

      // set up the notification...
      [[NSNotificationCenter defaultCenter]
	addObserver: self
	selector: @selector(handleNotification:)
	name: GormResizeCellNotification
	object: nil];
    }
  return self;
}

- (void) close
{
  [super close];
  [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (NSString *) resourceType
{
  return @"resource";
}

- (void) addObject: (id)anObject
{
	if([objects containsObject: anObject] == NO) {
		[super addObject: anObject];
	} else {
		NSString *type = [self resourceType];
		NSString *msg = [NSString stringWithFormat: _(@"Problem adding %@"), type];
		NSRunAlertPanel(msg,
						@"%@",
						_(@"OK"),
						nil, 
						nil,
						_(@"A resource with the same name exists, remove it first."));
	}
}

- (void) makeSelectionVisible: (BOOL)flag
{
	if (flag == YES && selected != nil) {
		NSUInteger	pos = [objects indexOfObjectIdenticalTo: selected];
		NSInteger		r = pos / [self numberOfColumns];
		NSInteger		c = pos % [self numberOfColumns];
		
		[self selectCellAtRow: r column: c];
	} else {
		[self deselectAllCells];
	}
	[self displayIfNeeded];
	[[self window] flushWindow];
}

- (void) mouseDown: (NSEvent*)theEvent
{
  NSInteger row, column;
  NSInteger newRow, newColumn;
  NSEventMask eventMask = NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDown
			| NSEventMaskMouseMoved | NSEventMaskLeftMouseDragged
			| NSEventMaskPeriodic;
  NSPoint lastLocation = [theEvent locationInWindow];
  NSEvent* lastEvent = theEvent;
  NSPoint initialLocation;

  /*
   * Pathological case -- ignore mouse down
   */
  if ((_numRows == 0) || (_numCols == 0))
    {
      [super mouseDown: theEvent];
      return; 
    }

  lastLocation = [self convertPoint: lastLocation
		       fromView: nil];
  initialLocation = lastLocation;
  // If mouse down was on a selectable cell, start editing/selecting.
  if ([self getRow: &row
	    column: &column
	    forPoint: lastLocation])
    {
      if ([_cells[row][column] isEnabled])
	{
	  if ((self.mode == NSRadioModeMatrix) && _selectedCell != nil)
	    {
	      [_selectedCell setState: NSOffState];
	      [self drawCellAtRow: _selectedRow column: _selectedCol];
          [self deselectSelectedCell];
	      //_selectedCells[_selectedRow][_selectedCol] = NO;
	      _selectedCell = nil;
	      _selectedRow = _selectedCol = -1;
	    }
	  [_cells[row][column] setState: NSOnState];
	  [self drawCellAtRow: row column: column];
	  [_window flushWindow];
      [self selectCellAtRow:row column:column];
	  //_selectedCells[row][column] = YES;
	  _selectedCell = _cells[row][column];
	  _selectedRow = row;
	  _selectedCol = column;
	}
    }
  else
    {
      return;
    }
  
  lastEvent = [NSApp nextEventMatchingMask: eventMask
		     untilDate: [NSDate distantFuture]
		     inMode: NSEventTrackingRunLoopMode
		     dequeue: YES];
  
  lastLocation = [self convertPoint: [lastEvent locationInWindow]
		       fromView: nil];


  while ([lastEvent type] != NSEventTypeLeftMouseUp)
    {
      if((![self getRow: &newRow
		 column: &newColumn
		 forPoint: lastLocation])
	 ||
	 (row != newRow)
	 ||
	 (column != newColumn)
	 ||
	 ((lastLocation.x - initialLocation.x) * 
	  (lastLocation.x - initialLocation.x) +
	  (lastLocation.y - initialLocation.y) * 
	  (lastLocation.y - initialLocation.y)
	  >= 25))
	{
  	  NSPasteboard	*pb;
	  NSInteger pos;
	  pos = row * [self numberOfColumns] + column;

	  // don't allow the user to drag empty resources.
	  if(pos < [objects count])
	    {
	      pb = [NSPasteboard pasteboardWithName: NSDragPboard];
	      [pb declareTypes: [self pbTypes]
		  owner: self];
	      [pb setString: [(GormResource *)[objects objectAtIndex: pos] name] 
		  forType: [[self pbTypes] objectAtIndex: 0]];
	      [self dragImage: [[objects objectAtIndex: pos] imageForViewer]
		    at: lastLocation
		    offset: NSZeroSize
  		    event: theEvent
		    pasteboard: pb
		    source: self
		    slideBack: YES];
	    }

	  return;
	}

      lastEvent = [NSApp nextEventMatchingMask: eventMask
			 untilDate: [NSDate distantFuture]
			 inMode: NSEventTrackingRunLoopMode
			 dequeue: YES];
      
      lastLocation = [self convertPoint: [lastEvent locationInWindow]
			   fromView: nil];

    }

  [self changeSelection: self];

}

- (void) pasteInSelection
{
}

- (void) deleteSelection
{
  if(![selected isSystemResource])
    {
      if([selected isInWrapper])
	{
	  NSFileManager *mgr = [NSFileManager defaultManager];
	  NSString *path = [selected path];
	  BOOL removed = [mgr removeItemAtPath: path
			      error: NULL];
	  if(!removed)
	    {
	      NSString *msg = [NSString stringWithFormat: @"Could not delete file %@", path];
	      NSLog(@"%@",msg);
	    }
	}
      [super deleteSelection];
    }
}

- (id) raiseSelection: (id)sender
{
  id	obj = [self changeSelection: sender];
  id	e;

  e = [document editorForObject: obj create: YES];
  [e orderFront];
  [e resetObject: obj];
  return self;
}

- (void) refreshCells
{
  NSUInteger	count = [objects count];
  NSUInteger	index;
  NSInteger		cols = 0;
  NSInteger		rows;
  NSInteger		width;

  // return if the superview is not available.
  if(![self superview])
    {
      return;
    }

  width = [[self superview] bounds].size.width;
  while (width >= 72)
    {
      width -= (72 + 8);
      cols++;
    }
  if (cols == 0)
    {
      cols = 1;
    }
  rows = count / cols;
  if (rows == 0 || rows * cols != count)
    {
      rows++;
    }
  [self renewRows: rows columns: cols];

  for (index = 0; index < count; index++)
    {
      id		obj = [objects objectAtIndex: index];
      NSButtonCell	*but = [self cellAtRow: index/cols column: index%cols];
      NSString          *name = [(GormResource *)obj name];

      [but setImage: [obj imageForViewer]];
      [but setTitle: name];
      [but setShowsStateBy: NSChangeGrayCellMask];
      [but setHighlightsBy: NSChangeGrayCellMask];
    }
  while (index < rows * cols)
    {
      NSButtonCell	*but = [self cellAtRow: index/cols column: index%cols];

      [but setImage: nil];
      [but setTitle: @""];
      [but setShowsStateBy: NSNoCellMask];
      [but setHighlightsBy: NSNoCellMask];
      index++;
    }
  [self setIntercellSpacing: NSMakeSize(8,8)];
  [self sizeToCells];
  [self setNeedsDisplay: YES];
}

@end


