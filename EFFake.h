//
//  EFFake.h
//  EFLaceView
//

#import <Cocoa/Cocoa.h>

// The data provided to EFViews must have a KVC-KVO complient NSColor titleColor property, and a class property keysForNonBoundsProperties
// This class makes a bridge to a coreData entity

@interface EFFake : NSManagedObject 

+ (NSA*) keysForNonBoundsProperties;
- (NSColor*) titleColor;
- 	   (void) setTitleColor: (NSColor*)aColor;

@end
