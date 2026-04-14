      double precision function cut(x1)
      implicit double precision (a-h,o-z)
      double precision dum1
      double precision dum2
      common/params/beta,cut3
      double precision x1
c######################################
c The following code is edited by hand
        if (x1.ge.cut3) then
	 cut=1.d0
	else
	 cut=0.d0
	endif
c######################################
      return
      end
