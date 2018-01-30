//  MyDocument.m
//  CollectionRAMON
//
//  Created by rOBERTO tORO on 06/04/2006.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.

#import "MyDocument.h"

@implementation MyDocument
#pragma mark [   Data-Type Independent   ]
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(message:) name:@"Message" object:nil];
	
	FreeSurfer_meshType=kLEFTWHITEMATTER;
	MGH_volumeType=kORIG;
}
#pragma mark -----
void launchPreferedViewer(char *str)
{
	NSString	*pref=[NSString stringWithUTF8String:str];
	NSWorkspace	*ws=[NSWorkspace sharedWorkspace];
	NSArray		*apps=[ws launchedApplications];
	int			i;
	
	for(i=0;i<[apps count];i++)
		if([[[apps objectAtIndex:i] objectForKey:@"NSApplicationName"] isEqualTo:pref])
			break;
	if(i==[apps count])
		[ws launchApplication:pref];
}
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
	NSString		*p,*x;
	
	for(i=0;i<numFiles;i++)
	{
		p=[files objectAtIndex:i];
		x=[p pathExtension];
		s = [NSEntityDescription insertNewObjectForEntityForName: @"Subject"  inManagedObjectContext: context];
		[s setValue:[p lastPathComponent]	forKey:@"name"];
		[s setValue:p						forKey:@"path"];
		
		if([x isEqualTo:@"gz"])
			[s setValue:@"GZCompressed"		forKey:@"type"];
		else
        if([x isEqualTo:@"nii"])
			[s setValue:@"Nifti"			forKey:@"type"];
		else
        if([x isEqualTo:@"hdr"])
			[s setValue:@"Analyze"			forKey:@"type"];
		else
		if([x isEqualTo:@"mgz"])
		{
			int		i;
			char	cmd[512];
			
			srand (time(NULL));
			i=rand();
			sprintf(cmd,"gunzip -c %s > /tmp/%i.mgh",[p UTF8String],i);
			system(cmd);
			[s setValue:[NSString stringWithFormat:@"/tmp/%i.mgh",i] forKey:@"path"];
			[s setValue:@"MGH"				forKey:@"type"];
		}
		else
		if([x isEqualTo:@"mgh"])
			[s setValue:@"MGH"				forKey:@"type"];
		else
        if([x isEqualTo:@"vramon"])
            [s setValue:@"VolumeRAMON"		forKey:@"type"];
        if([x isEqualTo:@"vramonz"])
            [s setValue:@"VolumeRAMONZip"		forKey:@"type"];
		else
			[s setValue:@"Unknown"			forKey:@"type"];
	}
	[tv setNeedsDisplay:YES];
		
    return YES;    
}
#pragma mark -
#pragma mark [   Data-Type Dependent   ]
// selection
-(void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	printf("____\n");
	int				ri=[table selectedRow];
	NSMutableArray	*arr=[ctrl arrangedObjects];
	id				obj=[arr objectAtIndex:ri];
	char			*path=(char*)[[obj valueForKey:@"path"] cString];
	char			*name=(char*)[[obj valueForKey:@"name"] cString];
	int				oldKey,newKey=-1;

	if(oldObj)
	{
	// remove oldObj from catalogue
		oldKey=[[oldObj valueForKey:@"key"] intValue];
		if([[oldObj valueForKey:@"type"] isEqualTo:@"GZCompressed"])	removeGZCompressed(oldKey);
		if([[oldObj valueForKey:@"type"] isEqualTo:@"FreeSurfer"])		removeFreeSurfer(oldKey);
		if([[oldObj valueForKey:@"type"] isEqualTo:@"Analyze"])			removeAnalyze(oldKey);
		if([[oldObj valueForKey:@"type"] isEqualTo:@"Nifti"])			removeNifti(oldKey);
		if([[oldObj valueForKey:@"type"] isEqualTo:@"MGH"])				removeMGH(oldKey);
        if([[oldObj valueForKey:@"type"] isEqualTo:@"VolumeRAMON"])		removeVolumeRAMON(oldKey);
        if([[oldObj valueForKey:@"type"] isEqualTo:@"VolumeRAMONZip"])	removeVolumeRAMONZip(oldKey);
		if([[oldObj valueForKey:@"type"] isEqualTo:@"SurfaceRAMON"])	removeSurfaceRAMON(oldKey);
	}
	
	// add obj to catalogue
	if([[obj valueForKey:@"type"]	isEqualTo:@"GZCompressed"])	newKey=addGZCompressed(path,name);
	if([[obj valueForKey:@"type"]	isEqualTo:@"FreeSurfer"])	newKey=addFreeSurfer(path,name,FreeSurfer_meshType);
	if([[obj valueForKey:@"type"]	isEqualTo:@"Analyze"])		newKey=addAnalyze(path,name);
	if([[obj valueForKey:@"type"]	isEqualTo:@"Nifti"])		newKey=addNifti(path,name);
	if([[obj valueForKey:@"type"]	isEqualTo:@"MGH"])			newKey=addMGH(path,name,MGH_volumeType);
    if([[obj valueForKey:@"type"]	isEqualTo:@"VolumeRAMON"])	newKey=addVolumeRAMON(path,name);
    if([[obj valueForKey:@"type"]	isEqualTo:@"VolumeRAMONZip"])newKey=addVolumeRAMONZip(path,name);
	if([[obj valueForKey:@"type"]	isEqualTo:@"SurfaceRAMON"])	newKey=addSurfaceRAMON(path,name);
	
	// if unable to load data, ask, otherwise, load.
	if(newKey==1)
	{
		NSAlert *alert=[NSAlert	alertWithMessageText:@"Unable to load data"
					defaultButton:@"Delete"
					alternateButton:@"Ignore"
					otherButton:nil
					informativeTextWithFormat:@"Data may not be available for %s",name];
		if([alert runModal]==1)
		{
			[ctrl removeObject:obj];
			[self tableViewSelectionDidChange:nil];
		}
	}
	else
	{
		[obj setValue:[NSNumber numberWithInt:newKey] forKey:@"key"];
		oldObj=obj;
	}
}
-(void)message:(NSNotification *)aNotification
{
	NSString		*s=[aNotification object];
	int				ri=[table selectedRow];
	NSMutableArray	*arr=[ctrl arrangedObjects];
	id				obj=[arr objectAtIndex:ri];
	char			*path=(char*)[[obj valueForKey:@"path"] cString];
	char			*name=(char*)[[obj valueForKey:@"name"] cString];
	int				oldKey,newKey=-1;
	
	if(	[s isEqualTo:@"WM-Left"]||
		[s isEqualTo:@"GM-Left"]||
		[s isEqualTo:@"IN-Left"]||
		[s isEqualTo:@"WM-Right"]||
		[s isEqualTo:@"GM-Right"]||
		[s isEqualTo:@"IN-Right"]||
		[s isEqualTo:@"orig"]||
		[s isEqualTo:@"nu"]||
		[s isEqualTo:@"brain"]||
		[s isEqualTo:@"aseg"]||
		[s isEqualTo:@"filled"]||
		[s isEqualTo:@"T1"])
	{
		oldKey=[[oldObj valueForKey:@"key"] intValue];
		removeFreeSurfer(oldKey);
		
		if(	[s isEqualTo:@"WM-Left"])
		{
			FreeSurfer_meshType=kLEFTWHITEMATTER;
			newKey=addFreeSurfer(path,name,kLEFTWHITEMATTER);
		}
		else
		if(	[s isEqualTo:@"GM-Left"])
		{
			FreeSurfer_meshType=kLEFTGRAYMATTER;
			newKey=addFreeSurfer(path,name,kLEFTGRAYMATTER);
		}
		else
		if(	[s isEqualTo:@"IN-Left"])
		{
			FreeSurfer_meshType=kLEFTINFLATED;
			newKey=addFreeSurfer(path,name,kLEFTINFLATED);
		}
		else
		if(	[s isEqualTo:@"WM-Right"])
		{
			FreeSurfer_meshType=kRIGHTWHITEMATTER;
			newKey=addFreeSurfer(path,name,kRIGHTWHITEMATTER);
		}
		else
		if(	[s isEqualTo:@"GM-Right"])
		{
			FreeSurfer_meshType=kRIGHTGRAYMATTER;
			newKey=addFreeSurfer(path,name,kRIGHTGRAYMATTER);
		}
		else
		if(	[s isEqualTo:@"IN-Right"])
		{
			FreeSurfer_meshType=kRIGHTINFLATED;
			newKey=addFreeSurfer(path,name,kRIGHTINFLATED);
		}
		else
		if(	[s isEqualTo:@"orig"])
		{
			MGH_volumeType=kORIG;
			newKey=addMGH(path,name,kORIG);
		}
		else
		if(	[s isEqualTo:@"nu"])
		{
			MGH_volumeType=kNU;
			newKey=addMGH(path,name,kNU);
		}
		else
		if(	[s isEqualTo:@"brain"])
		{
			MGH_volumeType=kBRAIN;
			newKey=addMGH(path,name,kBRAIN);
		}
		else
		if(	[s isEqualTo:@"aseg"])
		{
			MGH_volumeType=kASEG;
			newKey=addMGH(path,name,kASEG);
		}
		else
		if(	[s isEqualTo:@"filled"])
		{
			MGH_volumeType=kFILLED;
			newKey=addMGH(path,name,kFILLED);
		}
		else
		if(	[s isEqualTo:@"T1"])
		{
			MGH_volumeType=kT1;
			newKey=addMGH(path,name,kT1);
		}

		// if unable to load data, ask, otherwise, load.
		if(newKey==1)
		{
			NSAlert *alert=[NSAlert	alertWithMessageText:@"Unable to load data"
						defaultButton:@"Delete"
						alternateButton:@"Ignore"
						otherButton:nil
						informativeTextWithFormat:@"Data may not be available for %s",name];
			if([alert runModal]==1)
			{
				[ctrl removeObject:obj];
				[self tableViewSelectionDidChange:nil];
			}
		}
		else
		{
			[obj setValue:[NSNumber numberWithInt:newKey] forKey:@"key"];
			oldObj=obj;
		}
	}
}
#pragma mark -----
int addGZCompressed(char *path, char *name)
{
	char	ext[2048],cmd[2048];
	int		newKey,n;
	
	// get extension
	strcpy(ext,name);
	n=strlen(ext);
	while(ext[n]!='.')
		n--;
	ext[n]=(char)0;
	while(ext[n]!='.')
		n--;
	memcpy(ext,ext+n+1,strlen(ext)-n);
	
	
    // uncompress
	/*
    sprintf(cmd,"/usr/bin/gzip -cd %s > /tmp/tmp.%s",path,ext);
	system(cmd);
    */
	
	if(strcmp(ext,"orig")==0)
		newKey=addFreeSurfer(path,name,FreeSurfer_meshType);
	else
	if(strcmp(ext,"hdr")==0)
		newKey=addAnalyze("/tmp/tmp.hdr",name);
	else
	if(strcmp(ext,"nii")==0)
		newKey=addNifti(path,name);
	else
	if(strcmp(ext,"mgh")==0)
		newKey=addMGH(path,name,MGH_volumeType);
	else
	if(strcmp(ext,"vramon")==0)
		newKey=addVolumeRAMON(path,name);
	else
	if(strcmp(ext,"sramon")==0)
		newKey=addSurfaceRAMON(path,name);
		
	// remove temporary file
	//sprintf(cmd,"/bin/rm /tmp/tmp.%s",ext);
	//system(cmd);

	return newKey;
}
void removeGZCompressed(int key)
{
	removeData(key);
}
int addFreeSurfer(char *path, char *name, int meshType)
{
	int		key,sz;
	char	*addr;
	int		err;
	
	err=FreeSurfer_load(path,&addr,&sz, meshType);
	if(err)
	{
		printf("ERROR: Unable to load data at path: %s\n",path);
		return 1;
	}
	key=addData(addr,sz,name,"FreeSurfer"); if(key<0) printf("[addFreeSurfer] addData() failed\n");
	free(addr);
	addr=nil;
	
	launchPreferedViewer("SurfaceRAMON");
	
	return key;
}
void removeFreeSurfer(int key)
{
	removeData(key);
}
int addAnalyze(char *path, char *name)
{
	int		key;
	/*
	int		sz,swapped;
	char	*addr;
	Analyze_load(path,&addr,&sz,&swapped);
	key=addData(addr,sz,name,"Volume"); if(key<0) printf("[addAnalyze] addData() failed\n");
	free(addr);
	addr=nil;
	*/

	key=addData(path,strlen(path),name,"Volume"); if(key<0) printf("[addAnalyze] addData() failed\n");
	
	launchPreferedViewer("StereotaxicEditorRAMON");

	return key;
}
void removeAnalyze(int key)
{
	removeData(key);
}
int addNifti(char *path, char *name)
{
	int		key;
	/*
	int		sz,swapped;
	char	*addr;
	Nifti_load(path,&addr,&sz,&swapped);
	key=addData(addr,sz,name,"Volume"); if(key<0) printf("[addNifti] addData() failed\n");
	free(addr);
	addr=nil;
	 */
	key=addData(path,strlen(path),name,"Volume"); if(key<0) printf("[addNifti] addData() failed\n");

	
	launchPreferedViewer("StereotaxicEditorRAMON");
	
	return key;
}
void removeNifti(int key)
{
	removeData(key);
}
int addMGH(char *path, char *name, int volumeType)
{
	int		key;
	/*
	int		sz;
	char	*addr;
	MGH_load(path,&addr,&sz, volumeType);
	key=addData(addr,sz,name,"Volume"); if(key<0) printf("[addMGH] addData() failed\n");
	free(addr);
	addr=nil;
	 */
	key=addData(path,strlen(path),name,volumeType); if(key<0) printf("[addMGH] addData() failed\n");

	launchPreferedViewer("StereotaxicEditorRAMON");

	return key;
}
void removeMGH(int key)
{
	removeData(key);
}
int addVolumeRAMON(char *path, char *name)
{
	int		key;
	/*
	int		sz;
	char	*addr;
	VolumeRAMON_load(path,&addr,&sz);
	key=addData(addr,sz,name,"Volume"); if(key<0) printf("[addVolumeRAMON] addData() failed\n");
	free(addr);
	addr=nil;
	 */
	key=addData(path,strlen(path),name,"Volume"); if(key<0) printf("[addVolumeRAMON] addData() failed\n");

	launchPreferedViewer("StereotaxicEditorRAMON");

	return key;
}
void removeVolumeRAMON(int key)
{
	removeData(key);
}
int addVolumeRAMONZip(char *path, char *name)
{
    int		key;
    key=addData(path,strlen(path),name,"Volume"); if(key<0) printf("[addVolumeRAMONZip] addData() failed\n");
    
    launchPreferedViewer("StereotaxicEditorRAMON");
    
    return key;
}
void removeVolumeRAMONZip(int key)
{
    removeData(key);
}
int addSurfaceRAMON(char *path, char *name)
{
	int		key,sz;
	char	*addr;

	SurfaceRAMON_load(path,&addr,&sz);
	key=addData(addr,sz,name,"Surface"); if(key<0) printf("[addSurfaceRAMON] addData() failed\n");
	free(addr);
	addr=nil;

	launchPreferedViewer("MeshSurgery");

	return key;
}
void removeSurfaceRAMON(int key)
{
	removeData(key);
}
@end
