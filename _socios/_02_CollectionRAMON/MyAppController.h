/* MyAppController */

#import <Cocoa/Cocoa.h>

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#define KEYCATALOGUE	1972
#define MAXCONNECTIONS	10
typedef struct
{
	char	type[32];
	char	msg[32];
	int		key;
}Connection;
typedef struct
{
	int			nconnections;
	Connection	connection[MAXCONNECTIONS];
}Catalogue;

@interface MyAppController : NSObject
{
	NSTimer		*timer;
}
-(void)show:(NSTimer*)theTimer;

void start(void);
void stop(void);
int addData(int sz,char *type);
void removeData(int key);
int getKey(int sz);
@end
