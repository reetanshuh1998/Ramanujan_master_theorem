* The name of the loop integral
#define name "tadpole1L_pysecdec_integral"

* Whether or not we are producing code for contour deformation
#define contourDeformation "1"

* Whether or not complex return type is enforced
#define enforceComplex "0"

* number of integration variables
#define numIV "1"

* number of regulators
#define numReg "1"

#define integrationVariables "x0"
#define realParameters "msq"
#define complexParameters ""
#define regulators "eps"
Symbols `integrationVariables'
        `realParameters'
        `complexParameters'
        `regulators';

#define defaultQmcTransform "korobov3x3"

* Define the imaginary unit in sympy notation.
Symbol I;

#define calIDerivatives "SecDecInternalCalI,dSecDecInternalCalId1"
#define functions "`calIDerivatives',SecDecInternalRemainder,SecDecInternalCondefFac,dSecDecInternalCondefFacd1,SecDecInternalOtherPoly0"
CFunctions `functions';

#define decomposedPolynomialDerivatives "U,dFd0,F,ddFd0d0"
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
    Id SecDecInternalsDUMMYIntegrand = (( + (( + (1)) * (( + (1))^(-1)))) * ( + (((( + (1))^( + (1))) * (( + ( + (1)))^( + (0) + (-3))) * (( + ( + (1)))^( + (0) + (1))) * (( + (1))^( + (1)))) * (SecDecInternalCalI( + (1)*x0, + (0)))) + (((((( + (1)) * (dSecDecInternalCalId1( + (1)*x0, + (0)))) * ( + (1))))) * ( + (1)))*eps));

#endProcedure

#define highestPoles "0"
#define requiredOrders "1"
#define numOrders "2"

* Specify and enumerate all occurring orders in python.
* Define the preprocessor variables
* `shiftedRegulator`regulatorIndex'PowerOrder`shiftedOrderIndex''.
#define shiftedRegulator1PowerOrder1 "0"
#define shiftedRegulator1PowerOrder2 "1"

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
    Id SecDecInternalCalI(x0?,eps?) = (SecDecInternalCondefJac( + (1)*x0)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*eps)) * (( + (-msq))^( + (1) + (-1)*eps));
  Id dSecDecInternalCalId1(x0?,eps?) =  + (1) * (SecDecInternalCondefJac( + (1)*x0)) * (SecDecInternalCondefFac( + (1)*x0, + (1)*eps)) * ((( + (-msq))^( + (1) + (-1)*eps)) * ( + (-1)) * (log( + (-msq)))) + (1) * (SecDecInternalCondefJac( + (1)*x0)) * ( + (1) * ( + (1)) * (dSecDecInternalCondefFacd1( + (1)*x0, + (1)*eps))) * (( + (-msq))^( + (1) + (-1)*eps));

#endProcedure

#procedure insertOther
    Id SecDecInternalRemainder(x0?,eps?) =  + (1);
  Id SecDecInternalCondefFac(x0?,eps?) = ( + (1));
  Id dSecDecInternalCondefFacd1(x0?,eps?) =  + (0);
  Id SecDecInternalOtherPoly0(x0?,eps?) =  + ( + (1));

#endProcedure

#procedure insertDecomposed
    Id U(x0?,eps?) =  + ( + (1));
  Id dFd0(x0?,eps?) =  + (0);
  Id F(x0?,eps?) =  + ( + (-msq));
  Id ddFd0d0(x0?,eps?) =  + (0);

#endProcedure

* Define how deep functions to be inserted are nested.
#define insertionDepth "5"
