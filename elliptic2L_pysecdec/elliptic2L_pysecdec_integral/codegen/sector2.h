* The name of the loop integral
#define name "elliptic2L_pysecdec_integral"

* Whether or not we are producing code for contour deformation
#define contourDeformation "1"

* Whether or not complex return type is enforced
#define enforceComplex "0"

* number of integration variables
#define numIV "4"

* number of regulators
#define numReg "1"

#define integrationVariables "x0,x1,x2,x3"
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

#define decomposedPolynomialDerivatives "ddFd2d2,ddFd0d2,ddFd0d1,ddFd1d2,F,ddFd0d0,ddFd3d3,ddFd0d3,ddFd1d1,dFd3,ddFd1d3,U,dFd0,dFd1,dFd2,ddFd2d3"
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
    Id SecDecInternalsDUMMYIntegrand = (( + (( + (1)) * (( + (1))^(-1)))) * ( + (((( + (1)*x0^-5*x1^-2)^( + (1))) * (( + ( + (1))*x0^-2*x1^-1)^( + (0) + (-1))) * (( + ( + (1))*x0^-3*x1^-2)^( + (0) + (-1))) * (( + (1))^( + (1)))) * (SecDecInternalCalI( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (0))))));

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
    Id SecDecInternalCalI(x0?,x1?,x2?,x3?,eps?) = (SecDecInternalCondefJac( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3, + (1)*eps)) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3),SecDecInternalDeformedx2( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3),SecDecInternalDeformedx3( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3), + (1)*eps)) ^ ( + (-1) + (3)*eps)) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3),SecDecInternalDeformedx2( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3),SecDecInternalDeformedx3( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3), + (1)*eps)) ^ ( + (-1) + (-2)*eps));

#endProcedure

#procedure insertOther
    Id SecDecInternalRemainder(x0?,x1?,x2?,x3?,eps?) =  + (1);
  Id SecDecInternalCondefFac(x0?,x1?,x2?,x3?,eps?) = ((SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3)) ^ ( + (0))) * ((SecDecInternalCondefFacx1( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3)) ^ ( + (1) + (1)*eps)) * ((SecDecInternalCondefFacx2( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3)) ^ ( + (0))) * ((SecDecInternalCondefFacx3( + (1)*x0, + (1)*x1, + (1)*x2, + (1)*x3)) ^ ( + (0)));
  Id SecDecInternalOtherPoly0(x0?,x1?,x2?,x3?,eps?) =  + ( + (1));

#endProcedure

#procedure insertDecomposed
    Id ddFd2d2(x0?,x1?,x2?,x3?,eps?) =  + (2*msq)*x1 + (2*msq)*x1^2 + (2*msq)*x1^2*x3;
  Id ddFd0d2(x0?,x1?,x2?,x3?,eps?) =  + (2*msq - s)*x1 + (2*msq - s)*x1^2 + (2*msq - s)*x1^2*x3;
  Id ddFd0d1(x0?,x1?,x2?,x3?,eps?) =  + (3*msq - s) + (3*msq)*x3 + (2*msq - s)*x2 + (2*msq)*x1 + (4*msq - 2*s)*x1*x3 + (2*msq)*x1*x3^2 + (4*msq - 2*s)*x1*x2 + (4*msq - 2*s)*x1*x2*x3 + (2*msq)*x0 + (4*msq)*x0*x1 + (4*msq)*x0*x1*x3;
  Id ddFd1d2(x0?,x1?,x2?,x3?,eps?) =  + (3*msq) + (3*msq - s)*x3 + (2*msq)*x2 + (2*msq)*x1 + (4*msq - 2*s)*x1*x3 + (2*msq)*x1*x3^2 + (4*msq)*x1*x2 + (4*msq)*x1*x2*x3 + (2*msq - s)*x0 + (4*msq - 2*s)*x0*x1 + (4*msq - 2*s)*x0*x1*x3;
  Id F(x0?,x1?,x2?,x3?,eps?) =  + ( + (msq))*x0^2*x1^2 + ( + (2*msq - s))*x0*x1^2*x2 + ( + (msq))*x1^2*x2^2 + ( + (msq))*x0*x1^2 + ( + (msq))*x1^2*x2 + ( + (msq))*x0^2*x1^2*x3 + ( + (2*msq - s))*x0*x1^2*x2*x3 + ( + (msq))*x1^2*x2^2*x3 + ( + (2*msq - s))*x0*x1^2*x3 + ( + (2*msq - s))*x1^2*x2*x3 + ( + (msq))*x0*x1^2*x3^2 + ( + (msq))*x1^2*x2*x3^2 + ( + (msq))*x0^2*x1 + ( + (2*msq - s))*x0*x1*x2 + ( + (msq))*x1*x2^2 + ( + (3*msq - s))*x0*x1 + ( + (3*msq))*x1*x2 + ( + (msq))*x1 + ( + (3*msq))*x0*x1*x3 + ( + (3*msq - s))*x1*x2*x3 + ( + (2*msq - s))*x1*x3 + ( + (msq))*x1*x3^2 + ( + (msq))*x0 + ( + (msq))*x2 + ( + (msq)) + ( + (msq))*x3;
  Id ddFd0d0(x0?,x1?,x2?,x3?,eps?) =  + (2*msq)*x1 + (2*msq)*x1^2 + (2*msq)*x1^2*x3;
  Id ddFd3d3(x0?,x1?,x2?,x3?,eps?) =  + (2*msq)*x1 + (2*msq)*x1^2*x2 + (2*msq)*x0*x1^2;
  Id ddFd0d3(x0?,x1?,x2?,x3?,eps?) =  + (3*msq)*x1 + (2*msq - s)*x1^2 + (2*msq)*x1^2*x3 + (2*msq - s)*x1^2*x2 + (2*msq)*x0*x1^2;
  Id ddFd1d1(x0?,x1?,x2?,x3?,eps?) =  + (2*msq)*x2 + (4*msq - 2*s)*x2*x3 + (2*msq)*x2*x3^2 + (2*msq)*x2^2 + (2*msq)*x2^2*x3 + (2*msq)*x0 + (4*msq - 2*s)*x0*x3 + (2*msq)*x0*x3^2 + (4*msq - 2*s)*x0*x2 + (4*msq - 2*s)*x0*x2*x3 + (2*msq)*x0^2 + (2*msq)*x0^2*x3;
  Id dFd3(x0?,x1?,x2?,x3?,eps?) =  + (msq) + (2*msq - s)*x1 + (2*msq)*x1*x3 + (3*msq - s)*x1*x2 + (2*msq - s)*x1^2*x2 + (2*msq)*x1^2*x2*x3 + (msq)*x1^2*x2^2 + (3*msq)*x0*x1 + (2*msq - s)*x0*x1^2 + (2*msq)*x0*x1^2*x3 + (2*msq - s)*x0*x1^2*x2 + (msq)*x0^2*x1^2;
  Id ddFd1d3(x0?,x1?,x2?,x3?,eps?) =  + (2*msq - s) + (2*msq)*x3 + (3*msq - s)*x2 + (4*msq - 2*s)*x1*x2 + (4*msq)*x1*x2*x3 + (2*msq)*x1*x2^2 + (3*msq)*x0 + (4*msq - 2*s)*x0*x1 + (4*msq)*x0*x1*x3 + (4*msq - 2*s)*x0*x1*x2 + (2*msq)*x0^2*x1;
  Id U(x0?,x1?,x2?,x3?,eps?) =  + ( + (1))*x3 + ( + (1)) + ( + (1))*x2 + ( + (1))*x0 + ( + (1))*x1*x2*x3 + ( + (1))*x0*x1*x3 + ( + (1))*x1*x2 + ( + (1))*x0*x1;
  Id dFd0(x0?,x1?,x2?,x3?,eps?) =  + (msq) + (3*msq - s)*x1 + (3*msq)*x1*x3 + (2*msq - s)*x1*x2 + (msq)*x1^2 + (2*msq - s)*x1^2*x3 + (msq)*x1^2*x3^2 + (2*msq - s)*x1^2*x2 + (2*msq - s)*x1^2*x2*x3 + (2*msq)*x0*x1 + (2*msq)*x0*x1^2 + (2*msq)*x0*x1^2*x3;
  Id dFd1(x0?,x1?,x2?,x3?,eps?) =  + (msq) + (2*msq - s)*x3 + (msq)*x3^2 + (3*msq)*x2 + (3*msq - s)*x2*x3 + (msq)*x2^2 + (2*msq)*x1*x2 + (4*msq - 2*s)*x1*x2*x3 + (2*msq)*x1*x2*x3^2 + (2*msq)*x1*x2^2 + (2*msq)*x1*x2^2*x3 + (3*msq - s)*x0 + (3*msq)*x0*x3 + (2*msq - s)*x0*x2 + (2*msq)*x0*x1 + (4*msq - 2*s)*x0*x1*x3 + (2*msq)*x0*x1*x3^2 + (4*msq - 2*s)*x0*x1*x2 + (4*msq - 2*s)*x0*x1*x2*x3 + (msq)*x0^2 + (2*msq)*x0^2*x1 + (2*msq)*x0^2*x1*x3;
  Id dFd2(x0?,x1?,x2?,x3?,eps?) =  + (msq) + (3*msq)*x1 + (3*msq - s)*x1*x3 + (2*msq)*x1*x2 + (msq)*x1^2 + (2*msq - s)*x1^2*x3 + (msq)*x1^2*x3^2 + (2*msq)*x1^2*x2 + (2*msq)*x1^2*x2*x3 + (2*msq - s)*x0*x1 + (2*msq - s)*x0*x1^2 + (2*msq - s)*x0*x1^2*x3;
  Id ddFd2d3(x0?,x1?,x2?,x3?,eps?) =  + (3*msq - s)*x1 + (2*msq - s)*x1^2 + (2*msq)*x1^2*x3 + (2*msq)*x1^2*x2 + (2*msq - s)*x0*x1^2;

#endProcedure

* Define how deep functions to be inserted are nested.
#define insertionDepth "5"
