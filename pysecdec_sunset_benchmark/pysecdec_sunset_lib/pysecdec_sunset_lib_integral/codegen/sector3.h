* The name of the loop integral
#define name "pysecdec_sunset_lib_integral"

* Whether or not we are producing code for contour deformation
#define contourDeformation "1"

* Whether or not complex return type is enforced
#define enforceComplex "0"

* number of integration variables
#define numIV "2"

* number of regulators
#define numReg "1"

#define integrationVariables "x0,x1"
#define realParameters "m1,m2,m3,psq"
#define complexParameters ""
#define regulators "eps"
Symbols `integrationVariables'
        `realParameters'
        `complexParameters'
        `regulators';

#define defaultQmcTransform "korobov3x3"

* Define the imaginary unit in sympy notation.
Symbol I;

#define calIDerivatives "SecDecInternalCalI,dSecDecInternalCalId2,ddSecDecInternalCalId2d2"
#define functions "`calIDerivatives',SecDecInternalRemainder,SecDecInternalCondefFac,dSecDecInternalCondefFacd2,ddSecDecInternalCondefFacd2d2,SecDecInternalOtherPoly0"
CFunctions `functions';

#define decomposedPolynomialDerivatives "ddFd0d0,F,ddFd1d1,dFd0,U,dFd1,ddFd0d1"
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
    Id SecDecInternalsDUMMYIntegrand = (( + (( + (1)) * (( + (1))^(-1)))*eps^-1) * ( + (((( + (1))^( + (1))) * (( + ( + (1)))^( + (0) + (-3))) * (( + ( + (1)))^( + (0) + (1))) * (( + (1))^( + (1)))) * ((SecDecInternalCalI( + (0), + (1)*x1, + (0))))) + (((((( + (1)) * (dSecDecInternalCalId2( + (0), + (1)*x1, + (0)))) * ( + (1))))) * ( + (1)))*eps + ((((( + (0)) * (dSecDecInternalCalId2( + (0), + (1)*x1, + (0)))) * ( + (0))) + ((( + (1)) * (((( + (1)) * (ddSecDecInternalCalId2d2( + (0), + (1)*x1, + (0)))) * ( + (1))))) * ( + (1)))) * ( + (1/2)))*eps^2)) + (( + (( + (1)) * (( + (1))^(-1)))) * ( + (((( + (1)*x0^-2)^( + (1))) * (( + ( + (1))*x0^-1)^( + (0) + (-3))) * (( + ( + (1))*x0^-2)^( + (0) + (1))) * (( + (1))^( + (1)))) * ((SecDecInternalCalI( + (1)*x0, + (1)*x1, + (0))) + (( + (-1)) * (SecDecInternalCalI( + (0), + (1)*x1, + (0)))))) + ((((( + (0)) * (( + (1)*x0^-1)^( + (-3) + (0))) * (( + (1)*x0^-2)^( + (1) + (0))) * ((SecDecInternalCalI( + (1)*x0, + (1)*x1, + (0))) + (( + (-1)) * (SecDecInternalCalI( + (0), + (1)*x1, + (0)))))) * ( + (0))) + ((( + (1)*x0^-2) * ((( + (1)*x0^-1)^( + (-3) + (0))) * ( + (3)) * (log( + (1)*x0^-1))) * (( + (1)*x0^-2)^( + (1) + (0))) * ((SecDecInternalCalI( + (1)*x0, + (1)*x1, + (0))) + (( + (-1)) * (SecDecInternalCalI( + (0), + (1)*x1, + (0)))))) * ( + (1))) + ((( + (1)*x0^-2) * (( + (1)*x0^-1)^( + (-3) + (0))) * ((( + (1)*x0^-2)^( + (1) + (0))) * ( + (-2)) * (log( + (1)*x0^-2))) * ((SecDecInternalCalI( + (1)*x0, + (1)*x1, + (0))) + (( + (-1)) * (SecDecInternalCalI( + (0), + (1)*x1, + (0)))))) * ( + (1))) + ((( + (1)*x0^-2) * (( + (1)*x0^-1)^( + (-3) + (0))) * (( + (1)*x0^-2)^( + (1) + (0))) * ((((( + (1)) * (dSecDecInternalCalId2( + (1)*x0, + (1)*x1, + (0)))) * ( + (1)))) + (((( + (-1)) * (((( + (1)) * (dSecDecInternalCalId2( + (0), + (1)*x1, + (0)))) * ( + (1))))) * ( + (1)))))) * ( + (1)))) * ( + (1)))*eps));

#endProcedure

#define highestPoles "1"
#define requiredOrders "1"
#define numOrders "3"

* Specify and enumerate all occurring orders in python.
* Define the preprocessor variables
* `shiftedRegulator`regulatorIndex'PowerOrder`shiftedOrderIndex''.
#define shiftedRegulator1PowerOrder1 "0"
#define shiftedRegulator1PowerOrder2 "1"
#define shiftedRegulator1PowerOrder3 "2"

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
    Id SecDecInternalCalI(x0?,x1?,eps?) = (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*eps)) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps));
  Id dSecDecInternalCalId2(x0?,x1?,eps?) =  + (1) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*eps)) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * (((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps)) * ( + (-2)) * (log(F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) + (1) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*eps)) * (((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ( + (3)) * (log(U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps)) + (1) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * ( + (1) * ( + (1)) * (dSecDecInternalCondefFacd2( + (1)*x0, + (1)*x1, + (1)*eps))) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps));
  Id ddSecDecInternalCalId2d2(x0?,x1?,eps?) =  + (1) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*eps)) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ( + (1) * (((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps)) * ( + (-2)) * (log(F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) * ( + (-2)) * (log(F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) + (2) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*eps)) * (((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ( + (3)) * (log(U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) * (((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps)) * ( + (-2)) * (log(F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) + (1) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*eps)) * ( + (1) * (((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ( + (3)) * (log(U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) * ( + (3)) * (log(U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps)) + (2) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * ( + (1) * ( + (1)) * (dSecDecInternalCondefFacd2( + (1)*x0, + (1)*x1, + (1)*eps))) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * (((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps)) * ( + (-2)) * (log(F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) + (2) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * ( + (1) * ( + (1)) * (dSecDecInternalCondefFacd2( + (1)*x0, + (1)*x1, + (1)*eps))) * (((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ( + (3)) * (log(U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)))) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps)) + (1) * (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * ( + (1) * ( + (1)) * ( + (1) * ( + (1)) * (ddSecDecInternalCondefFacd2d2( + (1)*x0, + (1)*x1, + (1)*eps)))) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-3) + (3)*eps)) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (1) + (-2)*eps));

#endProcedure

#procedure insertOther
    Id SecDecInternalRemainder(x0?,x1?,eps?) =  + (1);
  Id SecDecInternalCondefFac(x0?,x1?,eps?) = ((SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1)) ^ ( + (-1) + (1)*eps));
  Id dSecDecInternalCondefFacd2(x0?,x1?,eps?) = ((SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1)) ^ ( + (-1) + (1)*eps)) * (log(SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1)));
  Id ddSecDecInternalCondefFacd2d2(x0?,x1?,eps?) =  + (1) * (((SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1)) ^ ( + (-1) + (1)*eps)) * (log(SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1)))) * (log(SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1)));
  Id SecDecInternalOtherPoly0(x0?,x1?,eps?) =  + ( + (1));

#endProcedure

#procedure insertDecomposed
    Id ddFd0d0(x0?,x1?,eps?) =  + (2*m3^2)*x1 + (2*m2^2)*x1^2;
  Id F(x0?,x1?,eps?) =  + ( + (m3^2))*x0^2*x1 + ( + (m2^2))*x0^2*x1^2 + ( + (m3^2))*x0 + ( + (m1^2 + m2^2 + m3^2 - psq))*x0*x1 + ( + (m2^2))*x0*x1^2 + ( + (m1^2)) + ( + (m1^2))*x1;
  Id ddFd1d1(x0?,x1?,eps?) =  + (2*m2^2)*x0 + (2*m2^2)*x0^2;
  Id dFd0(x0?,x1?,eps?) =  + (m3^2) + (m1^2 + m2^2 + m3^2 - psq)*x1 + (m2^2)*x1^2 + (2*m3^2)*x0*x1 + (2*m2^2)*x0*x1^2;
  Id U(x0?,x1?,eps?) =  + ( + (1))*x1 + ( + (1)) + ( + (1))*x0*x1;
  Id dFd1(x0?,x1?,eps?) =  + (m1^2) + (m1^2 + m2^2 + m3^2 - psq)*x0 + (2*m2^2)*x0*x1 + (m3^2)*x0^2 + (2*m2^2)*x0^2*x1;
  Id ddFd0d1(x0?,x1?,eps?) =  + (m1^2 + m2^2 + m3^2 - psq) + (2*m2^2)*x1 + (2*m3^2)*x0 + (4*m2^2)*x0*x1;

#endProcedure

* Define how deep functions to be inserted are nested.
#define insertionDepth "5"
