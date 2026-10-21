* Timing / reference driver for LoopTools (see compare_looptools.sh).
      program timing
      implicit none
      double complex r
      double precision tstart, tstop, acc
      integer i, n
#include "looptools.h"
      call ltini
      print *, 'C0(0,0,10;1,2,3) =', C0(0d0,0d0,10d0,1d0,2d0,3d0)
      print *, 'B0(5;1,1)        =', B0(5d0,1d0,1d0)
      n = 200000
      acc = 0
      call cpu_time(tstart)
      do i = 1, n
        call clearcache
        r = C0(0d0,0d0,10d0+i*1d-6,1d0,2d0,3d0)
        acc = acc + dble(r)
      enddo
      call cpu_time(tstop)
      print *, 'C0 microseconds/call:', (tstop-tstart)/n*1d6
      call cpu_time(tstart)
      do i = 1, n
        call clearcache
        r = B0(5d0+i*1d-6,1d0,1d0)
        acc = acc + dble(r)
      enddo
      call cpu_time(tstop)
      print *, 'B0 microseconds/call:', (tstop-tstart)/n*1d6, acc
      call ltexi
      end
