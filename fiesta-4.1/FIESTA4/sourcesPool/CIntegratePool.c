#include "CIntegratePoolCommon.h"
using namespace std;

#if THREADSMODE
#define ReturnInMain return 1
#else
#define ReturnInMain MPI_Finalize(); return 1
#endif


#if THREADSMODE
void* Integrate_thread(void *par);
int time_to_stop=0;

//global variables for thread control
pthread_t threads[MAX_THREADS];
int range[MAX_THREADS];

//threads connection
void start_threads(int count) {
  	for (int i=0;i!=count;i++) {
	  range[i]=i;
	  pthread_create(threads+i, NULL, Integrate_thread, (void*)(range+i));
	}
}

void stop_threads() {
 	time_to_stop=1;
	for (int i=0;i!=common::threads_number;i++) {
	   sem_post(common::job);
	}
	for (int i=0;i!=common::threads_number;i++) {
	   pthread_join( threads[i], NULL);
	} 
}

#else


#define INTEGRATE_REQUEST 1
#define NOTHING_MORE 2
#define PARSE_MODE 3
#define INIT_MODE 4
#define INTEGRATE_ANSWER_SIZE 5
#define INTEGRATE_ANSWER 6

void communicate_with_slaves(int numprocs);
int max_time;
map<pair<int,int>,int> mpi_submitted_tasks;
void wait ( int seconds );
#endif


int* badslaves;

int main(int argc, char *argv[])
{
  
  timeval start_time,stop_time;
  gettimeofday(&start_time,NULL);
	

    if (common::parse_argc_argv(argc,argv)) {
	    ReturnInMain;
	}
  
#if THREADSMODE
      int myid=-1;
#else
      int myid, numprocs;
     
    // Инициализация подсистемы MPI
    //int requested=MPI_THREAD_MULTIPLE;
    int requested=MPI_THREAD_FUNNELED;
    int provided;
    MPI_Init_thread(&argc, &argv, requested, &provided);
    //it can also return
    /*if (provided < requested) {
	cout<<provided<<"|"<<provided2<<"|"<<requested<<endl;
	cout<<"Current MPI environment does not support threads"<<endl;
	return 1;
    }*/
    
    //no check for that. They claim no significant difference between MPI_THREAD_FUNNELED and MPI_THREAD_SINGLE
    //but I will keep requesting
    //MPI_Init_thread can also return another value for provided but it does not help

    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);

    if (numprocs<=1) {
      cout<<"Program needs at least one slave"<<endl;
      MPI_Finalize();
      return 1;
    }
    
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
 
if ((common::gpu==1) && (common::gpu_threads_per_node!=-1)) {  // -1 is set manually and stands for each used each
    // there will be another check on gpu per node
    
    char NodeName[MPI_MAX_PROCESSOR_NAME];  
    int NodeNameLen,NodeNameTotalLen;  
    MPI_Get_processor_name(NodeName, &NodeNameLen);  
    NodeNameLen++;
    //printf("name: %s\n",processor_name);
    

    int *NodeNameCountVect,*NodeNameOffsetVect;
    char * NodeNameList=NULL;
    
    NodeNameCountVect = NULL;
    NodeNameOffsetVect = NULL;
    // just to kill the warning
    
    if (myid==0) NodeNameCountVect = new int[numprocs];
    
    //  Gather node name lengths to master to prepare c-array
    MPI_Gather(&NodeNameLen, 1, MPI_INT, NodeNameCountVect, 1, MPI_INT, 0, MPI_COMM_WORLD);
          
    if (myid==0) {
	NodeNameOffsetVect = new int [numprocs];
        NodeNameOffsetVect[0] = 0;
        NodeNameTotalLen = NodeNameCountVect[0];

        //  build offset vector and total char count for all node names
        for (int i = 1 ; i != numprocs ; ++i){
            NodeNameOffsetVect[i] = NodeNameCountVect[i-1] + NodeNameOffsetVect[i-1];
            NodeNameTotalLen += NodeNameCountVect[i];
        }
        //  char-array for all node names
        NodeNameList = new char [NodeNameTotalLen];      
    }
    
    //  Gatherv node names to char-array in master
    MPI_Gatherv(NodeName, NodeNameLen, MPI_CHAR, NodeNameList, NodeNameCountVect, NodeNameOffsetVect, MPI_CHAR, 0, MPI_COMM_WORLD);
    
   
    int *GPUForceCoreList = NULL;
    int *GPUMemoryPartList = NULL;
    
    if (myid==0) {

	map<string,int> proc_count;
	vector<int> proc_number; //in_node
	proc_number.reserve(numprocs);
	proc_number.push_back(0); // for master
	
	string s;
	
	GPUForceCoreList = new int [numprocs];
	GPUMemoryPartList = new int [numprocs];
	GPUForceCoreList[0]=-1;  // the master is not using the GPU anyway
	GPUMemoryPartList[0]=1;
	
	for (int i = 1 ; i != numprocs ; ++i){ 
	  s = (string) (NodeNameList+NodeNameOffsetVect[i]);
	  //cout<<s<<endl;  
	  map<string,int>::iterator itr = proc_count.find(s);
	  GPUMemoryPartList[i]=1; // default value
	  if (itr == proc_count.end()) {
	    proc_count.insert(make_pair(s,1));
	    GPUForceCoreList[i]=0; //use first GPU
	    proc_number.push_back(0);
	  } else {	    
	    if ((common::gpu_threads_per_node!=0) && ((itr->second)>=common::gpu_threads_per_node))
	      GPUForceCoreList[i]=-1; // do not use GPU
	    else 
	      GPUForceCoreList[i]=itr->second;
	    ++itr->second;
	    proc_number.push_back(itr->second-1);  // numbering in node from 0
	  }
	  
	}
	
	if (common::gpu_per_node>0) {
	  for (int i = 1 ; i != numprocs ; ++i){ 
	    if (GPUForceCoreList[i]==-1) continue;
	      else
		GPUForceCoreList[i]=GPUForceCoreList[i]%common::gpu_per_node;
		
	     s = (string) (NodeNameList+NodeNameOffsetVect[i]);
	     map<string,int>::iterator itr = proc_count.find(s);
	    
	     if ((common::gpu_threads_per_node>0) && (common::gpu_threads_per_node<itr->second)) {
		 GPUMemoryPartList[i] = common::gpu_threads_per_node/common::gpu_per_node;
		 if ((proc_number[i]%common::gpu_per_node)<(common::gpu_threads_per_node%common::gpu_per_node)) GPUMemoryPartList[i]++;		    
	     } else {
		 GPUMemoryPartList[i] = itr->second/common::gpu_per_node;
		 if ((proc_number[i]%common::gpu_per_node)<(itr->second%common::gpu_per_node)) GPUMemoryPartList[i]++;		    
	     }

	     //itr->second    is the number of threads at this node
	     //gpu_per_node   is the number of GPU
	  }  
	}

    }
    
    MPI_Scatter(GPUForceCoreList, 1, MPI_INT, &common::GPUForceCore, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatter(GPUMemoryPartList, 1, MPI_INT, &common::GPUMemoryPart, 1, MPI_INT, 0, MPI_COMM_WORLD);
    
    
    //cout<<myid<<"/?"<<common::GPUForceCore<<endl;
    if (myid==0) {
      delete GPUForceCoreList;
      delete GPUMemoryPartList;
    } else {
      //cout<<common::GPUForceCore<<"|"<<common::GPUMemoryPart<<endl;
      // nothing to do here!
      // we gave a value to GPUForceCore and it will be used at integrator initialization
    }
    

}    
    
#endif
  
	
	
	
     if ((common::PrintIntegrationCommand) && (myid<=0)) {	
  	cout<<"Command: "<<common::IntegrationCommand<<endl;	
     }	
	if (common::test_mode) {
	  int itest=0;
	  if (myid<=0) itest=common::integration_test();
#if MPIMODE	  
	  MPI_Finalize();
#endif	 
	  return itest;
	}  

#if MPIMODE
	  common::threads_number=1;
	  //for MPI slaves start one CIntegrate each
#endif
	

	if (myid<=0) {
	   if (common::prepare_databases()) {
		ReturnInMain;
	   }
	}
	
	if (myid!=0) {   //not starting for master in MPI
#if MPIMODE
	  int start_bad=0;
	  //if (myid==9) start_bad=1; else 
	  
	  if (common::start_CIntegrate(common::threads_number)) {  
	    start_bad=1;
	  }	  
	  
	    
	  MPI_Ssend(&start_bad, 1, MPI_INT, 0, INIT_MODE, MPI_COMM_WORLD);
	  if (start_bad) {
	      MPI_Finalize(); 
	      return 1;
	  }
#else
	  if (common::start_CIntegrate(common::threads_number)) {  
	      return 1;
	  }	  
#endif	
#if THREADSMODE	  

	  if(common::startGuard(argv[0])){
	    for (int thread_number=0;thread_number!=common::threads_number;++thread_number) {
	      kill(common::pids[thread_number],SIGKILL);
	      waitpid(common::pids[thread_number],NULL,0);
	    }
	    ReturnInMain;
	  }	  
	  
#endif
	}
	
#if MPIMODE 
	// we receive answers from the slaves confirming initialization
	if (myid==0) {
	    badslaves = (int*)malloc(sizeof(int)*numprocs);	
	    for (int rank = 1; rank < numprocs; ++rank) {		
		//int start_ok;
		MPI_Status status;
		
		MPI_Recv(badslaves+rank, 1, MPI_INT, rank, INIT_MODE, MPI_COMM_WORLD, &status);		
	    }// set common::only_parse


	}
#endif	    	
	
	
	if (common::direct && !common::debug) {
#if MPIMODE	    
	    if (myid==0) {
	      cout<<"CIntegratePoolMPI 4.1"<<endl;
	      cout<<"Slaves: "<<numprocs-1<<endl;
	      int realslaves = numprocs-1;
	      for (int rank = 1; rank < numprocs; ++rank) realslaves-=badslaves[rank];
	      if (realslaves==0) {
		cout<<"All slaves were unable to initialize MPI"<<endl;
		ReturnInMain;
	      }
	      if (realslaves!=numprocs-1) cout<<"Working slaves: "<<realslaves<<endl;
	    }
#else
	    cout<<"CIntegratePool 4.1"<<endl;
	    cout<<"Threads: "<<common::threads_number<<endl;    
#endif	    
	}
	
#if THREADSMODE	
	time_to_stop=0;	
	start_threads(common::threads_number);			
#endif	

	
	
	if (myid<=0) { //in threads mode it is always true
	    for (list<string>::iterator titr=common::tasks.begin();titr!=common::tasks.end();++titr) {
	    strcpy(common::task_prefix,titr->c_str());  
	     
	    char* val;
	    size_t st;
	    char key[200];
	    sprintf(key,"%s-Exact",common::task_prefix);
	    if(!(val=kcdbget(common::db_in, key, strlen(key),&st))){
		printf("Can't get Exact check\n");
		return 1;
	    } 
	    
	    if (common::direct) {
		kcdbset(common::db_out, key, strlen(key),val,strlen(val)); 
	    }
	    
	    if (!strcmp(val,"True")) {
		kcfree(val);   
		if (common::direct) {
		    sprintf(key,"%s-ExactValue",common::task_prefix);
		    if(!(val=kcdbget(common::db_in, key, strlen(key),&st))){
			printf("Can't get Exact value\n");
			return 1;
		    } 
		    kcdbset(common::db_out, key, strlen(key),val,strlen(val));
		    cout<<"Exact value for part "<<common::task_prefix<<" : "<<val<<endl;
		    kcfree(val);		    
		    sprintf(key,"%s-ExternalExponent",common::task_prefix);
		    if(!(val=kcdbget(common::db_in, key, strlen(key),&st))){
			printf("Can't get ExternalExponent\n");
			return 1;
		    } 
		    kcdbset(common::db_out, key, strlen(key),val,strlen(val)); 		    
		    kcfree(val);
		}
		continue;
	    }
	      
	      
	    kcfree(val);
	    
	    
	    if (common::direct && (common::tasks.size()>1)) cout<<"PERFORMING TASK "<<*titr<<endl;  
	    
	    if (common::prepare_task()) {
		  ReturnInMain;	      
	    }
	    
	    for (common::only_parse=common::preparse;common::only_parse>=0;common::only_parse--) {
	    
#if MPIMODE 
		//giving common::only_parse value to slaves
		for (int rank = 1; rank < numprocs; ++rank) {
		    if (!badslaves[rank]) MPI_Ssend(&common::only_parse, 1, MPI_INT, rank, PARSE_MODE, MPI_COMM_WORLD);
		}      
#endif	      
		timeval start_timeA,stop_timeA;
		gettimeofday(&start_timeA,NULL);
		
		if (common::direct && common::only_parse) {
		     cout<<"Parse check";fflush(stdout);
		}
			
		for (list<string>::iterator itr=common::prefixes.begin();itr!=common::prefixes.end();itr++) {
		    
		    common::prefix=(char*)itr->c_str();
		   
		    common::prepare_prefix_integration();
   
		// prepare starts submitter and receiver. submitter fills queue
		// in threads mode the integration is performed my Integrate_thread
#if MPIMODE		
		    communicate_with_slaves(numprocs);		
#endif	
		    common::finish_prefix_integration();
	    
		    if (common::had_error) {		    
			break;
		    }
		} //itr
		if (common::had_error) {		    
			break;
		}
		
		gettimeofday(&stop_timeA,NULL);
		
		if (common::direct && common::only_parse) {
		     cout<<".........."<<stop_timeA.tv_sec-start_timeA.tv_sec<<" seconds"<<endl;
		}	
		
	    } //parse_only
	    if (common::had_error) {		    
		break;
	    }
	    
	  //  sleep(5); 
	   
	 } //titr
	 

#if MPIMODE 
	/* Tell all the slaves to exit. */
	int size=0;
	for (int rank = 1; rank < numprocs; ++rank) {
	  if (!badslaves[rank]) MPI_Ssend(&size, 1, MPI_INT, rank, NOTHING_MORE, MPI_COMM_WORLD);
	}
	free(badslaves);
      
#endif
	
	
	} else {  //no slaves for threads mode
#if MPIMODE	  
	
	
	MPI_Status status;
	char result[256];    
	
	while (1) {	    
	    int size[4];  //second element is task number
	    //int *number=size+1;
	    // last element is time to be sent back
	    MPI_Recv(size, 3, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	    
	    if (status.MPI_TAG == PARSE_MODE) {
		common::only_parse=size[0];
		continue;
	    }// set common::only_parse
	    
	    if (status.MPI_TAG == NOTHING_MORE) break; // time to stop
	    	    

	    
	    
	    char * work=(char *)malloc(size[0]+1);    
	    MPI_Recv(work, size[0], MPI_CHAR, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
	    work[size[0]]='\0';
	    
	    timeval start_timeA,stop_timeA;
	    gettimeofday(&start_timeA,NULL);
	
	    common::Integrate(0,work,result);	    
	    	    //if (myid==numprocs-1) wait(20);  // DEBUG
	    
	    
	    gettimeofday(&stop_timeA,NULL);
	    
	    free(work);

	    
	    size[0] = strlen(result);	   
	    
	    size[3] = stop_timeA.tv_sec-start_timeA.tv_sec;
	    
	    //size[1]=number;
	    MPI_Ssend(size, 4, MPI_INT, 0, INTEGRATE_ANSWER_SIZE, MPI_COMM_WORLD);	    
	    //MPI_Ssend(&number, 1, MPI_INT, 0, 0, MPI_COMM_WORLD); //sending integral number back	    
	    MPI_Ssend(&result, size[0], MPI_CHAR, 0, INTEGRATE_ANSWER, MPI_COMM_WORLD);	    
	 }
	  
	  
	  
#endif	  
	}

#if THREADSMODE 
	stop_threads();
      // normal exit. kill the guard
	kill(common::guardpid,SIGKILL);

#endif	
	if (myid<=0) common::close_databases(); 
	if (myid!=0) common::stop_CIntegrate(common::threads_number); //don't close for MPI master
	
		
#if MPIMODE
	MPI_Finalize();
#endif
	
	gettimeofday(&stop_time,NULL);
	if ((common::direct) && (!common::debug) && ((common::tasks.size()>1) | (common::prefixes.size()>1))) 
	  cout<<"Total time: "<<stop_time.tv_sec-start_time.tv_sec<<" seconds"<<endl;
	
	if (common::had_error) return 1;
	
	return 0;
}


// functions depending on mode

#if THREADSMODE 

void* Integrate_thread(void *par) {

  int num=*((int *)par);
    
  while (1) {
      
      
      sem_wait(common::job);      
      if (common::had_error) break;
      if (time_to_stop) break;      
      pthread_mutex_lock(&common::queue_mutex);
      pair<pair<int, int>,string> task=*(common::job_queue.begin());           
      common::job_queue.pop_front();
      pthread_mutex_unlock(&common::queue_mutex);   
      
      sem_post(common::job_queue_filled);
      
      char result[256];

      
      if (task.second[0]=='?') {
	 // task.second[0]='0';
	  string temp=task.second;
	  const char* temp_data=temp.c_str()+3;
	  //communicates via pipe num
	  common::Integrate(num,temp_data,result);	  
      } else if (task.second[0]=='{') { 
	 // it's a ready answer from the database
	  snprintf(result,256,"%s",task.second.c_str());      
      } else {
	  snprintf(result,256,"{%s,0,0,0}",task.second.c_str());      
	  // either there are no entries at all (zero arrived)
	  // or there are no variables and we already summed up the result
      }
      
      sem_wait(common::rjob_queue_filled);
      
      pthread_mutex_lock(&common::rqueue_mutex);      
      common::rjob_queue.push_back(pair<pair<int, int>,string>(task.first,(string)result));
      pthread_mutex_unlock(&common::rqueue_mutex);

      sem_post(common::rjob);
      
  }
  return NULL;
}


#else


void wait ( int seconds )
{
         struct timespec reqtime;
        reqtime.tv_sec = seconds;
        reqtime.tv_nsec = 0;
        nanosleep(&reqtime, NULL);
}


pthread_t guard;
int guard_runner=0;

void* guard_thread(void *) {
  
  while (true) {
      do {
	wait(1);
	if (max_time==0) {
	  return NULL;
	  
	}
	guard_runner++;
	fflush(stdout);
      } while ((max_time<0) || (guard_runner<max_time*10));
      
      fflush(stdout);
      
      int size[4];
      size[0]=max_time;size[1]=0;size[2]=0;size[3]=0;
      MPI_Request request;
      MPI_Isend(size, 4, MPI_INT, 0, INTEGRATE_ANSWER_SIZE, MPI_COMM_WORLD,&request);
      guard_runner=0;
  }
  
  return NULL;
}

int submitted_all;

int receive_from_MPI_and_push_to_queue() {
    MPI_Status status;
    //int sizenumber;
    int size[4];
    //size of result    
    char* result;
    
    
    while (true) {
    
	MPI_Recv(size, 4, MPI_INT, MPI_ANY_SOURCE, INTEGRATE_ANSWER_SIZE, MPI_COMM_WORLD, &status);    
	
	//cout<<status.MPI_SOURCE<<endl;
	
	if (status.MPI_SOURCE==0) {
	    if (submitted_all) 
	      return 0; // all jobs were already submitted; now we can call the slow slaves bad and resubmit them
	    else {
	      cout<<"Ignoring answer from guard ("<<max_time<<","<<size[0]<<")"<<endl;
	      continue; // we did not submit all jobs yet! have to wait longer!
	    }
	    
	}
	
	guard_runner=0;
	
	if ((max_time<0) || (size[3]>max_time)) {
	  if (size[3]==0) 
	    max_time = 1;
	  else
	    max_time = size[3];
	}
	
	result=(char *)malloc(size[0]+1);
	MPI_Recv(result, size[0], MPI_CHAR, status.MPI_SOURCE, INTEGRATE_ANSWER, MPI_COMM_WORLD, &status);    
    
	if (badslaves[status.MPI_SOURCE]) {
	  cout<<"(ignoring late result from slave "<<status.MPI_SOURCE<<")";
	  free(result); // we are ignoring the result from this slave
	} else break;
    }
    
    result[size[0]]='\0';
    
    if (common::had_error) return status.MPI_SOURCE; 
    //no need to push them into queue, we are exiting anyway
    
    
    map<pair<int,int>,int>::iterator itr = mpi_submitted_tasks.find(make_pair(size[1],size[2]));
    if (itr==mpi_submitted_tasks.end()) {
	cout<<"Received a result from MPI that we were not waiting for!"<<endl;
	throw 1;	
    }
    else {
      //cout<<itr->second<<endl;
	mpi_submitted_tasks.erase(itr);
    }
    
    //puts result into queue for receiver    
    sem_wait(common::rjob_queue_filled);
    pthread_mutex_lock(&common::rqueue_mutex);   
    common::rjob_queue.push_back(pair<pair<int, int>,string>(make_pair(size[1],size[2]),(string)result));
    pthread_mutex_unlock(&common::rqueue_mutex);
    sem_post(common::rjob);
    free(result);      
    return status.MPI_SOURCE; 
}



void communicate_with_slaves(int numprocs) {
  
      max_time = -1;
      submitted_all = 0;
  
      pthread_create(&guard, NULL, guard_thread, NULL);
	    
	    int used_slaves=0;
	    int count_slaves=0;
	  
	    char res[256];
	    size_t st;
	  
	  
	int temp_entries = common::entries;
	
	// in continue mode we do not restart prefix integration
	if (common::results_mode>0) {
	  char * val;
	  sprintf(res,"%s-%s-R",common::task_prefix,common::prefix);
	  if((val=kcdbget(common::db_out, res, strlen(res),&st))){	      
	    if (strncmp(val,"{Print",6)!=0) {
		temp_entries = 0;		
		//cout<<"..we have a result..";
	    }
	    kcfree(val);
	  } 			
	}
	
	    
	    
	    for (int i=common::entries_start-1;i<=temp_entries-1;i++) {
	      // shifted indices here, we get with i+1
	      int local_entries;
	      
	      sprintf(res,"%s-%s-%d",common::task_prefix,common::prefix,i+1);
	      char* val;
	      if(!(val=kcdbget(common::db_in, res, strlen(res),&st))){
		      printf("Can't get with key %s\n",res);
		      exit(-1);
	      } 			
	      local_entries=kcatoi(val);   
	      kcfree(val);
		 
	      if ((!common::separate_terms) && (local_entries!=0)) local_entries = 1;
	      
	      for (int j=1;j<=local_entries;j++) {
		//taking task from queue
		sem_wait(common::job);			
		if (common::had_error) break;
		pthread_mutex_lock(&common::queue_mutex);
		pair<pair<int, int>,string> task=*(common::job_queue.begin());           				
		common::job_queue.pop_front();					
		pthread_mutex_unlock(&common::queue_mutex);         						
		sem_post(common::job_queue_filled);
	     		
		//char *result;

		
		if (task.second[0]=='?') {
		    //task.second[0]='0';
		    string temp=task.second;
		    const char* temp_data=temp.c_str()+3;
	  
		      
		    
		    int free_slave;
		    do 
		      count_slaves++;
		    while 
		      ((count_slaves<numprocs) && (badslaves[count_slaves]));
		    
		    if (count_slaves<numprocs) { //we still did not use all slaves
		      used_slaves++;		      
		      free_slave=count_slaves;	
		    } else {
		      //here we wait for an answer from one of the slaves	
		      free_slave=receive_from_MPI_and_push_to_queue();
		    }
		     
		    // now we can submit the new job

		    int size[3];
		    size[0]=temp.size()-3;
		    size[1]=task.first.first;
		    size[2]=task.first.second;
		    //cout<<free_slave<<"|"<<numprocs<<"|"<<used_slaves<<endl;
		    
		    mpi_submitted_tasks.insert(make_pair(task.first,free_slave));
		    // task sent to slaves
		  
		    
		    MPI_Ssend(size,3,MPI_INT,free_slave,INTEGRATE_REQUEST,MPI_COMM_WORLD);

		    MPI_Ssend((void*) temp_data,size[0],MPI_CHAR,free_slave,INTEGRATE_REQUEST,MPI_COMM_WORLD);
	  
		} else if (task.second[0]=='{') {
		    char result[256];
		    snprintf(result,256,"%s",task.second.c_str());      
		    sem_wait(common::rjob_queue_filled);
		    pthread_mutex_lock(&common::rqueue_mutex);   
		    common::rjob_queue.push_back(pair<pair<int, int>,string>(task.first,(string)result));
		    pthread_mutex_unlock(&common::rqueue_mutex);
		    sem_post(common::rjob);
		} else {
		    char result[256];
		    snprintf(result,256,"{%s,0,0,0}",task.second.c_str());      
		    sem_wait(common::rjob_queue_filled);
		    pthread_mutex_lock(&common::rqueue_mutex);   
		    common::rjob_queue.push_back(pair<pair<int, int>,string>(task.first,(string)result));
		    pthread_mutex_unlock(&common::rqueue_mutex);
		    sem_post(common::rjob);
		}
	      } // local_entries	    	      
	      
	    } //entries
	 
	    
	    /* There's no more work to be done, so receive all the outstanding
		results from the slaves. */
	    // in case of had_error we also need to collect results bask from slaves
    
	    submitted_all=1;
    
	    //cout<<"Here"<<endl;
    
	    for (int rank = 0; rank < used_slaves; ++rank) {
	      
		 int free_slave = receive_from_MPI_and_push_to_queue();
		 if (free_slave==0) {
		    // this means that we encounter a timeout; we need to resubmit all jobs 
		    set<pair<int,int> > ptasks;
		    for (map<pair<int,int>,int>::iterator itr = mpi_submitted_tasks.begin();itr!=mpi_submitted_tasks.end();++itr) {
			pair<int,int> ptask = mpi_submitted_tasks.begin()->first;
			int badslave = mpi_submitted_tasks.begin()->second;
			badslaves[badslave]=1;
			ptasks.insert(ptask);
		    }
		    cout<<"(slow slaves ("<<mpi_submitted_tasks.size()<<"), resubmitting)";
		    mpi_submitted_tasks.clear(); // we will be resubmitting
		    rank--; // we did not actually receive a result this time
		    set<pair<int,int> >::iterator pitr=ptasks.begin();
		    for (free_slave=1;free_slave!=numprocs;++free_slave) {
			if (pitr==ptasks.end()) break; // we submitted all
			if (badslaves[free_slave]) continue; // this one is bad
			string temp = common::form_integration_string(pitr->first,pitr->second); // forming the string again
			const char* temp_data=temp.c_str()+3;
			int size[3];
			size[0]=temp.size()-3;
			size[1]=pitr->first;
			size[2]=pitr->second;
			mpi_submitted_tasks.insert(make_pair(*pitr,free_slave));
			MPI_Ssend(size,3,MPI_INT,free_slave,INTEGRATE_REQUEST,MPI_COMM_WORLD);
			MPI_Ssend((void*) temp_data,size[0],MPI_CHAR,free_slave,INTEGRATE_REQUEST,MPI_COMM_WORLD);
			++pitr;
		    }
		    if (pitr!=ptasks.end()) {
			cout<<"Too many slaves died, could not resubmit all!"<<endl;
			throw 1;
		    }		      		      
		 }
	    }
  //cout<<"final setting max time to 0"<<endl;
    max_time=0;
    pthread_join(guard,NULL);
  
 // cout<<"Max piece time: "<<max_time<<endl;
  
}

#endif
