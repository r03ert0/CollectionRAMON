/*
 *  FreeSurfer.c
 *  CollectionRAMON
 *
 *  Created by rOBERTO tORO on 07/04/2006.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include "FreeSurfer.h"

void FreeSurfer_load(char *path, FreeSurferHeader *hdr)
{
	FILE	*f;
	int		sz;
	
	sz=sizeof(FreeSurferHeader);

	f=fopen(path,"r");
	if(f)
	{
		fread(hdr,sz,sizeof(char),f);
	}
}