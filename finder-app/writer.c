#include <stdio.h>
#include <syslog.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
int main (int argc, char* argv[]){
    openlog("Writer", LOG_PID|LOG_PERROR|LOG_CONS, LOG_USER);
    if(argc < 2 ){
        syslog(LOG_ERR, "Number of args is less than 2");
        closelog();
        return 0 ; 
    }
    char* filePath = argv[1];
    printf("file path :  %s",filePath);
    char* strToBeAdded = argv[2];
    ssize_t nr;
    int fd = open(filePath,O_RDWR | O_CREAT |O_TRUNC,S_IRWXU|S_IRWXG|S_IRWXO);
    if(fd == -1) {
        syslog(LOG_ERR, "File cannot be opened");
        closelog();
        return 0 ; 
    }

    nr = write(fd,strToBeAdded,strlen(strToBeAdded));
    if(nr == -1) {
        syslog(LOG_ERR, "Failed writing to the file");
        closelog();
        return 0 ; 
    }else {
        syslog(LOG_DEBUG , "Writing %s to %s",strToBeAdded,filePath);
    }

    closelog();
    return 0 ; 
}