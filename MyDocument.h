//  MyDocument.h
//  CollectionRAMON
//
//  Created by rOBERTO tORO on 06/04/2006.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.

#import <Cocoa/Cocoa.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/mman.h>
#define KEYCATALOGUE	"/nineteenseventytwo"
#include "Analyze.h"
#include "FreeSurfer.h"
#include "MGH.h"
#include "Nifti.h"

int	FreeSurfer_meshType;
int	MGH_volumeType;

@interface MyDocument : NSPersistentDocument
{
	IBOutlet NSTableView			*table;
	IBOutlet NSArrayController		*ctrl;
	id oldObj;
}
int addGZCompressed(char *path, char *name);
void removeGZCompressed(int key);
int addFreeSurfer(char *path, char *name, int meshType);
void removeFreeSurfer(int key);
int addAnalyze(char *path, char *name);
void removeAnalyze(int key);
int addNifti(char *path, char *name);
void removeNifti(int key);
int addMGH(char *path, char *name, int volumeType);
void removeMGH(int key);
int addVolumeRAMON(char *path, char *name);
void removeVolumeRAMON(int key);
int addVolumeRAMONZip(char *path, char *name);
void removeVolumeRAMONZip(int key);
int addSurfaceRAMON(char *path, char *name);
void removeSurfaceRAMON(int key);

void launchPreferedViewer(char *str);
@end
