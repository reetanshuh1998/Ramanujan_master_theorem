* lt_driver.f
* LoopTools driver for B0 and C0 — Python integration via subprocess
* Usage: lt_driver <func> <mudim> <delta> <args...>
*   B0: lt_driver B0 <mudim> <delta> <p> <m1sq> <m2sq>
*   C0: lt_driver C0 <mudim> <delta> <p1sq> <p2sq> <p3sq> <m1sq> <m2sq> <m3sq>
      program lt_driver
      implicit none

      character*256 func, buf
      double precision p, m1sq, m2sq
      double precision p1sq, p2sq, p3sq, m3sq
      double precision mudim_val, delta_val
      double complex result
      integer nargs

      double complex b0, c0
      external b0, c0

      call ltini

      nargs = iargc()
      if (nargs .lt. 1) then
        write(*,*) 'Usage: lt_driver B0 mudim delta p m1sq m2sq'
        stop
      endif

      call getarg(1, func)
      call getarg(2, buf)
      read(buf,*) mudim_val
      call getarg(3, buf)
      read(buf,*) delta_val

      call setmudim(mudim_val)
      call setdelta(delta_val)

      if (func(1:2) .eq. 'B0') then
        call getarg(4, buf)
        read(buf,*) p
        call getarg(5, buf)
        read(buf,*) m1sq
        call getarg(6, buf)
        read(buf,*) m2sq
        result = b0(p, m1sq, m2sq)
        write(*,'(2E25.16)') dble(result), dimag(result)

      else if (func(1:2) .eq. 'C0') then
        call getarg(4, buf)
        read(buf,*) p1sq
        call getarg(5, buf)
        read(buf,*) p2sq
        call getarg(6, buf)
        read(buf,*) p3sq
        call getarg(7, buf)
        read(buf,*) m1sq
        call getarg(8, buf)
        read(buf,*) m2sq
        call getarg(9, buf)
        read(buf,*) m3sq
        result = c0(p1sq, p2sq, p3sq, m1sq, m2sq, m3sq)
        write(*,'(2E25.16)') dble(result), dimag(result)

      endif

      call ltexi
      end
