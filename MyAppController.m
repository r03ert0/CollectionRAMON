#import "MyAppController.h"

Catalogue	*ctlg;
@implementation MyAppController
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	strcpy(consoleMsg,"empty string");
	start();
	timer=[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkConnection:) userInfo:nil repeats:YES];
}
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	stop();
	[timer invalidate];
}
// check connections to catalogue
-(void)checkConnection:(NSTimer*)theTimer
{
	int			err,i,m,n=(*ctlg).nconnections,key,att,shmFD;
	struct stat	cstat;
	char		skey[10],cmsg[512];
	
	for(i=0;i<n;i++)
	{
		key=(*ctlg).connection[i].key;
		att=(*ctlg).connection[i].connections;
		sprintf(skey,"%i",key);
		shmFD=shm_open(skey,O_RDWR,0666);
			if(shmFD<0) printf("[show] shm_open() failed (key=%s): %s\n",skey,strerror(errno));
			else
			{
		err=fstat(shmFD,&cstat);
			if(err<0) printf("[show] fstat() failed\n");
			else
			{
		close(shmFD);
		
		if((*ctlg).connection[i].msg[0]=='*')
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Message" object:[NSString stringWithUTF8String:&((*ctlg).connection[i].msg)[1]]];
	
		if(att>0)	strcpy((*ctlg).connection[i].msg,"connected");
		else		strcpy((*ctlg).connection[i].msg,"willing");
			
		sprintf(cmsg,"%2i.type:%s msg:%s key:%i attached:%i\n",
			i,
			(*ctlg).connection[i].type,
			(*ctlg).connection[i].msg,
			key,
			att);
		m=strcmp(cmsg,consoleMsg);
		if(m!=0)
		{
			strcpy(consoleMsg,cmsg);
			printf("%s\n",consoleMsg);
		}
			}
			}
	}
}
#pragma mark -
// start catalogue
void start(void)
{
	int		err,catFD;
	int		sz=sizeof(Catalogue);
	
	catFD=shm_open(KEYCATALOGUE,O_CREAT|O_RDWR|O_EXCL,S_IRUSR|S_IWUSR);
	if(catFD<0)
	{
		catFD=shm_open(KEYCATALOGUE,O_RDWR,S_IRUSR|S_IWUSR); if(catFD<0) printf("[start] shm_open() failed (key=%s): %s\n",KEYCATALOGUE,strerror(errno));
		shm_unlink(KEYCATALOGUE);
		close(catFD);
		catFD=shm_open(KEYCATALOGUE,O_CREAT|O_RDWR|O_EXCL,S_IRUSR|S_IWUSR); if(catFD<0) printf("[start] shm_open() failed (key=%s): %s\n",KEYCATALOGUE,strerror(errno));
	}
	err=ftruncate(catFD,(off_t)sz);
	ctlg=(Catalogue*)mmap(NULL,sz,PROT_READ|PROT_WRITE,MAP_SHARED,catFD,0); if((char*)ctlg==(char*)-1)  printf("[start] shmat() failed\n");
	(*ctlg).nconnections=0;
	printf("started\n");
}
// stop catalogue
void stop(void)
{
	int				err,i,n;
	key_t			fd;
	
	n=(*ctlg).nconnections;
	if(n>1)
	{
		printf("closing %i connections\n",n);
		for(i=0;i<n;i++)
		{
			fd=(*ctlg).connection[0].key;
			removeData(fd);
		}
	}
	err=shm_unlink(KEYCATALOGUE); if(err<0) printf("[stop] shm_unlink() failed: %s\n",strerror(errno));
	printf("stopped\n");
}
// get a key for unsuded memory space
int getKey(int sz)
{
	int				err,j,max=5,key=-1;
	int				shmFD;
	char			skey[10];

	for(j=0;j<max;j++)
	{
		key=rand()%9999;
		sprintf(skey,"%i",key);
		shmFD=shm_open(skey,O_CREAT|O_RDWR|O_EXCL,S_IRUSR|S_IWUSR);
		if(shmFD<0 && errno==EEXIST)
		{
			shmFD=shm_open(skey,O_RDWR,S_IRUSR|S_IWUSR);
			err=shm_unlink(skey); if(err<0) printf("[getKey] shm_unlink() failed\n");
			close(shmFD);
			shmFD=shm_open(skey,O_CREAT|O_RDWR|O_EXCL,S_IRUSR|S_IWUSR); printf("3.3 +\n");
			err=shm_unlink(skey); if(err<0) printf("[getKey] shm_unlink() failed\n");
			close(shmFD);
		}
		if(shmFD<0)
			printf("[getKey] shm_open() failed (key=%s): %s (errno=%i)\n",skey,strerror(errno),errno);
		else
		{
			close(shmFD);
			break;
		}
	}
	if(j==max){ key=-1; printf("[getKey] 5 unsuccessful trials\n");}

	return key;
}
// add data to catalogue
int addData(char *addr, int sz,char *name,char *type)
{
	printf("add: ");
	int			err,key=-1;
	int			shmFD;
	char		*shm,skey[10];
	Connection	con;

	// get connection
	key=getKey(sz);
		if(key<0) printf("[addData] getKey() failed\n");
		else
		{
	sprintf(skey,"%i",key);
	shmFD=shm_open(skey,O_RDWR,S_IRUSR|S_IWUSR);
		if(shmFD<0) printf("[addData] shm_open() failed (key=%s): %s\n",skey,strerror(errno));
		else
		{
	err=ftruncate(shmFD,(off_t)sz); if(err<0) printf("ftruncate() failed: %s\n",strerror(errno));
	
	// add data
	shm=mmap(NULL,sz,PROT_READ|PROT_WRITE,MAP_SHARED,shmFD,0);
		if(shm==(char*)-1) printf("[addData] mmap() failed: %s (%i)\n",strerror(errno),errno);
		else
		{
	memcpy(shm,addr,sz);
	err=munmap(shm,sz);
	close(shmFD);
		
	// add to catalogue
	strcpy(con.name,name);
	strcpy(con.type,type);
	strcpy(con.msg,"willing");
	con.key=key;
	con.connections=0;
	(*ctlg).connection[(*ctlg).nconnections++]=con;
		}
		}
		}
	printf("%i\n",key);
	
	return key;
}
// remove data from catalogue
void removeData(int fd)
{
	printf("remove %i\n",fd);

	int				err,i,j,att;
	int				shmFD;
	char			skey[10];
	struct timespec	ts;
	
	sprintf(skey,"%i",fd);
	
	ts.tv_sec = 0;
	ts.tv_nsec = 5000;
	
	for(i=0;i<(*ctlg).nconnections;i++)
		if((*ctlg).connection[i].key==fd) break;
	
	if(i<(*ctlg).nconnections)
	{

		// remove connection
		strcpy((*ctlg).connection[i].msg,"unwilling");
		do
		{
			att=(*ctlg).connection[i].connections;
			nanosleep(&ts, NULL);
		}
		while(att>1);
		shmFD=shm_open(skey,O_RDWR,S_IRUSR|S_IWUSR);
		err=shm_unlink(skey); if(err<0) printf("[removeData] shm_unlink() failed\n");
		close(shmFD);
		
		// remove from catalogue
		for(j=i;j<(*ctlg).nconnections-1;j++)
			(*ctlg).connection[j]=(*ctlg).connection[j+1];
		(*ctlg).nconnections--;
	}
	else
		printf("not in catalogue\n");
}
@end
