      double precision function dum1(x1,x2,x3,x4)
      implicit double precision (a-h,o-z)
      double precision cut
      double precision dum2
      common/params/beta,cut3
      double precision x1,x2,x3,x4
        w1=x1*x1
        w2=x2**3
        w3=x3**4
        w4=x4**5
        dum1=2.d0+w1+w2+w3+w4-w1*w2*w3*w4+4.d0*x1*x2*x3*x4

      return
      end