#include <stdio.h>
#include <stdlib.h>
#include <sys/errno.h>
#include <sys/mman.h>
#include <sys/fcntl.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
	int			err,fd;
	size_t		sz=8000000;
	struct stat	sb;
	char		*addr;
	
	fd=shm_open("/1234",O_CREAT|O_RDWR|O_EXCL,S_IRUSR|S_IWUSR); if(fd<0) printf("shm_open() failed: %s\n",strerror(errno));
	err=ftruncate(fd,(off_t)sz); if(err<0) printf("ftruncate() failed: %s\n",strerror(errno));
	err=fstat(fd,&sb); if(err<0) printf("fstat() failed: %s\n",strerror(errno));
	printf("File size is %i bytes\n",(int)sb.st_size);
	
	addr=mmap(NULL,sz,PROT_READ|PROT_WRITE,MAP_SHARED,fd,(off_t)0); if(addr==(char*)-1) printf("mmap() failed: %s\n",strerror(errno));
	err=munmap(addr,sz); if(err<0) printf("munmap() failed: %s\n",strerror(errno));
	
	err=shm_unlink("/1234"); if(err<0) printf("shm_unlink() failed: %s\n",strerror(errno));
	err=close(fd);  if(err<0) printf("close() failed: %s\n",strerror(errno));
	
	return 0;
}
