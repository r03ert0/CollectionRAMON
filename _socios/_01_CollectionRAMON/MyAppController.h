/* MyAppController */

#import <Cocoa/Cocoa.h>
#import "AnalyzeFile.h"

@interface MyAppController : NSObject
{
    NSConnection			*conn;
	IBOutlet NSTextField	*filename;
	AnalyzeFile				*anlz;
}
-(IBAction)select:(id)sender;
-(void)vendObject;
@end
