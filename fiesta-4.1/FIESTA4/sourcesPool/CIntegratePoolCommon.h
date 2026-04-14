#ifndef CIntegratePoolCommon
#define CIntegratePoolCommon

#if THREADSMODE

#else
#include <mpi.h>
#endif

#ifdef _XOPEN_SOURCE
#undef _XOPEN_SOURCE 
#endif
#define _XOPEN_SOURCE 600
#include <iomanip>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <kclangc.h>
#include <pthread.h>
#include <semaphore.h>
#include <list>
#include <map>
#include <vector>
#include <set>
#include <string>
#include <time.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>

#define MAX_THREADS 1024
#define MAX_QUEUE 50

class common{
public:
static pid_t openprogram(FILE **to, FILE **from,char* g_thepath);
static int init_params(FILE* pipe_to,FILE* pipe_from);
static int parse_argc_argv(int argc, char *argv[]);
static int prepare_databases();

static int prepare_task();

static void close_databases();

// submitter reads from input database and fills queue
// in threads mode IntegrateThread catches the queue
// in MPI mode it should be started by the master
// in MPI mode main thread reads out from the queue and sumbits via MPI
static void * submitter(void * par);

//receiver reads from queue with results
//in threads mode they come from IntegrateThread
//in MPI mode the master-thread fills the results queue after MPI exchange
static void * receiver(void * par);

static void prepare_prefix_integration();

static void finish_prefix_integration();

static int start_CIntegrate(int count);
static int startGuard(char* pname);

static std::string form_integration_string(int i, int j);

#ifdef intSIGHANDLER
static int sigCHL(int i);
#else
static void sigCHL(int i);
#endif

static void stop_CIntegrate(int count);

static int Integrate(int thread_number,const char* function,char* res);

static int integration_test();

static std::string IntegrationCommand;
static int PrintIntegrationCommand;


//the following options and should be read by all MPI threads from command line
static char integrator[200];
static char MPPrecision[200];
static char MPMin[200];
static char PrecisionShift[200];
static char SmallX[200];
static char MPThreshold[200];
static std::list <std::pair<std::string,std::string> > intpar;
static char binary_path[200];
static char input_prefix[200];
static 	char in[200];
static 	char out[200];
static char math_binary[200];
static int math_binary_defined;
static char* prefix;
static char* nvars;
static 	int in_defined;
static 	int out_defined;
static 	int prefix_defined;
static 	int binary_path_defined;
static 	int bucket;
static 	int threads_number;
static 	int test_mode;
static 	int notest;
static 	char CPUCores[200];
static int all_prefixes;
static int direct;
static int complex;
static int separate_terms;
static int mpfr;
static pid_t guardpid;
static int testF;
static int debug;
static int only_prepare;
static int gpu;
static KCDB* db_in;
static KCDB* db_out;
static int had_error;  // a signal to stop integrating
static int GPUForceCore; // by default -2, do nothing; -1 is do not use, otherwise it is the core number;
static int gpu_threads_per_node; // default, 0 is unlimited (but distributed); -1 means that each process uses all
static int gpu_per_node; // default, 0 is unlimited; if set, means the real number of GPU
static int GPUMemoryPart; // default is 1, each thread is not sharing GPU with anyone

static std::list<std::string> prefixes;

static char task_prefix[200];
static char requested_task_prefix[200];

static std::list<std::string> tasks;
//end of options and values


//queue related
// job: there is something to do for threads
// job_queue: there is a slot where to out a task
static sem_t* job;
static sem_t* job_queue_filled;
static sem_t* rjob;
static sem_t* rjob_queue_filled;
static pthread_mutex_t queue_mutex;
static pthread_mutex_t rqueue_mutex;
static std::list<std::pair<std::pair<int, int>, std::string> > job_queue;
static std::list<std::pair<std::pair<int, int>, std::string> > rjob_queue;
static pthread_t thread_s;
static pthread_t thread_r;


//needed only for gathering results
static int min_deg; 
static int SHIFT;
static std::map<std::pair<int,std::string>,std::pair<double,double> > results;
static std::map<std::pair<int,std::string>,std::pair<double,double> > results_im;

//numers of entries for each prefix, it is constant
static int entries;

// normally 1, but might be defferent if we are integrating a part of terms
static int entries_start; 

// initially 1 and 1 meaning we integrate all terms
static int part;
static int parts;

// 0 - standart, sum up everyhting in RAM
// 1 - save all results in out database
// 2 - save all results, but clean up when the final result is read

static int results_mode;

//on first pass it is 1
static int only_parse;
static int preparse;

//CIntegrate communication
static FILE* g_to[MAX_THREADS];
static FILE* g_from[MAX_THREADS];
static pid_t pids[MAX_THREADS];

};

#endif
