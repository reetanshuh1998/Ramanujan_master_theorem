#include "CIntegratePoolCommon.h"
using namespace std;

char common::integrator[200]="vegasCuba";
char common::MPPrecision[200]="default";
char common::MPMin[200]="default";
char common::PrecisionShift[200]="38";
char common::SmallX[200]="0.001";
char common::MPThreshold[200]="0.000000001";
list <pair<string,string> > common::intpar;


int common::part=1;
int common::parts=1;
int common::entries_start=1;

string common::IntegrationCommand;
int common::PrintIntegrationCommand=0;
int common::results_mode=0;
	char common::in[200];
	char common::out[200];	
	int common::complex=0;
	pid_t common::guardpid=0;
	int common::mpfr=0;
	int common::in_defined=0;
	int common::out_defined=0;
	int common::prefix_defined=0;
	int common::binary_path_defined=0;
	int common::bucket=10;
	int common::threads_number=1;
	char common::CPUCores[200]="1";
	int common::test_mode=0;
	int common::notest=1;
	char common::input_prefix[200];
	char common::binary_path[200];
	list<string> common::prefixes;
	int common::all_prefixes=1;
        int common::direct=1;
	int common::separate_terms=0;
	int common::only_prepare=0;
	int common::GPUForceCore=-2;
	int common::gpu_threads_per_node=0;
	int common::gpu_per_node=0;
	int common::GPUMemoryPart=1;
	
	KCDB* common::db_in;
	KCDB* common::db_out;
char common::task_prefix[200];
char common::requested_task_prefix[200]="all";
list<string> common::tasks;
	
char * common::prefix=NULL;
char * common::nvars=NULL;


sem_t* common::job;
sem_t* common::job_queue_filled;
sem_t* common::rjob;
sem_t* common::rjob_queue_filled;
list<pair<pair<int, int>, string> > common::job_queue;
list<pair<pair<int, int>, string> > common::rjob_queue;
pthread_mutex_t common::queue_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t common::rqueue_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_t common::thread_s;
pthread_t common::thread_r;

int common::min_deg;
int common::SHIFT;
map<pair<int,string>,pair<double,double> > common::results;
map<pair<int,string>,pair<double,double> > common::results_im;

int common::entries;

int common::had_error=0;
int common::only_parse;
int common::preparse=0;
int common::testF=0;
int common::debug=0;
int common::gpu=0;

char common::math_binary[200];
int common::math_binary_defined;

FILE* common::g_to[MAX_THREADS];
FILE* common::g_from[MAX_THREADS];
pid_t common::pids[MAX_THREADS];

pid_t common::openprogram(FILE **to, FILE **from,char* g_thepath)
{
int fdin[2], fdout[2];
pid_t childpid;
    if (pipe(fdin)<0) {
        perror("pipe");
        return(0);
    }
     if (pipe(fdout)<0) {
     perror("pipe");
        return(0);
    }
   
     if((childpid = fork()) == -1){
        perror("fork");
        return(0);
     }/*if((childpid = fork()) == -1)*/
    
     if(childpid == 0){

       /* Child process closes up input side of pipe */
        close(fdin[1]);
        close(fdout[0]);

        /*reopen stdin:*/
        close(0);
        if (dup(fdin[0])<0) {
            perror("dup");
            return(0);
        }
        /*reopen stdout:*/
	
        close(1);
        if (dup(fdout[1])<0) {
            perror("dup");
            return(0);
        }
                
        /*stderr > /dev/null*/
        //close(2);/*close stderr*/
        //open("/dev/null",O_WRONLY); /* reopen stderr*/
        /*argc[0] = must be the same as g_thepath:
          Fermat uses it to find the full path:*/
	char* lpath = getenv ("LD_LIBRARY_PATH");
	string newlpath;
	if (lpath==NULL) newlpath = "LD_LIBRARY_PATH=/usr/local/cuda/lib64"; else newlpath = ((string)"LD_LIBRARY_PATH=")+((string)lpath)+((string)":/usr/local/cuda/lib64");
	//cout<<newlpath<<endl;
	
	const char *env[] = { newlpath.c_str(),(char *)0 };
//ret = execle ("/bin/ls", "ls", "-l", (char *)0, env);

	
        execle(g_thepath, g_thepath, NULL, env);
        exit(0);
     }else{ /* Parent process closes up output side of pipe */
       
        close(fdin[0]);
	close(fdout[1]);
        
	if (  (*to=fdopen(fdin[1],"w"))==NULL){
           kill(childpid,SIGKILL);
           return(0);
        }
        
        if (  (*from=fdopen(fdout[0],"r"))==NULL){
           fclose(*to);
           kill(childpid,SIGKILL);
           return(0);
	 }	
     }
     return childpid;
}/*openprogram*/



int common::init_params(FILE* pipe_to,FILE* pipe_from) {
    char res[200];
    char* ignore;
    fputs("SetIntegrator\n",pipe_to);
    fputs(integrator,pipe_to);
    fputs("\n",pipe_to);
    fflush(pipe_to);
    ignore=fgets(res,200,pipe_from);    
    if (ignore==NULL) return 0;
    if (strncmp(res,"Ok",2)) {	      
	cerr<<"Setting integrator failed"<<endl;
	cerr<<res<<endl;  
	return 0;
    }
    for (list<pair<string, string> >::iterator itr=intpar.begin();itr!=intpar.end();itr++) {
	fputs("SetCurrentIntegratorParameter\n",pipe_to);
	fputs(itr->first.c_str(),pipe_to);
	fputs("\n",pipe_to);
	fputs(itr->second.c_str(),pipe_to);
	fputs("\n",pipe_to);
	fflush(pipe_to);
	ignore=fgets(res,200,pipe_from);    
	if (ignore==NULL) return 0;
	if (strncmp(res,"Ok",2)) {	      
	    cerr<<"Setting intpar "<<itr->first<<" failed"<<endl;
	    cerr<<res<<endl;  
	    return 0;
	}
    }
    
    if (math_binary_defined) {
	fputs("SetMath\n",pipe_to);
	fputs(math_binary,pipe_to);
	fputs("\n",pipe_to);
	fflush(pipe_to);
	ignore=fgets(res,200,pipe_from);    
	if (strncmp(res,"Ok",2)) {	      
	    cerr<<"Setting math binary failed"<<endl;
	    cerr<<res<<endl;  
	    return 0;
	}        
    }    
    if (strcmp(MPPrecision,"default")) {
	fputs("SetMPPrecision\n",pipe_to);
	fputs(MPPrecision,pipe_to);
	fputs("\n",pipe_to);
	fflush(pipe_to);
	ignore=fgets(res,200,pipe_from);    
	if (strncmp(res,"Ok",2)) {	      
	    cerr<<"Setting MPPrecision failed"<<endl;
	    cerr<<res<<endl;  
	    return 0;
	}
    }
    if (strcmp(MPMin,"default")) {
	fputs("SetMPMin\n",pipe_to);
	fputs(MPMin,pipe_to);
	fputs("\n",pipe_to);
	fflush(pipe_to);
	ignore=fgets(res,200,pipe_from); 
	if (ignore==NULL) return 0;
	if (strncmp(res,"Ok",2)) {	      
	    cerr<<"Setting MPMin failed"<<endl;
	    cerr<<res<<endl;  
	    return 0;
	}
    }
    fputs("SetMPPrecisionShift\n",pipe_to);
    fputs(PrecisionShift,pipe_to);
    fputs("\n",pipe_to);
    fflush(pipe_to);
    ignore=fgets(res,200,pipe_from);    
    if (ignore==NULL) return 0;
    if (strncmp(res,"Ok",2)) {	      
	cerr<<"Setting PrecisionShift failed"<<endl;
	cerr<<res<<endl;  
	return 0;
    }
    fputs("SetMPThreshold\n",pipe_to);
    fputs(MPThreshold,pipe_to);
    fputs("\n",pipe_to);
    fflush(pipe_to);
    ignore=fgets(res,200,pipe_from);    
    if (ignore==NULL) return 0;
    if (strncmp(res,"Ok",2)) {	      
	cerr<<"Setting MPThreshold failed"<<endl;
	cerr<<res<<endl;  
	return 0;
    }
    fputs("SetSmallX\n",pipe_to);
    fputs(SmallX,pipe_to);
    fputs("\n",pipe_to);
    fflush(pipe_to);
    ignore=fgets(res,200,pipe_from);    
    if (ignore==NULL) return 0;
    
    if (strncmp(res,"Ok",2)) {	      
	cerr<<"Setting SmallX failed"<<endl;
	cerr<<res<<endl;  
	return 0;
    }
    
    if (mpfr) {
      fputs("MPFR\n",pipe_to);
      fflush(pipe_to);
      ignore=fgets(res,200,pipe_from);    
      if (ignore==NULL) return 0;                  
    }
    
    if (GPUMemoryPart!=1) {
	    fputs("GPUMemoryPart\n",pipe_to);
	    stringstream ss;
	    ss << GPUMemoryPart;
	    fputs(ss.str().c_str(),pipe_to);
	    fputs("\n",pipe_to);
	    fflush(pipe_to);
	    ignore=fgets(res,200,pipe_from);    
	    if (ignore==NULL) return 0;	 	      
    }
    
    
    if (GPUForceCore!=-2) {
	 if (GPUForceCore==-1) {
	    fputs("GPUCores\n",pipe_to);
	    fputs("0",pipe_to);
	    fputs("\n",pipe_to);
	    fflush(pipe_to);
	    ignore=fgets(res,200,pipe_from);    
	    if (ignore==NULL) return 0;	 
	    fputs("CPUCores\n",pipe_to);
	    fputs(CPUCores,pipe_to);
	    fputs("\n",pipe_to);
	    fflush(pipe_to);
	    ignore=fgets(res,200,pipe_from);    
	    if (ignore==NULL) return 0;	   
	 } else {
	    fputs("GPUCores\n",pipe_to);
	    fputs("1",pipe_to);
	    fputs("\n",pipe_to);
	    fflush(pipe_to);
	    ignore=fgets(res,200,pipe_from);    
	    if (ignore==NULL) return 0;	   
	    fputs("GPUForceCore\n",pipe_to);
	    stringstream ss;
	    ss << GPUForceCore;
	    fputs(ss.str().c_str(),pipe_to);
	    fputs("\n",pipe_to);
	    fflush(pipe_to);
	    ignore=fgets(res,200,pipe_from);    
	    if (ignore==NULL) return 0;	 
	 }
    }
      
     
    
    if (strcmp(CPUCores,"1")) {      
      fputs("CPUCores\n",pipe_to);
      fputs(CPUCores,pipe_to);
      fputs("\n",pipe_to);
      fflush(pipe_to);
      ignore=fgets(res,200,pipe_from);    
      if (ignore==NULL) return 0;
    }
    

    
    if (!notest) {
      fputs("Integrate\n",pipe_to);
      fputs("1;\n0;\nx[1]+1;\n|\n",pipe_to);
      fflush(pipe_to);
      ignore=fgets(res,200,pipe_from);
      if (ignore==NULL) return 0;
      if ((!notest) && strncmp(res,"{1.5",4) && strncmp(res,"{1.4",4)) {	      
	  cerr<<"Integration failed"<<endl;
	  cerr<<res<<endl;  
	  return 0;
      }
    }
    
    if (testF) {
      fputs("TestF\n",pipe_to);      
      fflush(pipe_to);
      ignore=fgets(res,200,pipe_from);    
      if (ignore==NULL) return 0;
    }

    return 1;
}


int common::parse_argc_argv(int argc, char *argv[]) {
  char res[200];
  stringstream ss;
  	
  for(int i=0;i<argc;i++) {
    ss << argv[i]<<" ";
  }
  IntegrationCommand = ss.str();
  
 for(int i=1;i<argc;i++) {
	    if (!strcmp(argv[i],"-in")) {
		if(i+1==argc) {
		    printf("Missing path after -in\n");
		    return 1;
		} else {
		    if (((string)argv[i+1]).find(".kch")==string::npos) 
		      sprintf(in,"%s.kch",argv[i+1]);
		    else 
		      sprintf(in,"%s",argv[i+1]);		    
		    in_defined=1;
		    
		    string sin = (string)in;
		    size_t sitr = sin.find("in.kch");
		    if (sitr!=string::npos) {
		      sprintf(out,"%s",sin.replace(sitr,6,"out.kch").c_str());
		      out_defined=1;
		    }
		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-out")) {
		if(i+1==argc) {
		    printf("Missing path after -out\n");
		    return 1;
		} else {
		    if (((string)argv[i+1]).find(".kch")==string::npos) 
		      sprintf(out,"%s.kch",argv[i+1]);
		    else 
		      sprintf(out,"%s",argv[i+1]);	
		    out_defined=1;
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-math")) {
		if(i+1==argc) {
		    printf("Missing path after -math\n");
		    return 1;
		} else {
		    sprintf(math_binary,"%s",argv[i+1]);
		    math_binary_defined=1;
		    i++;
		}	
	    } else if (!strcmp(argv[i],"-part")) {
		if(i+1==argc) {
		    printf("Missing path after -part\n");
		    return 1;
		} else {
		    char temp[20];
		    sprintf(temp,"%s",argv[i+1]);
		    if (sscanf(temp,"%d/%d",&part,&parts)!=2) {		
		      printf("Incorrect syntax after -part\n");
		      return 1;
		    }
		    i++;
		}	      	    		    
	    } else if (!strcmp(argv[i],"-bucket")) {
		if(i+1==argc) {
		    printf("Missing path after -bucket\n");
		    return 1;
		} else {
		    sprintf(res,"%s",argv[i+1]);
		    bucket=kcatoi(res);
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-integrator")) {
		if(i+1==argc) {
		    printf("Missing path after -integrator\n");
		    return 1;
		} else {
		    sprintf(integrator,"%s",argv[i+1]);		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-intpar")) {
		if(i+1==argc) {
		    printf("Missing path after -intpar\n");
		    return 1;
		} else {
		    char buf1[200];
		    sprintf(buf1,"%s",argv[i+1]);		    
		    i++;
		    if(i+1==argc) {
			printf("Missing path after -intpar %s\n",buf1);
			return 1;
		    } else {
			char buf2[200];
			sprintf(buf2,"%s",argv[i+1]);		    			
			intpar.push_back(pair<string,string>((string)buf1,(string)buf2));
			i++;		    
		    }
		}		
	    } else if (!strcmp(argv[i],"-MPThreshold")) {
		if(i+1==argc) {
		    printf("Missing path after -MPThreshold\n");
		    return 1;
		} else {
		    sprintf(MPThreshold,"%s",argv[i+1]);		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-MPPrecision")) {
		if(i+1==argc) {
		    printf("Missing path after -MPPrecision\n");
		    return 1;
		} else {
		    sprintf(MPPrecision,"%s",argv[i+1]);		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-PrecisionShift")) {
		if(i+1==argc) {
		    printf("Missing path after -PrecisionShift\n");
		    return 1;
		} else {
		    sprintf(PrecisionShift,"%s",argv[i+1]);		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-SmallX")) {
		if(i+1==argc) {
		    printf("Missing path after -SmallX\n");
		    return 1;
		} else {
		    sprintf(SmallX,"%s",argv[i+1]);		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-MPMin")) {
		if(i+1==argc) {
		    printf("Missing path after -MPMin\n");
		    return 1;
		} else {
		    sprintf(MPMin,"%s",argv[i+1]);		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-threads")) {
		if(i+1==argc) {
		    printf("Missing path after -threads\n");
		    return 1;
		} else {
		    sprintf(res,"%s",argv[i+1]);
		    threads_number=kcatoi(res);
		    i++;
		}
	    } else if (!strcmp(argv[i],"-cpu_used_per_worker")) {
		if(i+1==argc) {
		    printf("Missing path after -cpu_used_per_worker\n");
		    return 1;
		} else {
		    sprintf(CPUCores,"%s",argv[i+1]);		    
		    i++;
		}
	    } else if (!strcmp(argv[i],"-prefix")) {
		if(i+1==argc) {
		    printf("Missing path after -prefix\n");
		    return 1;
		} else {
		    if (((string)argv[i+1]).find("{")==string::npos) 
		      sprintf(input_prefix,"%s-{0, 0}",argv[i+1]);
		    else 
		      sprintf(input_prefix,"%s",argv[i+1]);		  
		    prefix_defined=1;
		    all_prefixes=0;
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-task")) {
		if(i+1==argc) {
		    printf("Missing path after -task\n");
		    return 1;
		} else {
		    sprintf(requested_task_prefix,"%s",argv[i+1]);		    
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-CIntegratePath")) {
		if(i+1==argc) {
		    printf("Missing path after -CIntegratePath\n");
		    return 1;
		} else {
		    if (argv[i+1][0]=='/') 
		      sprintf(binary_path,"%s",argv[i+1]);
		    else {
		      sprintf(binary_path,"%s",argv[0]);
		      char* pos=binary_path+strlen(binary_path);
		      while ((*pos!='/') && (pos!=binary_path)) pos--;
		      if (*pos=='/') pos++;
		      sprintf(pos,"%s",argv[i+1]);
		    }
		    //cout<<binary_path<<endl;		    		    
		    binary_path_defined=1;
		    i++;
		}		
	    } else if (!strcmp(argv[i],"-test")) {
		test_mode=1;	
	    } else if (!strcmp(argv[i],"-print_command")) {
		PrintIntegrationCommand=1;	    
	    } else if (!strcmp(argv[i],"-separate_terms")) {
		separate_terms=1;	
	    } else if (!strcmp(argv[i],"-test_integrator")) {
		notest=0;	
	    } else if (!strcmp(argv[i],"-preparse")) {
		preparse=1;	
	    } else if (!strcmp(argv[i],"-complex")) {
		complex=1;	
	    } else if (!strcmp(argv[i],"-mpfr")) {
		mpfr=1;	
	    } else if (!strcmp(argv[i],"-testF")) {
		testF=1;
	    } else if (!strcmp(argv[i],"-debug")) {
		debug=1;
	    } else if (!strcmp(argv[i],"-save_all")) {
		results_mode=1;
	    } else if (!strcmp(argv[i],"-continue")) {
		results_mode=2;
	    } else if (!strcmp(argv[i],"-gpu")) {
		gpu=1;
	    } else if (!strcmp(argv[i],"-gpu_threads_per_node")) {
		if(i+1==argc) {
		    printf("Missing path after -gpu_threads_per_node\n");
		    return 1;
		} else {
		    sprintf(res,"%s",argv[i+1]);
		    gpu_threads_per_node=kcatoi(res);
		    i++;
		}
	    } else if (!strcmp(argv[i],"-gpu_per_node")) {
		if(i+1==argc) {
		    printf("Missing path after -gpu_per_node\n");
		    return 1;
		} else {
		    sprintf(res,"%s",argv[i+1]);
		    gpu_per_node=kcatoi(res);
		    i++;
		}
	    }else if (!strcmp(argv[i],"-from_mathematica")) {
		direct=0;	
	    }else if (!strcmp(argv[i],"-only_prepare")) {
		only_prepare=1;		    	      
	    } else {
		printf("Improper argument %s\n",argv[i]);
		return 1;
	    }
	}
	
	if (!binary_path_defined) {
	    sprintf(binary_path,"%s",argv[0]);
	    char* pos=binary_path+strlen(binary_path);
	    while ((*pos!='/') && (pos!=binary_path)) pos--;
	    if (*pos=='/') pos++;
	    if (complex) {
	     if (gpu) sprintf(pos,"CIntegrateMPCG"); else sprintf(pos,"CIntegrateMPC"); 
	    } else {
	     if (gpu) sprintf(pos,"CIntegrateMPG"); else sprintf(pos,"CIntegrateMP"); 
	    }
	}  
	
	if (threads_number>MAX_THREADS) {
	    printf("Number of threads can't exceed %d\n",MAX_THREADS);
	    return 1;	 
	}
    
	if (threads_number<=0) {
	    printf("Number of threads should be positive\n");
	    return 1;	 
	}
	
	
	return 0;
}

int common::prepare_databases() {
  
  char res[200];
  
	char sname[200];
	int pid = (int)getpid();
	
	
	sprintf(sname,"job%d",pid);
	//cout<<sname<<endl;
  	job = sem_open(sname, O_CREAT|O_EXCL, 0666, 0);
	sprintf(sname,"job_queue_filled%d",pid);
	job_queue_filled = sem_open(sname, O_CREAT|O_EXCL, 0666, MAX_QUEUE);
	sprintf(sname,"rjob%d",pid);
	rjob = sem_open(sname, O_CREAT|O_EXCL, 0666, 0);
	sprintf(sname,"rjob_queue_filled%d",pid);
	rjob_queue_filled = sem_open(sname, O_CREAT|O_EXCL, 0666, MAX_QUEUE);	
	
	if (!in_defined) {
	    printf("Missing input database\n");
	    return 1;	 
	}
    
	if (!out_defined) {
	    printf("Missing output database\n");
	    return 1;	 
	}
    
	if ((!prefix_defined) && (!all_prefixes)) {
	    printf("Missing prefix or -allprefixes option\n");
	    return 1;	 
	}
	
	char* val;
	size_t st;
	
	
	

	db_in=kcdbnew();
	
	
	sprintf(res,"%s#bnum=%lld#dfunit=8#apow=8#opts=c#zcomp=gz",in,(long long int)pow(2,bucket));
	
	if(!(kcdbopen(db_in,res, KCOWRITER | KCOCREATE | KCONOLOCK))){
	    printf("Database in open error\n");
	    return 1;
	}	
	
      if (strcmp(requested_task_prefix,"all")) {   //specific task request
	  tasks.push_back(requested_task_prefix);	
      } else {
	 if((val=kcdbget(db_in, "0-", 2,&st))){
	//	printf("Can't get tasks\n");
	//	return 1;
	   
	 char* temp=val;
	 temp++;
	 char* temp2=temp;
	 while (*temp2!='\0') {
	   while ((*temp2!=',') && (*temp2!='}')) temp2++;
	   *temp2='\0';
	   temp2++;
	   while (*temp2==' ') temp2++;
	   tasks.push_back(temp);
	   temp=temp2;
	 }	 
	 kcfree(val);	
	 
	 } else {
	    cout<<"Could not determine tasks!"<<endl;
	   
	 }
      }
      
     
      if (direct) {
	    sprintf(res,"%s#bnum=%lld#dfunit=8#apow=8#opts=c#zcomp=gz",out,(long long int)pow(2,bucket));
	    db_out=kcdbnew();
	    int mode = KCOWRITER | KCOCREATE;
	    if (results_mode>0) mode |= KCOAUTOSYNC;
	    if(!(kcdbopen(db_out,res,mode))){
		printf("Database out open error\n");
		return 1;
	    }
	    
	    kcdbset(db_out, "0-IntegrationCommand", strlen("0-IntegrationCommand"),IntegrationCommand.data(),strlen(IntegrationCommand.data()));
	    
	    char temp[200]="0-";
	    if (strcmp(requested_task_prefix,"all")) {
		char temp2[200];
		sprintf(temp2,"{%s}",requested_task_prefix);
		kcdbset(db_out, temp, strlen(temp),temp2,strlen(temp2));	      
	    } else {
		if ((val=kcdbget(db_in, temp, strlen(temp),&st))) {
		  kcdbset(db_out, temp, strlen(temp),val,strlen(val));
		  kcfree(val);
		}
	    }
	    
	    if((val=kcdbget(db_in, "0-RegVar", strlen("0-RegVar"),&st))){
		kcdbset(db_out, "0-RegVar", strlen("0-RegVar"),val,strlen(val));
		kcfree(val);
	    } 
	    if((val=kcdbget(db_in, "0-SmallVar", strlen("0-SmallVar"),&st))){
		kcdbset(db_out, "0-SmallVar", strlen("0-SmallVar"),val,strlen(val));
		kcfree(val);
	    }
	    if((val=kcdbget(db_in, "0-RequestedOrders", strlen("0-RequestedOrders"),&st))){
		kcdbset(db_out, "0-RequestedOrders", strlen("0-RequestedOrders"),val,strlen(val));
		kcfree(val);
	    }
	    
	    
      }	
	    
	
	

	
	
	return 0;
  
  
  
  
}


int common::prepare_task() {

  	    
	    char* val;
	    size_t st;
  
	  prefixes.clear();
	  results.clear();
	    
	 if (all_prefixes) {
	    char FES[200];
	    sprintf(FES,"%s-ForEvaluationString",task_prefix);
	    if(!(val=kcdbget(db_in, FES, strlen(FES),&st))){
		printf("Can't get prefixes\n");
		return 1;
	    } 
	    char* pr=val;
	    while (*pr!='\0') {
		char* pr2=pr;
		while (*pr2!='|') pr2++;
		*pr2='\0';
		prefixes.push_back((string) pr);
		pr=pr2;
		pr++;
	    }	 
	    pr=val;
	    while (*pr!=',') pr++;
	    *pr='\0';
	    min_deg=kcatoi(val);
	    //cout<<min_deg<<endl;
	    kcfree(val);	  
	   // for (list<string>::iterator itr=prefixes.begin();itr!=prefixes.end();itr++) cout<<*itr<<endl;
	   // throw 1;
	} else 	prefixes.push_back((string) input_prefix);
	
	if (direct) {
	    
	    list<string> to_copy;
	    to_copy.push_back("ForEvaluation");
	    to_copy.push_back("ExpandVariable");
	    to_copy.push_back("runorder");
	    to_copy.push_back("SHIFT");
	    to_copy.push_back("EXTERNAL");
	    to_copy.push_back("ExternalExponent");
	    
	    
	    for(list<string>::iterator itr=to_copy.begin();itr!=to_copy.end();itr++) {
		char temp[200];
		sprintf(temp,"%s-%s",task_prefix,itr->c_str());
		val=kcdbget(db_in, temp, strlen(temp),&st);
		kcdbset(db_out, temp, strlen(temp),val,strlen(val));
		kcfree(val);
	    }			    
	}

	

	    char temp[200];
	    sprintf(temp,"%s-SHIFT",task_prefix);
	    val=kcdbget(db_in, temp, strlen(temp),&st);
	    SHIFT=kcatoi(val);
	    kcfree(val);	    	
	    sprintf(temp,"%s-SCounter",task_prefix);
	    val=kcdbget(db_in, temp, strlen(temp),&st);
	    entries=kcatoi(val);
	    if (only_prepare) {
	      entries=0; 
	    } else if (parts!=1) {
	      // integrating a part of terms
	      entries_start = (part-1)*((int)(entries/parts)) + 1;
	      if (parts!=part) entries = (part)*((int)(entries/parts));
	    }
	    kcfree(val);
	    
	   // cout<<entries_start<<" | "<<entries<<endl;
	    
	    return 0;
}

void common::close_databases() {
	kcdbclose(db_in);
	kcdbdel(db_in);
	
	if (direct) {
	    kcdbclose(db_out);
	    kcdbdel(db_out);	
	}
	
	char sname[200];
	int pid = getpid();
	sprintf(sname,"job%d",pid);
	//cout<<sname<<endl;
  	//sem_close(job);
	sem_unlink(sname);
	sprintf(sname,"rjob%d",pid);
	//sem_close(rjob);
	sem_unlink(sname);
	sprintf(sname,"job_queue_filled%d",pid);
	//sem_close(job_queue_filled);
	sem_unlink(sname);
	sprintf(sname,"rjob_queue_filled%d",pid);
	//sem_close(rjob_queue_filled);
	sem_unlink(sname);
	
	
}

set<string> pref2;
int current_order;
string pref2_current;


string common::form_integration_string(int i, int j) {
    string to_send;
    size_t st;
    char res[200];
    
    if (j<0) {   
      
		    int local_entries = -j;
		    
		    sprintf(res,"%d;\n",local_entries);
		    
		    
      		   to_send=(string)"?;\n"+(string)nvars+(string)";\n"+(string)res;
		   
		   
		   
		   
	          
		    
		  
		    for (int j=1;j<=local_entries;j++) {
			if (testF) 
			  sprintf(res,"%s-%s-%d-%dF",task_prefix,prefix,i,j);
			else
			  sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,i,j);
			char* val2;
			if(!(val2=kcdbget(db_in, res, strlen(res),&st))){
			    printf("Can't get with key %s\n",res);
			    return NULL;
			} 			
			to_send=to_send+val2+(string)"\n";
			kcfree(val2);		  
		    }	      
		    for (int j=1;j<=local_entries;j++) {
			stringstream ss;
			ss << j;
			to_send=to_send+(string)"f["+ss.str()+(string)"]+";
		    }

		    to_send=to_send+(string)"0;\n|\n";
      
      
    } else {   // separate term 
			 to_send=(string)"?;\n"+(string)nvars+(string)";\n0;\n";
			if (testF)
			  sprintf(res,"%s-%s-%d-%dF",task_prefix,prefix,i,j);
			else
			  sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,i,j);
			char* val2;
			if(!(val2=kcdbget(db_in, res, strlen(res),&st))){
			    printf("Can't get with key %s\n",res);
			    return NULL;
			} 			
			to_send=to_send+val2+(string)"\n|\n";
			kcfree(val2);		  
  
    }
			
  return to_send;
			
}

void * common::submitter(void *) {
  
	char r0[200];
	char* r=r0;
	strcpy(r,prefix);
	//char *r=(char*)prefix;
	if (*r=='-') r++;
	while (*r!='-') r++;
	*r='\0';	      
	current_order=kcatoi(r0);
	r++;
	pref2.insert((string)r);
	pref2_current=(string)r;
	r--;
	*r='-';
  

	char res[200];
	char* val;
	size_t st;

	int temp_entries = entries;
	
	// in continue mode we do not restart prefix integration
	if (results_mode>0) {
	  sprintf(res,"%s-%s-R",task_prefix,prefix);
	  if((val=kcdbget(db_out, res, strlen(res),&st))){	      
	    if (strncmp(val,"{Print",6)!=0) {
		temp_entries = 0;		
	    }
	    kcfree(val);
	  } 			
	}
	
	
			
	
	for (int i=entries_start;i<=temp_entries;i++) {
	  
	    if (had_error) return NULL;
	  
	    sprintf(res,"%s-%s-%d",task_prefix,prefix,i);
	    if(!(val=kcdbget(db_in, res, strlen(res),&st))){
		printf("Can't get with key %s\n",res);
		return NULL;
	    } 			
	    
	    string to_send;
		
	    int local_entries=kcatoi(val);   
	    	    	    
	    if ((local_entries==0) && (!separate_terms)) {
	      /*
		to_send=(string)"0";	
		sem_wait(job_queue_filled);
		pthread_mutex_lock(&queue_mutex);
		job_queue.push_back(pair<pair<int, int>,string>(make_pair(i,0),to_send));
		pthread_mutex_unlock(&queue_mutex);
		sem_post(job); 
	      */
	    } else {	        
	      	if (((string)nvars=="0") && (!separate_terms)) {//we are evaluating the result here!
		    //cout<<"No integration"<<endl;

		    float result=0;
		    for (int j=1;j<=local_entries;j++) {
			if (testF)
			    sprintf(res,"%s-%s-%d-%dF",task_prefix,prefix,i,j);
			else
			    sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,i,j);
			char* val2;
			if(!(val2=kcdbget(db_in, res, strlen(res),&st))){
			    printf("Can't get with key %s\n",res);
			    return NULL;
			} 	
			float res0;
			if (!sscanf(val2,"%f",&res0)) {
			    printf("Integration string with no variables cannot be transformed to number\n%s\n",val2);
			    return NULL;
			}
			result+=res0;
			//cout<<val2<<endl;
			kcfree(val2);	
		    }
		    stringstream ss;
		    ss << result;
		    to_send=ss.str();
		    sem_wait(job_queue_filled);
		    pthread_mutex_lock(&queue_mutex);
		    job_queue.push_back(pair<pair<int, int>,string>(make_pair(i,0),to_send));
		    pthread_mutex_unlock(&queue_mutex);
		    sem_post(job); 
		} else {  //forming a string for integration
			 
		  
		 if (separate_terms) {		  
		   
		    for (int j=1;j<=local_entries;j++) {

		     sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,i,j);
		     char* val3;
		     if((results_mode>0) && (val3=kcdbget(db_out, res, strlen(res),&st))){
		      // we have a result in out
		      //cout<<"!";
		      to_send = (string) val3;
		      kcfree(val3);
		     } else if ((string)nvars=="0") {//we are evaluating the result here!  
		        if (testF)
			    sprintf(res,"%s-%s-%d-%dF",task_prefix,prefix,i,j);
			else
			    sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,i,j);
			char* val2;
			if(!(val2=kcdbget(db_in, res, strlen(res),&st))){
			    printf("Can't get with key %s\n",res);
			    return NULL;
			} 	
			float res0;
			if (!sscanf(val2,"%f",&res0)) {
			    printf("Integration string with no variables cannot be transformed to number\n%s\n",val2);
			    return NULL;
			}
			stringstream ss;
			ss << res0;
			to_send=ss.str();
		    
		       
		       
		     } else  
		     {
		       
		        to_send = form_integration_string(i,j);
			
		     }
		      sem_wait(job_queue_filled);
		      pthread_mutex_lock(&queue_mutex);
		      job_queue.push_back(pair<pair<int,int>,string>(make_pair(i,j),to_send));
		      pthread_mutex_unlock(&queue_mutex);
		      sem_post(job); 
		     
		    }
		 
		 } else { 
		   
		  sprintf(res,"%s-%s-%d-0",task_prefix,prefix,i);
		  char* val3;
		  if((results_mode>0) && (val3=kcdbget(db_out, res, strlen(res),&st))){
		      // we have a result in out
		      //cout<<"?";
		      to_send = (string) val3;
		      kcfree(val3);
		  } else {
		 
		   
		   to_send = form_integration_string(i,-local_entries);
		    

		  } //else
		  
		  sem_wait(job_queue_filled);
		  pthread_mutex_lock(&queue_mutex);
		  job_queue.push_back(pair<pair<int,int>,string>(make_pair(i,-local_entries),to_send));
		  pthread_mutex_unlock(&queue_mutex);
		  sem_post(job); 
		 }
		   
		
				  
	    

	
		    
		}
	
	    }
	    
	    kcfree(val);

	    
	}  
	
	
  return NULL;
}

void MyRound(double* res) {
  
	char result[256];
	snprintf(result,256,"%.15lf",*res);
	sscanf(result,"%lf",res); 
	
}



void * common::receiver (void*) {

    	char res[200];
	int points[10];
	int point=0;
	int failed=0;
	size_t st;
	
	double res1=0;
	double res2=0;
	double res1_im=0;
	double res2_im=0;
	
	if (direct && !only_parse) {
	    if (!debug) {cout<<"Integrating"; fflush(stdout);}else cout<<"\"{\n";
	}
	
	int temp_entries = entries;
	
	// in continue mode we do not restart prefix integration
	if (results_mode>0) {
	  char * val;
	  sprintf(res,"%s-%s-R",task_prefix,prefix);
	  if((val=kcdbget(db_out, res, strlen(res),&st))){	      
	    if (strncmp(val,"{Print",6)!=0) {
		temp_entries = 0;		
		if (sscanf(val,"{%lf,%lf,%lf,%lf}",&res1,&res2,&res1_im,&res2_im)!=4) {
		      cout<<"Failed to analyze old result"<<endl;
		      throw 1;
		}
		cout<<"..we have a result..";
		res2=res2*res2;
		res2_im=res2_im*res2_im;

	    }
	    kcfree(val);
	  } 			
	}
	
	
	
	for (int i=0;i!=10;i++) {
	    points[i]=(entries_start-1)+ ((i+1)*(entries - (entries_start-1)))/10;	
	}
	
	
	
	
	timeval start_timeA,stop_timeA;
        gettimeofday(&start_timeA,NULL);
	
	// get the old result if it exists
	if ((parts!=1) && (part!=1)) {
	    sprintf(res,"%s-%s-R",task_prefix,prefix);
	    char* val=kcdbget(db_out, res, strlen(res),&st);
	    if (val) {
		// old entry exists
	      if (strncmp(val,"{Print",6)!=0) {
		  // the entry is not thw warning with zeros
		  if (sscanf(val,"{%lf,%lf,%lf,%lf}",&res1,&res2,&res1_im,&res2_im)!=4) {
		      cout<<"Failed to analyze old result"<<endl;
		      throw 1;
		  }
		  if (!debug) {
		    cout<<"(with old result "<<setprecision(6)<<res1<<" +- "<<setprecision(6)<<sqrt(res2);
		    if (complex && (res1_im!=0)) cout<<" + ( "<<setprecision(6)<<res1_im<<" +- "<<setprecision(6)<<sqrt(res2_im)<<" ) * I";	  	
		    cout<<")";
		  }
		  res2=res2*res2;
		  res2_im=res2_im*res2_im;
	      }
	      kcfree(val);
	    }
	  
	}
	
	int done = 0;
 	for (int i=entries_start;i<=temp_entries;i++) {
	    
	  
	  int local_entries;
	  
	  sprintf(res,"%s-%s-%d",task_prefix,prefix,i);
	  char* val;
	  if(!(val=kcdbget(db_in, res, strlen(res),&st))){
		 printf("Can't get with key %s\n",res);
		 return NULL;
	  } 			
	  local_entries=kcatoi(val);   
	  kcfree(val);
	     // if (local_entries==0) local_entries++;
	  
	  if ((!separate_terms) && (local_entries!=0)) local_entries = 1;
	    
	  for (int j=1;j<=local_entries;j++) {
	  
	    sem_wait(rjob);
	    
	    pthread_mutex_lock(&rqueue_mutex);
	    pair<pair<int, int>,string> returned=*(rjob_queue.begin());           
	    rjob_queue.pop_front();
	    pthread_mutex_unlock(&rqueue_mutex);

	    sem_post(rjob_queue_filled);
      
  
	    
	    if (returned.second[0]!='{') failed=true;
	    
	    double temp1,temp2;
	    double temp1_im,temp2_im;
	    
	    if(!failed) {		
		if (sscanf(returned.second.c_str(),"{%lf,%lf,%lf,%lf}",&temp1,&temp2,&temp1_im,&temp2_im)!=4) failed=1;		
	    }
	    
	    if(!failed) {
		res1+=temp1;
		res2+=(temp2*temp2);
		res1_im+=temp1_im;
		res2_im+=(temp2_im*temp2_im);			
		if (results_mode>0) {
		  char res[200];
		  if (returned.first.second<0) 
		    sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,returned.first.first,0);
		  else
		    sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,returned.first.first,returned.first.second);
		  
		  if(!(kcdbadd(db_out, res, strlen(res), returned.second.c_str(), strlen(returned.second.c_str())))) {
		    if (kcdbecode(db_out)!=KCEDUPREC) {
		      cout<<"Can't set with key "<<res<<" and error "<<kcdbecode(db_out)<<endl;
		      exit(0);
		      return NULL;
		    }
		  }	
		  
		  
		  // here we need to add a value to the number of stored entries
		  sprintf(res,"%s-%s-done",task_prefix,prefix); 
		  done++;
		  int done_before=0;
		  val=kcdbget(db_out, res, strlen(res),&st);
		  if (val!=NULL) {
		    done_before = *((int*)val);
		    kcfree(val);
		  }
		  if (done>done_before) {
		    if (!kcdbset(db_out,  res,strlen(res),(char*)&done,sizeof(int))) {
		      cout<<"Can't increase entries count in the database"<<endl;
		    }		  
		  }
		}
	    } else {
	      cout<<"Integration error. To see the problematic integrand, run "<<endl;
	      if (returned.first.second<=0) 
		cout<<"bin/OutputIntegrand "<<common::in<<" \""<<task_prefix<<"-"<<prefix<<"-"<<returned.first.first<<"\""<<endl;
	      else
	        cout<<"bin/OutputIntegrand "<<common::in<<" \""<<task_prefix<<"-"<<prefix<<"-"<<returned.first.first<<"-"<<returned.first.second<<"\""<<endl;
	      cout<<"Result is:"<<endl ;
	      cout<<returned.second<<endl; 	      
	      had_error=true;
	      sem_post(job_queue_filled);  // to get submitter out if it was waiting
	      sem_post(common::job);	// to get Integrate_thread or communicate_with_slaves out of waiting for a new task	      
	      for (int i=1;i<=common::threads_number;i++) sem_post(common::rjob_queue_filled);
		    //to get Integrate threads or communicating with slaves get out of waiting for a free slot in receiver queue
	      exit(0);
	      return NULL;
	    }
	    if (debug) {	  
	      if (returned.first.second<0) 
		cout<<"{"<<returned.first.first<<", "<<0<<", "<<setprecision(6)<<temp1<<", "<<setprecision(6)<<temp2<<", "<<setprecision(6)<<temp1_im<<", "<<setprecision(6)<<temp2_im<<"},\n";
	      else
		cout<<"{"<<returned.first.first<<", "<<returned.first.second<<", "<<setprecision(6)<<temp1<<", "<<setprecision(6)<<temp2<<", "<<setprecision(6)<<temp1_im<<", "<<setprecision(6)<<temp2_im<<"},\n";
	    }
	  } //j   
	    if (!only_parse) {
	      while ((point!=10) && (i>=points[point])) {
		if (direct) {
		    if (!debug) cout<<".";
		    fflush(stdout);
		} else {	
		  char prefix_corrected[200];
		  sprintf(prefix_corrected,"%s",prefix);
		  char * pp=prefix_corrected;
		  while (*pp!='\0') {if(*pp=='/') *pp='|';pp++;}
		    sprintf(res,"%s-%s-%s-%d",out,task_prefix,prefix_corrected,point);
		   /* ofstream out;
		    out.open(res);
		    out<<"."<<endl;
		    out.close();*/
		    
		    
		    int fd;
		    fd = open(res, O_RDWR | O_CREAT | O_SYNC | O_TRUNC, S_IRUSR | S_IWUSR);
		    if (fd==-1) {
		      cout<<"File open error";
		      cout<<res<<endl;
		      throw 1;
		    }
		    if (write(fd,".",strlen("."))<=0) {
		      cout<<"File write error";
		      throw 1;
		    }
		    fsync(fd);
		    close(fd);
		    
		   
		}
		point++;
	      }
	    }
	}
	
	
	gettimeofday(&stop_timeA,NULL);
	
    
    char result[256];
    if (complex)     snprintf(result,256,"{%.15lf,%.15lf,%.15lf,%.15lf}\n",res1,sqrt(res2),res1_im,sqrt(res2_im)); else
    snprintf(result,256,"{%.15lf,%.15lf,0,0}\n",res1,sqrt(res2));  	
	
if (!only_parse) {	
    if (direct) {  //MPI version should be only direct
	sprintf(res,"%s-%s-R",task_prefix,prefix);
	if (!debug) cout<<stop_timeA.tv_sec-start_timeA.tv_sec<<" seconds";
	if (only_prepare) {
	  snprintf(result,256,"{Print[\"WARNING: database has no result for %s\"];0.,0,0,0}\n",prefix);  	
	  kcdbadd(db_out, res, strlen(res), result, strlen(result)); // not overwriting
	} else
	{
	if(!kcdbset(db_out, res, strlen(res), result, strlen(result))){
	    printf("Can't set with key %s\n",res);
	    return NULL;
	}
        }
	sprintf(res,"%s-%s-E",task_prefix,prefix);
	kcdbset(db_out, res, strlen(res), "False", strlen("False"));
	//snprintf(result,256,"{%5.5f,%5.5lf}\n",res1,sqrt(res2));  
	
	MyRound(&res1);
	MyRound(&res2);
	if (complex) {
	  MyRound(&res1_im);
	  MyRound(&res2_im);
	}
	
	
	
	
	if (!debug) 
	  cout<<endl<<"Result: "<<setprecision(6)<<res1<<" +- "<<setprecision(6)<<sqrt(res2);
	else
	  cout<<"{0,"<<setprecision(6)<<res1<<","<<setprecision(6)<<sqrt(res2);
	
	results.insert(pair<pair<int,string>,pair<double,double> >(pair<int,string>(current_order,pref2_current),pair<double,double>(res1,sqrt(res2))));
	
	
	if (complex && (res1_im!=0)) {
	  if (!debug) 
	    cout<<" + ( "<<setprecision(6)<<res1_im<<" +- "<<setprecision(6)<<sqrt(res2_im)<<" ) * I";	  
	  else
	    cout<<","<<setprecision(6)<<res1_im<<","<<setprecision(6)<<sqrt(res2_im)<<"}";	  
	  results_im.insert(pair<pair<int,string>,pair<double,double> >(pair<int,string>(current_order,pref2_current),pair<double,double>(res1_im,sqrt(res2_im))));
	}
	
	if (debug) cout<<"}\"";
	cout<<endl;
	
	fflush(stdout);
	//  results should be a map from a pair; we should also have a list of second prefix parts

	if (results_mode>1) {
	  
	  for (int i=entries_start;i<=temp_entries;i++) {
	    
	    if (separate_terms) {
	    
	      int local_entries;
	  
	      sprintf(res,"%s-%s-%d",task_prefix,prefix,i);
	      char* val;
	      if(!(val=kcdbget(db_in, res, strlen(res),&st))){
		  printf("Can't get with key %s\n",res);
		  return NULL;
	      } 			
	      local_entries=kcatoi(val);   
	      kcfree(val);
	     
	      for (int j=1;j<=local_entries;j++) {
		sprintf(res,"%s-%s-%d-%d",task_prefix,prefix,i,j);
		kcdbremove(db_out,res,strlen(res));	  
	      }
	    	      
	    } else {
	      sprintf(res,"%s-%s-%d-0",task_prefix,prefix,i);
	      kcdbremove(db_out,res,strlen(res));
	    }	  
	}
      }
	
	if (all_prefixes) {
	   for (set<string>::iterator itr=pref2.begin();itr!=pref2.end();itr++) {
	      
	      if (pref2.size()!=1) {
		  char * ExpandVariable;
		  size_t st;
		  char temp[200];
		  sprintf(temp,"%s-ExpandVariable",task_prefix);
		  if(!(ExpandVariable=kcdbget(db_in, temp, strlen(temp),&st))){
			printf("Can't get with key ExpandVariable\n");
			return NULL;
		   } 
//		  char temp[200];
		  strcpy(temp,itr->c_str());
		  char* temp1=temp;
		  temp1++;
		  char* temp2=temp1;
		  while (*temp2!=',') temp2++;
		  *temp2='\0';
		  temp2++;
		  while (*temp2==' ') temp2++;
		  char* temp3=temp2;
		  while (*temp3!='}') temp3++;
		  *temp3='\0';
		  cout<<ExpandVariable<<"^("<<temp1<<") * Log["<<ExpandVariable<<"]^("<<temp2<<") * (";		
		  kcfree(ExpandVariable);
	      }
	      for (int j=min_deg-SHIFT;j<=current_order-SHIFT;j++) {
		  double result3=0;
		  double result4=0;
		  double result3_im=0;
		  double result4_im=0;
		  for (int i=min_deg;i<=j+SHIFT;i++) {		      		      
		      sprintf(res,"%s-EXTERNAL-%d",task_prefix,j-i);
		      size_t st;
		      char* ext;
		      if(!(ext=kcdbget(db_in, res, strlen(res),&st))){
			printf("Can't get with key %s\n",res);
			return NULL;
		      } 		
		      kcdbset(db_out,res,strlen(res),ext,strlen(ext));
		      double dext=kcatof(ext);
		      kcfree(ext);
		      //cout<<ext<<" -> "<<dext<<endl;
		      map<pair<int,string>,pair<double,double> >::iterator fitr=results.find(pair<int,string>(i,*itr));
		      if (fitr!=results.end()) {
			result3+=((fitr->second.first)*(dext));
			result4+=(((fitr->second.second)*(fitr->second.second))*(dext)*(dext));		    
		      }
		      if (complex) {
			  map<pair<int,string>,pair<double,double> >::iterator fitr=results_im.find(pair<int,string>(i,*itr));
			  if (fitr!=results.end()) {
			    result3_im+=((fitr->second.first)*(dext));
			    result4_im+=(((fitr->second.second)*(fitr->second.second))*(dext)*(dext));		    
			  }			
		      }		      
		  }			
		  result4=sqrt(result4);		  
		  if (result3!=0) {
		    cout<<"("<<result3;
		    if (result4!=0) cout<<" + pm["<<j<<"]*"<<result4;
		    cout<<") * (ep)^"<<j;
		  
		    if ((j!=current_order-SHIFT) || (complex && (result3_im!=0)))  {
			cout<<" + ";
		    }
		  }
		  if (complex) {
		      result4_im=sqrt(result4_im);		  
		      if (result3_im!=0) {
			  cout<<"("<<result3_im;
			  if (result4_im!=0) cout<<" + pm["<<j<<"]*"<<result4_im;
			  cout<<") * I (ep)^"<<j;		  
			  if (j!=current_order-SHIFT) {
			      cout<<" + ";
			  }
		      } 		    
		  }
		  
	      }
	      if (pref2.size()!=1) {
		  cout<<" ) ";		  
	      }
	      cout<<endl;
	   }
	}
    } else {
	char prefix_corrected[200];
	sprintf(prefix_corrected,"%s",prefix);
	char * pp=prefix_corrected;
	while (*pp!='\0') {if(*pp=='/') *pp='|';pp++;}
	
	sprintf(res,"%s-%s-%s-R",out,task_prefix,prefix_corrected);
	
      /*	ofstream out;
	out.open(res);
	out<<result<<endl;
	out.close();
	*/
	//cout<<res<<endl<<result<<endl;
	
	int fd;
	fd = open(res, O_RDWR | O_CREAT | O_SYNC | O_TRUNC, S_IRUSR | S_IWUSR);
	if (fd==-1) {
	  cout<<"File open error";
	  cout<<res<<endl;
	  throw 1;
	}
	if (write(fd,result,strlen(result))<=0) {
	  cout<<"File write error";
	  throw 1;
	}
	fsync(fd);
	close(fd);
	
	
	
	
	
    }
    
} 
 
    return NULL;
}
  


  
void common::prepare_prefix_integration() {
    char res[200];
    char* val;
    size_t st;

  
         if (direct && (!only_parse) && (!debug)) {
	      cout<<"Terms of order "<<prefix<<": ";	    
	      if (separate_terms)	      
		sprintf(res,"%s-%s-T",task_prefix,prefix);
	      else
		sprintf(res,"%s-%s-T0",task_prefix,prefix);
	      val=kcdbget(db_in, res, strlen(res),&st);
	      
	      if ((val==NULL) && !separate_terms) {  //fix for old databases, that did not have the T0 part
		sprintf(res,"%s-%s-T",task_prefix,prefix);
		val=kcdbget(db_in, res, strlen(res),&st);
		cout<<"(?)";
	      }
	      
	      cout<<val;
	      kcfree(val);
	      
	      if (results_mode>0) {
		sprintf(res,"%s-%s-done",task_prefix,prefix); 	      
		val=kcdbget(db_out, res, strlen(res),&st);
	      
		if (val!=NULL) {
		  cout<<", done: "<<*((int*)val);
		  kcfree(val);
		}
	      }
	      
	      
	      
	      cout<<", max vars: ";
	      sprintf(res,"%s-%s-N",task_prefix,prefix);
	      val=kcdbget(db_in, res, strlen(res),&st);
	      cout<<val;
	      kcfree(val);
	      cout<<endl;    
	      fflush(stdout);
	    }
	     	     
	     	     
	    
	sprintf(res,"%s-%s-N",task_prefix,prefix);
	if(!(nvars=kcdbget(db_in, res, strlen(res),&st))){
	    printf("Can't get with key %s\n",res);
	    throw 1;
	} 	 	     
	     
	    pthread_create(&thread_s, NULL, submitter, NULL);
	    pthread_create(&thread_r, NULL, receiver, NULL);	
  
}

void common::finish_prefix_integration() {
  
  
	    pthread_join(thread_s, NULL);
	    pthread_join(thread_r, NULL);
	
	kcfree(nvars);

	    
	    if(direct && !only_parse) {
	      char *r=(char*)prefix;
	      if (*r=='-') r++;
	      while (*r!='-') r++;
	      *r='\0';
	      char temp[200];
	      sprintf(temp,"%s-MaxEvaluatedOrder",task_prefix);
	      kcdbset(db_out, temp, strlen(temp),prefix,strlen(prefix));
	    }
}

/*intSIGHANDLER : some systems require a signal handler to return an integer,
  so define the macro intSIGHANDLER if compiler fails:*/
#ifdef intSIGHANDLER
int common::sigCHL(int i)
#else
void common::sigCHL(int i)
#endif
{
    for (int thread_number=0;thread_number!=threads_number;++thread_number) {
	kill(pids[thread_number],SIGKILL);
    }
   exit(0);
#ifdef intSIGHANDLER
   return 0;
#endif
}/*sigCHL*/

/*The function startGuard returns 0 on success, or -1.*/

int common::startGuard(char* pname)
{
int fdin[2];
pid_t childpid;
     if (pipe(fdin) < 0) {
         perror("pipe");
         return(-1);
     }
     if((childpid = fork()) == -1){
        perror("fork");
        return(-1);
     }/*if((childpid = fork()) == -1)*/

     if(childpid == 0){
        /* Child process closes up input side of pipe */
        close(fdin[1]);
        /*Now we may read from fdin[0]*/
        /* if compiler fails here, try to define intSIGHANDLER
           in the beginning of this file:*/
        signal(SIGPIPE,SIG_IGN);/*Survive on the pipe closing*/
        /*Use childpid as a buffer -- we need not it anymore:*/
	
	strcpy(pname,"Guard");
	
        if (read(fdin[0], &childpid, sizeof(pid_t))<0) {
            perror("read");
            return(-1);
        }
        /*The father newer writes to the fdin[1] so if we here
          then the father is dead.*/
          for (int thread_number=0;thread_number!=threads_number;++thread_number) {
                kill(pids[thread_number],SIGKILL);
          }

        exit(0);
     }/*if(childpid == 0)*/

     /* Parent process closes up output side of pipe */
     guardpid=childpid;
     close(fdin[0]);
     //signal(SIGCHLD, sigCHL);
     return(0);
}/*startGuard*/


int common::start_CIntegrate(int count) {
  	for (int thread_number=0;thread_number!=count;thread_number++) {	  
	    g_to[thread_number]=NULL;
	    g_from[thread_number]=NULL;
	    if (((count!=1) && (gpu==1) && (gpu_threads_per_node>0) && (thread_number>=gpu_threads_per_node)) 
	    ||
	    ((count==1) && (gpu==1) && (GPUForceCore==-1))  //this version means MPI and no usage - there is no other way to move GPUForceCore from -2 to -1
	    ){ //not using the G
	      if (binary_path[strlen(binary_path)-1]=='G') 
		binary_path[strlen(binary_path)-1]='\0';	
	      GPUForceCore=-2;
	    }

	    
	    pids[thread_number]=openprogram(&g_to[thread_number], &g_from[thread_number],binary_path);   
	    
	    
	    
	    if ((count!=1) && (gpu==1) && (gpu_threads_per_node>=0)) {
	      // threads mode with more than one thread, while we use GPU and want to limit GPU per node
	      if ((thread_number<gpu_threads_per_node) || (gpu_threads_per_node==0)) {
		GPUForceCore = thread_number;
		if (gpu_per_node>0) {
		    GPUForceCore = GPUForceCore % gpu_per_node;
		    if ((gpu_threads_per_node>0) && (gpu_threads_per_node<count)) {
		      GPUMemoryPart = gpu_threads_per_node/gpu_per_node;
		      if ((thread_number%gpu_per_node)<(gpu_threads_per_node%gpu_per_node)) GPUMemoryPart++;		    
		    } else {
		      GPUMemoryPart = count/gpu_per_node;
		      if ((thread_number%gpu_per_node)<(count%gpu_per_node)) GPUMemoryPart++;		    
		    }
		}
	      }	else {
		GPUForceCore = -2; // this means we won't send any info about the core, it is a standard CPU thread
		GPUMemoryPart = 1;
              } // and GPUForceCore is back to -2
	    }
	    
	    	    
	    
	    //cout<<gpu_threads_per_node<<"|"<<GPUForceCore<<"|"<<binary_path<<"|"<<GPUMemoryPart<<endl;
	    
	    if (!init_params(g_to[thread_number],g_from[thread_number])) {
		kill(pids[thread_number],SIGKILL);
		waitpid(pids[thread_number],NULL,0);		
		return 1;	      
	    }	
	}
	
	
	
	return 0;
}

void common::stop_CIntegrate(int count) {
  	for (int thread_number=0;thread_number!=count;thread_number++) {	 
	    fputs("Exit\n",g_to[thread_number]);	    
	    fflush(g_to[thread_number]);	    
	    //kill(pids[thread_number],SIGKILL);	    
	    waitpid(pids[thread_number],NULL,0);	    	    
	}
}

int common::Integrate(int thread_number,const char* function,char* res) {
	char* ignore;
	if (only_parse) 
	  fputs("Parse\n",g_to[thread_number]);
	else 
	  fputs("Integrate\n",g_to[thread_number]);
	fputs(function,g_to[thread_number]);
	fflush(g_to[thread_number]);
	ignore=fgets(res,200,g_from[thread_number]);	
	if (ignore==NULL) {
	    //cout<<"CIntegrate communication failed"<<endl;
	    //throw 1;
	}
	return 0;  
}

int common::integration_test() {
      char res[200];
      if (common::start_CIntegrate(1)) return 1;	    
      cout<<"Ok"<<endl;
      fputs("GetCurrentIntegratorParameters\n",common::g_to[0]);
      fflush(common::g_to[0]);
      if (fgets(res,200,common::g_from[0])==NULL) return 1;
      cout<<res<<endl;	    
      /*if (gpu) {
	fputs("GPUData\n",common::g_to[0]);
	fflush(common::g_to[0]);
	while (fgets(res,200,common::g_from[0])!=NULL) {
	  cout<<res;	
	  if (!strcmp(res,"OK\n")) break;
	}
      } */     
      common::stop_CIntegrate(1);   
      return 0;
}
