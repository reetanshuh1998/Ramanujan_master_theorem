* The name of the loop integral
#define name "P126_pysecdec_integral"

* Whether or not we are producing code for contour deformation
#define contourDeformation "1"

* Whether or not complex return type is enforced
#define enforceComplex "0"

* number of integration variables
#define numIV "5"

* number of regulators
#define numReg "1"

#define integrationVariables "x0,x1,x2,x3,x4"
#define realParameters "s"
#define complexParameters "msq"
#define regulators "eps"
Symbols `integrationVariables'
        `realParameters'
        `complexParameters'
        `regulators';

#define defaultQmcTransform "korobov3x3"

* Define the imaginary unit in sympy notation.
Symbol I;

#define calIDerivatives "SecDecInternalCalI"
#define functions "`calIDerivatives',SecDecInternalRemainder,SecDecInternalCondefFac,SecDecInternalOtherPoly0"
CFunctions `functions';

#define decomposedPolynomialDerivatives "ddFd1d2,ddFd0d2,dFd3,dFd2,F,ddFd3d3,ddFd0d4,ddFd0d1,ddFd2d2,dFd0,ddFd0d0,ddFd1d3,ddFd4d4,U,ddFd0d3,ddFd2d4,ddFd1d1,ddFd3d4,dFd1,dFd4,ddFd2d3,ddFd1d4"
CFunctions `decomposedPolynomialDerivatives';

* Temporary functions and symbols for replacements in FORM
AutoDeclare CFunctions SecDecInternalfDUMMY;
AutoDeclare Symbols SecDecInternalsDUMMY;

* We generated logs in the subtraction and pack denominators
* and powers into a functions.
CFunctions log, exp, SecDecInternalPow, SecDecInternalDenominator, sqrt;

* We rewrite function calls as symbols
#Do function = {`functions',`decomposedPolynomialDerivatives',log,exp,SecDecInternalPow,SecDecInternalDenominator,sqrt}
  AutoDeclare Symbols SecDecInternal`function'Call;
#EndDo

* We need labels for the code optimization
AutoDeclare Symbols SecDecInternalLabel;

* The integrand may be longer than FORM can read in one go.
* We use python to split the the expression if necessary.
* Define a procedure that defines the "integrand" expression
#procedure defineExpansion
  Global expansion = SecDecInternalsDUMMYIntegrand;
    Id SecDecInternalsDUMMYIntegrand = (( + (( + (1)) * (( + (1))^(-1)))) * ( + (((( + (1)*x0^-3)^( + (1))) * (( + ( + (1))*x0^-1)^( + (0))) * (( + ( + (1))*x0^-2)^( + (0) + (-2))) * (( + (1))^( + (1)))) * (SecDecInternalCalI( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4, + (0))))));

#endProcedure

#define highestPoles "0"
#define requiredOrders "0"
#define numOrders "1"

* Specify and enumerate all occurring orders in python.
* Define the preprocessor variables
* `shiftedRegulator`regulatorIndex'PowerOrder`shiftedOrderIndex''.
#define shiftedRegulator1PowerOrder1 "0"

* Define two procedures to open and close a nested argument section
#procedure beginArgumentDepth(depth)
  #Do recursiveDepth = 1, `depth'
    Argument;
  #EndDo
#endProcedure
#procedure endArgumentDepth(depth)
  #Do recursiveDepth = 1, `depth'
    EndArgument;
  #EndDo
#endProcedure

* Define procedures to insert the dummy functions introduced in python and their derivatives.
#procedure insertCalI
    Id SecDecInternalCalI(x0?,x1?,x2?,x3?,x4?,eps?) = (SecDecInternalCondefJac( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4, + (1)*eps)) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx2( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx3( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx4( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4), + (1)*eps)) ^ ( + (3)*eps)) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx2( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx3( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4),SecDecInternalDeformedx4( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4), + (1)*eps)) ^ ( + (-2) + (-2)*eps));

#endProcedure

#procedure insertOther
    Id SecDecInternalRemainder(x0?,x1?,x2?,x3?,x4?,eps?) =  + (1);
  Id SecDecInternalCondefFac(x0?,x1?,x2?,x3?,x4?,eps?) = ((SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4)) ^ ( + (1) + (1)*eps)) * ((SecDecInternalCondefFacx1( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4)) ^ ( + (0))) * ((SecDecInternalCondefFacx2( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4)) ^ ( + (0))) * ((SecDecInternalCondefFacx3( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4)) ^ ( + (0))) * ((SecDecInternalCondefFacx4( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*x4)) ^ ( + (0)));
  Id SecDecInternalOtherPoly0(x0?,x1?,x2?,x3?,x4?,eps?) =  + ( + (1));

#endProcedure

#procedure insertDecomposed
    Id ddFd1d2(x0?,x1?,x2?,x3?,x4?,eps?) =  + (0);
  Id ddFd0d2(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq)*x4 + (2*msq)*x3*x4 + (2*msq)*x0*x4^2;
  Id dFd3(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq - s) + (2*msq - s)*x4 + (2*msq)*x3 + (2*msq)*x3*x4 + (2*msq - s)*x2 + (2*msq)*x2*x3 + (2*msq - s)*x1 + (2*msq)*x1*x3 + (2*msq)*x0*x4 + (msq)*x0*x4^2 + (2*msq)*x0*x2*x4 + (-s)*x0*x1 + (2*msq - s)*x0*x1*x4;
  Id dFd2(x0?,x1?,x2?,x3?,x4?,eps?) =  + (msq) + (2*msq - s)*x3 + (msq)*x3^2 + (2*msq)*x0*x4 + (2*msq)*x0*x3*x4 + (msq)*x0^2*x4^2;
  Id F(x0?,x1?,x2?,x3?,x4?,eps?) =  + ( + (-s))*x0*x1*x3 + ( + (msq))*x3^2 + ( + (msq))*x1*x3^2 + ( + (msq))*x2*x3^2 + ( + (-s))*x0^2*x1*x4 + ( + (2*msq))*x0*x3*x4 + ( + (2*msq - s))*x0*x1*x3*x4 + ( + (2*msq))*x0*x2*x3*x4 + ( + (msq))*x3^2*x4 + ( + (msq))*x0^2*x4^2 + ( + (msq))*x0^2*x1*x4^2 + ( + (msq))*x0^2*x2*x4^2 + ( + (msq))*x0*x3*x4^2 + ( + (-s))*x0*x1 + ( + (2*msq - s))*x3 + ( + (2*msq - s))*x1*x3 + ( + (2*msq - s))*x2*x3 + ( + (2*msq - s))*x0*x4 + ( + (2*msq))*x0*x1*x4 + ( + (2*msq))*x0*x2*x4 + ( + (2*msq - s))*x3*x4 + ( + (msq))*x0*x4^2 + ( + (msq)) + ( + (msq))*x1 + ( + (msq))*x2 + ( + (msq))*x4;
  Id ddFd3d3(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq) + (2*msq)*x4 + (2*msq)*x2 + (2*msq)*x1;
  Id ddFd0d4(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq - s) + (2*msq)*x4 + (2*msq)*x3 + (2*msq)*x3*x4 + (2*msq)*x2 + (2*msq)*x2*x3 + (2*msq)*x1 + (2*msq - s)*x1*x3 + (4*msq)*x0*x4 + (4*msq)*x0*x2*x4 + (-2*s)*x0*x1 + (4*msq)*x0*x1*x4;
  Id ddFd0d1(x0?,x1?,x2?,x3?,x4?,eps?) =  + (-s) + (2*msq)*x4 + (-s)*x3 + (2*msq - s)*x3*x4 + (-2*s)*x0*x4 + (2*msq)*x0*x4^2;
  Id ddFd2d2(x0?,x1?,x2?,x3?,x4?,eps?) =  + (0);
  Id dFd0(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq - s)*x4 + (msq)*x4^2 + (2*msq)*x3*x4 + (msq)*x3*x4^2 + (2*msq)*x2*x4 + (2*msq)*x2*x3*x4 + (-s)*x1 + (2*msq)*x1*x4 + (-s)*x1*x3 + (2*msq - s)*x1*x3*x4 + (2*msq)*x0*x4^2 + (2*msq)*x0*x2*x4^2 + (-2*s)*x0*x1*x4 + (2*msq)*x0*x1*x4^2;
  Id ddFd0d0(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq)*x4^2 + (2*msq)*x2*x4^2 + (-2*s)*x1*x4 + (2*msq)*x1*x4^2;
  Id ddFd1d3(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq - s) + (2*msq)*x3 + (-s)*x0 + (2*msq - s)*x0*x4;
  Id ddFd4d4(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq)*x0 + (2*msq)*x0*x3 + (2*msq)*x0^2 + (2*msq)*x0^2*x2 + (2*msq)*x0^2*x1;
  Id U(x0?,x1?,x2?,x3?,x4?,eps?) =  + ( + (1))*x4 + ( + (1))*x2 + ( + (1))*x1 + ( + (1)) + ( + (1))*x3*x4 + ( + (1))*x0*x2*x4 + ( + (1))*x0*x1*x4 + ( + (1))*x0*x4 + ( + (1))*x2*x3 + ( + (1))*x1*x3 + ( + (1))*x3;
  Id ddFd0d3(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq)*x4 + (msq)*x4^2 + (2*msq)*x2*x4 + (-s)*x1 + (2*msq - s)*x1*x4;
  Id ddFd2d4(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq)*x0 + (2*msq)*x0*x3 + (2*msq)*x0^2*x4;
  Id ddFd1d1(x0?,x1?,x2?,x3?,x4?,eps?) =  + (0);
  Id ddFd3d4(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq - s) + (2*msq)*x3 + (2*msq)*x0 + (2*msq)*x0*x4 + (2*msq)*x0*x2 + (2*msq - s)*x0*x1;
  Id dFd1(x0?,x1?,x2?,x3?,x4?,eps?) =  + (msq) + (2*msq - s)*x3 + (msq)*x3^2 + (-s)*x0 + (2*msq)*x0*x4 + (-s)*x0*x3 + (2*msq - s)*x0*x3*x4 + (-s)*x0^2*x4 + (msq)*x0^2*x4^2;
  Id dFd4(x0?,x1?,x2?,x3?,x4?,eps?) =  + (msq) + (2*msq - s)*x3 + (msq)*x3^2 + (2*msq - s)*x0 + (2*msq)*x0*x4 + (2*msq)*x0*x3 + (2*msq)*x0*x3*x4 + (2*msq)*x0*x2 + (2*msq)*x0*x2*x3 + (2*msq)*x0*x1 + (2*msq - s)*x0*x1*x3 + (2*msq)*x0^2*x4 + (2*msq)*x0^2*x2*x4 + (-s)*x0^2*x1 + (2*msq)*x0^2*x1*x4;
  Id ddFd2d3(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq - s) + (2*msq)*x3 + (2*msq)*x0*x4;
  Id ddFd1d4(x0?,x1?,x2?,x3?,x4?,eps?) =  + (2*msq)*x0 + (2*msq - s)*x0*x3 + (-s)*x0^2 + (2*msq)*x0^2*x4;

#endProcedure

* Define how deep functions to be inserted are nested.
#define insertionDepth "5"
