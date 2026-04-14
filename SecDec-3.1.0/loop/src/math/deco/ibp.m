
BeginPackage["IBP`"];
ibp::Usage = 
 "ibp[{decsec1,decsec2,...}] performs an integration by parts on each decomposed 
          sector function with linear (z[i_j]^-2) or higher divergences. It 
          returns the resulting list of functions."

  (*ibp[IBP_,flag_] := performibp[IBP,flag];*)
ibp[IBP_] := performibp[IBP];
Begin["`Private`"];

myclear[varname_] := Clear[varname];

(* write exponent list {1,2,z[i]}  as (1+2*eps)  *)

reformexpsback[rsec_] := 
  Block[{newsec,nbpars},
	newsec=rsec;
	If[Global`userdefined==0,
	   nbpars=Global`Nn
	   ,
	   nbpars=Global`feynpars
	   ];
	newsec[[2]]=Table[newsec[[2,tabi,1]] + 
			  newsec[[2,tabi,2]]*Global`eps
			  ,{tabi,nbpars}];
	newsec
	];

(* write exponents  z[i]^(1+2*eps) as {1,2,z[i]} *)

reformexps[rsec_] := 
  Block[{newsec,nbpars},
	newsec=rsec;
	If[Global`userdefined==0,
	   nbpars=Global`Nn
	   ,
	   nbpars=Global`feynpars
	   ];
	newsec[[2]]=Table[{(newsec[[2,tabi]])/.Global`eps->0,
			   D[newsec[[2,tabi]],Global`eps],
			   Global`t[tabi]},{tabi,nbpars}];
	newsec
	];

(* compute surface term *)

surface[var_,func_] := 
  Block[{numfac},

	(* add non-vanishing denominator from ibp integration to numerator *)
	numfac=Factor[1/(1+func[[2,var[[1]],1]]+func[[2,var[[1]],2]]*Global`eps)];

	(* take var to one in expo list, replace var by one in F and U and Num*)
	Return[{func[[1]],ReplacePart[func[[2]],var[[1]]->{0,0,var}],func[[3]]/.{var->1},
	      func[[4]]/.{var->1},(func[[5]]*numfac)/.{var->1},func[[6]]}];
	];

rest[var_,func_] :=
  Block[{exps,expos=Table[0,{3}],expouf=Table[0,{3}],nfact,nfac=Table[0,{3}],faclist=Table[0,{3}],res={}},
	
	(* add +1 to exponent of var *)
	exps=ReplacePart[func[[2]],{var[[1]],1}->1+func[[2,var[[1]],1]]];
	
	(* add non-vanishing denominator from ibp integration to numerator, 
	   minus sign with respect to surface term because minus sign appears 
	   in integration by parts *)
	nfact=-Factor[1/(1+func[[2,var[[1]],1]]+func[[2,var[[1]],2]]*Global`eps)];
	
	(* inner derivative of the full derivative times the overall 
	   ibp prefactor, three factors because of chain rule *)
	nfac[[1]]=Simplify[nfact*func[[6,1]]*D[func[[3]],var],TimeConstraint->3];
	expouf[[1]]={func[[6,1]]-1,func[[6,2]]};
	nfac[[2]]=Simplify[nfact*func[[6,2]]*D[func[[4]],var],TimeConstraint->3];
	expouf[[2]]={func[[6,1]],func[[6,2]]-1};
       	nfac[[3]]=Simplify[nfact*D[func[[5]],var],TimeConstraint->3]/func[[5]];
	expouf[[3]]={func[[6,1]],func[[6,2]]};

	(* Extract factors of t[i] from the new numerator, add them in the 
	   list of exponents and remove them from the numerator. *)	
        Do[If[MatchQ[nfac[[i]],0]==False,
		  faclist[[i]] = DeleteCases[If[TrueQ[Head[#[[1]]]==Global`t],#] 
					     &/@ FactorList[nfac[[i]]],Null];
		  If[faclist[[i]] != {},
			    expos[[i]] = ReplacePart[exps,{#[[1,1]],1}->exps[[#[[1,1]],1]]+#[[2]] &/@ faclist[[i]]];
			    nfac[[i]] = nfac[[i]]*Times @@ (#[[1]]^(-#[[2]]) &/@ faclist[[i]])
			    ,
			    expos[[i]] = exps;
			    ];
		  res=Append[res,{func[[1]],expos[[i]],func[[3]],func[[4]],func[[5]]*nfac[[i]],expouf[[i]]}];
		  ]
	     ,{i,1,3}];
	Return[res];
	];

ibpstart[function_] := 
  Block[{ibpvariables,newfunc,surff,restf},

	(* Find Feynman parameters which result in 
	 a linear or higher divergence. When a 
	 higher than linear divergence is found, 
	 add the same ibp variable several times 
	 to the list of variables to perform integration 
	 by part on. This results in only logarithmic 
	 divergences. *)
	(* mixture of IBP and subtraction:*)
	ibpvariables = #[[3]] &/@ 
	Sort[DeleteCases[Flatten[If[First[#/.{Global`eps->0}]<=-2,
				    Table[#,{-First[#/.{Global`eps->0}]-1}]
				    ] &/@ function[[2]],1],
			 Null], #1[[1]] < #2[[1]] &];
	
	If[ibpvariables == {}, 
	   Print["Sector does not contain linear poles. IBP not performed."];
	   Return[{function}]
	   ,
	   (*Print["Perform IBP on: ",ibpvariables];*)
	   (* Newfunc becomes a list after one iteration of 
	    IBP. If more than one iteration is needed, 
	    newfunc needs to be of the same input type. *)
	   newfunc={function};

	   Do[
	      (* compute surface term *)
	      surff=surface[ibpvariables[[var]],#]&/@newfunc;
	      (* compute rest *)
	      restf=Flatten[Join[rest[ibpvariables[[var]],#]&/@newfunc],1];
	      newfunc=Join[surff,restf];
	      ,{var,Length[ibpvariables]}
	      ];
	   Return[newfunc];
	   ];
	];


performibp[decomsectrs_] := 
  Block[{decsectrs},

	decsectrs=reformexps[#] &/@ decomsectrs;
	(*apply to all functions in primlist and flatten 
	 expressions such that they are of the initial Level 
	 once again *)
	decsectrs=Flatten[Join[ibpstart[#] &/@ decsectrs],1];
	decsectrs=reformexpsback[#] &/@ decsectrs;
	Return[decsectrs]
	];

End[];
EndPackage[];
