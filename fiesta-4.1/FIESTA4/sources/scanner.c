/*
    Copyright (C) Alexander Smirnov and Mikhail Tentyukov. 
    This file is part of the program CIntegrate.
    The program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 2 as
    published by the Free Software Foundation.

    The program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*/

/*
In this file one can find a translator of an incoming expression into
triples (ctTriad) and quadruples (rtTriad, for historical reasons).

masterScan() perform initialisations and invokes the translator
simpleScan() for all functions and then for the expression.

simpleScan() is a recursive translator, it invokes scanTerm() for each
term and then it sums up all the terms in some "native" order.

For subexpressions scanTerm() invokes the next copy of simpleScan().
scanTerm() scans each factor to a "commuting diad":
Let's consider a term. Let's assume it has an implicit coefficient 1 in
front.  We consider every factor as a commuting diad of a form
"operation", "operand", e.g. 3*x[1]*x[3]/x[2] will be
considered as a set of the following commuting diads:
'*', 3
'*', x[1]
'*', x[3]
'/',x[2]
Now we can re-order all these diads without affecting the result.
We try to evaluate such a sequence in some native order, see the function
processDiads().

After the sequence of the triples (ctTriad) is ready, the function
buildRtTriad() translates the sequence to the array of quadruples rtTriad
of a form "operation", "operand 1", "operand 2" and "result". The
fields "operand 1" and "operand 2" are pointers to some memory
addresses.  The "result" field is either the result of the quadruple
evaluation (double type), or the address of the memory cell in which
the result must be stored. The point is that the size of the address
field on 64 bit platforms is the same as the size of double, and the
usage of indirect references is rather slow, so it seems to be
reasonable to use a new memory cell for each intermediate result.

However, on a modern CPU such an approach appears to be completely wrong.
Modern processors have a big write-back cache memory (megabytes), and
provided the same memory address is permanently updated it is never
written to RAM but stays in the cache. On the other hand, if we write intermediate
results every time to a new address, all this data is sooner or later
written to RAM (after the cache exhausted). That is why
for "small" jobs, when all intermediate results fit into the
processor cache, the interpreter stores results directly to the
"result" field of a quadruple, while for "large-scale" jobs the
translator creates some buffers and provides the quadruples with re-usable
addresses of elements of these buffers.

The algorithm switches from the "small" to "large" model when the
number of generated triples reaches some threshold which strongly
depends on the size of the processor L2 (L3) cache per active core and
it is a subject for tuning for every specific architecture. The
corresponding value is hard-coded, it can be changed in the file
scanner.h, the macro INDIRECT_ADDRESSING_THRESHOLD.

After quadruple array is ready it can be evaluated by the interpreter
runExpr(), file runline.c
*/

#include <stdlib.h>
#include <stdio.h>

#include <math.h>
#include <errno.h>
#include <string.h>


#include "scanner.h"
#include "tries.h"
#include "constants.h"

#define O_B '['
#define C_B ']'

#define O_B_S "["
#define C_B_S "]"

/*mmap/munmap:*/
#include <unistd.h>
#include <sys/mman.h>

char* math_binary=NULL;



/*Attention!
The following three macros must be defined before including queue.h, otherwise
queues will use malloc() instead of mmap:*/
#define qFLAlloc(theSize) mmap(0,theSize,PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
#define qFLFree(theScratch,theLength) munmap(theScratch,theLength);
#define qFLAllocFail MAP_FAILED
#include "queue.h"


#ifndef NO_FILES
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#endif

#include <stdarg.h>

#define MAX_FLOAT_LENGTH 128

/*FL_something are bitwise flags:*/
#define FL_WITHOPTIMIZATION 1


char buffer_from_mathematica[8192]; 

void PutErrorMessage(char*,char*);

int stoprun=0;

void halt(int retval,char *fmt, ...)
{
va_list arg_ptr;
char buf[256];

   va_start (arg_ptr, fmt);
   vsnprintf(buf,255,fmt,arg_ptr);
   va_end (arg_ptr);
   if(stoprun==0)
      PutErrorMessage("CIntegrate",buf);
   stoprun=1;
   if(retval<0)
      exit(-retval);
}/*halt*/

static  void initIFArray(NINTERNAL_FLOAT *f,SC_INT l)
{
   SC_INT i;
   for(i=0;i<l;i++)
      initIFvar(f++);
}/*initIFArray*/

/*
 The quickselect algorith, returns the value of the `k'-th largest
 element from the array `v' of dimension `dim'. `k'-th largest element
 means that in the array there are not more than `k' elements which are
 bigger than the found one, and at least `k' elements which are not
 smaller than the found one.
 Implementation by M.Tentyukov based on the original C.A.R. Hoare ideas.
*/
static SC_INLINE SC_INT selectK(SC_INT *v, SC_INT dim, SC_INT k) 
{ SC_INT
left=0,right=dim-1; SC_INT m,l,r;

   k--;
   while(left<right){
      /*0..left-1 are greatest elements,
        right+1..dim-1 -- small elements.*/
     
      /*some optimization:*/
      if(k==left){/*just one element is missing, find 
                    and return the maximum:*/
         m=v[left];
         for(r=right; r>left;r--)if(v[r]>m) m=v[r];
         return m;
      }
      /*partitioning: left elements are _greater_ (or 
        equal) than the pivot, right elements are _less_ (or
        equal) than the pivot. This is the OPPOSITE w.r.t.
        the usual quicksort!
       */
      l=left;r=right;m=(l+r)>>1;
      do{
         while(v[l]>v[m])l++;
         while(v[r]<v[m])r--;
restart:
         if(l<r){
            SC_INT tmp=v[l]; v[l]=v[r];v[r]=tmp;
            if(m==l){
               m=r;
               l++;
               while(v[l]>v[m])l++;
               goto restart;
            }
            if(m==r){
               m=l;
               r--;
               while(v[r]<v[m])r--;
               goto restart;
            }
            l++;r--;
         }/*if(l<r)*/
      }while(l<r);
      /*Here if l>r, then v[l]==v[r]*/
      /*Now from 0 to r all elements greater or equal v[m],
        from l to dim all elements less or equal v[m]*/
      if(k<r)/*Too many big elements, 
               drop the right partition and repeat:*/
         right=r-1;
      else if (k>l)/*Not enough big elements,try get 
                     more from the right partition:*/
         left=l+1;
      else/*found*/
         return v[r];
   }/*while(left<right)*/
   return v[right];
}/*selectK*/

/*Set in masterScan():*/
SC_INT totalInputLength=-1;

SC_INT estimateHashSize(scan_t *theScan){
return (totalInputLength / 4) + 5;
}/*estimateHashSize*/

#ifndef NO_FILES
scan_t *newScanner(char *fname)
{
   scan_t *res;
   int fd=0;
   mpfr_set_default_prec(g_default_precision);

   if(fname!=NULL){
      fd=open(fname,O_RDONLY);
      if(fd <0)
         return NULL;
   }/*if(fname!=NULL)*/
   /*else -- fd=0 by initialization*/

   res=malloc(sizeof(scan_t));
   res->multiLine=NULL;

   res->buf[0]='\0';
   res->theChar=res->buf;
   res->fd=fd;
   res->fline=NULL;
   res->maxX=NULL;
   res->fNativeLine=NULL;   
   res->nativeXsplit=NULL;
   res->allMPvariables=NULL;

   res->x=NULL;
   res->f=NULL;
   res->pstack=NULL;
   res->flags=0;
#ifdef WITH_OPTIMIZATION
   res->flags|=FL_WITHOPTIMIZATION;
#endif
   res->nativeTline=NULL;
   res->condChain=NULL;
   res->allCondChain=NULL;   
   res->rtTriad.length=0;
   res->ctTriad.max=0;
   res->ctTriad.free=0;
   res->ctTriad.theScan=res;
   
   res->answer_position=NULL;
   res->answer=NULL;
   res->x_local=NULL;
   res->x_local2=NULL;
   
   return res;
}/*newScanner*/
#endif

scan_t *newScannerFromStr(char *str)
{
   scan_t *res;
   mpfr_set_default_prec(g_default_precision);
   res=malloc(sizeof(scan_t));
   res->multiLine=NULL;

   res->theChar=str;
   res->fd=-1;
   res->fline=NULL;
   res->fNativeLine=NULL;   
   res->nativeXsplit=NULL;
   res->maxX=NULL;
   res->allMPvariables=NULL;
   res->x=NULL;
   res->f=NULL;

   res->pstack=NULL;
   res->flags=0;

#ifdef WITH_OPTIMIZATION
   res->flags|=FL_WITHOPTIMIZATION;
#endif
   res->nativeTline=NULL;
   res->condChain=NULL;
   res->allCondChain=NULL;
   res->allocatedCondChains=NULL;
   res->constStrings=NULL;
   res->newConstantsPool.full=0;
   res->rtTriad.length=0;
   res->ctTriad.max=0;
   res->ctTriad.free=0;
   res->ctTriad.theScan=res;

   res->answer_position=NULL;
   res->answer=NULL;
   res->x_local=NULL;
   res->x_local2=NULL;
   
   return res;
}/*newScannerFromStr*/

scan_t *newScannerMultiStr(multiLine_t *multiLine)
{
   scan_t *res;
   mpfr_set_default_prec(g_default_precision);
   res=malloc(sizeof(scan_t));
   res->multiLine=multiLine;
   res->theChar=(char*)(multiLine->mline.buf[0]);
   res->fd=-1;
   res->fline=NULL;
   res->fNativeLine=NULL;   
   res->nativeXsplit=NULL;
   res->maxX=NULL;
   res->allMPvariables=NULL;
   res->x=NULL;
   res->f=NULL;

   res->pstack=NULL;
   res->flags=0;

#ifdef WITH_OPTIMIZATION
   res->flags|=FL_WITHOPTIMIZATION;
#endif
   res->nativeTline=NULL;
   res->condChain=NULL;
   res->allCondChain=NULL;
   res->allocatedCondChains=NULL;
   res->constStrings=NULL;
   res->newConstantsPool.full=0;
   res->rtTriad.length=0;
   res->ctTriad.max=0;
   res->ctTriad.free=0;
   res->ctTriad.theScan=res;

   res->answer_position=NULL;
   res->answer=NULL;
   res->x_local=NULL;
   res->x_local2=NULL;
   
   return res;
}/*newScannerMultiStr*/

int initMultiLine(multiLine_t *multiLine)
{
char *c;
   initCollect(&multiLine->mline);
   
   c=(char*)mmap (0, MULTILINESIZE+1,
        PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(c == MAP_FAILED){
      halt(-10, "mmap failed");
      return 1;
   }
   c[0]='\0';
   pushCell(&multiLine->mline,(void*)c);

   multiLine->nbuf=multiLine->free=0;

   return 0;
}/*initMultiLine*/

int addToMultiLine(multiLine_t *multiLine, char *str)
{
char *m=(char*)(multiLine->mline.buf[multiLine->mline.fill-1])+multiLine->free;
   while(*str!='\0'){   
      for(;multiLine->free<MULTILINESIZE;multiLine->free++)
         if( (*m++=*str++)=='\0' ){
            str--;
            break;
         }
      if(multiLine->free==MULTILINESIZE){
         ((char*)(multiLine->mline.buf[multiLine->mline.fill-1]))[MULTILINESIZE]='\0';
         m=(char*)mmap (0, MULTILINESIZE+1, PROT_READ|PROT_WRITE,
             MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
         if(m== MAP_FAILED){
            halt(-10, "mmap failed");
            return 1;
         }/*if(m == MAP_FAILED)*/
         pushCell(&multiLine->mline,m);
         multiLine->free=0;
      }/*if(multiLine->free==MULTILINESIZE)*/
   }/*while(*str!='\0')*/
   return 0;
}/*addToMultiLine*/

void destroyMultiLine(multiLine_t *multiLine)
{
void *tmp;
   while(multiLine->mline.fill != 0 ){
      tmp=popCell(&multiLine->mline);
      if(tmp!=NULL)
         munmap(tmp,MULTILINESIZE+1);
   }/*while(multiLine->mline.fill != 0 )*/
   free(multiLine->mline.buf);
   multiLine->mline.buf=NULL;
   multiLine->free=0;
   multiLine->nbuf=0;
}/*destroyMultiLine*/


static SC_INLINE void ctTriadRealloc( ct_triad_t *t)
{
   SC_INT bytesForInt, newBytesForInt;
   SC_INT newMax=t->max * 2;
   char *newOperation;
   SC_INT *newOperand;

   newOperation = (char*)mmap (0, newMax,
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(newOperation == MAP_FAILED)
      halt(-10, "mmap failed");
   memcpy(newOperation,t->operation,t->max);
   munmap(t->operation,t->max);
   t->operation=newOperation;
   
   
   bytesForInt=t->max*sizeof(SC_INT);
   newBytesForInt=newMax*sizeof(SC_INT);

   newOperand=(SC_INT*)mmap (0, newBytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(newOperand == MAP_FAILED)
      halt(-10, "mmap failed");
   memcpy(newOperand,t->triadType,bytesForInt);
   munmap(t->triadType,bytesForInt);
   t->triadType=newOperand;


   newOperand=(SC_INT*)mmap (0, newBytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(newOperand == MAP_FAILED)
      halt(-10, "mmap failed");
   memcpy(newOperand,t->lastUsing,bytesForInt);
   munmap(t->lastUsing,bytesForInt);
   t->lastUsing=newOperand;

   newOperand=(SC_INT*)mmap (0, newBytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(newOperand == MAP_FAILED)
      halt(-10, "mmap failed");
   memcpy(newOperand,t->refCounter,bytesForInt);
   munmap(t->refCounter,bytesForInt);
   t->refCounter=newOperand;

   newOperand=(SC_INT*)mmap (0, newBytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(newOperand == MAP_FAILED)
      halt(-10, "mmap failed");
   memcpy(newOperand,t->firstOperand,bytesForInt);
   munmap(t->firstOperand,bytesForInt);
   t->firstOperand=newOperand;

   newOperand=(SC_INT*)mmap (0, newBytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(newOperand == MAP_FAILED)
      halt(-10, "mmap failed");
   memcpy(newOperand,t->secondOperand,bytesForInt);
   munmap(t->secondOperand,bytesForInt);
   t->secondOperand=newOperand;
   t->max=newMax;
}/*ctTriadRealloc*/

static SC_INLINE void ctTriadInit(SC_INT hashSize, ct_triad_t *t)
{
   SC_INT bytesForInt;
   t->max=getpagesize();
   t->free=1;

   t->operation = (char*)mmap (0, t->max,
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(t->operation == MAP_FAILED)
      halt(-10, "mmap failed");

   bytesForInt=t->max*sizeof(SC_INT);

   t->triadType=(SC_INT*)mmap (0, bytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(t->triadType == MAP_FAILED)
      halt(-10, "mmap failed");

   t->lastUsing=(SC_INT*)mmap (0, bytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(t->lastUsing == MAP_FAILED)
      halt(-10, "mmap failed");

   t->refCounter=(SC_INT*)mmap (0, bytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(t->refCounter == MAP_FAILED)
      halt(-10, "mmap failed");

   t->firstOperand=(SC_INT*)mmap (0, bytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(t->firstOperand == MAP_FAILED)
      halt(-10, "mmap failed");
   t->secondOperand=(SC_INT*)mmap (0, bytesForInt, 
      PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
   if(t->secondOperand == MAP_FAILED)
      halt(-10, "mmap failed");

   hash_init(hashSize,&t->hashTable, t);
}/*ctTriadInit*/

static SC_INLINE void ctTriadFree( ct_triad_t *t)
{
   SC_INT bytesForInt=t->max * sizeof(SC_INT);
      munmap(t->operation,t->max);
      munmap(t->triadType,bytesForInt);
      munmap(t->lastUsing,bytesForInt);
      munmap(t->refCounter,bytesForInt);
      munmap(t->firstOperand,bytesForInt);
      munmap(t->secondOperand,bytesForInt);
      t->free=t->max=0;
      if(t->hashTable.theSizeInBytes > 0 )
         hash_destroy(&t->hashTable);
      t->theScan = NULL;
}/*ctTriadFree*/

static SC_INLINE void rtTriadInit(rt_triad_t *t, SC_INT theLength)
{
   t->operations=(char*)malloc(theLength);
   if(t->operations==NULL)
      halt(-10,"malloc failed");
   t->nativeOperations=(char*)malloc(theLength);
   if(t->nativeOperations==NULL)
      halt(-10,"malloc failed");
   t->operands=(rt_triadaddr_t*)malloc(theLength*sizeof(rt_triadaddr_t));
   if(t->operands==NULL)
      halt(-10,"malloc failed");
   t->nativeOperands=(rt_triadaddr_t*)malloc(theLength*sizeof(rt_triadaddr_t));
   if(t->nativeOperands==NULL)
      halt(-10,"malloc failed");
#ifdef GPU   
   t->gpu_operands=(rt_gpu_triad*)malloc(theLength*sizeof(rt_gpu_triad));
   if(t->gpu_operands==NULL)
      halt(-10,"malloc failed");   
#endif
   t->length=theLength;
}/*rtTriadInit*/


static SC_INLINE void rtTriadClear(rt_triad_t *t)
{
    // this happens only for MPFR
   char *rto=t->operations;
   char *rtoStop=t->operations+t->length;/*Note, in runline the 
       last iteration is out of the loop so it is shorter by 1.*/
   rt_triadaddr_t *rta=t->operands;
   for(;rto<rtoStop;rto++,rta++){
      switch(*rto){
         case ROP_IPOW_F:
            clearIFvar(&(rta->aIF.result));
            break;
         default:
         clearIFvar(&(rta->aF.result));
      }/*switch(*rto)*/
   }/*for(;rto<rtoStop;rto++,rta++)*/
}/*rtTriadClear*/

static SC_INLINE void rtTriadFree(rt_triad_t *t)
{
  free(t->operands);
  t->operands=NULL;
  free(t->nativeOperands);
  t->nativeOperands=NULL;
  free(t->operations);
  t->operations=NULL;
  free(t->nativeOperations);
  t->nativeOperations=NULL;
#ifdef GPU   
  free(t->gpu_operands);
  t->gpu_operands=NULL;
#endif 
  t->length=0;
}/*rtTriadFree*/

/*if l<0, does not deallocate array itself:*/
static SC_INLINE void freeIFArray(NINTERNAL_FLOAT *f,SC_INT l)
{
   if(l<0){
      SC_INT i;
      l=-l;
      for(i=0;i<l;i++)
         clearIFvar(f+i);
   }
   else{
      SC_INT i;
      for(i=0;i<l;i++)
         clearIFvar(f+i);
      free(f);
   }
}/*freeIFArray*/

void destroyScanner( scan_t *theScan)
{
   if(theScan==NULL)
      return;
#ifndef NO_FILES
   if(theScan->fd)/*Not a stdin*/
      close(theScan->fd);
#endif
   if(theScan->multiLine!=NULL)
      destroyMultiLine(theScan->multiLine);

   if(theScan->ctTriad.max!=0)
     ctTriadFree(&theScan->ctTriad);

   if(theScan->rtTriad.length!=0){
      rtTriadClear(&theScan->rtTriad);
      rtTriadFree(&theScan->rtTriad);
   }/*if(theScan->rtTriad.length!=0)*/
   mpfr_free_cache();
   if(theScan->f!=NULL)
      free(theScan->f);

   if(theScan->x!=NULL)
      freeIFArray(theScan->x,theScan->nx);
   if(theScan->nativeXsplit!=NULL)
      free(theScan->nativeXsplit);
   if(theScan->maxX!=NULL)
      free(theScan->maxX);

   if(theScan->fline!=NULL){
      freeIFArray(theScan->fline->buf,theScan->fline->fill);
      free(theScan->fline);
   }/*if(theScan->fline!=NULL)*/
   if(theScan->fNativeLine!=NULL){
      free(theScan->fNativeLine->buf);
      free(theScan->fNativeLine);
   }
   if(theScan->allMPvariables!=NULL){
      free(theScan->allMPvariables->buf);
      free(theScan->allMPvariables);
   }
   if(theScan->pstack!=NULL){
      free(theScan->pstack->buf);
      free(theScan->pstack);
   }


   if(theScan->nativeTline!=NULL){
      void *tmp;   
      free(theScan->nativeTline->buf[0]);
      theScan->nativeTline->buf[0]=NULL;
      while(  (tmp=popCell(theScan->nativeTline))!=NULL )
	  free(tmp);
      free(theScan->nativeTline->buf);
      free(theScan->nativeTline);
   }
   
   if(theScan->condChain!=NULL){
      free(theScan->condChain->buf);
      free(theScan->condChain);
   }
   if(theScan->allCondChain!=NULL){
      free(theScan->allCondChain->buf);
      free(theScan->allCondChain);
   }
   if(theScan->allocatedCondChains!=NULL){
      void *tmp;
      while(  (tmp=popCell(theScan->allocatedCondChains))!=NULL )
         free(tmp);
      free(theScan->allocatedCondChains->buf);
      free(theScan->allocatedCondChains);
   }
   if(theScan->constStrings!=NULL){
      free(theScan->constStrings->buf);
      free(theScan->constStrings);
   }  
   if(theScan->newConstantsPool.full > 0 ){
      destroyMPool(&theScan->newConstantsPool);
      theScan->newConstantsPool.full=0;
   }
   
   free(theScan->answer_position);
   free(theScan->answer);
   free(theScan->x_local);
   free(theScan->x_local2);
   
   
   free(theScan);
   totalInputLength=-1; /*let it be processed normally by the next masterScan()*/
}/*destroyScanner*/

static SC_INLINE int ReadNextBlock(scan_t *theScan)
{
#ifndef NO_FILES
ssize_t r;
   if(theScan->fd<0){
      halt(14,"ReadNextBlock: unexpected end of input");
      return 1;
   }
   while( ( (r=read(theScan->fd,theScan->buf,INBUFSIZE))<0 ) && (errno == EINTR)  );
   if(r<1){
      halt(14,"ReadNextBlock: unexpected end of input");
      return 1;
   }
   theScan->buf[r]='\0';
   theScan->theChar=theScan->buf;
   return 0;
#endif
   if(theScan->multiLine!=NULL){
      munmap(theScan->multiLine->mline.buf[theScan->multiLine->nbuf],MULTILINESIZE+1);
      theScan->multiLine->mline.buf[theScan->multiLine->nbuf]=NULL;
      theScan->theChar=theScan->multiLine->mline.buf[++theScan->multiLine->nbuf];
      if(theScan->multiLine->nbuf>=theScan->multiLine->mline.fill){
         halt(14,"ReadNextBlock: unexpected end of input");
         return 1;
      }
   }/*if(theScan->multiLine!=NULL)*/
   return 0;
}/*ReadNextBlock*/

static SC_INLINE int skipUntilEndOfComment(scan_t *theScan)
{
   while(*(theScan->theChar)!='}'){
      (theScan->theChar)++;
      if( *(theScan->theChar) == '\0' ){
         if(theScan->multiLine == NULL)
            return 0;
         if(ReadNextBlock(theScan))
            return 1;
      }
   }
   /*Here *(theScan->theChar)=='}'*/
   (theScan->theChar)++;
   /*Note* here *(theScan->theChar) may be '\0', no problem,
     nextCharComplex() will invoke ReadNextBlock(). */
   return 0;
}/*skipUntilEndOfComment*/

/* The function returns the current character corresponding to *theChar,
   ignoring white spaces (<=' ' ), and sets the pointer theChar to the next
   position. The double \ (combination \\) is treated as one \ character.
   The single \ at the end of the line is ignored:
 */

static char nextCharComplex(scan_t *theScan)
{
   for(;;){
      switch(*(theScan->theChar)){
         case '\0':/*Each time reading a new buffer we add '\0' at the end*/
            if(theScan->multiLine == NULL)
               return '\0';
            if(ReadNextBlock(theScan))
               return '\0';
            continue;
         case '{':
            if(skipUntilEndOfComment(theScan))
               return '\0';
            continue;
         case '\\':/*Look at the next element: exceptions are '\n' and '\\'*/
            switch((theScan->theChar)[1]){
               case '\0':/*The block is expired*/
                  if(theScan->multiLine == NULL)
                     return '\0';
                  (theScan->theChar)++;
                  if(ReadNextBlock(theScan))
                     return '\0';
                  if(*(theScan->theChar)=='\n'){
                     (theScan->theChar)++;
                     continue;
                  }else{
                     if(*(theScan->theChar)=='\\')
                        (theScan->theChar)++;
                     return '\\';
                  }
               case '\n':
                  (theScan->theChar)+=2;
                  break;
              case '\\':
                  (theScan->theChar)+=2;
                  return '\\';
            }/*switch((theScan->theChar)[1])*/
            break;
      }/*switch(*(theScan->theChar))*/
      if(*(theScan->theChar)>' ')
         break;
      (theScan->theChar)++;
   }/*for(;;)*/
   return *(theScan->theChar)++;
}/*nextCharComplex*/

static SC_INLINE char nextChar(scan_t *theScan)
{

   if(*(theScan->theChar) > ' ' ){
      switch(*(theScan->theChar)){
         case '\\':
         case '{':
             return nextCharComplex(theScan);
         default:
             return *(theScan->theChar)++;
      }
   }
   while(*(theScan->theChar) == ' ')(theScan->theChar)++;
   if(*(theScan->theChar) > ' ' ){
      switch(*(theScan->theChar)){
         case '\\':
         case '{':
             return nextCharComplex(theScan);
         default:
             return *(theScan->theChar)++;
      }
   }
   return nextCharComplex(theScan);
}/*nextChar*/

static void parseError(char *msg)
{
   halt(16,"Parse error: %s\0",msg);
}

static SC_INLINE char parseInt(int *n,scan_t *theScan)
{
char c;
   for(;;)switch(c=nextChar(theScan)){
      case '0':case '1':case '2':case '3':case '4':case '5':case '6':case '7':
      case '8':case '9':
        *n=*n*10+c-'0';
        break;
      default:
        return c;
   }/*for(;;)switch(c=nextChar(theScan))*/
}/*parseInt*/



static SC_INLINE char parseInt2(int *e,int *n,scan_t *theScan)
{
char c;
   *e=1;
   for(;;)switch(c=nextChar(theScan)){
      case '0':case '1':case '2':case '3':case '4':case '5':case '6':case '7':
      case '8':case '9':
        (*e)*=10;
        *n=*n*10+c-'0';
        break;
      default:
        return c;
   }/*for(;;)switch(c=nextChar(theScan))*/
}/*parseInt2*/

static SC_INLINE char *parseConst(char *buf,int l,scan_t *theScan)
{
   for(;l>0;l--,buf++)switch(*buf=nextChar(theScan)){
      case '0':case '1':case '2':case '3':case '4':case '5':case '6':case '7':
      case '8':case '9':
        break;
      default:
        return buf;
   }/*for(;l>0;l--,buf++)switch(*buf=nextChar(theScan))*/
   parseError("Too long number");
   return NULL;
}/*parseConst*/

static SC_INLINE int simpleScan(int iniOp, scan_t *theScan);



#ifdef STATISTICS_OUT
long int allT=0;
long int newT=0;
#endif


/*returns  the triad number*/
static SC_INLINE SC_INT sCtTriad(int op,SC_INT triadType,SC_INT operand1,
                                  SC_INT operand2,ct_triad_t *t)
{
SC_INT n=t->free;
   if (n >= t->max)
      ctTriadRealloc(t);
   t->operation[n]=op;
   t->triadType[n]=triadType;
   t->firstOperand[n]=operand1;
   t->secondOperand[n]=operand2;
#ifdef STATISTICS_OUT
      allT++; newT++;
#endif
   t->free++;
   return n;
}/*sCtTriad*/

/*returns  the triad number*/
static SC_INLINE SC_INT tandsCtTriad(int op,SC_INT triadType,SC_INT operand1,SC_INT operand2,ct_triad_t *t)
{
SC_INT n=t->free;
SC_INT res;
   if (n >= t->max)
      ctTriadRealloc(t);
   t->operation[n]=op;
   t->firstOperand[n]=operand1;
   t->triadType[n]=triadType;
   t->secondOperand[n]=operand2;

#ifdef WITH_OPTIMIZATION
   if(t->theScan->flags & FL_WITHOPTIMIZATION) {
      res=hash_tands(n, &t->hashTable);
#ifdef STATISTICS_OUT
      allT++;
#endif
      if(n == res){/*A new triad was installed*/
         t->free++;
#ifdef STATISTICS_OUT
         newT++;
#endif
      }/*if(n == res)*/
   }/*if(t->theScan->flags & FL_WITHOPTIMIZATION)*/
   else{
      res=n;
      t->free++;
   }
#else
   res=n;
   t->free++;
#endif
   return res;
}/*tandsCtTriad*/


/*x[a]:*/
#define MK_X(a) (-(a))
/*f[a]:*/
#define MK_F(a) (-(theScan->nx +(a)))
/*fline->buf[a]:*/
#define MK_FLOAT(a) (-(theScan->nx +theScan->nf+1+(a)))

static SC_INLINE NINTERNAL_FLOAT *getAddress(SC_INT op,scan_t *theScan)
{
  
  //printf("address op: %d\n",(int)op);
   if(op > 0){/*Triad*/
      return &(theScan->rtTriad.operands[op-1].aF.result);
   }/*if(op > 0)*/
   if(op >= - theScan->nx) /*x*/{
      return theScan->x -(op);
   }
   if(op >= -theScan->nx-theScan->nf)/*f*/
      return getAddress(theScan->f[-op-theScan->nx],theScan);
   /*Note, getAddress might be called recursively, its ok!
     E.g., the function body consists only from one 
     another function*/
   /*fline*/
   return theScan->fline->buf -op-(theScan->nx +theScan->nf+1);
}/*getAddress*/

static SC_INLINE FLOAT *getNativeAddress(SC_INT op,scan_t *theScan,SC_INT *slot)
{
  //printf("native op: %d\n",(int)op);
   *slot = 0;
   if(op > 0)/*Triad*/ {
      SC_INT res = theScan->ctTriad.lastUsing[op];
      *slot = res;
      return (FLOAT*)(theScan->nativeTline->buf[ res / TLINE_POOL]) + ((res % TLINE_POOL)*CubaBatch*COMPLEX_MULTIPLIER);
   }
   if(op >= - theScan->nx) /*x*/ {
      *slot = op;
      return ((FLOAT*)theScan->nativeXsplit) -(op * CubaBatch * COMPLEX_MULTIPLIER);
   }
   if(op >= -theScan->nx-theScan->nf)/*f*/
      return getNativeAddress(theScan->f[-op-theScan->nx],theScan,slot);
   /*Note, getNativeAddress might be called recursively, its ok!
     E.g., the function body consists only from one 
     another function*/
   /*fline*/     
   *slot = op;   
   return (FLOAT*)(theScan->fNativeLine->buf) +COMPLEX_MULTIPLIER*CubaBatch*(-op-(theScan->nx +theScan->nf+1));
}/*getNativeAddress*/

#define MKFP(OP,c) if(c==NULL)return R##OP##_F;return R##OP##_P

static SC_INLINE char mkROPlabels(char OPlabel,void *c)
{
   switch(OPlabel){
      case OP_NEG:
         MKFP(OP_NEG,c);
      case OP_INV:
         MKFP(OP_INV,c);
      case OP_LOG:
         MKFP(OP_LOG,c);
      case OP_CPY:
         MKFP(OP_CPY,c);
      case OP_IPOW:
         MKFP(OP_IPOW,c);
      case OP_IPOW2:
         MKFP(OP_IPOW2,c);
      case OP_IPOW3:
         MKFP(OP_IPOW3,c);
      case OP_IPOW4:
         MKFP(OP_IPOW4,c);
      case OP_IPOW5:
         MKFP(OP_IPOW5,c);
      case OP_IPOW6:
         MKFP(OP_IPOW6,c);
      case OP_POW:
         MKFP(OP_POW,c);
      case OP_MINUS:
         MKFP(OP_MINUS,c);
      case OP_DIV:
         MKFP(OP_DIV,c);
      case OP_PLUS:
         MKFP(OP_PLUS,c);
      case OP_MUL:
         MKFP(OP_MUL,c);
   }/*switch(OPlabel)*/
   halt(-10,"mkROPlabels %d: %p", OPlabel, c);
   return 0;
}/*mkROPlabels*/




static SC_INLINE void *allocatNativeTLinePool()
{
   VFLOAT * tmp = NULL;
   MALLOC(tmp,(TLINE_POOL*sizeof(FLOAT)*CubaBatch*COMPLEX_MULTIPLIER));
   if(tmp==NULL) halt(-10,"allocatNativeTLinePool: malloc fails");
   return tmp;
}/*allocatTLinePool*/

#define BUILDTR_INCR_ALL_POINTERS myIndex++,\
    cto++,cta1++,cta2++,ctNotUsed1++,ctNotUsed2++,ctLastUsing++

#ifdef GPU   
static SC_INT physical_memory(SC_INT memory) {
    SC_INT page_size = 1048576;
    return ((memory-1)/page_size+1)*page_size;  
}    

static SC_INT memory_estimate(int ops,int ops2,int X) {
    return physical_memory(ops*CubaBatch*sizeof(FLOAT) * COMPLEX_MULTIPLIER)+
    physical_memory(ops2*CubaBatch*sizeof(FLOAT) * COMPLEX_MULTIPLIER)+
	  physical_memory(X*CubaBatch*sizeof(FLOAT) * COMPLEX_MULTIPLIER);
}
#endif
    
/*Translator from triads to tetrads:*/
static SC_INLINE int buildRtTriad(scan_t *theScan)
{
char *cto=theScan->ctTriad.operation+1;
char *ctoStop=theScan->ctTriad.operation+theScan->ctTriad.free;
SC_INT *ctLastUsing=theScan->ctTriad.lastUsing+1;
SC_INT *ctNotUsed1=theScan->ctTriad.triadType+1;
SC_INT *ctNotUsed2=theScan->ctTriad.refCounter+1;
SC_INT *cta1=theScan->ctTriad.firstOperand+1;
SC_INT *cta2=theScan->ctTriad.secondOperand+1;

SC_INT myIndex=1;
//int tlineInd=0;

qFL_t tlineQ=QFL0;

NINTERNAL_FLOAT *ptr1,*ptr2,*ptr3;
FLOAT *ptr1N,*ptr2N,*ptr3N;

char *rto;
char *rtoN;
rt_triadaddr_t *rta;
rt_triadaddr_t *rtaN;
#ifdef GPU 
rt_gpu_triad *rtg;
#endif


    theScan->x=malloc(theScan->nx * sizeof(NINTERNAL_FLOAT));
     if(theScan->x == NULL) halt(-10,"malloc failed");

    MALLOC(theScan->nativeXsplit,theScan->nx * sizeof(FLOAT) * CubaBatch * COMPLEX_MULTIPLIER);
    if(theScan->nativeXsplit == NULL)  halt(-10,"malloc failed");

    initIFArray(theScan->x,theScan->nx);
   {/*Block*/
      int i;
      for(i=0; i<theScan->nx; i++)
         pushCell(theScan->allMPvariables,theScan->x+i);
   }/*Block*/
   

      /*We need not triadType anymore, reuse it as a "notUsed1" pointer:*/
      memset(ctNotUsed1,0,(theScan->ctTriad.free-1)*sizeof(SC_INT));
      /*We need not refCounter anymore, reuse it as a "notUsed2" pointer:*/
      memset(ctNotUsed2,0,(theScan->ctTriad.free-1)*sizeof(SC_INT));
     
      qFLInit(NULL,getpagesize()/sizeof(void*),&tlineQ,QFL_REALLOC_IF_FULL);    
      theScan->nativeTline=initCollect(NULL);
      
      //pushCell( theScan->nativeTline, allocatNativeTLinePool(&tlineInd));


   rtTriadInit(&theScan->rtTriad, theScan->ctTriad.free-1);
   
   rto=theScan->rtTriad.operations;
   rtoN=theScan->rtTriad.nativeOperations;
   rta=theScan->rtTriad.operands;
#ifdef GPU    
   rtg=theScan->rtTriad.gpu_operands;
#endif   
   rtaN=theScan->rtTriad.nativeOperands;
   
   // during the cycle we 
   // 1) find triads which are used maximum by the current one (maximum two of those), values stores in ctNotUsed1=triadtype, ctNotUsed1=refcounter
   // 2) for each of those use the lastusing in them in its second meaning (the slot in tline)
   // 3) use lastusing (first meaning) to fill notused1 or 2
   // 4) fill lastusing with its slot in tline (second meaning)
  
   SC_INT slot=0;
   
   for(;cto<ctoStop;BUILDTR_INCR_ALL_POINTERS){


	  //1 and 2
         {
            SC_INT **nuInd,*notUsedIndBuf[3]={ctNotUsed1,ctNotUsed2,NULL};
            for(nuInd=notUsedIndBuf;*nuInd!=NULL;nuInd++){
               if( **nuInd != 0){
                  SC_INT ind=(theScan->ctTriad.lastUsing)[**nuInd];
                  if(ind>0){
                     long int tmp=ind;
                     qFLPushLifo(&tlineQ, (void*)(tmp));
                  }/*if(ind>0)*/
               }
            }
         }
         //3
         /*Now set up the ctNotUsed field for the corresponding triad:*/
         if((*ctLastUsing != 0) && (*ctLastUsing != theScan->ctTriad.free-1)){   
             //second comparisson is important because otherwise we can read from slot outside of memory
             // but the +1 shift has to be here, or we won't catch last using by previous
               SC_INT *tmp=theScan->ctTriad.triadType+(*ctLastUsing +1);
               if(*tmp!=0)/*first one is opccupied, use the second one:*/
                  tmp=theScan->ctTriad.refCounter+(*ctLastUsing +1);
               *tmp=myIndex;
         }/*if(*ctLastUsing != 0)*/
         
         //4
         void *tmp=qFLPop(&tlineQ);
         if(tmp!=NULL){  // reusing a triad
	      *ctLastUsing= (long int)tmp;
         }
         else{   // new slot
	      *ctLastUsing= slot;
	      slot++;
         }
  
   }
  
   {
      int i;
      for (i=0;i*TLINE_POOL<slot;++i) pushCell( theScan->nativeTline, allocatNativeTLinePool());
   }
           //         if(tlineInd>=TLINE_POOL) pushCell( theScan->nativeTline, allocatNativeTLinePool(&tlineInd));  //tlineind is autimaticalli set to 0 here
		//     *ctLastUsing=((theScan->nativeTline->fill-1)*TLINE_POOL+tlineInd);		     
                 //    tlineInd++;   
   
   
   
#ifdef GPU   
      
// calculating whether we should decrease the number of blocks      
      
//SC_INT needed_ram_per_thread =  (slot) * (sizeof(FLOAT) * COMPLEX_MULTIPLIER+1);  //data. +1 here is to be safe
//needed_ram_per_thread += theScan->fNativeLine->fill * sizeof(FLOAT)* COMPLEX_MULTIPLIER;  // numbers
//needed_ram_per_thread +=  theScan->nx * sizeof(FLOAT) * COMPLEX_MULTIPLIER; // x
//needed_ram_per_thread += 1; // to be safe
//SC_INT needed_ram_per_block = needed_ram_per_thread * CUDA_BLOCK_SIZE;
    
 SC_INT needed_ram = memory_estimate(slot,theScan->fNativeLine->fill,theScan->nx)*1.1;

SC_INT needed_ram_extra= physical_memory((4 * sizeof(FLOAT*)) * (theScan->ctTriad.free+1))+
			physical_memory((1 * sizeof(char)) * (theScan->ctTriad.free+1))+
			100000;
			
SC_INT ram_free = (memory_limit/GPUMemoryPart - needed_ram_extra);
			//instructions
//int maxblocks = (memory_limit/GPUMemoryPart - needed_ram_extra)/(needed_ram_per_block);
    //maxsm=1;
//fprintf(stderr,"%zu | %d | %lu\n",memory_limit/GPUMemoryPart,maxblocks,CUDA_BLOCKS_PER_SM*cuda_sm);
//if (maxblocks<=0) {
  //  fprintf(stderr,"Expression is too huge to be integrated or memory limit is too small\n");
//}
			
  //  size_t total,freee;
    //cudaMemGetInfo(&freee,&total);
    //fprintf(stderr,"%zd,%zd\n",total,freee);	
  //  memory_limit = freee;

//if (maxblocks>1) maxblocks = (int)floor(maxblocks*0.8);
  //if (CUDA_BLOCKS_PER_SM*cuda_sm>maxblocks) {
			
			
  if (ram_free<needed_ram) {
      
      
      //decreasing arrays with native numbers
     
      //fprintf(stderr,"CubaBatch was %d\n",CubaBatch); 
      CubaBatch = CUDA_BLOCK_SIZE*cuda_sm * (   CUDA_BLOCKS_PER_SM * ram_free /needed_ram );
      //fprintf(stderr,"CubaBatch is set to %d\n",CubaBatch); 
      needed_ram = memory_estimate(slot,theScan->fNativeLine->fill,theScan->nx)*1.1;
      while (ram_free<needed_ram) {
	//fprintf(stderr,"Still not enough! %zu,%zu\n",ram_free,needed_ram);	
	CubaBatch -=CUDA_BLOCK_SIZE*cuda_sm;
	needed_ram = memory_estimate(slot,theScan->fNativeLine->fill,theScan->nx)*1.1;		
      }
      //fprintf(stderr,"CubaBatch after cycle is set to %d  (%ld)\n",CubaBatch,slot); 
      
  
      
      SC_INT i,j;
      for (i=0;i!=theScan->fNativeLine->fill;++i) {
	//printf("%f, %f\n",((FLOAT*)theScan->fNativeLine->buf)[i*(COMPLEX_MULTIPLIER*CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm)], ((FLOAT*)theScan->fNativeLine->buf)[i*(COMPLEX_MULTIPLIER*CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm)+(CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm)]);
	for (j=0;j!=CubaBatch;++j) {
	    ((FLOAT*)theScan->fNativeLine->buf)[(i*(COMPLEX_MULTIPLIER*CubaBatch))+j]=
	    ((FLOAT*)theScan->fNativeLine->buf)[(i*(COMPLEX_MULTIPLIER*CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm))];
	}
#ifdef COMPLEX	    
	for (j=0;j!=CubaBatch;++j) {
	    ((FLOAT*)theScan->fNativeLine->buf)[(i*(COMPLEX_MULTIPLIER*CubaBatch))+j+(CubaBatch)]=
	    ((FLOAT*)theScan->fNativeLine->buf)[(i*(COMPLEX_MULTIPLIER*CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm))+(CUDA_BLOCK_SIZE*CUDA_BLOCKS_PER_SM*cuda_sm)];
	}
#endif	    	
      }
    //fprintf(stderr,"Blocks [%d]",maxblocks);


  } //else  fprintf(stderr,"Blocks [%ld]",CUDA_BLOCKS_PER_SM*cuda_sm);


#endif   
   
   
   
cto=theScan->ctTriad.operation+1;
ctoStop=theScan->ctTriad.operation+theScan->ctTriad.free;
ctLastUsing=theScan->ctTriad.lastUsing+1;
ctNotUsed1=theScan->ctTriad.triadType+1;
ctNotUsed2=theScan->ctTriad.refCounter+1;
cta1=theScan->ctTriad.firstOperand+1;
cta2=theScan->ctTriad.secondOperand+1;
myIndex=1;
      

   for(;cto<ctoStop;BUILDTR_INCR_ALL_POINTERS){
     
         // and here we start to built rt triads
     	 ptr3=NULL;
         ptr3N=(FLOAT*)(theScan->nativeTline->buf[(*ctLastUsing)/TLINE_POOL])+(((*ctLastUsing)%TLINE_POOL)*CubaBatch*COMPLEX_MULTIPLIER);
   
	 switch(*cto){   // initializing results inside triads for MPFR
	    case OP_IPOW:
		initIFvar(&(rta->aIF.result));
		pushCell(theScan->allMPvariables,&(rta->aIF.result));
		break;
	    default:
		initIFvar(&(rta->aF.result));
		pushCell(theScan->allMPvariables,&(rta->aF.result));
	  }/*iswitch(*cto)*/
	  SC_INT slot=0;
#ifdef GPU
	  getNativeAddress(myIndex,theScan,&slot);      
	  rtg->resultSlot = slot;      
	  // we obtain the slot of the current triad
	  rtg->secondOperandSlot = 0; 
	  // it might stay empty if the operand is missing
#endif      
	  ptr1=getAddress(*cta1,theScan);
	  ptr1N=getNativeAddress(*cta1,theScan,&slot);            
#ifdef GPU
	  rtg->firstOperandSlot = slot;      
#endif
      
	  /*OP_IPOW requires integer for a second argument:*/
	  if(*cto == OP_IPOW){
	      rta->aIF.firstOperand=ptr1;
	      rta->aIF.secondOperand=*cta2;	  	  
	      rtaN->aIPN.firstOperand=(VFLOAT*)ptr1N;
	      rtaN->aIPN.secondOperand=*cta2;
	      rtaN->aIPN.result=(VFLOAT*)ptr3N;
	  }/*if(*cto == OP_IPOW)*/
	  else{
	 
	    if ((*cto == OP_POW) || (*cto == OP_PLUS) || (*cto == OP_MINUS) || (*cto == OP_MUL) || (*cto == OP_DIV)) {	    
		SC_INT slot=0;
		ptr2=getAddress(*cta2,theScan);
		ptr2N=getNativeAddress(*cta2,theScan,&slot); 	 	    
#ifdef GPU
		rtg->secondOperandSlot = slot;      
#endif	    
	    } else {
	      ptr2 = NULL;
	      ptr2N = NULL;
	    }  
	    // printf("ptr1: %p, ptr1N: %p, ptr2: %p, ptr2N: %p, ptr3: %p, ptr3N: %p\n",ptr1,ptr1N,ptr2,ptr2N,ptr3,ptr3N);

            rta->aF.firstOperand=ptr1;
            rta->aF.secondOperand=ptr2;	      
	    rtaN->aPN.firstOperand=(VFLOAT*)ptr1N;
            rtaN->aPN.secondOperand=(VFLOAT*)ptr2N;
            rtaN->aPN.result=(VFLOAT*)ptr3N;

	  }/*if(*cto == OP_IPOW)...else*/
	  rta++;
	  rtaN++;
#ifdef GPU 
	  rtg++;
#endif    
	  *(rto++)=mkROPlabels(*cto,(void *)ptr3);
	  *(rtoN++)=mkROPlabels(*cto,(void *)ptr3N);      
   }/*for(;cto<ctoStop;BUILDTR_INCR_ALL_POINTERS)*/

   qFLDestroy(&tlineQ);
   

   return 0;
}/*buildRtTriad*/

/*Sets triad fields lastUsing and refCounter*/
static SC_INLINE void markTriad(int op,SC_INT triad,SC_INT op1,SC_INT op2,scan_t *theScan)
{
   /*What about functions?:*/
   while( (op1< - theScan->nx)&&(op1 >= -theScan->nx-theScan->nf) )
      op1=theScan->f[-op1-theScan->nx];

   if(op1>0){
      if(theScan->ctTriad.lastUsing[op1]<triad){
         theScan->ctTriad.lastUsing[op1]=triad;
         (theScan->ctTriad.refCounter[op1])++;
      }
   }/*if(op1>0)*/

   /*Integer power is a special case, do not interprete op2 as a triple:*/
   if(OP_IPOW==op)
      return;

   /*What about functions?:*/
   while( (op2< - theScan->nx)&&(op2 >= -theScan->nx-theScan->nf) )
      op2=theScan->f[-op2-theScan->nx];

   if((op1!=op2)&&(op2>0)){
      if(theScan->ctTriad.lastUsing[op2]<triad){
         theScan->ctTriad.lastUsing[op2]=triad;
         (theScan->ctTriad.refCounter[op2])++;
      }
   }/*if((op1!=op2)&&(op2>0))*/
}/*markTriad*/


static SC_INLINE int addCpyOp(scan_t *theScan)
{
SC_INT op=popInt(theScan->pstack),res;
   /*-1 is a non-optimisible triad type:*/
   res=sCtTriad(OP_CPY,-1,op,op,&theScan->ctTriad);
   addInt(theScan->pstack,res);
   markTriad(OP_CPY,res,op,op,theScan);
   return 0;
}/*addCpyOp*/
      
static SC_INLINE SC_INT checkOp(int op, SC_INT op1, SC_INT op2, scan_t *theScan)
{
SC_INT triad;
SC_INT *s,*c;
   /*Form a new triad:*/
   triad=sCtTriad(op,0,op1,op2,&theScan->ctTriad);
   /*check if there is such a triad in the global scope:*/
   triad=hash_check(triad, &theScan->ctTriad.hashTable);
   theScan->ctTriad.free--;
#ifdef STATISTICS_OUT
   allT--; newT--;
#endif
   if(triad!=0)
      return triad;

   /*No is such a triad in the global scope, look it up in the chain:*/
   s=theScan->allCondChain->buf+theScan->allCondChain->fill;
   c=theScan->allCondChain->buf;
   for(;c<s;c++){
      /*Form a new triad:*/
      triad=sCtTriad(op,*c,op1,op2,&theScan->ctTriad);
      /*check if there is such a triad in the chain:*/
      triad=hash_check(triad, &theScan->ctTriad.hashTable);
      theScan->ctTriad.free--;
#ifdef STATISTICS_OUT
      allT--; newT--;
#endif
      if(triad!=0)/*found*/
         return triad;
   }/*for(;c<s;c++)*/
   /*not found*/
   return 0;
}/*checkOp*/

static SC_INLINE int addOp( int op, scan_t *theScan)
{
   SC_INT op1,op2,triad;
   if( (op > 0 )&&(op<=OP_CPY) ){ /*unary*/
      op1=op2=popInt(theScan->pstack);
   }else{
      op2=popInt(theScan->pstack);
      op1=popInt(theScan->pstack);
   }
   if(op1==0||op2==0){
      parseError("Stack underflow");
      return 1;
   }
#ifdef WITH_OPTIMIZATION
   if(theScan->flags & FL_WITHOPTIMIZATION) {
      if(theScan->allCondChain->fill > 0){/*"if" is active*/
            triad=checkOp(op,op1,op2,theScan);
            if(triad==0)/*not found -- install with the latest chain*/
              triad=tandsCtTriad(op,
                theScan->allCondChain->buf[theScan->allCondChain->fill-1],
                op1,op2,&theScan->ctTriad);            
            /*now triad is not 0*/
      }/*if(theScan->allCondChain->fill > 0)*/
      else
         triad=tandsCtTriad(op,0,op1,op2,&theScan->ctTriad);
   }/*if(theScan->flags & FL_WITHOPTIMIZATION)*/
   else
#endif /*#ifdef WITH_OPTIMIZATION*/
      triad=tandsCtTriad(op,0,op1,op2,&theScan->ctTriad);
   addInt(theScan->pstack,triad);
   markTriad(op,triad,op1,op2,theScan);
   return 0;
}/*addOp*/



/*
   simpleScan() collects terms into an array of the following structure.
   This is the local variable of simpleScan(), and is reset by memset() in 
   the beginning of simpleScan()
*/
typedef struct termStruct_struct{
SC_INT addrr;

SC_INT nTriads;
SC_INT nMul;
SC_INT nDiv;
SC_INT nPow;
SC_INT nLog;
SC_INT nIf;
} termStruct_t;

typedef struct cDiad{
char operation;/* OP_MUL or OP_DIV */
/* 'x' -- just x;
   'X' -- "extra" x obtained after reduction of the power to 1;(not used now)
   'f' -- just f;
   'p' -- power;
   'l' -- log;
   'i' -- if;
   '\0' -- from nested scan;
   'c' -- coefficient: */
char theType;
SC_INT addr;
}cDiad_t;
/*The idea is to sort diads as mentioned, similar diads are sorted
according addr.*/

#define D_X 0
#define D_XX 1
#define D_F 2
#define D_P 3
#define D_L 4
#define D_I 5
#define D_0 6
#define D_C 7


#define MAX_DIADS_IN_CHAIN 32
#define MK_DLINK(D) if(chainRoots[D]==-1)chainRoots[D]=dCounter;\
                    else chainLinks[chainCurrentLink[D]]=dCounter;\
                    chainCurrentLink[D]=dCounter;\
                    chainLinks[dCounter]=-1


static SC_INLINE int processDiadChain(
                                       int *nDiadChains, 
                                       char *from,
                                       char *links,
                                       cDiad_t *diad,
                                       scan_t *theScan)
{
   if(*from < 0 )
      return 0;
   if(*nDiadChains==0){
      /*if nDiadChains==0, then the first operation may be '/'. This is very rare situation, 
        so we just add 1 to the stack, if so.*/
      if(diad[*from].operation == OP_DIV){
         addInt(theScan->pstack,MK_FLOAT(1));/*First operation is '/'*/
      }/*if(diad[*from].operation == OP_DIV)*/
      else{
         addInt(theScan->pstack,diad[*from].addr);
         *from=links[*from];
      }
      *nDiadChains=1;
   }/*if(*nDiadChains==0)*/
   while(*from >= 0){
      addInt(theScan->pstack,diad[*from].addr);
      if( addOp(diad[*from].operation,theScan) )
         return 1;
      *from=links[*from];
   }/*while(*from >= 0)*/
   return 0;
}/*processDiadChain*/

static SC_INLINE int processDiads(
                         int nDiadChains,
                         cDiad_t *diad,
                         char *chainRoots,
                         char *chainLinks,
                         scan_t *theScan)
{
   if(processDiadChain(&nDiadChains,chainRoots+D_X,chainLinks,diad,theScan))
       return 1;
   if(processDiadChain(&nDiadChains,chainRoots+D_C,chainLinks,diad,theScan))
       return 1;
   if(processDiadChain(&nDiadChains,chainRoots+D_F,chainLinks,diad,theScan))
       return 1;
   if(processDiadChain(&nDiadChains,chainRoots+D_P,chainLinks,diad,theScan))
       return 1;
   if(processDiadChain(&nDiadChains,chainRoots+D_L,chainLinks,diad,theScan))
       return 1;
   if(processDiadChain(&nDiadChains,chainRoots+D_I,chainLinks,diad,theScan))
       return 1;
   if(processDiadChain(&nDiadChains,chainRoots+D_0,chainLinks,diad,theScan))
       return 1;
   return 0;
}/*processDiads*/





static SC_INLINE char *evaluateString(char *str)
{

  FILE *fp = popen(str, "r");

  char*  buf=buffer_from_mathematica;

  while (fgets(buf, 1024, fp)) {
    buf+=1024;
  }

  pclose(fp);

  if (strlen(buffer_from_mathematica)==0) 
      return NULL;
  else 
      return buffer_from_mathematica;
}/*evaluateString*/


static SC_INLINE int pushConst(char *str,int invAlso,scan_t *theScan)
{
SC_INT tmp=mpoolAdd(str,&(theScan->newConstantsPool),strlen(str)+1);
   if(tmp<0)
      return -1;
   addInt(theScan->constStrings, tmp);
   if(invAlso)
      addInt(theScan->constStrings,-1);
   return 0;
}/*pushConst*/

static SC_INLINE SC_INT installConstant(char *str,char *val,scan_t *theScan)
{
SC_INT cpos;
char *p;
FLOAT r=strtod(val,&p);

   if(p==NULL)
      return -1;
   if(*p!='\0')
      if(*p!='\n')
         return -1;

   cpos=theScan->fNativeLine->fill;
   addNativeFloat(theScan->fNativeLine,r);
   addNativeFloat(theScan->fNativeLine,1.0l/r);
   if( pushConst(val,1,theScan)<0 )
      return -1;

   installTrie(str,&cpos,&(theScan->newConstantsTrie));
   return cpos;
}/*installConstant*/

static SC_INLINE SC_INT evaluateConstant(char *str,scan_t *theScan)
{
char *theAnswer;
SC_INT cpos=checkTrie(str,&(theScan->newConstantsTrie));
   if((cpos<0) && (math_binary!=NULL)) {
      char buf[256];
      sprintf(buf,"echo \"N[%s,4096]\" | %s -noprompt 2>/dev/null | cut -f1 -d\"\\`\" | sed \':a;N;$!ba;s/\\n//g\'",str,math_binary);
      theAnswer=evaluateString(buf);   
      if(theAnswer==NULL){
         halt(16," Can't evaluate '%s'\n",buf);
         return -1;
      }
      cpos=installConstant(str,theAnswer,theScan);
      if(cpos<0)
         return -1;
      //free(theAnswer);
   }
   return cpos;
}/*evaluateConstant*/

/*Returns the position in fline or -1 on error. If val==NULL, assumes that val = str. If invAlso!=0,
  stores also the inverse value to the next after cpos cell:*/
static SC_INLINE SC_INT tAndSConst(char *str,char *val,int invAlso,scan_t *theScan)
{
SC_INT cpos;
char *p;
FLOAT r;

   cpos=checkTrie(str,&(theScan->newConstantsTrie));
   if(cpos>=0)
      return cpos; /*found*/

   if(val==NULL)
      val=str;

   r=strtod(val,&p);

   if(p==NULL)
      return -1;
   if(*p!='\0')
      if(*p!='\n')
         return -1;
   cpos=theScan->fNativeLine->fill;
   addNativeFloat(theScan->fNativeLine,r);
   if(invAlso)
      addNativeFloat(theScan->fNativeLine,1.0l/r);
   if( pushConst(val,invAlso,theScan)<0 )
      return -1;
   installTrie(str,&cpos,&(theScan->newConstantsTrie));
   return cpos;
}/*tAndSConst*/

static SC_INLINE char scanPolyGamma(scan_t *theScan)
{
   char c,*id=ID_CONST_POLYGAMMA;
   char polyGamma[128];
   int i,l=strlen(id);
   SC_INT cpos=-1;

   /*If ID_CONST_POLYGAMMA == "PolyGamma" then "Pol" is scanned, now scan "yGamma":*/
   for(i=3;i<l;i++){
      c=nextChar(theScan);
      if(c != id[i]){
         halt(16,"Parse error: %c expected instead of %c\n",id[i],c);
         return'\0';
      }
   }/*for(i=1;i<l;i++)*/
   i=l=0;
   if(nextChar(theScan)!=O_B){parseError("'"O_B_S"' expected");return '\0';}
   if(parseInt(&i,theScan)!=','){parseError("',' expected");return '\0';}
   c=parseInt(&l,theScan);
   if (c=='/') {
	int l2=0;
	if(parseInt(&l2,theScan)!=C_B){parseError("'"C_B_S"' expected");return '\0';}
	sprintf(polyGamma,"PolyGamma[%d,%d/%d]",i,l,l2);
	cpos=evaluateConstant(polyGamma,theScan);
   } 
	else
   {


   	if(c!=C_B){parseError("'"C_B_S"' expected");return '\0';}
	   /*now in i and l we have a weight*/

	   sprintf(polyGamma,"PolyGamma[%d,%d]",i,l);

	   if( (i==1)&&(l==1) )
	      cpos=tAndSConst(polyGamma,STR_CONST_POLYGAMMA1_1,1,theScan);
	   else if( (i==2)&&(l==1) )
	      cpos=tAndSConst(polyGamma,STR_CONST_POLYGAMMA2_1,1,theScan);
	   else if( (i==2)&&(l==2) )
	      cpos=tAndSConst(polyGamma,STR_CONST_POLYGAMMA2_2,1,theScan);
	   else if( (i==2)&&(l==3) )
	      cpos=tAndSConst(polyGamma,STR_CONST_POLYGAMMA2_3,1,theScan);
	   else if( (i==2)&&(l==4) )
	      cpos=tAndSConst(polyGamma,STR_CONST_POLYGAMMA2_4,1,theScan);
	   else if( (i==3)&&(l==1) )
	      cpos=tAndSConst(polyGamma,STR_CONST_POLYGAMMA3_1,1,theScan);
	   else if( (i==3)&&(l==2) )
	      cpos=tAndSConst(polyGamma,STR_CONST_POLYGAMMA3_2,1,theScan);
	   else
	      cpos=evaluateConstant(polyGamma,theScan);
	}
   if(cpos<0){
      halt(16,"Parse error: can't evaluate %s\n",polyGamma);
      return '\0';
   }

   addInt(theScan->pstack,MK_FLOAT(cpos));
   return nextChar(theScan);
}/*scanPolyGamma*/

/*
   simpleScan() collects terms into the 'termStruct' with the corresponding 
   prefix operations in 'operation':
*/
static SC_INLINE char scanTerm(int iniOp,
                               termStruct_t *termStruct, 
                               char *operation,
                               scan_t *theScan)
{
   cDiad_t diad[MAX_DIADS_IN_CHAIN];
   char chainRoots[8];/*indexes of diad for the first 'x',..., or -1 if absent*/
   char chainCurrentLink[8];/*the last link, or -1*/
   char chainLinks[MAX_DIADS_IN_CHAIN];/*index of the next element, or -1 if no.*/
   int dCounter=0;
   int nDiadChains=0;
   char c;
   int n;
      diad[0].operation=OP_MUL;
      memset(chainRoots,-1,8);
      memset(chainCurrentLink,-1,8);
      /*No reasons to initialize chainLinks*/
      for(;;){
         c=nextChar(theScan);
         if(c=='\\'){                    /*ignoring "\\012" for backward compatibility*/
            if( (nextChar(theScan)!='0')||
                (nextChar(theScan)!='1')||
                (nextChar(theScan)!='2')
              ){ 
                  parseError("Unexpected '\\'");
                  return '\0';
               }
              c=nextChar(theScan);
         }/*if(c=='\\')*/

         /*The operand:*/
         diad[dCounter].theType='\0';
         switch(c){
            case '-':
              *operation=OP_MINUS;
              /*no break*/
            case '+':/*ignore leading '+':*/
              continue;
            case '(':
              if(simpleScan(0,theScan)<0)
                 return '\0';
              MK_DLINK(D_0);
              c=nextChar(theScan);
              break;
            case 'L':
              if(nextChar(theScan)!='o'){parseError("'o' expected");return '\0';}
              if(nextChar(theScan)!='g'){parseError("'g' expected");return '\0';}
            case 'l':
              if(nextChar(theScan)!=O_B){
                 parseError("'"O_B_S"' expected");
                 return '\0';
              }
              if(simpleScan(OP_LOG,theScan)<0)
                 return '\0';
              diad[dCounter].theType='l';
              MK_DLINK(D_L);
              termStruct->nLog++;
              c=nextChar(theScan);
              break;
            case 'f':
            case 'x':
              if(nextChar(theScan)!=O_B){
                 parseError("'"O_B_S"' expected");
                 return '\0';
              }
              n=0;
              if(parseInt(&n,theScan)!=C_B){
                 parseError("'"C_B_S"' expected");
                 return '\0';
              }
              /*Attention! The case x() will be treated as x[0]!*/
              if(c=='x'){
                 addInt(theScan->pstack,MK_X(n));
                 diad[dCounter].theType='x';
                 MK_DLINK(D_X);
              }else{
                 addInt(theScan->pstack,MK_F(n));
                 diad[dCounter].theType='f';
                 MK_DLINK(D_F);
              }
              c=nextChar(theScan);
              break;
	    case 'G': {
                 SC_INT cpos=tAndSConst("G",STR_CONST_EulerGamma,1,theScan);
                 if(cpos<0){
                    parseError("Can't evaluate EulerGamma");
                    return '\0';
                 }
                 diad[dCounter].theType='c';
                 MK_DLINK(D_C);
                 addInt(theScan->pstack,MK_FLOAT(cpos));
	              c=nextChar(theScan);
                 break;
		}
#ifdef COMPLEX		
	    case 'I': {  // that's I, complex identity
		 SC_INT cpos;
		 cpos=checkTrie("I",&(theScan->newConstantsTrie));
		 if(cpos<0) {	
		    cpos=theScan->fNativeLine->fill;
		    if(theScan->fNativeLine->fill >= theScan->fNativeLine->top) reallocCollectNativeFloat(theScan->fNativeLine);
		    int j;
		    for (j=0;j!=CubaBatch;++j) {
		         ((FLOAT*)theScan->fNativeLine->buf)[theScan->fNativeLine->fill*2*CubaBatch+j]=0;   
			 ((FLOAT*)theScan->fNativeLine->buf)[theScan->fNativeLine->fill*2*CubaBatch+j+CubaBatch]=1;	
		    }
		    theScan->fNativeLine->fill++;
		     if(pushConst("I",0,theScan)>=0 ) // success
			installTrie("I",&cpos,&(theScan->newConstantsTrie));		
		 }
                 if(cpos<0){
                    parseError("Can't initialize I");
                    return '\0';
                 }
                 diad[dCounter].theType='c';
                 MK_DLINK(D_C);
                 addInt(theScan->pstack,MK_FLOAT(cpos));
	              c=nextChar(theScan);
                 break;
		}
#endif
            case 'P':
              /*Either P, or PolyGamma, or Power*/
              c=nextChar(theScan);
              if(c=='o'){
                 c=nextChar(theScan);
                 if(c=='w'){
                    if(nextChar(theScan)!='e'){parseError("'er[' expected");return '\0';}
                    if(nextChar(theScan)!='r'){parseError("'r[' expected");return '\0';}

                    case 'p':
                       if(nextChar(theScan)!=O_B){
                          parseError("'"O_B_S"' expected");
                          return '\0';
                       }

                       if(simpleScan(OP_POW,theScan)<0)
                          return '\0';

                       diad[dCounter].theType='p';
                       MK_DLINK(D_P);

                        termStruct->nPow++;
                        c=nextChar(theScan);
                        break;
                 }/*if(c=='w')*/
                 else if(c == ID_CONST_POLYGAMMA[2]){
                    /*"PolyGamma", see a macros *_CONST_POLYGAMMA* 
                       in the file constants.h*/
                    diad[dCounter].theType='c';
                    MK_DLINK(D_C);
                    c=scanPolyGamma(theScan);
                    if(c=='\0')
                       return '\0';
                    break;
                 }/*else if(c == ID_CONST_POLYGAMMA[3])*/
              }/*if(c=='o')*/
              else{/*"pi", see a macros *_CONST_PI in the file constants.h*/
                 SC_INT cpos=tAndSConst("Pi",STR_CONST_PI,1,theScan);
                 if(cpos<0){
                    parseError("Can't evaluate Pi");
                    return '\0';
                 }
                 diad[dCounter].theType='c';
                 MK_DLINK(D_C);
                 addInt(theScan->pstack,MK_FLOAT(cpos));
                 break;
              }/*if(c=='o')...else*/
              parseError("'P','Power' or 'PolyGamma' expected");
              return '\0';
            case '0':case '1':case '2':case '3':case '4':
            case '5':case '6':case '7':case '8':case '9':
              diad[dCounter].theType='c';
              MK_DLINK(D_C);
              {/*Block*/
                 char *ptrC,constBuf[CONST_BUF];
                 SC_INT cpos;
                 constBuf[0]=c;
                 ptrC=parseConst(constBuf+1,CONST_BUF-2,theScan);
                 if(ptrC == NULL)
                    return '\0';
                 c=*ptrC;
                 if(c=='.'){
                    ptrC=parseConst(ptrC+1,CONST_BUF-(ptrC-constBuf)-2,theScan);
                    if(ptrC == NULL)
                       return '\0';
                    c=*ptrC;
                 }
                 if(c=='*'){
		    char c2=nextChar(theScan);
		    if (c2=='^') { // the way Mathamatica sends exponent
		        *ptrC='E';
		        char c3=nextChar(theScan);
			ptrC++;
			*ptrC=c3; // there should be at least one symbol after *^ and we have to use it to catch the -			
			ptrC=parseConst(ptrC+1,CONST_BUF-(ptrC-constBuf)-2,theScan);
			if(ptrC == NULL)
			  return '\0';
			c=*ptrC;
		    } else {  // no, that was just a multiplication
		      (theScan->theChar)--; 
		    }
		 }  
                 *ptrC='\0';/*Now in constBuf[] we have the string*/
                 /*Now if isFloat!=0 then it is a floating point const.
                   Also if l>8 we couldn't use integers for native arithmetics.*/
                 cpos=tAndSConst(constBuf,NULL,1,theScan);
                 if(cpos<0){
                    halt(16,"Parse error: can't convert %s to number\n",constBuf);
                    return '\0';
                 }/*if(cpos<0)*/
// ?????                 
/*#ifndef MIXED_ARITHMETIC*/
/*Problems with increasing precision for inverse constants.
  Switch off for non-native arithmetics.*/

                 /*Replace division by multiplication:*/
                 if(diad[dCounter].operation == OP_DIV){
                    diad[dCounter].operation = OP_MUL;
                    addInt(theScan->pstack,MK_FLOAT(cpos+1));
                 }
                 else
/*#endif*/
                    addInt(theScan->pstack,MK_FLOAT(cpos));
              }/*Block*/
              break;
            default:
                 halt(16,"Parse error: unexpected %c\n",c);
                 return '\0';
         }/*switch(c)*/
         diad[dCounter].addr=popInt(theScan->pstack);
         dCounter++;
         if(dCounter >= MAX_DIADS_IN_CHAIN){
            if(processDiads(
                    nDiadChains,
                    diad,
                    chainRoots,
                    chainLinks,
                    theScan)
              )
               return '\0';
            nDiadChains++;
            dCounter=0;
         }

         /*The operation:*/
         switch(c){
            case '*':
               diad[dCounter].operation=OP_MUL;
               termStruct->nMul++;
               break;
            case '/':
               diad[dCounter].operation=OP_DIV;
               termStruct->nDiv++;
               break;
            case ',':
               if( iniOp!= OP_POW ){
                  parseError("Unexpected ','");
                  return '\0';
               }
               /*No break!*/
            case '+':
            case '-':
            case ')':
            case ']':
            case ';':

               if(processDiads(
                    nDiadChains,
                    diad,
                    chainRoots,
                    chainLinks,
                    theScan)
                 )
                  return '\0';
               nDiadChains++;
               dCounter=0;
               return c;
            default:
              halt(16,"Parse error: unexpected %c\n",c);
              return '\0';
         }/*switch(c)*/
      }/*for(;;)*/
}/*scanTerm*/

/*if xVar>0, this is the power of bare x[xVar]:*/
static SC_INLINE char processPower(SC_INT xVar,scan_t *theScan)
{
char c;
int n,neg=0;
   do{
      c=nextChar(theScan);
      switch(c){
            case '-':
               neg=-1;
               break;
            case '0':case '1':case '2':case '3':case '4':
            case '5':case '6':case '7':case '8':case '9':              
              n=c-'0';/*first char is scanned already!*/
              c=parseInt(&n,theScan);
              if(c == '.'){
                 int n2=0;
                 int e;
                 c=parseInt2(&e,&n2,theScan);
                 if(n2!=0){/*Fractional part present*/
                    FLOAT r=(FLOAT)n+((FLOAT)n2)/e;
                    if(neg<0)
                       r*=-1.0;

                    addInt(theScan->pstack,MK_FLOAT(theScan->fNativeLine->fill));
	            addNativeFloat(theScan->fNativeLine,r);
                    addNativeFloat(theScan->fNativeLine,1.0l/r);
                    {/*Block*/
                       char buf[MAX_FLOAT_LENGTH];
                       if(neg<0) sprintf(buf,"-%d.%d",n,n2); else sprintf(buf,"%d.%d",n,n2);
                       if(pushConst(buf,1,theScan))
                          return '\0';
                    }/*Block*/

                 if((xVar>0) && (r<0)){
                    if (theScan->maxX[xVar] == 0)
                        theScan->maxX[0]++;
                    if (theScan->maxX[xVar] < ceil(-r))
                        theScan->maxX[xVar]= ceil(-r);
                 }/*if(xVar>0)*/
                    if(addOp(OP_POW ,theScan))
                       return 0;
                    return c;
                 }/*if(n2!=0)*/
              }/*if(c == '.')*/

              if(c == '/'){
                 int n2=0;
                 int e;
                 c=parseInt2(&e,&n2,theScan);
                 if(n2!=0){/*Fractional part present*/
                    FLOAT r=(FLOAT)n/(FLOAT)n2;
                    if(neg<0)
                       r*=-1.0;

                    addInt(theScan->pstack,MK_FLOAT(theScan->fNativeLine->fill));
	            addNativeFloat(theScan->fNativeLine,r);
                    addNativeFloat(theScan->fNativeLine,1.0l/r);
                    {/*Block*/
                       char buf[MAX_FLOAT_LENGTH];
                       if(neg<0) sprintf(buf,"-%d/%d",n,n2); else sprintf(buf,"%d/%d",n,n2);
//sprintf(buf,"2.5");
		//	evaluateConstant(buf,theScan);
                       if(pushConst(buf,1,theScan))
                          return '\0';
                    }/*Block*/

                 if((xVar>0) && (r<0)){
                    if (theScan->maxX[xVar] == 0)
                        theScan->maxX[0]++;
                    if (theScan->maxX[xVar] < ceil(-r))
                        theScan->maxX[xVar]= ceil(-r);
                 }/*if(xVar>0)*/

                    if(addOp(OP_POW ,theScan))
                       return 0;
                    return c;
                 }/*if(n2!=0)*/
              }/*if(c == '.')*/


              /*Integer power!*/
              if(n==0){
                 /*a^0=1, so pop one element and put 1:*/
                 popInt(theScan->pstack);
                 addInt(theScan->pstack,MK_FLOAT(1));                 
              }else if (n>1){
                switch(n){
                   case OP_IPOW2:
                      if(addOp(OP_IPOW2 ,theScan))
                         return 0;
                      break;
                   case OP_IPOW3:
                      if(addOp(OP_IPOW3 ,theScan))
                         return 0;
                      break;
                   case OP_IPOW4:
                      if(addOp(OP_IPOW4 ,theScan))
                         return 0;
                      break;
                   case OP_IPOW5:
                      if(addOp(OP_IPOW5 ,theScan))
                         return 0;
                      break;
                   case OP_IPOW6:
                      if(addOp(OP_IPOW6 ,theScan))
                         return 0;
                      break;
                   default: 
                      addInt(theScan->pstack,n);
                      if(addOp(OP_IPOW ,theScan))
                         return 0;
                }/*switch(n)*/
              }/*if (n>1)*/
              if(neg<0){
                 if(addOp(OP_INV ,theScan))
                     return 0;
                 if(xVar>0){
                    if (theScan->maxX[xVar] == 0)
                        theScan->maxX[0]++;
                    if (theScan->maxX[xVar] < n)
                        theScan->maxX[xVar]= n;
                 }/*if(xVar>0)*/
              }/*if(neg<0)*/
              return c;
      }/*switch(c)*/
   }while(neg<0);
   return c;
}/*processPower*/


static SC_INLINE int cmpTerms(termStruct_t *term1,termStruct_t *term2)
{
   return (
      (term1->nTriads == term2->nTriads)&&
      (term1->nMul == term2->nMul)&&
      (term1->nDiv == term2->nDiv)&&
      (term1->nPow == term2->nPow)&&
      (term1->nLog == term2->nLog)&&
      (term1->nIf == term2->nIf)
   ); 
}/*cmpTerms*/

static SC_INLINE void couplePairs(size_t memStack,scan_t *theScan)
{
   if(theScan->pstack->fill == memStack+1){
      addOp(OP_PLUS,theScan);
      return;
   }
   if(theScan->pstack->fill == memStack+2){
      addOp(OP_PLUS,theScan);
      addOp(OP_PLUS,theScan);
      return;
   }
   /**/
   {
      SC_INT mem=popInt(theScan->pstack);
         addOp(OP_PLUS,theScan);
         couplePairs(memStack,theScan);  
         addInt(theScan->pstack,mem);
         addOp(OP_PLUS,theScan);
   }
}/*couplePairs*/

/*
  Initial state: one term in the stack.Final state: one term in the stack:
 */
static SC_INLINE int processSameTerms(int i,
                                      termStruct_t *term, 
                                      char *operations, 
                                      int termCounter,
                                      scan_t *theScan)
{
   size_t memStack=theScan->pstack->fill;
   char lastOp='\0';
   SC_INT lastAddrr=0;
   termStruct_t *cterm=term+i;
   char *coperation=operations+i;
   for(;;){
      for(i++;i<termCounter;i++)if( (term[i].addrr!=0) &&(cmpTerms(cterm,term+i)) )
            break;
      if(i==termCounter){/*non-paired term*/
         lastAddrr=cterm->addrr;
         cterm->addrr=0;
         lastOp=*coperation;
         break;
      }/*if(i==termCounter)*/
      /*Now cterm and term+i is a pair.*/
      if(*coperation==OP_MINUS){
         if(operations[i]==OP_MINUS)
            operations[i]=OP_PLUS;
         else
            operations[i]=OP_MINUS;
         addInt(theScan->pstack,cterm->addrr);
         addInt(theScan->pstack,term[i].addrr);
         addOp(operations[i],theScan);
         addOp(*coperation,theScan);
      }else{/* *coperation==OP_PLUS */
         addInt(theScan->pstack,cterm->addrr);
         addInt(theScan->pstack,term[i].addrr);
         addOp(operations[i],theScan);/*now the result is in the stack*/
         /* *coperation is OP_PLUS, we know!*/
      }/*if(coperation==OP_MINUS)*/
      cterm->addrr=0;
      term[i].addrr=0;

      /*Try to find next element:*/
      for(i++;i<termCounter;i++)if( (term[i].addrr!=0) &&(cmpTerms(cterm,term+i)) )
            break;
      if(i==termCounter)/*not found*/
         break;
      /*Process the rest of the chain:*/
      cterm=term+i;
      coperation=operations+i;
   }/*for(;;)*/
   /*Now in the stack may be several operand all with positve coefficients.*/
   if(memStack != theScan->pstack->fill)
      couplePairs(memStack,theScan);
   if(lastOp!='\0'){
      addInt(theScan->pstack,lastAddrr);
      addOp(lastOp,theScan);
   }
   return 0;
}/*processSameTerms*/

/*
  Initial state: no terms in the stack.The first operation must be OP_PLUS.
  Final state: one term in the stack:
 */
static SC_INLINE int addSameTerms(int i,
                                      termStruct_t *term,
                                      char *operations,
                                      int termCounter,
                                      scan_t *theScan)
{
termStruct_t *cterm=term+i;
   for(i++;i<termCounter;i++)
      if(cmpTerms(cterm,term+i))
         break;
   if(i==termCounter){/*Only one such a term, just add it to the stack:*/
      addInt(theScan->pstack,cterm->addrr);
      cterm->addrr=0;
      return 0;
   }/*if(i==termCounter)*/
   /*At least one pair*/
   addInt(theScan->pstack,cterm->addrr);
   addInt(theScan->pstack,term[i].addrr);
   addOp(operations[i],theScan);/*No reason for the error checking*/
   /*Need not term->addrr anymore, mark as used:*/
   cterm->addrr=0;
   term[i].addrr=0;
   for(i++;i<termCounter;i++)
      if(cmpTerms(cterm,term+i))
         break;
   if(i==termCounter)/*There are no more such terms*/
      return 0;
   /*There are other terms in a chain -- normal process:*/
   return processSameTerms(i,term,operations,termCounter,theScan);
}/*addSameTerms*/

static SC_INLINE int processTermsChain(termStruct_t *term, 
                                       char *operations,
                                       int termCounter,
                                       size_t memStack,
                                       scan_t *theScan)
{
   SC_INT i;
   switch(termCounter){
      case 0:
         return 0;
      case 1:
         if(memStack!=theScan->pstack->fill){/*continuation!*/
            /*The stack contains somethnig from the previous buffer,
              add the current term:*/
            addInt(theScan->pstack,term->addrr);
            addOp(*operations,theScan);
         }else{/*just put to the stack*/
            addInt(theScan->pstack,term->addrr);
            if(*operations == OP_MINUS)
               addOp(OP_NEG,theScan);
         }
         return 0;
      case 2:
         if(memStack==theScan->pstack->fill){
            /*The only result from the expression*/
            addInt(theScan->pstack,term->addrr);
            if(*operations == OP_MINUS)
               addOp(OP_NEG,theScan);         
            addInt(theScan->pstack,term[1].addrr);
            addOp(operations[1],theScan);/*No reason for the error checking*/
         }else{
            /*The stack contains somethnig from the previous buffer,
              perform binary operation and add the result to the stack:*/
            addInt(theScan->pstack,term->addrr);
            if(*operations==OP_MINUS){
               if(operations[1]==OP_MINUS)
                  operations[1]=OP_PLUS;
               else
                  operations[1]=OP_MINUS;
            }/*if(coperation==OP_MINUS)*/
            addInt(theScan->pstack,term[1].addrr);
            addOp(operations[1],theScan);/*No reason for the error checking*/
            addOp(*operations,theScan);/*No reason for the error checking*/
         }
         return 0;
      default:
         break;
   }/*switch(termCounter)*/

   if(memStack==theScan->pstack->fill){
      /*Stack is empty, there may be a problem with negative terms,
        so we try to find a group with leading positive term:*/
      for(i=0; i<termCounter;i++)
         if( (operations[i]==OP_PLUS)&&(term[i].nIf==0) )
            break;
      if(i<termCounter)/*there is at least one term with a positive coefficient*/
         addSameTerms(i,term, operations,termCounter,theScan);
      else /*all terms are negative, put 0 into the stack*/
         addInt(theScan->pstack,MK_FLOAT(0));
   }/*if(memStack==theScan->pstack->fill)*/

   /*Now we have something in the stack.*/

   for(i=0; i<termCounter;i++)if( (term[i].addrr!=0)&&(term[i].nIf==0) )
      processSameTerms(i,term, operations,termCounter,theScan);

   for(i=0; i<termCounter;i++)if(term[i].addrr!=0)
      processSameTerms(i,term, operations,termCounter,theScan);

   return 0;
}/*processTermsChain*/

/*
   simpleScan collects terms  into the array term, with the corresponding prefix operations 
   in the array operations. Each time the term chain become longer than MAX_TERMS_IN_CHAIN,
   it builds triads.
   Returns number of processed terms but not bigger than MAX_TERMS_IN_CHAIN.
   The point is that we need this value only to distinguish single term and many terms
   and try to avoid integer overflow.
*/
#define MAX_TERMS_IN_CHAIN 1024
static SC_INLINE int simpleScan(int iniOp, scan_t *theScan)
{
char c='\0';
termStruct_t term[MAX_TERMS_IN_CHAIN];
char operations[MAX_TERMS_IN_CHAIN];
int termCounter=0,wasChainProcessed=0;
size_t memStack=theScan->pstack->fill;
      operations[0]=OP_PLUS;
      while(c!='q'){
         memset(term+termCounter,0,sizeof(termStruct_t));
         c=scanTerm(iniOp,term+termCounter,operations+termCounter,theScan);
         if(c=='\0')
            return -1;
         term[termCounter].addrr=popInt(theScan->pstack);
         termCounter++;

         if(termCounter>=MAX_TERMS_IN_CHAIN){
            processTermsChain(term,operations,termCounter,memStack,theScan);
            termCounter=0;wasChainProcessed=1;
         }
         switch(c){
            case ',':/*p(... , */
               processTermsChain(term,operations,termCounter,memStack,theScan);
               if(wasChainProcessed || termCounter!=1 )
                  c=processPower(0,theScan);
               else{
                  SC_INT xVar=-term[0].addrr;
                  if( (xVar < 1)|| (xVar > theScan->nx) )
                     xVar=0;
                  c=processPower(xVar,theScan);
               }
               if(c!=C_B){
                  if(c!='\0')
                     parseError("'"C_B_S"' expected");
                  return -1;
               }
               return (wasChainProcessed)?MAX_TERMS_IN_CHAIN:termCounter;
            case '-':
              operations[termCounter]=OP_MINUS;
              break;
            case '+':
              operations[termCounter]=OP_PLUS;
              break;
            case ')':
            case ']':
            case ';':      
               c='q';/*Quit from the while()*/
              break;
            default:
              halt(16,"Parse error: unexpected %c\n",c);
              return -1;
         }/*switch(c)*/
      }/*while(c!='q')*/

      processTermsChain(term,operations,termCounter,memStack,theScan);
      if(iniOp == OP_LOG )
         if(addOp(OP_LOG,theScan))
            return -1;
      return (wasChainProcessed)?MAX_TERMS_IN_CHAIN:termCounter;
}/*simpleScan*/

static SC_INLINE int intlog2(FLOAT x){return ceil(log(x)*1.44269504088896l);}

static SC_INLINE int getPrecision(scan_t *theScan)
{
int i;
FLOAT prod=1.0;
   if(theScan->maxX[0]>0){
      for(i=1;i<theScan->nx; i++){
         if(theScan->maxX[i]>0) prod*=ipow(g_mpsmallX,theScan->maxX[i]);
      }
   }
   if(prod>g_mpthreshold)
      prod=g_mpthreshold/2.0;

   if(prod<ABS_MONOM_MIN)
      prod=ABS_MONOM_MIN;/*To avoid overflow*/

   if(g_mpminChanged==0)
      g_mpmin=prod;/*else -- user defined*/
   return intlog2(1.0/prod)+g_mpPrecisionShift;
}/*getPrecision*/

int masterScan(scan_t *theScan)
{
int nx=0,nf=0,i;
char c;

   
   switch(c=nextChar(theScan)){
            case '\\':/*Mathematica60 bug: it sends "\\012" instead of '\n'*/
               if( (nextChar(theScan)!='0')||
                   (nextChar(theScan)!='1')||
                   (nextChar(theScan)!='2')
                 ){
                    parseError("Unexpected '\\'");
                    return 1;
               }
                 c=nextChar(theScan);
                 if( (c<'0')||(c>'9') ){
                    parseError("Number expected");
                    return 1;
                 }
            case '0':case '1':case '2':case '3':case '4':
            case '5':case '6':case '7':case '8':case '9':
              nx=c-'0';/*first char is scanned already!*/
              if(parseInt(&nx,theScan)==';')
                 break;
            default:                 
                 halt(16,"Parse error: number of x with ; expected instead of %c\n",c);
                 return 1;
   }/*switch(c)*/
   nx++;/*f counted from 1, not 0!*/
   switch(c=nextChar(theScan)){
            case '\\':/*Mathematica60 bug: it sends "\\012" instead of '\n'*/
               if( (nextChar(theScan)!='0')||
                   (nextChar(theScan)!='1')||
                   (nextChar(theScan)!='2')
                 ){
                    parseError("Unexpected '\\'");
                    return 1;
               }
                 c=nextChar(theScan);
                 if( (c<'0')||(c>'9') ){
                    parseError("Number expected");
                    return 1;
                 }
            case '0':case '1':case '2':case '3':case '4':
            case '5':case '6':case '7':case '8':case '9':
              nf=c-'0';/*first char is scanned already!*/
              if(parseInt(&nf,theScan)==';')
                 break;
            default:                 
                 halt(16,"Parse error: number of f with ; expected instead of %c\n",c);
                 return 1;
   }/*switch(c)*/
   nf++;/*f counted from 1, not 0!*/

   theScan->maxX=malloc(sizeof(SC_INT)*(nx+1));
   memset(theScan->maxX,0,sizeof(SC_INT)*(nx+1));

   theScan->nx=nx;
   theScan->nf=nf;

   ctTriadInit(estimateHashSize(theScan),&theScan->ctTriad);

   theScan->x_local = malloc(sizeof(FLOAT)*theScan->nx);
   theScan->x_local2 = malloc(sizeof(FLOAT)*theScan->nx);
   theScan->answer_position = malloc(sizeof(int)*CubaBatch); // positions of answers from the native bunch
   theScan->answer = malloc(sizeof(FLOAT)*CubaBatch*COMPLEX_MULTIPLIER); // answers for batch
   
   
   theScan->fNativeLine=initCollectNativeFloat(INIT_FLOAT_SIZE, NULL);
   theScan->constStrings=initCollectInt(NULL);
   initMPool(&(theScan->newConstantsPool),1024);
   theScan->allMPvariables=initCollect(NULL);

   if(initTrie(&(theScan->newConstantsTrie))<0)
      halt(-20,"initTrie failed -- not enough memory?");

   /*0 and 1 are pre-set:*/
   tAndSConst("0",NULL,0,theScan);
   /*also 1/1 since we replace / by *: for case ##/1*/
   tAndSConst("1",NULL,1,theScan);

   theScan->pstack=initCollectInt(NULL);

   theScan->condChain=initCollectInt(NULL);
   addInt(theScan->condChain,0);/*First element will be used as a buffer length*/

   theScan->allCondChain=initCollectInt(NULL);

   theScan->allocatedCondChains=initCollect(NULL);
   pushCell(theScan->allocatedCondChains,NULL);
   /*indexes must be counted from 1! 0 is a NULL pointer*/

   theScan->f=malloc(theScan->nf * sizeof(SC_INT));

   if(theScan->f==NULL)
      halt(-10,"malloc failed");

   /*Scan all f first:*/
   for(i=1;i<nf;i++){
      if(simpleScan(0,theScan)<0)
         return 1;/*Failure*/
      /*Store result and remove it from the stack:*/
      theScan->f[i]=popInt(theScan->pstack);
   }/*for(i=1;i<nf;i++)*/
   if (simpleScan(0,theScan)<0)
      return 1;/*Failure*/
   if(theScan->ctTriad.free - 1 != theScan->pstack->buf[theScan->pstack->fill-1] )
   /*Last triad is not the resulting one (e.g., first "if", or pure number)*/
      addCpyOp(theScan);
      
   // last operation is always CPY   
   //addCpyOp(theScan);   
      
      
   /*Now convert ctTrian into rtTriad:*/
   hash_destroy(&(theScan->ctTriad.hashTable));

   i=getPrecision(theScan);
   if (g_default_precisionChanged == 0)
      g_default_precision=i;

   mpfr_set_default_prec(g_default_precision);

   //printf("!!!%d\n",theScan->fNativeLine->fill);
   
   theScan->fline=initCollectFloat(theScan->fNativeLine->fill, NULL);

   addInt(theScan->constStrings,0);/*To be on the safe side*/

  // printf("%d %d %d\n",theScan->fNativeLine->fill,theScan->constStrings->fill,theScan->newConstantsPool.fill);
   for(i=0; i <theScan->fNativeLine->fill; i++){
      char *str=(char*) (theScan->newConstantsPool.pool + theScan->constStrings->buf[i]);
      pushCell(theScan->allMPvariables,theScan->fline->buf+theScan->fline->fill);
      //printf("!%s!\n",str);
      addInternalFloatStr(theScan->fline,str);
      if(theScan->constStrings->buf[i+1] == -1){
         /*Store also */
         /*Initialise the last cell -- note, no reallocation may occur!:*/
         reservFloat(theScan->fline);
         /*fline->buf[1] is 1, fline->buf[fline->fill-1] is 'val', we
           store 1/val into fline->buf[fline->fill]:*/
#ifndef COMPLEX
         mpfr_div(theScan->fline->buf[theScan->fline->fill],
               theScan->fline->buf[1],
               theScan->fline->buf[theScan->fline->fill-1],GMP_RNDN);
#else
	 mpfr_div(theScan->fline->buf[theScan->fline->fill].re,
               theScan->fline->buf[1].re,
               theScan->fline->buf[theScan->fline->fill-1].re,GMP_RNDN);
	 mpfr_set_d(theScan->fline->buf[theScan->fline->fill].im,0.0,GMP_RNDN);   	 
	 // HERE WE ASSUMED CONSTANTS TO BE REAL! I is not inverted
#endif
         pushCell(theScan->allMPvariables,theScan->fline->buf+theScan->fline->fill);
         theScan->fline->fill++;/*Store the cell*/
         i++;/*Skip next "-1" in theScan->constStrings*/
      }/*if(theScan->constStrings->buf[i+1] == -1)*/
   }/*for(i=0; i <theScan->fNativeline->fill; i++)*/
   destroyTrie(&(theScan->newConstantsTrie));
   if(buildRtTriad(theScan))
      return 1;/*Failure*/
   ctTriadFree(&theScan->ctTriad);
   /*Now in theScan->rtTriad we have translated triads.*/
   /*The only p`roblem -- with the x array, it must be copied to 
     theScan->x before evaluation.*/
   return 0;
}/*masterScan*/
