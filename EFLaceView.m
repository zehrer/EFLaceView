#import "EFLaceView.h"

static void *_propertyObservationContext 				= (void *)1091, // 4 keyCodes
				*_dataObjectsObservationContext 			= (void *)1092,	
				*_selectionIndexesObservationContext 	= (void *)1093;

@implementation EFLaceView		
- (void)shouldAddInputHoleTo:(EFView*)v {//	[_inputs log];	EFView *vv = [self.subviews filterOne:^BOOL(id object) { return object == v; }];
	[self deselectViews];
	[self  selectView:v];
	[_inputs insert:nil];
	self.needsDisplay = YES;
}
#pragma mark - *** bindings ***
-   (void) bind:	(NSS*)b toObject:  (id)o 
	 withKeyPath:	(NSS*)kp options:  (NSD*)opt 				{
	 
	SameString( b, @"dataObjects" ) 		? ^{	[_dataObjectsContainer = o addObserver:self forKeyPath:_dataObjectsKeyPath = kp 
																								 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
																								 context:_dataObjectsObservationContext];
															[self startObservingDataObjects:self.dataObjects];
															[self         setOldDataObjects:self.dataObjects];
	}():	
	SameString( b, @"selectionIndexes") ?^{	[_selectionIndexesContainer = o addObserver:self forKeyPath:_selectionIndexesKeyPath = kp
																											options:0 context:_selectionIndexesObservationContext];	
	}():	
	[super bind:b toObject:o withKeyPath:kp options:opt];	[self setNeedsDisplay:YES];
}
-   (void) unbind:(NSS*)b				 							{

	SameString( b, @"dataObjects" ) 	  	?^{	[self stopObservingDataObjects:[self dataObjects]];
															[_dataObjectsContainer removeObserver:self forKeyPath:_dataObjectsKeyPath];
															[@[@"dataObjectsContainer", @"dataObjectsKeyPath"]setStringsToNilOnbehalfOf:self];					
	}():
	SameString( b, @"selectionIndexes" ) ?^{	[_selectionIndexesContainer removeObserver:self forKeyPath:_selectionIndexesKeyPath];
															[@[@"_selectionIndexesContainer", @"selectionIndexesKeyPath"]setStringsToNilOnbehalfOf:self];	
	}():  
	[super unbind:b];	[self setNeedsDisplay:YES];
}
-   (void) startObservingDataObjects:(NSA*)dataObjects	{			if ([dataObjects isEqual:AZNULL]) return;

/* 	Register to observe each of the new dataObjects, and each of their observable properties.
		we need old and new values for drawingBounds to figure out what our dirty rect 				*/
		
	NSI options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;		__block EFView *dummy;
	
	[dataObjects do:^(id newDataObj) { 															LOG_EXPR(newDataObj);

		[newDataObj addObserver:self forKeyPath:@"drawingBounds" options:options context:_propertyObservationContext];
		[newDataObj addObserver:self forKeyPath:@"titleColor" 	options:options context:_propertyObservationContext];
		
		[self    addSubview:dummy = EFView.new];
		[self scrollRectToVisible:dummy.bounds]; //make new view visible if view in scrolling view
		
		// bind view to data
		[@[@"title",@"titleColor", @"originX", @"originY", @"width", @"height",@"tag",@"verticalOffset", @"inputs",@"outputs", @"icon"]each:^(id obj) {
			[dummy bind:obj toObject:newDataObj withKeyPath:obj options:nil]; }];
		[@[@"icon",@"originX", @"originY", @"width", @"height",@"inputs", @"outputs"] each:^(id obj) {
			[newDataObj bind:obj toObject:dummy withKeyPath:obj options:nil]; }];
		
		[dummy setValue:newDataObj forKeyPath:@"data"];
	}];
}
-   (void) stopObservingDataObjects: (NSA*)dataObjects 	{	if ([dataObjects isEqual:AZNULL]) return;
	
	[dataObjects each:^(id oldDataObject) {	[oldDataObject removeObserver:self forKeyPath:@"drawingBounds"];
		
		[@[@"originX", @"originY",@"width", @"heigth", @"inputs", @"outputs"]each:^(id obj) { [oldDataObject unbind:obj]; }];
			[[self.subviews copy] each:^(EFView *aView) {
				if ([aView vFK:@"data"] != oldDataObject) return;
				[@[@"title",@"titleColor",@"originX",@"originY",@"width",@"height",@"tag",@"verticalOffset",@"inputs",@"outputs"]each:^(id obj){[aView unbind:obj]; }];
				[aView removeFromSuperview];
			}];
	}];
}
-   (void) observeValueForKeyPath:   (NSS*)keyPath 
								 ofObject:   (id)object 
									change:   (NSD*)change 
								  context:   (void*)context 		{	
								  
		context == _dataObjectsObservationContext 		? ^{
			
			NSA *_newDataObjects = [[object vFKP:_dataObjectsKeyPath] copy];				LOG_EXPR(_newDataObjects);
			[self startObservingDataObjects:[_newDataObjects arrayWithoutArray:[_oldDataObjects arrayByAddingObject:AZNULL]]];
			[self	stopObservingDataObjects: [_oldDataObjects arrayWithoutArray:[_newDataObjects arrayByAddingObject:AZNULL]]];
			self.oldDataObjects =_newDataObjects;
			[self setNeedsDisplay:YES];
}():	context == _propertyObservationContext 			? [self setNeedsDisplay:YES] :
		context == _selectionIndexesObservationContext 	? [self.subviews makeObjectsPerformSelector:@selector(setNeedsDisplay:) withObject:@YES] : nil;
//		//; each:^(NSView* v) { [v setNeedsDisplay:YES]; }] : nil;
}
#pragma mark - *** setters and accessors ***
-  (NSA*) dataObjects 												{	 return [[_dataObjectsContainer valueForKeyPath:_dataObjectsKeyPath] arrayWithoutObject:AZNULL];	}
- (EFView*) viewForData:(id)data 								{ return [self.subviews filterOne:^BOOL(EFView* view) { return [view valueForKey:@"data"] == data; }] ?: nil;	}
- (NSIS*) selectionIndexes 										{	return [_selectionIndexesContainer valueForKeyPath:_selectionIndexesKeyPath];	}
- (NSMA*) laces		 												{	return 

	[self.dataObjects reduce:NSMA.new withBlock:^id(id sum, id startObject) {
		[[startObject valueForKey:@"outputs"] each:^(id startHole) {
			[(NSSet*)[startHole valueForKey:@"laces"] each:^(id endHole){
				[sum addObject:@{@"startHole":startHole,@"endHole":endHole}.mutableCopy];//nil];
			}];
		}];
		return sum;
	}];
}

#pragma mark - *** drawing ***
-  (void) drawLinkFrom:(NSP)s to:(NSP)e color:(NSC*)c 	{	 [self drawLinkFrom:s to:e fromColor:c toColor:c]; }
-  (void) drawLinkFrom:(NSP)s to:(NSP)e fromColor:(NSC*)c toColor:(NSC*)c2  	{	

	NSColor *insideColor = c; NSP startPoint, endPoint; startPoint = s, endPoint = e;
	// a lace is made of an outside gray line of width 5, and a inside insideColor(ed) line of width 3
	NSPoint p0 = NSMakePoint(startPoint.x,startPoint.y );
	NSPoint p3 = NSMakePoint(endPoint.x,endPoint.y );
	NSPoint p1 = NSMakePoint(startPoint.x + treshold( (endPoint.x - startPoint.x) / 2, 50), startPoint.y);
	NSPoint p2 = NSMakePoint(endPoint.x -treshold((endPoint.x - startPoint.x)/2,50),endPoint.y);	
	//p0 and p1 are on the same horizontal line.  distance between p0 and p1 is set with the treshold fuction.  the same holds for p2 and p3.
	NSBP* path = NSBP.new;
	[path setLineWidth:0];
	[path appendBezierPathWithOvalInRect:NSMakeRect(startPoint.x-2.5,startPoint.y-2.5,5,5)];
	[path fillWithColor:WHITE];
	[path removeAllPoints];
	[path appendBezierPathWithOvalInRect:NSMakeRect(startPoint.x-1.5,startPoint.y-1.5,3,3)];
	[path fillWithColor:insideColor];
	[path removeAllPoints];
	[path appendBezierPathWithOvalInRect:NSMakeRect(endPoint.x-2.5,endPoint.y-2.5,5,5)];
	[path fillWithColor:WHITE];
	[path removeAllPoints];
	[path appendBezierPathWithOvalInRect:NSMakeRect(endPoint.x-1.5,endPoint.y-1.5,3,3)];
	[path fillWithColor:insideColor];
	[path removeAllPoints];
	[path moveToPoint:p0];
	[path curveToPoint:p3 controlPoint1:p1 controlPoint2:p2];
	[path strokeWithColor:GREY andWidth:5];
	[path removeAllPoints];
	[path moveToPoint:p0];
	[path curveToPoint:p3 controlPoint1:p1 controlPoint2:p2];
	[path strokeWithColor:insideColor andWidth:3];
}
//-  (BOOL) isOpaque 													{	return YES;	}
-  (void) drawRect:(NSR)rect 										{
	
	// Draw frame
	//	NSEraseRect(rect);
	//	if (![NSGraphicsContext currentContextDrawingToScreen])
	//	{
	//		NSFrameRect([self bounds]);
	//	}
	NSRectFillWithColor(self.bounds, [NSC colorWithPatternImage:[NSIMG imageNamed:@"wall"]]);
	// Draw laces
	[self.dataObjects each:^(id startObject) {
//		LOG_EXPR(startObject);
		id startHoles = [startObject vFK:@"outputs"];
		if ( [startHoles count] ) {
			EFView* startView = [self viewForData:startObject];
			for (id startHole in startHoles) {
				NSSet * endHoles = [startHole vFK:@"laces"];
				if (endHoles.count) {
					NSPoint startPoint = [startView startHolePoint:startHole];
					for (id endHole in endHoles) {
						id endData = [endHole vFK:@"data"];
						EFView* endView 	= [self viewForData:endData];
						NSPoint endPoint 	= [endView endHolePoint:endHole];
						startView.isSelected || endView.isSelected ? ^{
							NSColor *start, *end;
							start = startView.titleColor;
							end = endView.titleColor;
							
							[self drawLinkFrom:startPoint to:endPoint fromColor:start toColor:end];
							//:([NSGraphicsContext currentContextDrawingToScreen])?[NSColor selectedControlColor]:[NSColor yellowColor]] 
						}():	[self drawLinkFrom:startPoint to:endPoint color:[NSColor yellowColor]];
					}
				}
			}
		}
	}];
	
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
	if (_isRubbing) { NSBP *path;
		[path = [NSBezierPath bezierPathWithRect:NSUnionRect(NSMakeRect(_rubberStart.x,_rubberStart.y,0.1f,0.1f),NSMakeRect(_rubberEnd.x,_rubberEnd.y,0.1f,0.1f)) ]fillWithColor:[[WHITE blendedColorWithFraction:0.2f ofColor:BLACK]colorWithAlphaComponent:0.3f]];
		[NSBezierPath setDefaultLineWidth:0.5f];
		[path strokeWithColor:WHITE andWidth:1.0f];
		//NSFrameRect(rubber);[NSBezierPath strokeRect:rubber];
	}
}	
#pragma mark - *** geometry ***
-  (void) deselectViews 											{		[_selectionIndexesContainer setValue:nil forKeyPath:_selectionIndexesKeyPath];	}
-  (void) selectView:(EFView*)aView 							{	[self selectView:aView state:YES];	}
-  (void) selectView:(EFView*)aView state:(BOOL)select 	{

	NSMutableIndexSet *selection = [[self selectionIndexes] mutableCopy];
	unsigned int DataObjectIndex = [[self dataObjects] indexOfObject:[aView valueForKey:@"data"]];
	select ? [selection addIndex:DataObjectIndex] : [selection removeIndex:DataObjectIndex];
	[_selectionIndexesContainer setValue:selection forKeyPath:_selectionIndexesKeyPath];
}
-  (NSA*) selectedSubViews											{
																																	//	NSArray *selectedDataObjects = ;	NSPredicate *predicate = ;
		return [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"data IN %@", [self.dataObjects objectsAtIndexes:self.selectionIndexes]]];
}
-  (BOOL) isStartHole:(NSP)pnt 									{
 return [self.subviews any:^BOOL(EFView *efv) { return !([efv startHole:pnt]) ? NO : ^{ _startSubView = efv; _startHole = [efv startHole:pnt]; return YES; }();  }];
}
-  (BOOL) isEndHole:	 (NSP)pnt	 								{ return [self.subviews any:^BOOL(EFView *efv) { return ![efv endHole:pnt] ? NO : ^{ _endSubView = efv; _endHole = [efv endHole:pnt];
			return YES; }(); }]; }
#pragma mark - *** connections ***
-  (void) connectHole:(id)startHole  toHole:(id)endHole	{	if ([startHole valueForKey:@"data"] == [endHole valueForKey:@"data"]) return;

	NSDictionary *conn = @{@"startHole": startHole, @"endHole": endHole};
	if ([self.laces containsObject:conn]) return;	
	// check if already connected	for (NSDictionary *aDict in [self laces]) {		if ([conn isEqualToDictionary:aDict]) {			return;		}	}
	[self willChangeValueForKey:@"laces"];
	[[self laces] addObject: conn];
	[self didChangeValueForKey:@"laces"];
	[[startHole mutableSetValueForKey:@"laces"] addObject:endHole];
}
#pragma mark - *** events ***
-  (BOOL) acceptsFirstResponder	 								{	return YES;	}
-  (void) keyDown:  (NSE*)theEvent	 							{	
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
-  (void) mouseDown:(NSE*)theEvent 								{

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

//		for (NSString *key in [[newDataObject class] keysForNonBoundsProperties]) { @"tag",@"inputs",@"outputs",@"title",@"titleColor ",@"verticalOffset" ,@"originX",@"originY",@"width", @"height" [newDataObject addObserver:self forKeyPath:key options:0 context:_propertyObservationContext];	}	for  (NSString *key in [[oldDataObject class] keysForNonBoundsProperties]) {[oldDataObject removeObserver:self forKeyPath:key];	}
//		NSMA *onlyNew =	;	[onlyNew				  removeObject:AZNULL];	[onlyNew removeObjectsInArray:_oldDataObjects];
//		NSMA *removed =	_oldDataObjects.mutableCopy;		[removed				  removeObject:AZNULL];	[removed removeObjectsInArray:_newDataObjects];
//-	(id) delegate {	return _delegate;}-  (void) setDelegate:(id)newDelegate {	_delegate = newDelegate;}
//-  (NSA*)oldDataObjects { return _oldDataObjects; }-  (void) setOldDataObjects:(NSA*)anOldDataObjects {	if (_oldDataObjects != anOldDataObjects) {		_oldDataObjects = [anOldDataObjects mutableCopy];	}}
//+   (void) initialize 												{	[self exposeBinding:@"dataObjects"];	[self exposeBinding:@"selectionIndexes"];	}
//-   (NSA*) exposedBindings 										{	return @[@"dataObjects", @"selectedObjects"];												} 
//+ (NSSet*) keyPathsForValuesAffectingLaces				 	{	return [NSSet setWithObjects:@"dataObjects", nil];											} 

//	NSEnumerator *startObjects = [[self dataObjects] objectEnumerator];	id startObject;	while ((startObject = [startObjects nextObject])) {
//		if ( [startHoles = [startObject valueForKey:@"outputs"] count] )	{
//			NSEnumerator *startHolesEnum = [startHoles objectEnumerator];
//			id startHole;
//			while ((startHole = [startHolesEnum nextObject]))	{
//				NSSet * endHoles = 
//				if ([endHoles count])	{
//					NSEnumerator * endHolesEnum = [endHoles objectEnumerator];
//					id endHole;
//					while ((endHole = [endHolesEnum nextObject]))			{
//						NSMutableDictionary *aDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//						[_laces addObject:aDict];
//		}
//	}];	return _laces;
