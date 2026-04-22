#include <kclangc.h>




int main(int argc, char *argv[])
{
    if ((argc!=3) && (argc!=4) && (argc!=5)) {
	printf("Incorrect number of arguments, 2, 3 or 4 required\n First argument is database name. \n Second argument is the integral entry containing the task (1 in most cases), the prefix and the sector number separated with -\n Third argument (if it is there) is the term number inside the given sector. \n Fourth argument can be F to produce the F function for tests in case of complex mode\n");
	return 1;
    }
  
    char res[200];
    KCDB* db;
   
    db=kcdbnew();
	
    sprintf(res,"%s#opts=c#zcomp=gz",argv[1]);

        
    if(!(kcdbopen(db,res, KCOREADER | KCONOLOCK))){
      printf("Database open error\n");	
      return 1;
    }	

    char * val;
    size_t st;
    val=kcdbget(db, argv[2], strlen(argv[2]),&st);
		
    if(!val) {
      printf("Entry missing\n");	
      return 1;
    }	
    
    int n=kcatoi(val);
    
    kcfree(val);
    
    char res2[200];
    
    sprintf(res2,"%s",argv[2]);
    int i;
    
    i=strlen(res2)-1;
    while (i>0) {
	if (res2[i]=='-') break;
	i--;
    }
    
    if(i<=0) {
      printf("Incorrect entry\n");	
      return 1;
    }	
    
    res2[i+1]='N';
    res2[i+2]='\0';
    
    val=kcdbget(db, res2, strlen(res2),&st);
		
    if(!val) {
      printf("Number of variables missing\n");	
      return 1;
    }	    
    
    printf("Integrate\n");
    
    
    
    
    int start=1;
    int end=n;
    
    if (argc>=4) {
	start=kcatoi(argv[3]);
	end=kcatoi(argv[3]);
	n=0;
    }
    
    
    printf("%d;\n%d;\n",(int)kcatoi(val),n);
    kcfree(val);
    
    for(i=start;i<=end;i++) {
	
	if (argc==5) 
	  sprintf(res,"%s-%d%s",argv[2],i,argv[4]);
	else
	  sprintf(res,"%s-%d",argv[2],i);
    
	val=kcdbget(db, res, strlen(res),&st);
		
	if(!val) {
	  printf("Integral entry missing\n");	
	  return 1;
	}	
    
	printf("%s\n",val);
    
	kcfree(val);    
	
    }
    
    if (argc==3) {
      for(i=1;i<=n;i++) {
	  printf("f[%d]+",i);
      }
      printf("0;\n");
    }
    
    printf("|\nExit\n");
    
    
  
    kcdbclose(db);
    kcdbdel(db);
  
    return 0;
}
