/*
 *  Analyze.h
 *  CollectionRAMON
 *
 *  Created by rOBERTO tORO on 06/04/2006.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct
{
    // header key
	int		sizeof_hdr;
	char	data_type[10];
    char	db_name[18];
	int		extents;
	short	session_error;
	char	regular;
	char	hkey_un0;
	
	// image dimension
	short	dim[8];		// dim[0]<15 => little endian
	short	unused[7];
	short	datatype;
	short	bitpix;
	short	dim_un0;
	float	pixdim[8];
	float	vox_offset;
	float	funused[3];
	float	cal_max;
	float	cal_min;
	float	compressed;
	float	verified;
	int		glmax;
	int		glmin;
	
	// data history
	char	descrip[80];
	char	aux_file[24];
	char	orient;
	char	originator[10];
	char	generated[10];
	char	scannum[10];
	char	patient_id[10];
	char	exp_date[10];
	char	exp_time[10];
	char	hist_un0[3];
	int		views;
	int		vols_added;
	int		start_field;
	int		field_skip;
	int		omax;
	int		omin;
	int		smax;
	int		smin;
}AnalyzeHeader;

void Analyze_load(char *path, char **addr,int *sz);
void Analyze_load_hdr(char *path, AnalyzeHeader *hdr);
void Analyze_load_img(char *path, AnalyzeHeader hdr, char *img);

int bytesPerVoxel(AnalyzeHeader hdr);

void reverse_hdr(AnalyzeHeader *hdr);
void reverse_img(char *img, AnalyzeHeader hdr);

void reverse_short(short *v);
void reverse_int(int *v);
void reverse_float(float *v);