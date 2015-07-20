/*
 *  SurfaceRAMON.c
 *  CollectionRAMON
 *
 *  Created by roberto on 25/05/2010.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "SurfaceRAMON.h"

#include "VolumeRAMON.h"

void SurfaceRAMON_load(char *path, char **surf,int *sz)
{
	char	tailer[1024];
	// make tailer
	sprintf(tailer,"<tailer>\n%s\n</tailer>",path);
	
	*sz=strlen(tailer);
	*surf=calloc(*sz,1);
	memcpy(*surf,tailer,strlen(tailer));
}
