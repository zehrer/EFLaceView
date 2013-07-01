
// EFLaceView

#import <AtoZ/AtoZ.h>
#import <Carbon/Carbon.h> 
#import "EFView.h"

@class EFLaceView;
@interface NSObject (EFLaceViewDelegateMethod)
- (BOOL)EFLaceView:(EFLaceView*)aView shouldSelectView:(EFView *)aView state:(BOOL)aBool;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldSelectLace:(NSDictionary*)aLace;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldConnectHole:(id)startHole toHole:(id)endHole;
- (BOOL)EFLaceView:(EFLaceView*)aView shouldDrawView:(EFView *)aView;
@end

@class EFLaceView;
@interface NSObject (EFViewControllerDelegate)
- (void)shouldAddInputHoleTo:(EFView*)v;
@end

@interface EFLaceView : NSView
{
	NSObject*	_dataObjectsContainer, 	*_selectionIndexesContainer;
	NSString*	_dataObjectsKeyPath, 	*_selectionIndexesKeyPath;
	NSPoint		_startPoint, _endPoint,	_rubberStart, _rubberEnd;
	EFView*		_startSubView, 			*_endSubView;
	BOOL			_isMaking, 					_isRubbing;
	id				_startHole, 				_endHole;
}

@property (weak)	IBOutlet NSArrayController* inputs, *outputs;
@property (weak)	id   delegate;
@property (nonatomic,copy) NSA *oldDataObjects;
																									#pragma mark - *** setters and accessors
- (NSMA*) laces;
-  (NSA*) dataObjects;
- (NSIS*) selectionIndexes;
																									#pragma mark - *** bindings ***
-  (void) startObservingDataObjects:(NSA*)dataObjects;
-  (void) stopObservingDataObjects: (NSA*)dataObjects;
																									#pragma mark - *** geometry ***
- (void) deselectViews;
- (NSA*) selectedSubViews;
- (BOOL) isStartHole: (NSP)aPoint;
- (BOOL) isEndHole:	 (NSP)aPoint;
- (void) selectView:  (EFView*)aView;
- (void) selectView:  (EFView*)aView state:(BOOL)aBool;
- (void) drawLinkFrom:(NSP)startPoint to:(NSP)endPoint color:(NSC*)insideColor;
- (void) connectHole: (id)startHole  toHole:(id)endHole;
@end

//CGFloat treshold(CGFloat x, CGFloat tr);
#pragma mark - *** utility functions***
//CGFloat treshold(CGFloat x,CGFloat tr) {	return ( x > 0 ) ? (( x > tr ) ? x : tr ) :-x + tr;	}
NS_INLINE CGFloat treshold(CGFloat x,CGFloat tr) {	return ( x > 0 ) ? (( x > tr ) ? x : tr ) :-x + tr;	}


//@interface NSObject (EFLaceViewDataObject)
//+ (NSA*)keysForNonBoundsProperties;
//@end
//- (id)delegate;
//- (void)setDelegate:(id)newDelegate;
//- (NSA*)oldDataObjects;
//- (void)setOldDataObjects:(NSA*)anOldDataObjects;
