//
//  MyDocument.h
//  EFLaceViewCoreData
//

#import <Cocoa/Cocoa.h>

#import "EFLaceView.h"

@interface MyDocument : NSPersistentDocument {
	
	IBOutlet id controller;
	IBOutlet EFLaceView* myView;

}

@end
