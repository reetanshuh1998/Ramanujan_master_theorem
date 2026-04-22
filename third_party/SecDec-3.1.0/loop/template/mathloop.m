(****************** USER INPUT for construction of integrand ***************************)


(* there are TWO OPTIONS to define the graph: constructing it from the 
   labelled vertices (option 1) 
   or giving the list of propagators explicitly (option 2)
   Note that tensor integrals can only be defined by giving the list of propagators 
   including the loop momentum flow explicitly. *)

(* If option 1 is used give list of propagators connecting two vertices with syntax
         {mass,{vertex1,vertex2}}, where mass denotes the propagator mass and 
	 the vertices are labeled with integer numbers.
	 Note that vertices containing an external momentum p_i must carry the label i *)
(*  If option 2 is used give 
         -list of propagators (proplist) 
          masses can have any name, but names should be defined below in the list masses={..}
         -numerator: list of scalar products of loop momenta contracted with 
          external vectors or loop momenta, e.g. for 2*k.p1*l.p2 write
          numerator={2,k*p1,l*p2};
         *)
	 
	 
(* example is 1-loop box with one massive propagator and one off-shell leg (p1^2 nonzero) *)	 

(* momlist: list of loop momenta: (can have any name) *)

momlist={k1};

(* list of propagators (proplist) *) 

(* input option 1: propagators as connections between labelled vertices: *)

proplist={{msq,{1,2}},{0,{2,3}},{0,{3,4}},{0,{4,1}}};


(* input option 2: explicit momentum flow *)
(* remove comments below if you want to use option 2 *)


(*proplist={(k1-p1)^2,k1^2-msq,(k1+p2)^2,(k1+p2+p3)^2};*)


(*       -numerator: list of scalar products of loop momenta contracted with 
          external vectors or loop momenta, e.g. for 2 k1.p1*k2.p2 write
          numerator={2,k1*p1,k2*p2}; for scalar integrals numerator={1}          *) 
	  
(*numerator={2,k1*p1,k1*p2}; *)
numerator={1};

(******* Propagator powers (optional) ***************************************)
(* give propagator powers if different from one, ordering must match the ordering in proplist *)

powerlist=Table[1,{i,1,Length[proplist]}];  

(******* Set Dimension ******************************************************)
(* Dimension can be changed, but symbol for epsilon must remain the same *)

Dim=4-2*eps;

(* the prefactor defined below will NOT be included in the numerical result *) 
(* note that a factor 
  standardprefac=(-1)^Nnu*Gamma[Nnu-loops*Dim/2]/Product[nu[i],{i,N}]],
  with Nnu being the sum of all propagator powers nu[i], 
  which comes from the Feynman parametrisation, 
  will be included automatically in the numerical result, i.e. setting
  prefactor=1 means that standardprefac is included in the numerical result.
  Setting prefactor=X meanst that the numerical result (including standardprefac) 
  is divided by X.         *)

prefactor=Gamma[1+eps];


ExternalMomenta = {p1,p2,p3,p4};

(* if different from Length[ExternalMomenta], for example for 2-point functions, 
   give number of external legs *)

externallegs=4;

(* KINEMATICS (to be used at algebraic level) *************************************** *)
(* to assign numerical values to the kinematic invariants use the file kinematics.input 
   OR insert them directly into ScalarProductRules below. 
   In the latter case the replacement by numerical values will be done when the functions are 
   generated, which means that the values cannot be changed later *)
   
(* define names for kinematic invariants and masses (SP[pi,pj]=pi*pj) *)
(* NOTE that the order of the numerical values for the kinematic invariants in kinem.input
   MUST MATCH the order given in the lists below, where the masses should be listed after the 
   kinematic invariants;
   example: s=4, t=-3/4, s1=0.2, msq=1 should correspond to the following line in kinem.input:
   4 -3/4 0.2 1 
   if you swap s and t in the list below, you must swap 4 and -3/4 in kinem.input *)  

KinematicInvariants = {s,t,s1};
Masses={msq};

ScalarProductRules = {
  SP[p1,p1]->s1,
  SP[p2,p2]->0,
  SP[p3,p3]->0,
  SP[p3,p2]->t/2,
  SP[p1,p3]->-t/2-s/2,
  SP[p1,p2]->s/2-s1/2,
  SP[p4,p4]->0,SP[p1,p4]->t/2-s1/2,SP[p2,p4]->s1/2-t/2-s/2,SP[p3,p4]->s/2};

(* ``Mandelstamrelations`` allow to define constraints between kinematic invariants. 
 If specified, the program will assume that the expression given in the curly bracket is zero.
 This avoids spurious terms (proportional to this expression) in the integrand 
 when constructing the integrand from the explicit propagators rather than the labelled vertices. 
 Examples:
 - four-point (box) kinematics with all legs light-like: Mandelstamrelations={s+t+u} 
 (Note that this does NOT mean that  one of the invariants will be eliminated, it just means that 
  spurious terms proportional to s+t+u will be removed)
 - box kinematics with leg 4 off-shell (where p4^2 is called p4sq in KinematicInvariants):
 Mandelstamrelations={s+t+u-p4sq}
*)
Mandelstamrelations={};
 

(*Include an equation on the RHS of threshold, which when evaluating 
 to false leads to an automated switching off of the integration of 
 the imaginary part. All invariants listed in the KinematicInvariants, 
 Masses and ScalarProductRules lists can be utilized, as well as 
 functions Min,Max,Sqrt,Power,+,-,*,/ using Mathematica notation *)

threshold= s >= 4*msq;


(* *************** advanced options: *************** *)

(******* define splitlist ***************************************************)
(* Specify those Feynman parameters which may have an endpoint singularity 
   at z[i]=1, such that the integral will  be split at 1/2 and the singularity at 
   one will be remapped to a singularity at zero.
   E.g., if you want the integration over Feynman parameter z[3] to be split, 
   write "3" into the splitlist. *)

splitlist={};

