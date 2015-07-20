//  MyDocument.m
//  CollectionRAMON
//
//  Created by rOBERTO tORO on 06/04/2006.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.

#import "MyDocument.h"

@implementation MyDocument

- (id)init 
{
    self = [super init];
    if (self != nil)
	{
		oldObj=nil;
	}
    return self;
}

- (NSString *)windowNibName 
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
    [super windowControllerDidLoadNib:windowController];
	[table registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}
#pragma mark -
// drag and drop support
-(BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil] owner:self];
    [pboard setData:data forType:NSFilenamesPboardType];

    return YES;
}
-(NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id )info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if(row>=0)
		return NSDragOperationEvery;
	else
		return NSDragOperationNone;
}
-(BOOL)tableView:(NSTableView*)tv acceptDrop:(id )info row:(int)row dropOperation:(NSTableViewDropOperation)op
{
    NSPasteboard	*pboard=[info draggingPasteboard];
	NSArray			*files=[pboard propertyListForType:NSFilenamesPboardType];
	int				i,numFiles=[files count];
	NSManagedObjectContext *context = [self managedObjectContext];
	NSManagedObject *s;
	NSString		*p;
	
	for(i=0;i<numFiles;i++)
	{
		p=[files objectAtIndex:i];
		s = [NSEntityDescription insertNewObjectForEntityForName: @"Subject"  inManagedObjectContext: context];
		[s setValue:[p lastPathComponent]	forKey:@"name"];
		[s setValue:p						forKey:@"path"];
		[s setValue:@"Unknown"				forKey:@"type"];
	}
		
    return YES;    
}
#pragma mark ---
// selection
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	int		ri=[table selectedRow];
	NSArray	*arr=[ctrl arrangedObjects];
	id		obj=[arr objectAtIndex:ri];
	char	*path=(char*)[[obj valueForKey:@"path"] cString];
	int		oldKey,newKey=-1;

	if(oldObj)
	{
	// remove oldObj from catalogue
		oldKey=[[oldObj valueForKey:@"key"] intValue];
		if([[oldObj valueForKey:@"type"] isEqualTo:@"FreeSurfer"])	removeFreeSurfer(oldKey);
		if([[oldObj valueForKey:@"type"] isEqualTo:@"Analyze"])		removeAnalyze(oldKey);
	}
	
	// add obj to catalogue
	if([[obj valueForKey:@"type"]	isEqualTo:@"FreeSurfer"])	newKey=addFreeSurfer(path);
	if([[obj valueForKey:@"type"]	isEqualTo:@"Analyze"])		newKey=addAnalyze(path);
	[obj setValue:[NSNumber numberWithInt:newKey] forKey:@"key"];
	oldObj=obj;
}
#pragma mark -
int addFreeSurfer(char *path)
{
	int		key,shmID;
	char	*shm;
	/**/char	tst[]="esta es una pruebita";
	
	key=addData(strlen(tst)+1);
	shmID=shmget(key,1,0666);
	shm=shmat(shmID,NULL,0);
	//FreeSurfer_load((char*)[[obj valueForKey:@"path"] cString]);
	/**/strcpy(shm,tst);
	shmdt(shm);

	return key;
}
void removeFreeSurfer(int key)
{
	removeData(key);
}
int addAnalyze(char *path)
{
	int		err,key,sz,shmID;
	char	*addr,*shm;

	Analyze_load(path,&addr,&sz);
	key=addData(sz,"Analyze"); if(key<0) printf("[addAnalyze] addData() failed\n");
		else
		{
	shmID=shmget(key,sz,0666); if(shmID<0) printf("[addAnalyze] shmget() failed\n");
		else
		{
	shm=shmat(shmID,NULL,0);	if(shm==(char*)-1) printf("[addAnalyze] shmat() failed\n");
		else
		{
	memcpy(shm,addr,sz);
	err=shmdt(shm);
		}
		}
		}
	free(addr);

	return key;
}
void removeAnalyze(int key)
{
	removeData(key);
}
@end
