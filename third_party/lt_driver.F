* lt_driver.F
* Minimal LoopTools driver for Python integration
* Reads: function_name p1 p2 ... from command line args
* Outputs: Re Im
* Compile: gfortran -o lt_driver lt_driver.F -L<path> -looptools

#include "externals.h"
#include "types.h"
#include "defs.h"

      program lt_driver
      implicit none

#include "lt.h"

      character*10 func
      double precision p, m1sq, m2sq
      double precision p1sq, p2sq, p3sq, m3sq
      double precision mudim_val, delta_val
      double complex result
      integer nargs

      double complex B0, C0
      external B0, C0

      call ltini

* Set mu^2 = 1 and delta = 0 (finite part in MS-bar)
      mudim_val = 1d0
      delta_val = 0d0
      call setmudim(mudim_val)
      call setdelta(delta_val)

      nargs = iargc()
      if (nargs .lt. 1) then
        write(*,*) 'Usage: lt_driver B0 p m1sq m2sq'
        write(*,*) '   or: lt_driver C0 p1sq p2sq p3sq m1sq m2sq m3sq'
        stop
      endif

      call getarg(1, func)

      if (func .eq. 'B0') then
        call getarg(2, func)
        read(func,*) p
        call getarg(3, func)
        read(func,*) m1sq
        call getarg(4, func)
        read(func,*) m2sq
        result = B0(p, m1sq, m2sq)
        write(*,'(2E25.16)') dble(result), dimag(result)

      else if (func .eq. 'C0') then
        call getarg(2, func)
        read(func,*) p1sq
        call getarg(3, func)
        read(func,*) p2sq
        call getarg(4, func)
        read(func,*) p3sq
        call getarg(5, func)
        read(func,*) m1sq
        call getarg(6, func)
        read(func,*) m2sq
        call getarg(7, func)
        read(func,*) m3sq
        result = C0(p1sq, p2sq, p3sq, m1sq, m2sq, m3sq)
        write(*,'(2E25.16)') dble(result), dimag(result)

      else
        write(*,*) 'Unknown function: ', func
      endif

      call ltexi
      end
