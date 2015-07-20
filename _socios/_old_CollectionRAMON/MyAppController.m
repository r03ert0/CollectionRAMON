#import "MyAppController.h"

@implementation MyAppController
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	anlz=[[AnalyzeFile new] retain];
	[self vendObject];

    return;
}
-(IBAction)select:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSString	*name;
    int			result;
    
    [openPanel setAllowsMultipleSelection:NO];
    result=[openPanel runModalForDirectory:nil file:nil types:[NSArray arrayWithObjects:@"hdr",@"img",nil]];
    if (result == NSOKButton)
    {
        name=[[openPanel filenames] objectAtIndex:0];
        [anlz initWithFile:name];
		[filename setStringValue:name];
    }
}
-(void)vendObject
{
    NSConnection	*theConnection;
	
    theConnection=[NSConnection defaultConnection];
    NSLog(@"Creating connection...");

    [theConnection setRootObject:anlz];
    if ([theConnection registerName:@"anlz"] == NO)
      NSLog(@"Failed to register name\n");
}
@end
