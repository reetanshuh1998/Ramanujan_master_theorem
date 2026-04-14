* The "lambda" parameters controlling the size of the deformation
#define deformationParameters "SecDecInternalLambda0,SecDecInternalLambda1"
Symbols `deformationParameters';

* The deformed integration variable functions (including appearing derivatives)
#define deformedIntegrationVariableDerivativeFunctions "SecDecInternalCondefFacx0,SecDecInternalCondefFacx1,SecDecInternalDeformedx0,dSecDecInternalDeformedx0d0,dSecDecInternalDeformedx0d1,SecDecInternalDeformedx1,dSecDecInternalDeformedx1d0,dSecDecInternalDeformedx1d1"
CFunctions `deformedIntegrationVariableDerivativeFunctions';

* The Jacobian determinant of the contour deformation (including appearing derivatives)
#define contourdefJacobianFunctions "SecDecInternalCondefJac"
CFunctions `contourdefJacobianFunctions';

* Define the calls to the contour deformation.
#Do function = {`deformedIntegrationVariableDerivativeFunctions',`contourdefJacobianFunctions'}
  AutoDeclare Symbols SecDecInternal`function'Call;
#EndDo

* Define the function that takes the real part
CFunction SecDecInternalRealPart;

* Define the call replacement symbols for the real part
AutoDeclare Symbols SecDecInternalSecDecInternalRealPartCall;

* Define the name of the polynomial for the contour deformation
* ("F" in loop integrals)
#define SecDecInternalContourDeformationPolynomial "F"

* Define the polynomials that should remain positive
* (e.g. "U" in loop integrals)
#define positivePolynomials "U"

* The transformation of the Feynman parameters
#procedure insertDeformedIntegrationVariables
    Id SecDecInternalCondefFacx0(x0?,x1?) = ( + (1)) + (( + (-I*SecDecInternalLambda0)) * ( + (1) + (-1)*x0) * (SecDecInternalRealPart(( + (1) * ( + (1)) * (dFd0( + (1)*x0, + (1)*x1, + (1)*eps))))));
  Id SecDecInternalCondefFacx1(x0?,x1?) = ( + (1)) + (( + (-I*SecDecInternalLambda1)) * ( + (1) + (-1)*x1) * (SecDecInternalRealPart(( + (1) * ( + (1)) * (dFd1( + (1)*x0, + (1)*x1, + (1)*eps))))));
  Id SecDecInternalDeformedx0(x0?,x1?) = ( + (1)*x0) + (( + (-I*SecDecInternalLambda0)*x0) * ( + (1) + (-1)*x0) * (SecDecInternalRealPart( + (1) * ( + (1)) * (dFd0( + (1)*x0, + (1)*x1, + (1)*eps)))));
  Id dSecDecInternalDeformedx0d0(x0?,x1?) = ( + (1)) + ( + (1) * ( + (-I*SecDecInternalLambda0)*x0) * ( + (1) + (-1)*x0) * (SecDecInternalRealPart( + (1) * ( + (1)) * ( + (1) * ( + (1)) * (ddFd0d0( + (1)*x0, + (1)*x1, + (1)*eps))))) + (1) * ( + (-I*SecDecInternalLambda0)*x0) * ( + (-1)) * (SecDecInternalRealPart( + (1) * ( + (1)) * (dFd0( + (1)*x0, + (1)*x1, + (1)*eps)))) + (1) * ( + (-I*SecDecInternalLambda0)) * ( + (1) + (-1)*x0) * (SecDecInternalRealPart( + (1) * ( + (1)) * (dFd0( + (1)*x0, + (1)*x1, + (1)*eps)))));
  Id dSecDecInternalDeformedx0d1(x0?,x1?) =  + (1) * ( + (-I*SecDecInternalLambda0)*x0) * ( + (1) + (-1)*x0) * (SecDecInternalRealPart( + (1) * ( + (1)) * ( + (1) * ( + (1)) * (ddFd0d1( + (1)*x0, + (1)*x1, + (1)*eps)))));
  Id SecDecInternalDeformedx1(x0?,x1?) = ( + (1)*x1) + (( + (-I*SecDecInternalLambda1)*x1) * ( + (1) + (-1)*x1) * (SecDecInternalRealPart( + (1) * ( + (1)) * (dFd1( + (1)*x0, + (1)*x1, + (1)*eps)))));
  Id dSecDecInternalDeformedx1d0(x0?,x1?) =  + (1) * ( + (-I*SecDecInternalLambda1)*x1) * ( + (1) + (-1)*x1) * (SecDecInternalRealPart( + (1) * ( + (1)) * ( + (1) * ( + (1)) * (ddFd0d1( + (1)*x0, + (1)*x1, + (1)*eps)))));
  Id dSecDecInternalDeformedx1d1(x0?,x1?) = ( + (1)) + ( + (1) * ( + (-I*SecDecInternalLambda1)*x1) * ( + (1) + (-1)*x1) * (SecDecInternalRealPart( + (1) * ( + (1)) * ( + (1) * ( + (1)) * (ddFd1d1( + (1)*x0, + (1)*x1, + (1)*eps))))) + (1) * ( + (-I*SecDecInternalLambda1)*x1) * ( + (-1)) * (SecDecInternalRealPart( + (1) * ( + (1)) * (dFd1( + (1)*x0, + (1)*x1, + (1)*eps)))) + (1) * ( + (-I*SecDecInternalLambda1)) * ( + (1) + (-1)*x1) * (SecDecInternalRealPart( + (1) * ( + (1)) * (dFd1( + (1)*x0, + (1)*x1, + (1)*eps)))));

#endProcedure

* Procedure that inserts the Jacobian determinant and
* its required derivatives. This procedure is written
* by python.
#procedure insertContourdefJacobianDerivatives
    Id SecDecInternalCondefJac(x0?,x1?) = ((( + (1) * ( + (1)) * (dSecDecInternalDeformedx0d0( + (1)*x0, + (1)*x1))) * ( + (1) * ( + (1)) * (dSecDecInternalDeformedx1d1( + (1)*x0, + (1)*x1)))) + ( + (0))) + (( + (-1)) * (( + (1) * ( + (1)) * (dSecDecInternalDeformedx0d1( + (1)*x0, + (1)*x1))) * ( + (1) * ( + (1)) * (dSecDecInternalDeformedx1d0( + (1)*x0, + (1)*x1)))));

#endProcedure

* Procedure that removes vanishing derivatives of the deformed
* integration variables. This procedure is written by python.
#procedure removeVanishingDeformedIntegrationVariableDerivatives
    Id SecDecInternalDeformedx0(x0?{0,1},x1?) = x0;
  Id dSecDecInternalDeformedx0d1(x0?{0,1},x1?) = 0;
  Id SecDecInternalDeformedx1(x0?,x1?{0,1}) = x1;
  Id dSecDecInternalDeformedx1d0(x0?,x1?{0,1}) = 0;

#endProcedure
