//
//  EFLaceView.h
// EFLaceView
//


#import <Cocoa/Cocoa.h>
#import "EFView.h"

float treshold(float x,float tr);

@interface EFLaceView : NSView
{
	NSObject*		_dataObjectsContainer;
	NSString*		_dataObjectsKeyPath;
	NSObject*		_selectionIndexesContainer;
	NSString*		_selectionIndexesKeyPath;
	
	NSArray*		_oldDataObjects;
	
	BOOL			_isMaking;
	
	NSPoint			_startPoint;
	NSPoint			_endPoint;
	NSPoint			_rubberStart;
	NSPoint			_rubberEnd;
	BOOL			_isRubbing;
	
	id				_startHole;
	id				_endHole;
	
	EFView*			_startSubView;
	EFView*			_endSubView;
	
	id				_delegate;
	
}


#pragma mark - *** bindings ***

- (void)startObservingDataObjects:(NSArray *)dataObjects;
- (void)stopObservingDataObjects:(NSArray *)dataObjects;


#pragma mark - *** setters and accessors

- (id)delegate;
- (void)setDelegate:(id)newDelegate;


- (NSMutableArray *)laces;

- (NSArray *)dataObjects;

- (NSIndexSet *)selectionIndexes;

- (NSArray *)oldDataObjects;
- (void)setOldDataObjects:(NSArray *)anOldDataObjects;

#pragma mark - *** geometry ***

- (BOOL)isStartHole:(NSPoint)aPoint;
- (BOOL)isEndHole:(NSPoint)aPoint;
- (void)drawLinkFrom:(NSPoint)startPoint to:(NSPoint)endPoint color:(NSColor *)insideColor;
- (void)deselectViews;
- (void)selectView:(EFView *)aView;
- (void)selectView:(EFView *)aView state:(BOOL)aBool;
- (NSArray*)selectedSubViews;

- (void) connectHole:(id)startHole  toHole:(id)endHole;

@end

@interface NSObject (EFLaceViewDataObject)
+ (NSArray *)keysForNonBoundsProperties;
@end

@interface NSObject (EFLaceViewDelegateMethod)

- (BOOL)EFLaceView:(EFLaceView*)aView shouldSelectView:(EFView *)aView state:(BOOL)aBool;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldSelectLace:(NSDictionary*)aLace;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldConnectHole:(id)startHole toHole:(id)endHole;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldDrawView:(EFView *)aView;

@end