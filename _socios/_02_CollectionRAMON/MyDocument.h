//  MyDocument.h
//  CollectionRAMON
//
//  Created by rOBERTO tORO on 06/04/2006.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.

#import <Cocoa/Cocoa.h>
#include "Analyze.h"
#include "FreeSurfer.h"

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#define KEYCATALOGUE	1972


@interface MyDocument : NSPersistentDocument
{
	IBOutlet NSTableView			*table;
	IBOutlet NSArrayController		*ctrl;
	id oldObj;
}
int addFreeSurfer(char *path);
void removeFreeSurfer(int key);
int addAnalyze(char *path);
void removeAnalyze(int key);
@end
