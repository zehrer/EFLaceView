//
//  MyDocument.h
//  EFLaceViewCoreData
//

#import <Cocoa/Cocoa.h>
#import "EFLaceView.h"

@interface ImageToDataTransformer : NSValueTransformer
@end

@interface LaceDocument : NSPersistentDocument 	
@property (assign)	IBOutlet NSArrayController *controller;
@property (assign)	IBOutlet EFLaceView* myView;
@property (assign) IBOutlet NSSegmentedControl *insertRemove;
@end

@interface MiniatureAppDelegate : NSObject <NSApplicationDelegate>
@end

