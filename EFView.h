//
//  EFView.h
// EFLaceView
//


#import <Cocoa/Cocoa.h>

@interface EFView : NSView  
{
	NSString*				_title;
	NSColor*					_titleColor;
	NSMutableSet*			_inputs;
	NSMutableSet*			_outputs;
	NSMutableDictionary*	_stringAttributes;
	id							_data;
	float						_verticalOffset;
	int						_tag;
}

#pragma mark - *** class ***
#pragma mark - *** holes ***
- (NSArray*) orderedHoles:  (NSSet*)   aSet;
-  (NSPoint) startHolePoint:(id) aStartHole;
-  (NSPoint) endHolePoint:  (id)   aEndHole;
-       (id) startHole:     (NSPoint)aPoint;
-       (id) endHole:       (NSPoint)aPoint;

#pragma mark - *** setters and accessors ***
@property (nonatomic,assign) 	float verticalOffset, width, height, originX, originY;						
@property (readonly) 			BOOL isSelected;
@property (nonatomic,strong) 	NSString *title;
@property (nonatomic,strong) 	NSColor *titleColor;
#pragma mark drawingbounds

#pragma mark inputs and outputs
- (NSMutableSet*) inputs;
- 	    (NSArray*) orderedInputs;
- (NSMutableSet*) outputs;
- 		 (NSArray*) orderedOutputs;
#pragma mark - *** geometry ***
-        (NSSize) minimalSize;


@end
