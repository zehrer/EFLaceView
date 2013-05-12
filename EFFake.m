//
//  EFFake.m
//  EFLaceView
//

#import "EFFake.h"

@implementation EFFake
+ (NSArray*) keysForNonBoundsProperties		{

	static NSArray *keys = nil;
	return keys = keys ?: @[@"tag", @"inputs", @"outputs", @"title", @"titleColor", @"verticalOffset",
							  @"originX", @"originY", @"width", @"height"];

}
- (NSColor*) titleColor								{

	[self willAccessValueForKey:@"titleColor"];
						NSColor *color = [self primitiveValueForKey:@"titleColor"];
	[self didAccessValueForKey:@"titleColor"];
	if (!color) {	NSData *colorData = [self valueForKey:@"colorAsData"];
		if (!colorData) {
			[self setValue:[NSKeyedArchiver archivedDataWithRootObject:[NSColor grayColor]]
					forKey:@"colorAsData"];
			colorData = [self valueForKey:@"colorAsData"];
		}
		if (colorData) [self setPrimitiveValue:color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData] forKey:@"titleColor"];
	}
	return color;
} 
-     (void) setTitleColor:(NSColor*)aColor	{

	[self willChangeValueForKey:															  @"titleColor"];
	[self setPrimitiveValue:aColor                                     forKey:@"titleColor"];
	[self didChangeValueForKey:															  @"titleColor"];
	[self setValue:[NSKeyedArchiver archivedDataWithRootObject:aColor]forKey:@"colorAsData"];
} 

@end
