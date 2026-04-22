(************ user input for definition of integrand ************************)

(* This example is for the massive two-loop vertex graph *)


(* the prefactor defined below will NOT be included in the numerical result *)

prefactor=Gamma[1-eps]^2*Gamma[1+eps]/Gamma[1-2*eps]/Gamma[2 + eps];

(************ kinematics (to be used at algebraic level) ********************)
(* to assign numerical values to the kinematic invariants use the file 
 kinem.input OR insert them directly into ScalarProductRules below. In the 
 latter case the replacement by numerical values will be done when the 
 functions are generated, which means that the values cannot be changed 
 later *)

ExternalMomenta = {p1,p2,p3,p4};

(* if different from Length[ExternalMomenta], for example for 2-point 
 functions, give number of external legs *)

externallegs=4;
   
(* define names for kinematic invariants and masses (SP[pi,pj]=pi*pj) *)
(* NOTE that the order of the numerical values for the kinematic invariants 
 in kinem.input MUST MATCH the order given in the lists below, where the 
 masses should be listed after the kinematic invariants;
 example: s=4, t=-3/4, s1=0.2, msq=1 should correspond to the following 
 line in kinem.input:
 4 -3/4 0.2 1 
 if you swap s and t in the list below, you must swap 4 and -3/4 in 
 kinem.input *)  

KinematicInvariants = {s,t,s1};
Masses={msq};

ScalarProductRules = {
  SP[p1,p1]->s1,
  SP[p2,p2]->0,
  SP[p3,p3]->0,
  SP[p3,p2]->t/2,
  SP[p1,p3]->-t/2-s/2,
  SP[p1,p2]->s/2-s1/2,
  SP[p4,p4]->0,
  SP[p1,p4]->t/2-s1/2,
  SP[p2,p4]->s1/2-t/2-s/2,
  SP[p3,p4]->s/2};

(*Include an equation on the RHS of threshold, which when evaluating 
 to false leads to an automated switching off of the integration of 
 the imaginary part. All invariants listed in the KinematicInvariants, 
 Masses and ScalarProductRules lists can be utilized, as well as 
 functions Min,Max,Sqrt,Power,+,-,*,/ using Mathematica notation *)

threshold= s >= 4*msq;

(************ advanced options: *********************************************)

(* set dimension *)
(* dimension can be changed, but symbol for epsilon must remain the same *)

Dim=4-2*eps;

(* define splitlist *)
(* Specify those Feynman parameters which may have an endpoint singularity 
 at z[i]=1, such that the integral will be split at 1/2 and the singularity 
 at one will be remapped to a singularity at zero. E.g., if you want the 
 integration over Feynman parameter z[3] to be split, write "3" into the 
 splitlist. *)

splitlist={};

(************ integrand specification ***************************************)

(* specify your functions *)
(* The syntax is as follows: 
 {NumberOfFunction,{exponent of each Feynman parameter (list)},
    {{function U,exponent of U,decomposition flag},
     {function F,exponent of F,decomposition flag}},
  Numerator},
 where the decomposition flag should be chosen A if no further decomposition
 is needed and chosen B if further sector decomposition will be needed. 
 The numerator may depend on the regulator "eps" and contain products of 
 terms. The numerator may not contain singular terms. Feynman parameters 
 are denoted by the letter z[number].*)

expou=2*eps;
expof=-2-eps;

U[z_]:=z[1] + z[2] + z[3] + z[4];

F[z_]:=-t*z[1]*z[3] - s1*z[1]*z[4] - s*z[2]*z[4] +
  msq*z[1]*(z[1] + z[2] + z[3] + z[4]);

functionlist = {
  {1, {0, 0, 0}, 
   {{(U[z]/.z[1]->1)/.z[4]->z[1], expou, A}, 
    {(F[z]/.z[1]->1)/.z[4]->z[1], expof, A}}, 1}, 
  {2, {0, 0, 0}, 
   {{(U[z]/.z[2]->1)/.z[4]->z[2], expou, A},  
    {(F[z]/.z[2]->1)/.z[4]->z[2], expof, B}}, 1}, 
  {3, {0, 0, 0}, 
   {{(U[z]/.z[3]->1)/.z[4]->z[3], expou, A}, 
    {(F[z]/.z[3]->1)/.z[4]->z[3], expof, B}}, 1}, 
  {4, {0, 0, 0}, 
   {{U[z]/.z[4]->1, expou, A}, 
    {F[z]/.z[4]->1, expof, B}}, 1}
};
