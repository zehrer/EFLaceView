
#import "LaceDocument.h"
#define moc managedObjectContext
#define NSDC [NSDocumentController sharedDocumentController]
#define LOGCMD NSLog(@"%s", __PRETTY_FUNCTION__)

@implementation MiniatureAppDelegate


-(void)applicationDidFinishLaunching:(NSNotification *)notification	{
// Schedule "Checking whether document exists." into next UI Loop. Because document is not restored yet.  So we don't know what do we have to create new one. Opened document can be identified here. (double click document file)
	[AZSOQ addOperation:[NSBLO blockOperationWithBlock:^{
	// If there is a recent document, try to open it.
		if (![NSDC recentDocumentURLs].count) { [NSDC openUntitledDocumentAndDisplay:YES error: nil]; return; }
		[[NSDC recentDocumentURLs] log];
		LOG_EXPR(getenv("XCODE_COLORS"));
		[NSDC openDocumentWithContentsOfURL:[NSDC recentDocumentURLs][0] display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
			EFLaceView* d = ((LaceDocument*)document).myView;
			LOG_EXPR(d);
			[d setDelegate:self];
			LOG_EXPR(d.delegate);
		}];
	}]];
	AZLOG(@"********\n\n\n\n");
	[runCommand(@"printf \"COLUMNS = %d\n\" $COLUMNS") log];
	AZLOG(@"********\n\n\n\n");
}
- (BOOL)EFLaceView:(EFLaceView*)a shouldSelectView:(EFView*)v state:(BOOL)b	{ LOGCMD; return YES;}
- (BOOL)EFLaceView:(EFLaceView*)a shouldSelectLace:(NSDictionary*)aLace 		{LOGCMD;  return YES;}
- (BOOL)EFLaceView:(EFLaceView*)a shouldConnectHole:(id)s toHole:(id)e 			{LOGCMD;return YES;}
- (BOOL)EFLaceView:(EFLaceView*)a shouldDrawView:(EFView*)v							{LOGCMD;return YES;}

@end
@implementation LaceDocument
@synthesize insertRemove, controller, myView;

- (IBAction)segmentSwitch:(id)sender {
	if (sender == insertRemove) 
		((NSSegmentedControl*)sender).selectedSegment == 1 ? [controller insert:nil] : [controller remove:nil];
}

- (EFLaceView*)view { return  myView; }
- (id)init																						{
	return self = super.init ?	
		[self.moc observeName:NSManagedObjectContextObjectsDidChangeNotification usingBlock:^(NSNOT*n) { 
			// n.userInfo
			[@"Coredata doc did chamnge! %@" log];	
		}], [controller observeName:@"canInsert" usingBlock:^(NSNotification *n) {
				NSLog(@"canInsert: %@", n);
				[insertRemove.cell setEnabled:[n.object canInsert] forSegment:1];
		}], [controller observeName:@"canRemove" usingBlock:^(NSNotification *n) {
				NSLog(@"canRemove: %@", n);
				[insertRemove.cell setEnabled:[n.object canRemove] forSegment:0];
		}],self : nil;
}
- (void) awakeFromNib {
//	NSView *idView = myView.superview;
//	BBMeshView *x = [BBMeshView.alloc initWithFrame:idView.bounds];
//	[x addSubview:myView];
//	[idView addSubview:x];
	[[myView window]setAcceptsMouseMovedEvents:YES];
	[insertRemove.cell setEnabled:YES forSegment:0],
	[insertRemove.cell setEnabled:YES forSegment:1];
}
- (void)windowWillClose:(NSNotification *)n 											{
	[myView isDescendantOf:[n.object contentView]] ? nil : [myView unbind:@"dataObjects"], [myView unbind:@"selectionIndexes"];
}
- (NSS*)windowNibName 																		{	return NSStringFromClass(self.class); }
- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 	{
	[super windowControllerDidLoadNib:windowController];
	// user interface preparation code
	[@{@"dataObjects":@"arrangedObjects", @"selectionIndexes":@"selectionIndexes"} each:^(id key, id value) {
		[myView bind:key toObject:controller withKeyPath:value options:nil]; }];
}
- (void)printShowingPrintPanel:(BOOL)showPanels										{
	// Obtain a custom view that will be printed
	NSView *printView = myView;
	[[self printInfo] setHorizontalPagination:NSFitPagination];
	[[self printInfo] setVerticalPagination:NSFitPagination];
	[[self printInfo] setOrientation:NSLandscapeOrientation];
	// Construct the print operation and setup Print panel
	NSPrintOperation *op = [NSPrintOperation printOperationWithView:printView printInfo:[self printInfo]];
	[op setShowsPrintPanel:showPanels];
	if (showPanels) {}		// Add accessory view, if needed
	// Run operation, which shows the Print panel if showPanels was YES
	[self runModalPrintOperation:op delegate:nil didRunSelector:NULL contextInfo:NULL];
}
-(BOOL)configurePersistentStoreCoordinatorForURL:(NSURL*)u ofType:(NSS*)t 
			modelConfiguration:(NSS*)c storeOptions:(NSD*)o error:(NSERR**)e	{
	return [super configurePersistentStoreCoordinatorForURL:u ofType:t modelConfiguration:c storeOptions:
	o ? [o dictionaryWithValuesForKeys:@[NSMigratePersistentStoresAutomaticallyOption,@YES, NSInferMappingModelAutomaticallyOption, @YES]] :
		 @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption: @YES} error:e];
}
@end

//-(BOOL)configurePersistentStoreCoordinatorForURL:(NSURL*)u ofType:(NSS*)t 
//			modelConfiguration:(NSS*)c storeOptions:(NSD*)opts error:(NSERR**)error	{
//	return [super configurePersistentStoreCoordinatorForURL:u ofType:t modelConfiguration:c storeOptions:[opts dictionaryByAppendingEntriesFromDictionary:@{NSMigratePersistentStoresAutomaticallyOption : @"YES",NSInferMappingModelAutomaticallyOption : @"TRUE"}] error:error];
//}

//- (NSS*)windowNibName 	{	return @"CustomNSVDoc";	}

//- (void)makeWindowControllers
//{
//	NSWindowController *mainWindowController = [NSWindowController.alloc initWithWindowNibName:@"LaceDocument" owner:self];
// 	[mainWindowController setShouldCloseDocument:YES];
//	[self addWindowController:mainWindowController];
//}

@implementation ImageToDataTransformer
+ (BOOL)allowsReverseTransformation { return YES;	}
+ (Class)transformedValueClass{ return NSData.class;	}
- (id)transformedValue:(id)v	{ return [[v representations][0]representationUsingType:NSPNGFileType properties:nil];	}
- (id)reverseTransformedValue:(id)value	{ return  [NSImage imageWithData:value];	}
@end
