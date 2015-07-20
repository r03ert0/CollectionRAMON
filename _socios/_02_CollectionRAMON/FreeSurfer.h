/*
 *  FreeSurfer.h
 *  CollectionRAMON
 *
 *  Created by rOBERTO tORO on 07/04/2006.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */
#include <stdio.h>

typedef struct
{
    int		sizeof_hdr;
}FreeSurferHeader;

void FreeSurfer_load(char *path, FreeSurferHeader *hdr);