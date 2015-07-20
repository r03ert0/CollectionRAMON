//
//  AnalyzeFile.m
//  CollectionRAMON
//
//  Created by rOBERTO tORO on 06/03/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "AnalyzeFile.h"

@implementation AnalyzeFile
-(NSString*)name
{
	return [NSString stringWithCString:vd.name];
}
-(NSString*)path
{
	return path;
}
-(BOOL)littleEndian
{
	return vd.littleEndian;
}
-(NSData*)dim
{
	return [NSData dataWithBytes:vd.dim length:3*sizeof(int)];
}
-(NSData*)pdim
{
	return [NSData dataWithBytes:vd.pdim length:3*sizeof(float)];
}
-(NSData*)orig
{
	return [NSData dataWithBytes:vd.orig length:3*sizeof(int)];
}
-(NSNumber*)dataType
{
	return [NSNumber numberWithInt:vd.dataType];
}
-(NSData *)img
{
	return img;
}
#pragma mark -
-(id)init
{
	self=[super init];
	if(self)
	{
		
	}
	return self;
}
#pragma mark -
-(void)initWithFile:(NSString*)newPath
{
	[newPath retain];
	[path release];
	path=newPath;

	img=[[NSData alloc]	initWithContentsOfFile:
					[[path stringByDeletingPathExtension]
					stringByAppendingPathExtension:@"img"]];
	hdr=[[NSData alloc] initWithContentsOfFile:
					[[path stringByDeletingPathExtension]
					stringByAppendingPathExtension:@"hdr"]];
	parseAnalyzeData(&vd, (unsigned char*)[hdr bytes], [hdr length]);
	vd.data=(unsigned char *)[img bytes];
}
void parseAnalyzeData(VolumeDescription *d, unsigned char *h, int nbytes)
{
    int			i=0,j;
    int			size;
    char		u[5];
    bool		le=false;
    short		x;

    printf("parsing analyze data\n");
    // read header
    //  header_key
    
    size=readInt(h,&i,le);						// sizeof_hdr: int
    i+=10;										// data_type: 10*byte
    for(j=0;j<18;j++)
		(*d).name[j]=readByte(h,&i);			// db_name: 18*byte 
    i+=4; 										// extents: int
    i+=2;										// session_error: short
    i+=1;										// regular: byte
    i+=1;	 									// hkey_un0: byte

// image_dimension
    x=readShort(h,&i,le);						// dim[0] (endian): short
    if ((x < 0) || (x > 15)) 
        le=(*d).littleEndian = true;
    printf(le?"little\n":"big\n");
    (*d).dim[0]=(int)readShort(h,&i,le);	// dim[1] (width): short
    (*d).dim[1]=(int)readShort(h,&i,le);	// dim[2] (height): short
    (*d).dim[2]=(int)readShort(h,&i,le);	// dim[3] (nImages): short
    i+=2;										// dim[4] :short
    i+=2*3;										// dim[5-7] 
    u[0]=(char)readByte(h,&i);				// vox_units
    u[1]=(char)readByte(h,&i);
    u[2]=(char)readByte(h,&i);
    u[3]=(char)readByte(h,&i);
    u[4]=(char)0;
    i+=8;										// cal_units[8] : 8*byte
    i+=2;										// unused1: short
    (*d).dataType=readShort(h,&i,le);		// datatype :short
    i+=2;										// bitpix:short
    i+=2;										// dim_un0:short
    i+=4;										// pixdim[0] :float
    (*d).pdim[0]=readFloat(h,&i,le);		// pixdim[1] (width):float
    (*d).pdim[1]=readFloat(h,&i,le);		// pixdim[2] (height):float
    (*d).pdim[2]=readFloat(h,&i,le);		// pixdim[3] (depth):float
    i+=4*4;										// pixdim[4-7]  :float*4
    i+=4;										// vox_offset :float
    i+=4;										// roi_scale :float
    i+=4;										// funused1 :float
    i+=4;										// funused2 :float
    i+=4;										// cal_max :float
    i+=4;										// cal_min :float
    i+=4;										// compressed:int
    i+=4;										// verified  :int
    i+=4;
    i+=4;

// data_history 

    i+=80;										// descrip :byte*80 
    i+=24;										// aux_file :byte*24
    i+=1;										// orient :byte
    (*d).orig[0]=readShort(h,&i,le);		// origin x
    (*d).orig[1]=readShort(h,&i,le);		// origin y
    (*d).orig[2]=readShort(h,&i,le);		// origin z
	if((*d).orig[0]==0) (*d).orig[0]=(*d).dim[0]/2;
	if((*d).orig[1]==0) (*d).orig[1]=(*d).dim[1]/2;
	if((*d).orig[2]==0) (*d).orig[2]=(*d).dim[2]/2;
    i+=2*2;										// origin, origin
    i+=10;										// generated :byte*10
    i+=10;										// scannum :byte*10
    i+=10;										// patient_id  :byte*10
    i+=10;										// exp_date :byte*10
    i+=10;										// exp_time  :byte*10
    i+=3;										// hist_un0:byte*3
    i+=1;										// views :int
    i+=1;										// vols_added :int
    i+=1;										// start_field  :int
    i+=1;										// field_skip:int
    i+=1;										// omax  :int
    i+=1;										// omin :int
    i+=1;										// smax  :int
    i+=1;										// smin :int

    switch ((*d).dataType)
    {
     case 2:	// DT_UNSIGNED_CHAR 
      break;
     case 4:	// DT_SIGNED_SHORT 
      break;
     case 8:	// DT_SIGNED_INT
      break; 
     case 16:	// DT_FLOAT 
      break; 
     case 128:	// DT_RGB
      break; 
    }
}
#pragma mark -
unsigned char readByte(unsigned char *b, int *i)
{
    int	p=(*i);
    (*i)++;
    return *(unsigned char*)(b+p);
}
short readShort(unsigned char *b, int *i, bool flag)
{
    short x;
    int	p=(*i);
    (*i)+=2;
    if(!flag)
    {
        unsigned char b1=readByte(b,&p);
        unsigned char b2=readByte(b,&p);
        x=(short)(((b2 & 0xff) << 8) | (b1 & 0xff));
    }
    else
        x= *(short*)(b+p);
    return x;
}
int readInt(unsigned char *b, int *i, bool flag)
{
    int	x;
    int	p=(*i);
    (*i)+=4;
    if(!flag)
    {
        unsigned char by[4];
        by[3]=readByte(b,&p);
        by[2]=readByte(b,&p);
        by[1]=readByte(b,&p);
        by[0]=readByte(b,&p);
        x=*(int*)by;
    }
    else
        x=*(int*)(b+p);
    return x;
}
float readFloat(unsigned char *b, int *i, bool flag)
{
    int	p=(*i);
    (*i)+=4;
    if(!flag)
    {
        unsigned char by[4];
        by[3]=readByte(b,&p);
        by[2]=readByte(b,&p);
        by[1]=readByte(b,&p);
        by[0]=readByte(b,&p);
        return *(float*)by;
    }
    else
        return *(float*)(b+p);
}
short shortAt(unsigned char *b, bool flag)
{
    if(!flag)
    {
        unsigned char by[2];
        by[1]=*(b+0);
        by[0]=*(b+1);
        return *(short*)by;
    }
    else
        return *(short*)b;
}

float floatAt(unsigned char *b, bool flag)
{
    if(!flag)
    {
        unsigned char by[4];
        by[3]=*(b+0);
        by[2]=*(b+1);
        by[1]=*(b+2);
        by[0]=*(b+3);
        return *(float*)by;
    }
    else
        return *(float*)b;
}
#pragma mark -
double vol_getValueAt(VolumeDescription d, float *p)
{
    double		val;
	
	switch(d.dataType)
	{
		case 2: // byte
			val=vol_getByteAt(d,p);
			break;
		case 4: // short
			val=vol_getShortAt(d,p);
			break;
		case 8: // int
			val=vol_getIntAt(d,p);
			break;
		case 16: //float
			val=vol_getFloatAt(d,p);
			break;
	}

	return val;
}

short vol_getByteAt(VolumeDescription d, float *p)
{
    int		voxel;
	unsigned char b;
    
    if(p[0]<0||p[0]>=d.dim[0]||p[1]<0||p[1]>=d.dim[1]||p[2]<0||p[2]>=d.dim[2])
        return 0;
    voxel=((int)p[2])*d.dim[0]*d.dim[1]+((int)p[1])*d.dim[0]+((int)p[0]);
    b=(d.data+voxel)[0];
	return b;
}
int vol_getIntAt(VolumeDescription d, float *p)
{
    bool	flag=d.littleEndian;
    int		voxel;
    unsigned char b[4];
    
    if(p[0]<0||p[0]>=d.dim[0]||p[1]<0||p[1]>=d.dim[1]||p[2]<0||p[2]>=d.dim[2])
        return 0;
    voxel=((int)p[2])*d.dim[0]*d.dim[1]+((int)p[1])*d.dim[0]+((int)p[0]);
    voxel*=sizeof(int);
    b[0]=(d.data+voxel)[0];
    b[1]=(d.data+voxel)[1];
    b[2]=(d.data+voxel)[2];
    b[3]=(d.data+voxel)[3];
    if(!flag)
    {
        unsigned char by[4];
        by[3]=*(b+0);
        by[2]=*(b+1);
        by[1]=*(b+2);
        by[0]=*(b+3);
        return *(int*)by;
    }
    else
        return *(int*)b;
}
short vol_getShortAt(VolumeDescription d, float *p)
{
    bool	flag=d.littleEndian;
    int		voxel;
    unsigned char b[2];
    
    if(p[0]<0||p[0]>=d.dim[0]||p[1]<0||p[1]>=d.dim[1]||p[2]<0||p[2]>=d.dim[2])
        return 0;
    voxel=((int)p[2])*d.dim[0]*d.dim[1]+((int)p[1])*d.dim[0]+((int)p[0]);
    voxel*=sizeof(short);
    b[0]=(d.data+voxel)[0];
    b[1]=(d.data+voxel)[1];
    if(!flag)
    {
        unsigned char by[2];
        by[1]=*(b+0);
        by[0]=*(b+1);
        return *(short*)by;
    }
    else
        return *(short*)b;
}
void vol_setShortAt(VolumeDescription d, float *p, short val)
{
    int	voxel;

    if(p[0]<0||p[0]>=d.dim[0]||p[1]<0||p[1]>=d.dim[1]||p[2]<0||p[2]>=d.dim[2])
        return;
    voxel=((int)p[2])*d.dim[0]*d.dim[1]+((int)p[1])*d.dim[0]+((int)p[0]);
    voxel*=sizeof(short);
    
    // big endian only !!
    (d.data+voxel)[0]=val&0x00ff;
    (d.data+voxel)[1]=val>>8;
}
float vol_getFloatAt(VolumeDescription d, float *p)
{
    bool	flag=d.littleEndian;
    int		voxel;
    unsigned char b[4];
    
    if(p[0]<0||p[0]>=d.dim[0]||p[1]<0||p[1]>=d.dim[1]||p[2]<0||p[2]>=d.dim[2])
        return 0;
    voxel=((int)p[2])*d.dim[0]*d.dim[1]+((int)p[1])*d.dim[0]+((int)p[0]);
    voxel*=sizeof(float);
    b[0]=(d.data+voxel)[0];
    b[1]=(d.data+voxel)[1];
    b[2]=(d.data+voxel)[2];
    b[3]=(d.data+voxel)[3];
    if(!flag)
    {
        unsigned char by[4];
        by[3]=*(b+0);
        by[2]=*(b+1);
        by[1]=*(b+2);
        by[0]=*(b+3);
        return *(float*)by;
    }
    else
        return *(float*)b;
}

@end
