#import "MyAppController.h"

Catalogue	*ctlg;
@implementation MyAppController
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	start();
	timer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(show:) userInfo:nil repeats:YES];
}
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	stop();
	[timer invalidate];
}
// show and check connections to catalogue
-(void)show:(NSTimer*)theTimer
{
	int	err,i,n=(*ctlg).nconnections,key,shmID;
	struct shmid_ds	stat;
	
	for(i=0;i<n;i++)
	{
		key=(*ctlg).connection[i].key;
		shmID=shmget(key,1,0666);			if(shmID<0) printf("[showCatalogue] shmget() failed (key=%i): %s\n",key,strerror(errno));
		err=shmctl(shmID,IPC_STAT,&stat);	if(err<0) printf("[showCatalogue] shmctl() failed\n");
		if(stat.shm_nattch>0)	strcpy((*ctlg).connection[i].msg,"connected");
		else					strcpy((*ctlg).connection[i].msg,"willing");
			
		printf("%2i.type:%s msg:%s key:%i attached:%i\n",
			i,
			(*ctlg).connection[i].type,
			(*ctlg).connection[i].msg,
			key,
			stat.shm_nattch);
	}
}
#pragma mark -
// start catalogue
void start(void)
{
	int		catID;
	
	catID=shmget(KEYCATALOGUE,sizeof(Catalogue),IPC_CREAT|0666); if(catID<0) printf("[startCatalogue] shmget() failed (key=%i): %s\n",KEYCATALOGUE,strerror(errno));
	ctlg=(Catalogue*)shmat(catID,NULL,0); if((char*)ctlg==(char*)-1)  printf("[startCatalogue] shmat() failed\n");
	(*ctlg).nconnections=0;
	printf("started\n");
}
// stop catalogue
void stop(void)
{
	int				err,i,n,catID;
	key_t			key;
	
	n=(*ctlg).nconnections;
	if(n>1)
	{
		catID=shmget(KEYCATALOGUE,sizeof(Catalogue),0666); if(catID<0) printf("[stopCatalogue] shmget() failed (key=%i): %s\n",KEYCATALOGUE,strerror(errno));
		printf("closing %i connections\n",n);
		for(i=0;i<n;i++)
		{
			key=(*ctlg).connection[0].key;
			removeData(key);
		}
	}
	err=shmctl(catID,IPC_RMID,NULL); if(err<0) printf("[stopCatalogue] shmctl() failed: %s\n",strerror(errno));
	printf("stopped\n");
}
// add data to catalogue
int addData(int sz,char *type)
{
	printf("add: ");
	int			key=-1;
	int			shmID;
	Connection	con;

	// get connection
	key=getKey(sz);
		if(key<0) printf("[addToCatalogue] getUnusedKey() failed\n");
		else
		{
	shmID=shmget(key,sz,0666);
		if(shmID<0) printf("[addToCatalogue] shmget() failed (key=%i): %s\n",key,strerror(errno));
		else
		{
	// add to catalogue
	strcpy(con.type,type);
	strcpy(con.msg,"willing");
	con.key=key;
	(*ctlg).connection[(*ctlg).nconnections++]=con;
		}
		}
	printf("%i\n",key);
	
	return key;
}
// remove data from catalogue
void removeData(int key)
{
	printf("remove %i\n",key);
	int				err,i,j,shmID;
	struct shmid_ds	stat;
	struct timespec	ts;
	ts.tv_sec = 0;
	ts.tv_nsec = 5000;
	
	for(i=0;i<(*ctlg).nconnections;i++)
		if((*ctlg).connection[i].key==key) break;
	
	if(i<(*ctlg).nconnections)
	{
		// remove connection
		strcpy((*ctlg).connection[i].msg,"unwilling");
		shmID=shmget(key,1,0666); if(shmID<0) printf("[removeFromCatalogue] shmget() failed (key=%i): %s\n",key,strerror(errno));
		do
		{
			err=shmctl(shmID,IPC_STAT,&stat); if(err<0) printf("[removeFromCatalogue] shmctl() failed\n");
			nanosleep(&ts, NULL);
		}
		while(stat.shm_nattch>1);
		err=shmctl(shmID,IPC_RMID,NULL); if(err<0) printf("[removeFromCatalogue] shmctl() failed\n");
		
		// remove from catalogue
		for(j=i;j<(*ctlg).nconnections-1;j++)
			(*ctlg).connection[j]=(*ctlg).connection[j+1];
		(*ctlg).nconnections--;
	}
	else
		printf("not in catalogue\n");
}
// get a key for unsuded memory space
int getKey(int sz)
{
	int				j,max=5,key=-1;
	int				shmID;

	for(j=0;j<max;j++)
	{
		key=rand()%9999;
		shmID=shmget(key,sz,IPC_CREAT|IPC_EXCL|0666);
		if(errno==17)
		{
			shmID=shmget(key,sz,0666);
			shmctl(shmID,IPC_RMID,NULL);
			shmID=shmget(key,sz,IPC_CREAT|IPC_EXCL|0666);
		}
		if(shmID<0)
			printf("[getUnusedKey] shmget() failed (key=%i): %s (errno=%i)\n",key,strerror(errno),errno);
		else
			break;
	}
	if(j==max){ key=-1; printf("[getUnusedKey] 5 unsuccessful trials\n");}

	return key;
}
@end
