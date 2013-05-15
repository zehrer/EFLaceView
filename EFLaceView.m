//
//  EFLaceView.m
// EFLaceView
//

#import "EFLaceView.h"
#import "EFView.h"
#import <AtoZ/AtoZ.h>
#import <Carbon/Carbon.h> // 4 keyCodes
//#warning TODO : implement delegates

static void *_propertyObservationContext 				= (void *)1091;
static void *_dataObjectsObservationContext 			= (void *)1092;
static void *_selectionIndexesObservationContext 	= (void *)1093;

#pragma mark - *** utility functions***
float treshold(float x,float tr) {	return (x>0)?((x>tr)?x:tr):-x+tr;	}

@implementation EFLaceView
#pragma mark - *** bindings ***
+     (void) initialize 							{	[self exposeBinding:@"dataObjects"];	[self exposeBinding:@"selectionIndexes"];	}
- (NSA*) exposedBindings 						{	return @[@"dataObjects", @"selectedObjects"];												} 
+   (NSSet*) keyPathsForValuesAffectingLaces {	return [NSSet setWithObjects:@"dataObjects", nil];											} 
-     (void) bind:(NSString*)b toObject:(id)o withKeyPath:(NSString*)kp options:(NSDictionary*)opt {
	[b isEqualToString:@"dataObjects"] ? ^{
		_dataObjectsContainer	= o;
		_dataObjectsKeyPath 		= kp;
		[_dataObjectsContainer addObserver:self forKeyPath:_dataObjectsKeyPath 
											options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
											context:_dataObjectsObservationContext];
		[self startObservingDataObjects:[self dataObjects]];
		[self setOldDataObjects:[self dataObjects]];	}():	
	[b isEqualToString:@"selectionIndexes"] ?^{
		_selectionIndexesContainer = o;
		_selectionIndexesKeyPath 	= kp;
		[_selectionIndexesContainer addObserver:self forKeyPath:_selectionIndexesKeyPath 
													options:0 context:_selectionIndexesObservationContext];
	}():	[super bind:b toObject:o withKeyPath:kp options:opt];			[self setNeedsDisplay:YES];
}
-     (void) unbind:(NSString*)bindingName {

	[bindingName isEqualToString:@"dataObjects"] 	  ?^{
		[self stopObservingDataObjects:[self dataObjects]];
		[_dataObjectsContainer removeObserver:self forKeyPath:_dataObjectsKeyPath];
		_dataObjectsContainer 	= nil;
		_dataObjectsKeyPath 		= nil;					  }():
	[bindingName isEqualToString:@"selectionIndexes"] ?^{
		[_selectionIndexesContainer removeObserver:self forKeyPath:_selectionIndexesKeyPath];
		_selectionIndexesContainer 	= nil;
		_selectionIndexesKeyPath 		= nil; 			 }():  [super unbind:bindingName];		[self setNeedsDisplay:YES];
}
- (void)startObservingDataObjects:(NSArray *)dataObjects {
	if ([dataObjects isEqual:[NSNull null]]) 		return;
/* Register to observe each of the new dataObjects, and each of their observable properties -- we need old and new values for drawingBounds to figure out what our dirty rect */
	for (id newDataObject in dataObjects) {
		[newDataObject addObserver:self forKeyPath:@"drawingBounds" 
								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:_propertyObservationContext];
		EFView *dummy = EFView.new;
		[self addSubview:dummy];
		[self scrollRectToVisible:dummy.bounds]; //make new view visible if view in scrolling view
		// bind view to data
		[dummy bind:@"title" 			toObject:newDataObject withKeyPath:@"title" 				options:nil];
		[dummy bind:@"titleColor" 		toObject:newDataObject withKeyPath:@"titleColor" 		options:nil];
		[dummy bind:@"originX" 			toObject:newDataObject withKeyPath:@"originX" 			options:nil];
		[dummy bind:@"originY" 			toObject:newDataObject withKeyPath:@"originY" 			options:nil];
		[dummy bind:@"width" 			toObject:newDataObject withKeyPath:@"width" 				options:nil];
		[dummy bind:@"height"			toObject:newDataObject withKeyPath:@"height" 			options:nil];
		[dummy bind:@"tag" 				toObject:newDataObject withKeyPath:@"tag" 				options:nil];
		[dummy bind:@"verticalOffset" toObject:newDataObject withKeyPath:@"verticalOffset" 	options:nil];
		
		[dummy bind:@"inputs" toObject:newDataObject withKeyPath:@"inputs" options:nil];
		[dummy bind:@"outputs" toObject:newDataObject withKeyPath:@"outputs" options:nil];
		
		[newDataObject bind:@"originX" toObject:dummy withKeyPath:@"originX" options:nil];
		[newDataObject bind:@"originY" toObject:dummy withKeyPath:@"originY" options:nil];
		[newDataObject bind:@"width" toObject:dummy withKeyPath:@"width" options:nil];
		[newDataObject bind:@"height" toObject:dummy withKeyPath:@"height" options:nil];
		
		[newDataObject bind:@"inputs" toObject:dummy withKeyPath:@"inputs" options:nil];
		[newDataObject bind:@"outputs" toObject:dummy withKeyPath:@"outputs" options:nil];
		
		[dummy setValue:newDataObject forKeyPath:@"data"];
		
		for (NSString *key in [[newDataObject class] keysForNonBoundsProperties]) {	
			//@"tag",@"inputs",@"outputs",@"title",@"titleColor",@"verticalOffset",@"originX",@"originY",@"width",@"height"
			[newDataObject addObserver:self forKeyPath:key options:0 context:_propertyObservationContext];
		}
	}
}
- (void)stopObservingDataObjects:(NSArray *)dataObjects {
	if ([dataObjects isEqual:[NSNull null]]) {
		return;
	}
	
	for (id oldDataObject in dataObjects) {
		[oldDataObject removeObserver:self forKeyPath:@"drawingBounds"];
		for  (NSString *key in [[oldDataObject class] keysForNonBoundsProperties]) {
			[oldDataObject removeObserver:self forKeyPath:key];
		}
		[oldDataObject unbind:@"originX"];
		[oldDataObject unbind:@"originY"];
		[oldDataObject unbind:@"width"];
		[oldDataObject unbind:@"heigth"];
		[oldDataObject unbind:@"inputs"];
		[oldDataObject unbind:@"outputs"];
		
		for (EFView *aView in [[self subviews] copy]) {
			if ([aView valueForKey:@"data"] == oldDataObject) {
				[aView unbind:@"title"];
				[aView unbind:@"titleColor"];
				[aView unbind:@"originX"];
				[aView unbind:@"originY"];
				[aView unbind:@"width"];
				[aView unbind:@"height"];
				[aView unbind:@"tag"];
				[aView unbind:@"verticalOffset"];
				
				[aView unbind:@"inputs"];
				[aView unbind:@"outputs"];
				
				[aView removeFromSuperview];
			}
		}
	}
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == _dataObjectsObservationContext) {
		NSArray *_newDataObjects = [object valueForKeyPath:_dataObjectsKeyPath];		
		
		NSMutableArray *onlyNew = [_newDataObjects mutableCopy];
		[onlyNew removeObject:[NSNull null]];
		[onlyNew removeObjectsInArray:_oldDataObjects];
		[self startObservingDataObjects:onlyNew];
		
		NSMutableArray *removed = [_oldDataObjects mutableCopy];
		[removed removeObject:[NSNull null]];
		[removed removeObjectsInArray:_newDataObjects];
		[self stopObservingDataObjects:removed];
		
		[self setOldDataObjects:_newDataObjects];
		[self setNeedsDisplay:YES];
		return;
	}
	
	if (context == _propertyObservationContext)	{
		[self setNeedsDisplay:YES];
		return;
	}
	
	if (context == _selectionIndexesObservationContext) {
		for (NSView* view in [self subviews]) {
			[view setNeedsDisplay:YES];
		}
		return;
	}
}
#pragma mark - *** setters and accessors ***
-   (id) delegate {
	return _delegate;
}
- (void) setDelegate:(id)newDelegate {
	_delegate = newDelegate;
}
- (NSA*) dataObjects {
	NSMutableArray *result = [[_dataObjectsContainer valueForKeyPath:_dataObjectsKeyPath] mutableCopy];
	[result removeObject:[NSNull null]];
	return result;
}
- (EFView*) viewForData:(id)data {
	for (EFView* view in [self subviews]) {
		if ([view valueForKey:@"data"] == data) {
			return view;
		}
	}
	return nil;
}
- (NSIS*) selectionIndexes {
	return [_selectionIndexesContainer valueForKeyPath:_selectionIndexesKeyPath];
}
- (NSA*)oldDataObjects { return _oldDataObjects; }
- (void) setOldDataObjects:(NSArray *)anOldDataObjects {
	if (_oldDataObjects != anOldDataObjects) {
		_oldDataObjects = [anOldDataObjects mutableCopy];
	}
}
- (NSMA*) laces {
	NSMutableArray* _laces = [[NSMutableArray alloc]init];
	
	NSEnumerator *startObjects = [[self dataObjects] objectEnumerator];
	id startObject;
	while ((startObject = [startObjects nextObject]))
	{
		id startHoles = [startObject valueForKey:@"outputs"];
		if ([startHoles count]>0)
		{
			NSEnumerator *startHolesEnum = [startHoles objectEnumerator];
			id startHole;
			while ((startHole = [startHolesEnum nextObject]))
			{
				NSSet * endHoles = [startHole valueForKey:@"laces"];
				if ([endHoles count]>0)
				{
					NSEnumerator * endHolesEnum = [endHoles objectEnumerator];
					id endHole;
					while ((endHole = [endHolesEnum nextObject]))
					{
						NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:startHole,@"startHole",endHole,@"endHole",nil];
						[_laces addObject:aDict];
					}
				}
			}
		}
	}
	
	return _laces;
}
#pragma mark - *** drawing ***
- (void) drawLinkFrom:(NSPoint)startPoint to:(NSPoint)endPoint color:(NSColor *)insideColor {
	// a lace is made of an outside gray line of width 5, and a inside insideColor(ed) line of width 3
	
	NSPoint p0 = NSMakePoint(startPoint.x,startPoint.y );
	NSPoint p3 = NSMakePoint(endPoint.x,endPoint.y );
	
	NSPoint p1 = NSMakePoint(startPoint.x+treshold((endPoint.x - startPoint.x)/2,50),startPoint.y);
	NSPoint p2 = NSMakePoint(endPoint.x -treshold((endPoint.x - startPoint.x)/2,50),endPoint.y);	
	
	//p0 and p1 are on the same horizontal line
	//distance between p0 and p1 is set with the treshold fuction
	//the same holds for p2 and p3
	
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path setLineWidth:0];
	[[NSColor grayColor] set];
	[path appendBezierPathWithOvalInRect:NSMakeRect(startPoint.x-2.5,startPoint.y-2.5,5,5)];
	[path fill];
	
	path = [NSBezierPath bezierPath];
	[path setLineWidth:0];
	[insideColor set];
	[path appendBezierPathWithOvalInRect:NSMakeRect(startPoint.x-1.5,startPoint.y-1.5,3,3)];
	[path fill];
	
	path = [NSBezierPath bezierPath];
	[path setLineWidth:0];
	[[NSColor grayColor] set];
	[path appendBezierPathWithOvalInRect:NSMakeRect(endPoint.x-2.5,endPoint.y-2.5,5,5)];
	[path fill];
	
	path = [NSBezierPath bezierPath];
	[path setLineWidth:0];
	[insideColor set];
	[path appendBezierPathWithOvalInRect:NSMakeRect(endPoint.x-1.5,endPoint.y-1.5,3,3)];
	[path fill];
	
	path = [NSBezierPath bezierPath];
	[path setLineWidth:5];
	[path moveToPoint:p0];
	[path curveToPoint:p3 controlPoint1:p1 controlPoint2:p2];
	[[NSColor grayColor] set];
	[path stroke];
	
	
	path = [NSBezierPath bezierPath];
	[path setLineWidth:3];
	[path moveToPoint:p0];
	[path curveToPoint:p3 controlPoint1:p1 controlPoint2:p2];
	[insideColor set];
	[path stroke];
}
//- (BOOL)isOpaque {
//	return YES;
//}
- (void) drawRect:(NSRect)rect {
	
	// Draw frame
	//	NSEraseRect(rect);
	//	if (![NSGraphicsContext currentContextDrawingToScreen])
	//	{
	//		NSFrameRect([self bounds]);
	//	}
	
	// Draw laces
	for (id startObject in [self dataObjects]) {
		id startHoles = [startObject valueForKey:@"outputs"];
		if ([startHoles count]>0) {
			EFView* startView = [self viewForData:startObject];
			for (id startHole in startHoles) {
				NSSet * endHoles = [startHole valueForKey:@"laces"];
				if ([endHoles count]>0) {
					NSPoint startPoint = [startView startHolePoint:startHole];
					for (id endHole in endHoles) {
						id endData = [endHole valueForKey:@"data"];
						EFView* endView = [self viewForData:endData];
						NSPoint endPoint = [endView endHolePoint:endHole];
						if (startView.isSelected || endView.isSelected) {
							[self drawLinkFrom:startPoint to:endPoint color:([NSGraphicsContext currentContextDrawingToScreen])?[NSColor selectedControlColor]:[NSColor yellowColor]];
						} else {
							[self drawLinkFrom:startPoint to:endPoint color:[NSColor yellowColor]];
						}
					}
				}
			}
		}
	}
	
	// Draw lace being created
	if (_isMaking) {
		if (([self isEndHole:_endPoint])&&(_endSubView != _startSubView)) {
			_endPoint = [_endSubView endHolePoint:_endHole];
			[self drawLinkFrom:_startPoint to:_endPoint color:[NSColor yellowColor]];
		} else {
			[self drawLinkFrom:_startPoint to:_endPoint color:([NSGraphicsContext currentContextDrawingToScreen])?[NSColor whiteColor]:[NSColor yellowColor]];
		}
	}
	
	// Draw selection rubber band
	if (_isRubbing) {
		NSRect rubber = NSUnionRect(NSMakeRect(_rubberStart.x,_rubberStart.y,0.1f,0.1f),NSMakeRect(_rubberEnd.x,_rubberEnd.y,0.1f,0.1f));
		[NSBezierPath setDefaultLineWidth:0.5f];
		[[[[NSColor whiteColor] blendedColorWithFraction:0.2f ofColor:[NSColor blackColor]]colorWithAlphaComponent:0.3f] setFill];
		[NSBezierPath fillRect:rubber];
		[[NSColor whiteColor] setStroke];
		[NSBezierPath setDefaultLineWidth:1.0f];
		//NSFrameRect(rubber);
		[NSBezierPath strokeRect:rubber];
	}
}	
#pragma mark - *** geometry ***
- (void) deselectViews {
	[_selectionIndexesContainer setValue:nil forKeyPath:_selectionIndexesKeyPath];
}
- (void) selectView:(EFView *)aView {
	[self selectView:aView state:YES];
}
- (void) selectView:(EFView *)aView state:(BOOL)select {
	NSMutableIndexSet *selection = [[self selectionIndexes] mutableCopy];
	unsigned int DataObjectIndex = [[self dataObjects] indexOfObject:[aView valueForKey:@"data"]];
	if (select) {
		[selection addIndex:DataObjectIndex];
	} else {
		[selection removeIndex:DataObjectIndex];
	}
	[_selectionIndexesContainer setValue:selection forKeyPath:_selectionIndexesKeyPath];
}
- (NSA*) selectedSubViews{
	NSArray *selectedDataObjects = [[self dataObjects] objectsAtIndexes:[self selectionIndexes]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"data IN %@", selectedDataObjects];
	return [[self subviews] filteredArrayUsingPredicate:predicate];
}
- (BOOL) isStartHole:(NSPoint)aPoint {
	EFView *aView;
	NSEnumerator *enu =[[self subviews] objectEnumerator];
	while ((aView = [enu nextObject])) 	{
		if ([aView startHole:aPoint] != nil ) {
			_startSubView = aView;
			_startHole = [aView startHole:aPoint];
			return YES;
		}
	}
	return NO;
}
- (BOOL) isEndHole:(NSPoint)aPoint	{
	EFView *aView;
	NSEnumerator *enu =[[self subviews] objectEnumerator];
	while ((aView = [enu nextObject])) {
		if ([aView endHole:aPoint] != nil) {
			_endSubView = aView;
			_endHole = [aView endHole:aPoint];
			return YES;
		}
	}
	return NO;
}
#pragma mark - *** connections ***
- (void) connectHole:(id)startHole  toHole:(id)endHole {
	if ([startHole valueForKey:@"data"] == [endHole valueForKey:@"data"]) {
		return;
	}
	NSDictionary *conn = @{@"startHole": startHole, @"endHole": endHole};
	
	// check if already connected
	for (NSDictionary *aDict in [self laces]) {
		if ([conn isEqualToDictionary:aDict]) {
			return;
		}
	}
	[self willChangeValueForKey:@"laces"];
	[[self laces] addObject: conn];
	[self didChangeValueForKey:@"laces"];
	
	[[startHole mutableSetValueForKey:@"laces"] addObject:endHole];
}
#pragma mark - *** events ***
- (BOOL) acceptsFirstResponder {
	return YES;
}
- (void) keyDown:(NSEvent*)theEvent {	
	if([theEvent keyCode] == kVK_Delete) {
		if ([_dataObjectsContainer respondsToSelector:@selector(remove:)]) {
			// remove selected item
			[_dataObjectsContainer performString:@"remove:" withObject:self];
			[self setNeedsDisplay:YES];
			return;
		}
	}
	
	if (([theEvent keyCode] == kVK_Escape) && ([[self selectionIndexes] count]>0)) {
		[self deselectViews];
		[self setNeedsDisplay:YES];
		return;
	}
	
	NSBeep();
}
- (void) mouseDown:(NSEvent*)theEvent {
	NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	// Did we click on a start hole ?
	if (![self isStartHole:mouseLoc]) { 
		// clicked outside a hole for begining a new lace
		// Did we click on an end hole ?
		if (![self isEndHole:mouseLoc]) { 
			// clicked outside any hole : so manage selections
			[self deselectViews];
			
			//Rubberband selection
			_isRubbing = YES;
			_rubberStart = mouseLoc;
			_rubberEnd = mouseLoc;
			BOOL keepOn = YES;
			
			NSRect rubber;
			
			while (keepOn) {
				theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
				mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
				_rubberEnd = mouseLoc;
				rubber = NSUnionRect(NSMakeRect(_rubberStart.x,_rubberStart.y,0.1,0.1),NSMakeRect(_rubberEnd.x,_rubberEnd.y,0.1,0.1));
				
				switch ([theEvent type]) {
					case NSLeftMouseDragged: {
						// find views partially inside rubber and select them
						for (EFView* aView in [[self subviews] copy]) {
							[self selectView:aView state:NSIntersectsRect([aView frame],rubber)];
						}
						[self setNeedsDisplay:YES];
						break;
					}
					case NSLeftMouseUp: {
						keepOn = NO;
						_isRubbing = NO;
						
						[self setNeedsDisplay:YES];
						break;
					}
					default:
						/* Ignore any other kind of event. */
						break;
				}
			}
			return;
		}
		
		// We clicked on an end hole
		// Dragging from an existing connection end will disconnect and recontinue the drag 
		NSEnumerator *enu = [[self laces] reverseObjectEnumerator]; // last created lace first 
		NSDictionary *aDict;
		while ((aDict = [enu nextObject]))
		{
			if(aDict[@"endHole"] == _endHole) break;
		}
		if(!aDict) return; //nothing to un-drag...
		
		_startHole = aDict[@"startHole"];
		_startSubView = [self viewForData:[_startHole valueForKey:@"data"]];
		
		[_startHole willChangeValueForKey:@"laces"];
		[_endHole willChangeValueForKey:@"laces"];
		[self willChangeValueForKey:@"laces"];
		
		[[_startHole mutableSetValueForKey:@"laces"] removeObject:_endHole];
		[[_endHole mutableSetValueForKey:@"laces"] removeObject:_startHole];
		
		_startPoint = [_startSubView startHolePoint:_startHole];
		_endPoint = mouseLoc;
	} else { // we clicked on a start hole
		_startPoint = [_startSubView startHolePoint:_startHole];
	}
	
	_isMaking= YES;
	BOOL keepOn = YES;
	//BOOL isInside = YES;
	
	[[NSCursor crosshairCursor] set];
	while (keepOn) {
		theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
		mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		//isInside = [self mouse:mouseLoc inRect:[self bounds]];
		switch ([theEvent type]) {
			case NSLeftMouseDragged:
				_endPoint = mouseLoc;
				[self setNeedsDisplay:YES];
				break;
			case NSLeftMouseUp:
				[[NSCursor arrowCursor] set];
				if ([self isEndHole:mouseLoc]) {
					[self connectHole:_startHole toHole:_endHole];
				}
				keepOn = NO;
				_isMaking = NO;
				[_startHole didChangeValueForKey:@"laces"];
				[_endHole didChangeValueForKey:@"laces"];
				[self didChangeValueForKey:@"laces"];
				
				[self setNeedsDisplay:YES];
				break;
			default:
				/* Ignore any other kind of event. */
				break;
		}
	};
	return;
}

@end
