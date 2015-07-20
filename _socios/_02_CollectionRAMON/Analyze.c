/*
 *  Analyze.c
 *  CollectionRAMON
 *
 *  Created by rOBERTO tORO on 06/04/2006.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include "Analyze.h"

void Analyze_load(char *path, char **addr,int *sz)
{
	AnalyzeHeader	hdr;
	
	Analyze_load_hdr(path,&hdr);
	*sz=sizeof(hdr)+hdr.dim[1]*hdr.dim[2]*hdr.dim[3]*bytesPerVoxel(hdr);
	printf("block size: %i bytes\n",*sz);
	*addr=calloc(*sz,1);
	memcpy(*addr,&hdr,sizeof(hdr));
	Analyze_load_img(path,hdr,&((*addr)[sizeof(hdr)]));
}
void Analyze_load_hdr(char *path, AnalyzeHeader *hdr)
{
	FILE	*f;
	int		sz;
	
	sz=sizeof(AnalyzeHeader);

	f=fopen(path,"r");
	if(f)
	{
		fread(hdr,sz,sizeof(char),f);
		fclose(f);
		
		if((*hdr).dim[0]<0||(*hdr).dim[0]>15) // it's little endian
			reverse_hdr(hdr);
		
		printf("data_type=%s\ndb_name=%s\ndim=(%i,%i,%i)\ndatatype=%i\npixdim=(%f,%f,%f)\ndescrip=%s\naux_file=%s\n",
		(*hdr).data_type,
		(*hdr).db_name,
		(*hdr).dim[1],(*hdr).dim[2],(*hdr).dim[3],
		(*hdr).datatype,
		(*hdr).pixdim[1],(*hdr).pixdim[2],(*hdr).pixdim[3],
		(*hdr).descrip,
		(*hdr).aux_file);
	}
}
void Analyze_load_img(char *origPath, AnalyzeHeader hdr, char *img)
{
	char	path[512];
	int		len;
	int		sz=hdr.dim[1]*hdr.dim[2]*hdr.dim[3];
	FILE	*f;
	
	strcpy(path,origPath);
	len=strlen(path);
	path[len-3]='i';
	path[len-2]='m';
	path[len-1]='g';

	f=fopen(path,"r");
	if(f)
	{
		fread(img,sz,bytesPerVoxel(hdr),f);
		if(hdr.dim[0]<0||hdr.dim[0]>15)
			reverse_img(img,hdr);
	}
}
int bytesPerVoxel(AnalyzeHeader hdr)
{
	int	bpv=0;

	switch(hdr.datatype)
	{
		case 2:		bpv=1;	break;
		case 4:		bpv=2;	break;
		case 8:		bpv=4;	break;
		case 16:	bpv=4;	break;
	}
	
	return bpv;
}
#pragma mark -

void reverse_hdr(AnalyzeHeader *hdr)
{
	int		i;
	
    // header key
	reverse_int(&(*hdr).sizeof_hdr);
	reverse_int(&(*hdr).extents);
	reverse_short(&(*hdr).session_error);
	
	// image dimension
	for(i=1;i<8;i++) reverse_short(&(*hdr).dim[i]);		// dim[0]<0 or dim[0]>15 => little endian
	for(i=0;i<7;i++) reverse_short(&(*hdr).unused[i]);
	reverse_short(&(*hdr).datatype);
	reverse_short(&(*hdr).bitpix);
	reverse_short(&(*hdr).dim_un0);
	for(i=0;i<8;i++) reverse_float(&(*hdr).pixdim[i]);
	reverse_float(&(*hdr).vox_offset);
	for(i=0;i<3;i++) reverse_float(&(*hdr).funused[i]);
	reverse_float(&(*hdr).cal_max);
	reverse_float(&(*hdr).cal_min);
	reverse_float(&(*hdr).compressed);
	reverse_float(&(*hdr).verified);
	reverse_int(&(*hdr).glmax);
	reverse_int(&(*hdr).glmin);
	
	// data history
	reverse_int(&(*hdr).views);
	reverse_int(&(*hdr).vols_added);
	reverse_int(&(*hdr).start_field);
	reverse_int(&(*hdr).field_skip);
	reverse_int(&(*hdr).omax);
	reverse_int(&(*hdr).omin);
	reverse_int(&(*hdr).smax);
	reverse_int(&(*hdr).smin);
}
void reverse_img(char *img, AnalyzeHeader hdr)
{
	int		i,sz=hdr.dim[1]*hdr.dim[2]*hdr.dim[3];
	
	switch(hdr.datatype)
	{
		case 2: break;
		case 4: for(i=0;i<sz;i++) reverse_short(&((short*)img)[i]);	break;
		case 8: for(i=0;i<sz;i++) reverse_int(&((int*)img)[i]);	break;
		case 16:for(i=0;i<sz;i++) reverse_float(&((float*)img)[i]);	break;
	}
}	
void reverse_short(short *v)
{
	unsigned char	b[2];
	
	b[0]=((unsigned char*)v)[1];
	b[1]=((unsigned char*)v)[0];
	*v=*(short*)b;
}
void reverse_int(int *v)
{
	unsigned char	b[4];
	
	b[0]=((unsigned char*)v)[3];
	b[1]=((unsigned char*)v)[2];
	b[2]=((unsigned char*)v)[1];
	b[3]=((unsigned char*)v)[0];
	*v=*(int*)b;
}
void reverse_float(float *v)
{
	unsigned char	b[4];
	
	b[0]=((unsigned char*)v)[3];
	b[1]=((unsigned char*)v)[2];
	b[2]=((unsigned char*)v)[1];
	b[3]=((unsigned char*)v)[0];
	*v=*(float*)b;
}

