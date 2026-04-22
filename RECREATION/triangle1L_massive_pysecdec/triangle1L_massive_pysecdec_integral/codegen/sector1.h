* The name of the loop integral
#define name "triangle1L_massive_pysecdec_integral"

* Whether or not we are producing code for contour deformation
#define contourDeformation "1"

* Whether or not complex return type is enforced
#define enforceComplex "0"

* number of integration variables
#define numIV "2"

* number of regulators
#define numReg "1"

#define integrationVariables "x0,x1"
#define realParameters "s,msq"
#define complexParameters ""
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

#define decomposedPolynomialDerivatives "U,ddFd0d0,ddFd0d1,dFd0,F,ddFd1d1,dFd1"
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
    Id SecDecInternalsDUMMYIntegrand = (( + (( + (1)) * (( + (1))^(-1)))) * ( + (((( + (1)*x0^-3)^( + (1))) * (( + ( + (1))*x0^-1)^( + (0) + (-1))) * (( + ( + (1))*x0^-2)^( + (0) + (-1))) * (( + (1))^( + (1)))) * (SecDecInternalCalI( + (1)*x0, + (1)*x1, + (0))))));

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
    Id SecDecInternalCalI(x0?,x1?,eps?) = (SecDecInternalCondefJac( + (1)*x0, + (1)*x1)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*x1, + (1)*eps)) * ((U(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-1) + (2)*eps)) * ((F(SecDecInternalDeformedx0( + (1)*x0, + (1)*x1),SecDecInternalDeformedx1( + (1)*x0, + (1)*x1), + (1)*eps)) ^ ( + (-1) + (-1)*eps));

#endProcedure

#procedure insertOther
    Id SecDecInternalRemainder(x0?,x1?,eps?) =  + (1);
  Id SecDecInternalCondefFac(x0?,x1?,eps?) = ((SecDecInternalCondefFacx0( + (1)*x0, + (1)*x1)) ^ ( + (0))) * ((SecDecInternalCondefFacx1( + (1)*x0, + (1)*x1)) ^ ( + (0)));
  Id SecDecInternalOtherPoly0(x0?,x1?,eps?) =  + ( + (1));

#endProcedure

#procedure insertDecomposed
    Id U(x0?,x1?,eps?) =  + ( + (1)) + ( + (1))*x1 + ( + (1))*x0;
  Id ddFd0d0(x0?,x1?,eps?) =  + (2*msq);
  Id ddFd0d1(x0?,x1?,eps?) =  + (2*msq - s);
  Id dFd0(x0?,x1?,eps?) =  + (2*msq) + (2*msq - s)*x1 + (2*msq)*x0;
  Id F(x0?,x1?,eps?) =  + ( + (msq))*x0^2 + ( + (2*msq - s))*x0*x1 + ( + (msq))*x1^2 + ( + (2*msq))*x0 + ( + (2*msq))*x1 + ( + (msq));
  Id ddFd1d1(x0?,x1?,eps?) =  + (2*msq);
  Id dFd1(x0?,x1?,eps?) =  + (2*msq) + (2*msq)*x1 + (2*msq - s)*x0;

#endProcedure

* Define how deep functions to be inserted are nested.
#define insertionDepth "5"
