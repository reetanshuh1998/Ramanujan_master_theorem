/*[6~
    This file is a part of the program QLink.
    Copyright (C) Alexander Smirnov <asmirnov@particle.uni-karlsruhe.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 2 as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

	------------------------------------------------------------------
	
*/

#include <time.h>
#include <sys/time.h>
#define _XOPEN_SOURCE 600
#include <fcntl.h>

#include <string.h>
#include <kclangc.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <mathlink.h>
#include <unistd.h>


#define FILELIMIT 50
#define MAXVALUESIZE 500000000



	KCDB *dbhandle[FILELIMIT];
	char *dbname[FILELIMIT];
	KCDB *db;

	

int BucketSize;
bool Compression;
bool AutoBucket;
bool NoLock;


int CurrentBucket[FILELIMIT];

int64_t Entries[FILELIMIT];
int64_t Buckets[FILELIMIT];



void PutErrorMessage(const char* function,const char* message) {
			fprintf(stderr, "%s: %s\n",function,message);
			MLPutFunction(stdlink,"CompoundExpression",2);
			MLPutFunction(stdlink,"Message",2);
			MLPutFunction(stdlink,"MessageName",2);
			MLPutSymbol(stdlink, function);
			MLPutString(stdlink, "failed");
			MLPutString(stdlink, message);
			MLPutSymbol(stdlink, "False");
}

int DBNumber(char* name) {
	int i;
	for (i=0;i<FILELIMIT;i++) {
		if((dbname[i]!=NULL) && (strcmp(dbname[i],name)==0)) {
			return(i);
		}
	};
	return(-1);
}

int FreeDBNumber() {
	int i;
	for (i=0;i<FILELIMIT;i++) {
		if((dbname[i]==NULL)) {
			return(i);
		}
	};
	return(-1);
}

#define checkSlash(s) if(*(s)!= '\0'){char *sss=(s); for(;*sss!='\0';sss++);if(*(sss-1)=='/')*(sss-1)='\0';}

void qsetbucketsize(int i) {
  BucketSize=i;
  MLPutSymbol(stdlink, "True");
}

void qsetcompressionon() {
  Compression=true;
  MLPutSymbol(stdlink, "True");
}

void qsetcompressionoff() {
  Compression=false;
  MLPutSymbol(stdlink, "True");
}

void qsetautobucketon() {
  AutoBucket=true;
  MLPutSymbol(stdlink, "True");
}

void qsetautobucketoff() {
  AutoBucket=false;
  MLPutSymbol(stdlink, "True");
}

void qsetnolock() {
  NoLock=true;
  MLPutSymbol(stdlink, "True");
}

void qsetlock() {
  NoLock=false;
  MLPutSymbol(stdlink, "True");
}


void qget(char* s,char* key) {
  int i;
  char* val;
  checkSlash(s);
 
	i=DBNumber(s);
	if (i>=0) {
		db=dbhandle[i];
		size_t st;
		if(!(val=kcdbget(db, key, strlen(key),&st))){
			PutErrorMessage("QGet",kcdbemsg(db));
		} else {			
			MLPutString(stdlink, val);
			kcfree(val);
		}
	} else {
		PutErrorMessage("QGet","this database is not open");
	}

}



void qsafeget(char* s,char* key) {
  int i;
  char* val;
  checkSlash(s);
  
  i=DBNumber(s);
  if (i>=0) {
    db=dbhandle[i];
    size_t st;
    if(!(val=kcdbget(db, key, strlen(key),&st))){
      MLPutSymbol(stdlink, "False");
    } else {
      MLPutString(stdlink, val);
      kcfree(val);
    }
  } else {
    PutErrorMessage("QSafeGet","this database is not open");
  }

}

void qcheck(char* s,char* key) {
  char* val;
		int i;
		checkSlash(s);
	i=DBNumber(s);
	if (i>=0) {
		db=dbhandle[i];
      	       size_t st;
    		if(!(val=kcdbget(db, key, strlen(key),&st))){
			MLPutSymbol(stdlink, "False");
		} else {
			MLPutSymbol(stdlink, "True");
			kcfree(val);
		}
	} else {
		PutErrorMessage("QClose","this database is not open");
	}
}


void qlist(char* s) {


    int i;
    char* key;
 KCCUR* cur;
    checkSlash(s);
  
size_t st;
	i=DBNumber(s);
	if (i>=0) {
		db=dbhandle[i];
		if ((i=kcdbcount(db))<0) {
			PutErrorMessage("QList",kcdbemsg(db));
			return;
		}
		cur = kcdbcursor(db);
		kccurjump(cur);
		MLPutFunction(stdlink,"List",i);
	        while ((key = kccurgetkey(cur, &st, 1)) != NULL) {
                      MLPutString(stdlink, key);
                      kcfree(key);
                }
                kccurdel(cur);	
			
	} else {
		PutErrorMessage("QList","this database is not open");
	}


}


void qsize(char* s) {
  int i;
  double d;
  checkSlash(s);
  i=DBNumber(s);
  if (i>=0) {
    db=dbhandle[i];
    d=kcdbsize(db);
    if(d<0){
      PutErrorMessage("QSize",kcdbemsg(db));
    } else {
      MLPutDouble(stdlink,d);
    }
  } else {
    PutErrorMessage("QSize","this database is not open");
  }
}


void qremove(char* s,char* key) {
  	int i;
	checkSlash(s);
	i=DBNumber(s);
	if (i>=0) {
		db=dbhandle[i];
		if(!(kcdbremove(db, key, strlen(key)))){
			PutErrorMessage("QRemove",kcdbemsg(db));
		} else {
			MLPutSymbol(stdlink, "True");
		}
	} else {
		PutErrorMessage("QRemove","this database is not open");
	}
}


bool file_not_needed(char* path) {
    int fd;
    fd = open(path, O_RDONLY);
    if (fd==-1) {
	return 0;      
    }
#ifdef F_FULLFSYNC
// OS X 
  fcntl(fd, F_FULLFSYNC);
#else  
  fdatasync(fd);
#endif

#ifndef POSIX_FADV_DONTNEED
  fcntl(fd, F_NOCACHE, 1);
#else
  // the preferred old way
#ifndef __USE_FILE_OFFSET64
  posix_fadvise(fd, 0,0,POSIX_FADV_DONTNEED);
#else
  posix_fadvise64(fd, 0,0,POSIX_FADV_DONTNEED);
#endif
#endif

    close(fd);
    return 1;
}


bool open_database(int i,int read) {
    char res[200];
    if (Compression) 
	if (AutoBucket)
	  sprintf(res,"%s.kch#bnum=%lld#dfunit=1#apow=8#opts=cl#zcomp=gz",dbname[i],(long long int)pow(2,CurrentBucket[i])); //linear!
	else
	  sprintf(res,"%s.kch#bnum=%lld#dfunit=1#apow=8#opts=c#zcomp=gz",dbname[i],(long long int)pow(2,CurrentBucket[i]));
    else 
	sprintf(res,"%s.kch#bnum=%lld#dfunit=8#apow=8",dbname[i],(long long int)pow(2,CurrentBucket[i]));
    
    int flag;
    if (read) flag= KCOREADER | KCONOLOCK; 
      else {	
	flag=KCOWRITER | KCOCREATE;
	if (NoLock) flag = flag | KCONOLOCK;
      }
    if(!(kcdbopen(dbhandle[i],res, flag))){
	return 0;
    } else {  			
	Entries[i]=kcdbcount(dbhandle[i]);
	Buckets[i]=(long long int)pow(2,CurrentBucket[i]);
	return 1;
    }
}



void qput(char* s,char* key,char* value) {
		int i;
		checkSlash(s);

	i=DBNumber(s);
	if (i>=0) {
		db=dbhandle[i];
		if(!kcdbset(db, key, strlen(key), value, strlen(value))){
			PutErrorMessage("QPut",kcdbemsg(db));
		} else {
		       if (AutoBucket) {
			  Entries[i]++;
			  if (4*Entries[i]>=Buckets[i]) {
			    double lll=log2(kcdbcount(db));						    
			    //printf("%d\n",CurrentBucket[i]);
			    char path[100];			
			    if (floor(lll)+4>=CurrentBucket[i]) {
				FILE * tfile;
				sprintf(path,"%s.time",dbname[i]);
				tfile = fopen (path,"a");
				fprintf(tfile,"Current bucket is %d\n",CurrentBucket[i]);
				struct timeval start_timeA,stop_timeA;
				gettimeofday(&start_timeA,NULL);					  
				CurrentBucket[i]++;
				if (CurrentBucket[i]>BucketSize) BucketSize=CurrentBucket[i];
				sprintf(path,"%s.temp",dbname[i]);
				kcdbdumpsnap(db,path);
				kcdbclose(db);
			    	sprintf(path,"%s.kch",dbname[i]);
				remove(path);			
				open_database(i,0);
				sprintf(path,"%s.temp",dbname[i]);
				kcdbloadsnap(db,path);				
				if (!file_not_needed(path)) {
				    MLPutSymbol(stdlink, "False"); 
				} else {
				    MLPutSymbol(stdlink, "Ok");  
				}			      
				remove(path);	
				gettimeofday(&stop_timeA,NULL);
				fprintf(tfile,"Increasing bucket took %d seconds\n",((int) (stop_timeA.tv_sec-start_timeA.tv_sec)));
				fclose(tfile);
			    }
			  else			 		  
			    MLPutSymbol(stdlink, "True");
			  } else
			  MLPutSymbol(stdlink, "True");
		       } else MLPutSymbol(stdlink, "True");
		}
	} else {
		PutErrorMessage("QPut","this file is not open");
	}

}



void qopen(char* s) {
	int i;
	checkSlash(s);
	i=FreeDBNumber();
	if (i<0) {PutErrorMessage("QOpen","Too many open files!");return;};
	dbhandle[i]=kcdbnew();
	db=dbhandle[i];
	dbname[i]=(char*)malloc(strlen(s)+1);	
	strcpy(dbname[i],s);	
	CurrentBucket[i]=BucketSize;
	if (!open_database(i,0)) {
	    PutErrorMessage("QOpen",kcdbemsg(db));	  
	} else {		
	    MLPutSymbol(stdlink, "True");	  
	}
}



void qread(char* s) {
	int i;
	checkSlash(s);
	i=FreeDBNumber();
	if (i<0) {PutErrorMessage("QRead","Too many open files!");return;};
	dbhandle[i]=kcdbnew();
	db=dbhandle[i];
	dbname[i]=(char*)malloc(strlen(s)+1);	
	strcpy(dbname[i],s);	
	CurrentBucket[i]=BucketSize;
	if (!open_database(i,1)) {
	    PutErrorMessage("QRead",kcdbemsg(db));	  
	} else {		
	    MLPutSymbol(stdlink, "True");	  
	}
}


void qremovedatabase(char* s) {
  
	int i;
	checkSlash(s);
	i=DBNumber(s);
	if (i>=0) {
		PutErrorMessage("QRemoveDatabase","database is open and cannot be removed");
	} else {
char res[200];
sprintf(res,"%s.kch",s);

		if(!(remove(res)==0)){
			sprintf(res,"Can't remove file %s.kch",s);
			PutErrorMessage("QRemoveDatabase",res);
		} else
		{
			MLPutSymbol(stdlink, "True");
		}
	}
}


void qrepair(char* s) {
  PutErrorMessage("QRepair","This method is not supported by the KyotoCabinet!");
  
}

void qclose(char* s) 
{     int i;
 checkSlash(s);
	i=DBNumber(s);
	if (i>=0) {
		db=dbhandle[i];
		if(!kcdbclose(db)){
			PutErrorMessage("QClose",kcdbemsg(db));
		} else
		{
		 
			free(dbname[i]);
			dbname[i]=NULL;
			kcdbdel(dbhandle[i]);
			MLPutSymbol(stdlink, "True");
		}
	} else {
		PutErrorMessage("QClose","this file is not open");
	}

}


int main(int argc, char* argv[])
//	int argc; char* argv[];
{	int i;
  if ((argc==2) && !strcmp(argv[1],"-test")) {
      printf("Ok\n");
      return 0;
  }
 BucketSize=25; 
 Compression=false;
 AutoBucket=false;
 NoLock=false;
	for (i=0;i<FILELIMIT;i++) {dbname[i]=NULL;};
	/*	val=malloc(MAXVALUESIZE+1);*/
	return MLMain(argc, argv);
}


