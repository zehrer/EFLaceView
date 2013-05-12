//
//  EFView.h
// EFLaceView
//


#import <Cocoa/Cocoa.h>

@interface EFView : NSView  {
	int						_tag;
	NSString*				_title;
	NSColor*				_titleColor;
	NSMutableSet*			_inputs;
	NSMutableSet*			_outputs;
	float					_verticalOffset;
	NSMutableDictionary*	_stringAttributes;
	id						_data;
}

#pragma mark - *** class ***


#pragma mark - *** holes ***
- (NSArray *)orderedHoles:(NSSet *)aSet;
- (NSPoint)startHolePoint:(id) aStartHole;
- (NSPoint)endHolePoint:(id) aEndHole;
- (id)startHole:(NSPoint)aPoint;
- (id)endHole:(NSPoint)aPoint;

#pragma mark - *** setters and accessors ***

// vertical offset
- (float)verticalOffset;
- (void)setVerticalOffset:(float)aValue;

// selected
- (BOOL)isSelected;

// title
- (NSString *)title;
- (void)setTitle:(NSString *)aTitle;

// title color
- (NSColor *)titleColor;
- (void)setTitleColor:(NSColor *)aColor;

#pragma mark drawingbounds
- (float) originX;
- (float) originY;
- (float) width;
- (float) height;
- (void) setOriginX:(float)aFloat;
- (void) setOriginY:(float)aFloat;
- (void) setWidth:(float)aFloat;
- (void) setHeight:(float)aFloat;

#pragma mark inputs and outputs
- (NSMutableSet*)inputs;
- (NSArray *)orderedInputs;

- (NSMutableSet *)outputs;
- (NSArray*)orderedOutputs;

#pragma mark - *** geometry ***
- (NSSize) minimalSize;


@end
