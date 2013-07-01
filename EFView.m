//  EFView.m    EFLaceView

#import "EFView.h"
#import "EFLaceView.h"
#define HOLESIZE 10

static void *_inoutputObservationContext = (void *)1094;

//@synthesize inputs = _inputs, outputs = _outputs;

//- (id)init {	return [self initWithFrame:AZRectFromDim(20)];	}
@implementation EFView
- (void) viewDidMoveToSuperview {

		self.delegate = [self.superviews objectWithClass:EFLaceView.class];
		NSLog(@"Lacey delegate: %@... %@", _delegate, _delegate.propertiesPlease);

}
- (id)initWithFrame:(NSRect)frame {
	
	if (self != [super initWithFrame:AZRectCheckWithMinSize(frame, (NSSZ){100,100})] ) return nil;
	
	[self.window setAcceptsMouseMovedEvents:YES];
	_inputs		 		= NSMutableSet.new;
	_outputs 			= NSMutableSet.new;
	_stringAttributes = @{NSFontAttributeName :AtoZ.controlFont,NSForegroundColorAttributeName:RANDOMCOLOR}.mutableCopy;
	_title 				= @"Title bar";
	NSSize titleSize 	= [self.title sizeWithAttributes:_stringAttributes];
	_titleColor		 	= ORANGE;
	_verticalOffset = titleSize.height / 2;
	[self setFrameSize:[self minimalSize]];
	[self setNeedsDisplay:YES];
	[NSEVENTLOCALMASK:NSMouseMovedMask|NSRightMouseDownMask handler:^NSEvent *(NSEvent *e){
		if (e.type == NSMouseMoved) {
			BOOL isit = [self.dragZone containsPoint:self.windowPoint];
			if ( isit != _shouldResize) { self.shouldResize = isit; self.needsDisplay = YES; }
		}
		else if ( e.type == NSRightMouseDown) {
			LOG_EXPR(e.locationInWindow);
			LOG_EXPR(self.frame);
		 	if ( NSPointInRect(self.superview.windowPoint, self.frame) ) {
				[AZTalker say:$(@"right click! in view %ld", [self.superview.subviews indexOfObject:self])];
				if (_delegate && [_delegate respondsToSelector:@selector(shouldAddInputHoleTo:)])
					[_delegate shouldAddInputHoleTo:self];
				else [AZTalker say:@"something wrong with delegate!"];
			}
		}
			return e;
	}];
	// need to update view when labels or positions are changed in inputs or ouputs
  	[self addObserver:self forKeyPath:@"inputs" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:_inoutputObservationContext];
  	[self addObserver:self forKeyPath:@"outputs" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:_inoutputObservationContext];
	return self;
}
- (NSImage*)icon { 	return _icon ?: ^{ return self.icon = NSIMG.randomMonoIcon;  }(); }
- (void)removeFromSuperview {
	
	[[_inputs.allObjects arrayByAddingObjectsFromArray:_outputs.allObjects]each:^(id obj) {
		[@[@"label", @"position"]do:^(id k){ [obj removeObserver:self forKeyPath:k]; }];
	}];
	[super removeFromSuperview];
}
- (void)dealloc {	[@[@"inputs", @"outputs"]do:^(id k){ [self removeObserver:self forKeyPath:k]; }]; }
#pragma mark - *** setters and accessors ***
- (void) setVerticalOffset:(CGF)o	{
	_verticalOffset 	= MAX(o, 0);
	self.height 		= MAX(self.minimalSize.height, self.height);
	[self.superview setNeedsDisplay:YES];
}
- (BOOL) isSelected 				 		{
	return [((EFLaceView*)self.superview).selectedSubViews containsObject:self];
}
- (NSC*) color 							{ NSLog(@" fetching coolor %@", _titleColor);
	return _titleColor;
}
- (void) setTitleColor:(NSC*)c {	
	if (c == [self titleColor])return;
	_titleColor = c;
	[self setNeedsDisplay:YES];
}
- (NSS*) title 				{	return _title ?: @"N/A"; }
- (void) setTitle:(NSS*)t 	{	if (t == _title) return;	_title = t;
	self.width = MAX(self.minimalSize.width, self.width);	self.needsDisplay = YES;
}
-  (CGF) originX 				{	return super.originX;	}
-  (CGF) originY				{	return super.originY; 	}
-  (CGF) width 				{	return super.width;		}
-  (CGF) height 				{	return super.height;		}
- (void) setOriginX:(CGF)x {
	if (x == self.originX) return;
	self.frame = AZRectExceptOriginX(self.frame, x);
	[self.superview setNeedsDisplay:YES];
}
- (void) setOriginY:(CGF)y {	if (y == self.originY) return;
	self.frame = AZRectExceptOriginY(self.frame, y);
	[self.superview setNeedsDisplay:YES];
}
- (void) setWidth:  (CGF)w {	if (w == self.width) return;
	[self setFrame:AZRectExceptWide(self.frame, w)];
	[self.superview setNeedsDisplay:YES];
}
- (void) setHeight: (CGF)h {
	if (h == self.height) return;
	self.frame = AZRectExceptHigh(self.frame, MAX(h, self.minimalSize.height));
	[self.superview setNeedsDisplay:YES];
}

#pragma mark inputs
- (NSA*) orderedInputs 				{	return [self orderedHoles:self.inputs];	}
- (NSA*) orderedHoles:(NSSet*)h 	{
	return [h.allObjects sortedArrayUsingDescriptors:
			  @[[NSSortDescriptor.alloc initWithKey:@"position" ascending:YES]]];
}
#pragma mark outputs
- (NSA*) orderedOutputs 			{	return [self orderedHoles:_outputs];	}
#pragma mark - *** geometry ***
-   (id) endHole:  (NSP)e 			{
	NSPoint mousePos = [self convertPoint:e fromView:[self superview]];
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	float heightOfText = stringSize.height;
	if ((mousePos.x > 0) && (mousePos.x < 15)) {
		int hole = (-mousePos.y + [self bounds].origin.y + [self bounds].size.height - [self verticalOffset] - heightOfText * 0.5) / heightOfText;
		id res = ((hole > 0) && (hole <= [[self inputs] count])) ? [self orderedInputs][hole - 1] : nil;
		if (res) {
			[res setValue:_data forKey:@"data"];
		}
		return res;
	}
	return nil;
}
-   (id) startHole:(NSP)s 			{
	NSPoint mousePos = [self convertPoint:s fromView:[self superview]];
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	float heightOfText = stringSize.height;
	if ((mousePos.x > [self bounds].origin.x + [self bounds].size.width - 15) && (mousePos.x < [self bounds].origin.x + [self bounds].size.width)) {
		int hole = (-mousePos.y + [self bounds].origin.y + [self bounds].size.height - [self verticalOffset] - heightOfText * 0.5) / heightOfText;
		id res = ((hole > 0) && (hole <= [[self outputs] count])) ? [self orderedOutputs][hole - 1] : nil;
		if (res) {
			[res setValue:_data forKey:@"data"];
		}
		return res;
	}
	return nil;
}
-  (NSP) endHolePoint:  (id)e	 	{
	
	NSSize stringSize 	= [self.title sizeWithAttributes:_stringAttributes];
	float heightOfText 	= stringSize.height;
	int hole 				= [[self orderedHoles:self.inputs] indexOfObject:e] + 1;
	NSAssert( (hole <= self.inputs.count), @"hole should be within Inputs range in endholePoint:");
	return [self convertPoint:NSMakePoint(5 + 4, self.bounds.origin.y + self.height - self.verticalOffset - heightOfText * (hole + 1.0)) toView:self.superview];
}
-  (NSP) startHolePoint:(id)s		{
	NSSize stringSize = [[self title] sizeWithAttributes:_stringAttributes];
	float heightOfText = stringSize.height;
	
	int hole =  [[self orderedHoles:self.outputs] indexOfObject:s] + 1;
	
	NSAssert( (hole <= self.outputs.count), @"hole should be within Outputs range in startholePoint:");
	return [self convertPoint:NSMakePoint(self.bounds.origin.x + self.width - 5 - 4, self.bounds.origin.y + self.height - self.verticalOffset - heightOfText * (hole + 1.0)) toView:self.superview];
}
- (NSSZ) minimalSize 				{
	NSSize titleSize = [[self title] sizeWithAttributes:_stringAttributes];
	float maxInputWidth = 0;
	int i;
	for (i = 0; i < [[self inputs] count]; i++) {
		NSString *inputLabel = [[self orderedInputs][(unsigned)i] valueForKey:@"label"];
		float inputWidth = 10 + 4 + [inputLabel sizeWithAttributes:_stringAttributes].width + 5;
		maxInputWidth = MAX(inputWidth, maxInputWidth);
	}
	float maxOutputWidth = 0;
	int j;
	for (j = 0; j < [[self outputs] count]; j++) {
		NSString *outputLabel = [[self orderedOutputs][(unsigned)j] valueForKey:@"label"];
		float outputWidth = 10 + 4 + [outputLabel sizeWithAttributes:_stringAttributes].width + 5;
		maxOutputWidth = MAX(outputWidth, maxOutputWidth);
	}
	
	NSSize result;
	result.width = MAX(titleSize.width + 16, maxInputWidth + maxOutputWidth);
	result.height = (titleSize.height) * (2.0 + (([[self inputs] count] > [[self outputs] count]) ? [[self inputs] count] : [[self outputs] count])) + [self verticalOffset] + 12;
	LOG_EXPR(result);
	return result;
}
#pragma mark - *** drawing ***
- (void)drawRect:(NSRect)rect 	{
	
	AZRect *bnds 					= $AZR(AZInsetRect(self.bounds,4));
	const float backgroundAlpha 	= 0.7;
	NSSize stringSize = [self.title sizeWithAttributes:_stringAttributes];
	//draw body background
	NSColor *base = self.titleColor ?: WHITE;
	NSR bRect, tRect;
	bRect = NSMakeRect(bnds.minX, bnds.minY, bnds.w, bnds.h - stringSize.height);
	tRect = NSMakeRect(bnds.minX, bnds.minY+ bnds.h - stringSize.height, bnds.w, stringSize.height);
	[[NSBP bezierPathWithBottomRoundedRect:bRect radius:8] fillWithColor:[[base blendedColorWithFraction:0.8 ofColor:NSColor.controlBackgroundColor]alpha:backgroundAlpha]];
	
	//draw title background
	[[NSBP bezierPathWithTopRoundedRect:tRect radius:8] gradientFillWithColor:[self.titleColor colorWithAlphaComponent:backgroundAlpha]];
	
	//draw title
	[self.title drawAtPoint:NSMakePoint(bnds.minX + (bnds.w - stringSize.width) / 2, bnds.minY + bnds.h - stringSize.height) withAttributes:_stringAttributes];
	
	// draw end of lace
	for (NSDictionary *aDict in [self inputs]) {
		
		NSPoint end, labelOrigin; end = labelOrigin = [self convertPoint:[self endHolePoint:aDict] fromView:self.superview];
		[[NSBP bezierPathWithOvalInRect:AZSquareAround(end, HOLESIZE/2)]strokeWithColor:BLACK andWidth:HOLESIZE/4];
		
		NSString *inputLabel = [aDict vFK:@"label"];
		labelOrigin.x += 5;
		labelOrigin.y -= stringSize.height / 2;
		[[NSColor blackColor] set];
		[inputLabel drawAtPoint:labelOrigin withAttributes:_stringAttributes];
	}
	
	// draw start of lace
	[self.outputs each:^(NSD* aDict) {
		
		NSPoint start = [self convertPoint:[self startHolePoint:aDict] fromView:self.superview];
		[[NSBP bezierPathWithOvalInRect:AZSquareAround(start, HOLESIZE/2)]// NSMakeRect(start.x - 3, start.y - 3, 6, 6)];
		 strokeWithColor:WHITE andWidth:3];
		NSPoint labelOrigin;
		NSString *outputLabel = [aDict valueForKey:@"label"];
		labelOrigin.x = start.x - 5 - [outputLabel sizeWithAttributes:_stringAttributes].width;
		labelOrigin.y = start.y - stringSize.height / 2;
		[[NSColor blackColor] set];
		[outputLabel drawAtPoint:labelOrigin withAttributes:_stringAttributes];
	}];
	
	//draw outline
	[self.isSelected && NSGraphicsContext.currentContextDrawingToScreen ? /*_titleColor*/
													[NSColor selectedControlColor] : [NSColor controlShadowColor]  setStroke];
	float lineWidth = self.isSelected && NSGraphicsContext.currentContextDrawingToScreen ? 2.0 : 1.0;
	
	CGFloat dash[] = {5, 1, 4, 1, 3, 1, 2, 1, 1, 1, 1, 2, 1, 3, 1, 4, 1, 5};
//	[NSBP bezierPathWithBottomRoundedRect:(NSRect) radius:	]	
//	[[NSColor colorWithCalibratedRed:1.000 green:0.400 blue:0.000 alpha:1.000] set]; 
//	[path setLineDash:dash count:2 phase:0];
//	[path stroke];
	NSBP *shape = [NSBP bezierPathWithRoundedRect:NSInsetRect(bnds.rect, -lineWidth / 2 + 0.15, -lineWidth / 2 + 0.15) radius:8]; //0.15 to be perfect on a zoomed printing
//	[shape setDashPattern:@[@15,@15]];
	static CGF  phase = 0;
	phase++;
	if (_shouldResize) [self.dragZone drawWithFill:BLACK andStroke:RED];
	
	if (self.isSelected){ 
		[shape setLineDash:dash count:18 phase:phase];
	   [shape strokeWithColor:BLACK andWidth:4];
		[NSThread detachNewThreadSelector:@selector(setNeedsDisplay:) toTarget:self withObject:@YES];
		// setNeedsDisplay:YES];// performSelector:@selector(setNeedsDisplay:) withBool:YES];
	}
	//		NSRect r = AZRectExceptOriginY([self frame], self.height);
	//		NSRectFillWithColor(rect, RED);
}
- (BOOL) acceptsFirstResponder { return  NO; }
- (void)setFrame:(NSRect)aRect	{  // Notifies frame changes, aka dragging etc.
	
	//	[self willChangeValueForKey:@"drawingBounds"];	NSD*d; AZRect *newR = $AZR(aRect);
	//	[d= @{@"minX":@"originX", @"minY":@"originY", @"h":@"height",@"w":@"width"} each:^(id key, id value) {
	//		[self willChangeValueForKey:value];
	//		[self setFloat:[newR floatForKey:key] forKey:value];
	//	}];
	//	[super setFrame:aRect];
	//	[[d.allValues arrayByAddingObject:@"drawingBounds"] do:^(id obj) { [self didChangeValueForKey:obj]; }];
	AZRect *orFrame = $AZR(self.frame), *newR = $AZR(aRect);
	
	NSMA *changed = NSMA.new;
	[@{@"minX":@"originX", @"minY":@"originY", @"h":@"height",@"w":@"width"} each:^(id key, id value) {
		if ( [orFrame floatForKey:key] == [newR floatForKey:key]) return;
		[self willChangeValueForKey:value];
		[changed addObject:value];
	}];
	if (!changed.count) return;
	[self willChangeValueForKey:@"drawingBounds"]; 
	[super setFrame:aRect];
	[changed each:^(id obj) {
		[self didChangeValueForKey:obj];
		[self didChangeValueForKey:@"drawingBounds"];
	}];
}
#pragma mark - *** events ***

- (NSV*) hitTest:	  (NSPoint)p 							{ return (([self startHole:p]) || ([self endHole:p])) ? nil : [super hitTest:p];	}
- (NSBP*)dragZone {
	NSSZ s = AZSizeFromDimension(MIN(AZMaxDim(self.size)*.1, 25));
	NSBP *p = [NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignTopLeft,s)];
	[p appendBezierPath:[NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignTopRight,s)]];
	[p appendBezierPath:[NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignBottomRight,s)]];
	[p appendBezierPath:[NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignBottomLeft,s)]];
	return p;
}
- (AZAlign)resizeCorner {
	NSSZ s = AZSizeFromDimension(MIN(AZMaxDim(self.size)*.1, 25));
	NSP lp = self.windowPoint;
	return _resizeCorner = 
	[[NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignTopLeft,s)]containsPoint:lp] ? AZAlignTopLeft :
	[[NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignTopRight,s)]containsPoint:lp] ? AZAlignTopRight :
	[[NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignBottomRight,s)]containsPoint:lp] ?AZAlignBottomRight :
	[[NSBP bezierPathWithRect:AZCornerRectPositionedWithSize(self.bounds, AZAlignBottomLeft,s)]containsPoint:lp] ? AZAlignBottomLeft : AZAlignLeft;
}
//- (void) mouseMoved:(NSEvent *)theEvent {
	
	//	isDrag ? [NSCursor.operationNotAllowedCursor  set] : [NSCursor.arrowCursor set];
//}

- (void) setResizeDelta:(NSPoint)resizeDelta { _resizeDelta = resizeDelta; LOG_EXPR(_resizeDelta); }
- (void) mouseDown:(NSEvent*)e 			{
	
	EFLaceView *sView = (EFLaceView*)self.superview;
	
	e.modifierFlags & NSShiftKeyMask 	?	[sView selectView:self state:YES] 		// add to selection
	: 	e.modifierFlags & NSCommandKeyMask	?	[sView selectView:self state:!self.isSelected] // inverse selection
	:	!self.isSelected							?	[sView deselectViews], [sView selectView:self state:YES] : 	nil;
	
	AZAlign a = self.resizeCorner;
	NSP ref = e.locationInWindow;
	NSR oRect = self.frame;
	LOG_EXPR(AZAlignToString(self.resizeCorner));
	BOOL keepOn = YES; NSPoint mouseLoc, lastMouseLoc = self.superview.windowPoint;	NSRect initialFrame = self.frame;
	while (keepOn) {
		if ((e = [self.window nextEventMatchingMask:NSLeftMouseUpMask|NSLeftMouseDraggedMask|NSPeriodicMask]).type == NSLeftMouseDragged) {
			mouseLoc = self.superview.windowPoint;
			if (_shouldResize) {
				//				AZAlign q = AZClosestCorner(AZSquareAround(self.localPoint,5), self.frame);
				self.resizeDelta = AZSubtractPoints( e.locationInWindow, ref);// mouseLoc, lastMouseLoc);
				NSR nRect = oRect;
				if (a == AZAlignTopLeft) {
					
				 	if (_resizeDelta.x < 0) { 	nRect.size.width 	+= ABS(_resizeDelta.x);  
						nRect.origin.x 	-= ABS(_resizeDelta.x); 
					}
					else { 	nRect.size.width -= _resizeDelta.x; 
						nRect.origin.x += _resizeDelta.x; }
					nRect.size.height += _resizeDelta.y;
				}
				self.frame = nRect;
				//				self.frame = AZRectExceptSize(self.frame, (NSSZ){savedRect.width + mouseLoc.x - lastMouseLoc.x,savedRect.height + mouseLoc.y - lastMouseLoc.y});
				//				lastMouseLoc = mouseLoc;
				[self autoscroll:e];
				[self.superview setNeedsDisplay:YES];
				[self setNeedsDisplay:YES];
			} else {
				//				[NSCursor.closedHandCursor set];
				[NSCursor.operationNotAllowedCursor set];
				//				mouseLoc = self.superview.windowPoint;
				[sView.selectedSubViews each:^(NSView *v) { 
					v.frame = NSOffsetRect(v.frame, mouseLoc.x - lastMouseLoc.x, mouseLoc.y - lastMouseLoc.y); }];
				lastMouseLoc = mouseLoc;
				[self autoscroll:e];
				[sView setNeedsDisplay:YES];
			}
		}
		else if (e.type == NSLeftMouseUp) {
		
			[[NSCursor arrowCursor] set];
			if (!NSContainsRect([sView bounds], [self frame])) {
				// revert to original frame if not inside superview
				[self setFrame:initialFrame];
				[sView setNeedsDisplay:YES];
			
			}
			keepOn = NO;
	
		}//	default:			/* Ignore any other kind of event. */	break;
	}
	
}
- (void) observeValueForKeyPath:(NSS*)keyPath 
							  ofObject:(id)object 
							    change:(NSD*)change 
							   context:(void*)context 	{
	
	if ([keyPath isEqualToAnyOf:@[@"inputs",@"outputs"]] && context == _inoutputObservationContext) {
		
		NSSet *old, *new; 	NSMutableSet *inserted, *removed;
		[inserted	= [new = [change valueForKey:@"new"]mutableCopy] minusSet:old = [change valueForKey:@"old"]]; //compute inserted labels
		[removed		= old.mutableCopy minusSet:new]; //compute removed labels
		[inserted each:^(id sender) {
			//make label observed by the view for changes on label or on position
			[@[@"label", @"position",@"laces"] each:^(id obj) { 
				[sender addObserver:self forKeyPath:obj options:0 context:_inoutputObservationContext];
			}];
		}];
		[removed each:^(id sender) { [@[@"label", @"position",@"laces"] each:^(id obj) {	[sender removeObserver:self forKeyPath:obj]; }]; }];
		//update size and redraw
		self.width 	= MAX(self.minimalSize.width,  self.width );
		self.height = MAX(self.minimalSize.height, self.height);
		[self.superview setNeedsDisplay:YES];
	}
	if ( SameString(keyPath, @"label") && context == _inoutputObservationContext ) { //update size and redraw 
		CGF newD; NSSZ m = self.minimalSize;
		if (self.width 	!= (newD = MAX(m.width,  self.width))) self.width = newD;
		if (self.height 	!= (newD = MAX(m.height, self.width))) self.width = newD;
	}
	if (([keyPath isEqualToString:@"position"]) && (context == _inoutputObservationContext) ) [[self superview] setNeedsDisplay:YES];  
	//redraw superview (laces may have changed because of positions of labels)
	if ([keyPath isEqualToString:@"laces"]) [[self superview] setNeedsDisplay:YES];													//redraw laces because of undos
}

@end
