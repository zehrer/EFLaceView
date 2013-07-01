//
//  EFView.h
// EFLaceView
//


#import <Cocoa/Cocoa.h>

@class EFLaceView;
@interface EFView : NSView
@property (weak) IBOutlet NSArrayController* inputsController, *outputsCOntroller;
@property (weak) EFLaceView* delegate;
@property (nonatomic) NSMutableSet *inputs, *outputs;

#pragma mark - *** holes ***
- (NSA*) orderedHoles:  (NSSet*)   aSet;
-  (NSPoint) startHolePoint:(id) aStartHole;
-  (NSPoint) endHolePoint:  (id)   aEndHole;
-	   (id) startHole:	 (NSPoint)aPoint;
-	   (id) endHole:	   (NSPoint)aPoint;

#pragma mark - *** setters and accessors ***
AZPROP( NSIMG,		 	 	  icon );
AZPROP( NSS,			 	 title );
AZPROP( NSC,   	  titleColor );
AZPROP( NSMD, stringAttributes );

@property	id	data;
@property	int tag;

@property (nonatomic,assign) 	CGF verticalOffset, width, height, originX, originY;						
@property (readonly) 			BOOL 		isSelected;
@property (nonatomic) 			BOOL 		shouldResize;
@property (nonatomic) 			AZAlign 		resizeCorner;
@property (nonatomic) 			NSP 		resizeDelta;
@property (RONLY) NSBP	*resizePath;
//@property (nonatomic,strong) 	NSString *title;
//@property (nonatomic,strong) 	NSColor 	*titleColor;
//@property (nonatomic,strong) 	NSImage 	*icon;
#pragma mark drawingbounds

#pragma mark inputs and outputs
- (NSMutableSet*) inputs;
- 		(NSA*) orderedInputs;
- (NSMutableSet*) outputs;
- 		 (NSA*) orderedOutputs;
#pragma mark - *** geometry ***
-		(NSSize) minimalSize;


@end
