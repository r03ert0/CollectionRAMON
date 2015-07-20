/* MyAppController */

#import <Cocoa/Cocoa.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/mman.h>
#include <sys/stat.h>
#define KEYCATALOGUE	"/nineteenseventytwo"
#define MAXCONNECTIONS	10
typedef struct
{
	char	name[256];
	char	type[32];
	char	msg[32];
	int		key;
	short	connections;
}Connection;
typedef struct
{
	int			nconnections;
	Connection	connection[MAXCONNECTIONS];
}Catalogue;
@interface MyAppController : NSObject
{
	NSTimer		*timer;
	char		consoleMsg[512];
}
-(void)checkConnection:(NSTimer*)theTimer;
void start(void);
void stop(void);
int addData(char *addr, int sz,char *name, char *type);
void removeData(int key);
int getKey(int sz);
@end
