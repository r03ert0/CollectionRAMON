//
//  AnalyzeFile.h
//  CollectionRAMON
//
//  Created by rOBERTO tORO on 06/03/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct
{
	char	name[18];	
    bool	littleEndian;
    short	dataType;
    int		dim[3];
    float	pdim[3];
    int		orig[3];
	
	float   f;			// intensity correction factor (to have 95% of the volume under 255)
    
    float	v2m[12];	// voxel to milimeter: origin(v), sag(m/v), cor(m/v), axi(m/v)
    float	m2v[12];	// milimeter to voxel: origin(v), sag(v/m), cor(v/m), axi(v/m)

    unsigned char	*data;
}VolumeDescription;

@interface AnalyzeFile : NSObject
{
	NSData				*hdr;
	NSData				*img;
	NSString			*path;
	VolumeDescription	vd;
}

//accessors
-(NSString*)name;
-(NSString*)path;
-(BOOL)littleEndian;
-(NSData*)dim;
-(NSData*)pdim;
-(NSData*)orig;
-(NSNumber*)dataType;
-(NSData *)img;

-(void)initWithFile:(NSString*)path;
void parseAnalyzeData(VolumeDescription *d, unsigned char *h, int nbytes);
unsigned char readByte(unsigned char *b, int *i);
short readShort(unsigned char *b, int *i, bool flag);
int readInt(unsigned char *b, int *i, bool flag);
float readFloat(unsigned char *b, int *i, bool flag);
short shortAt(unsigned char *b, bool flag);
float floatAt(unsigned char *b, bool flag);
double vol_getValueAt(VolumeDescription d, float *p);
short vol_getByteAt(VolumeDescription d, float *p);
int vol_getIntAt(VolumeDescription d, float *p);
short vol_getShortAt(VolumeDescription d, float *p);
void vol_setShortAt(VolumeDescription d, float *p, short val);
float vol_getFloatAt(VolumeDescription d, float *p);

@end
