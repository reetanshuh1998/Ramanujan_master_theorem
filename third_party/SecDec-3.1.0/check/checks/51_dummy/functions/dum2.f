      double precision function dum2(x1,x2)
      implicit double precision (a-h,o-z)
      double precision cut
      double precision dum1
      common/params/beta,cut3
      double precision x1,x2
        w1=x1*x1
        w2=x2*x2
        dum2=w1+w2+3.d0*w1*w2+4.d0*x1*x2+beta*beta-sqrt(beta*x1*x2)

      return
      end