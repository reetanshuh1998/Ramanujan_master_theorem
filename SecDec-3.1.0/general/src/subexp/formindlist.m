(*
  #****m* SecDec/general/src/subexp/formindlist.m
  #  NAME
  #    formindlist.m
  #
  #  USAGE
  #  is loaded by subandexpand*l*h*.m
  # 
  #  USES 
  #  output from the sector decomposition *secP*l*h*.out
  #
  #  USED BY 
  #    
  #  subandexpand*l*h*.m
  #
  #  PURPOSE
  #  takes output from sector decomposition, manipulates it using various symmetries of the problem
  #  to form 'integrandfunctionlist', and also store[*,*], which are then used as the
  #  input for symbsub.m and formfortran.m 
  #    
  #  INPUTS
  #  
  #  from subandexpand*l*h*.m:
  #  n: number of integration variables
  #  logi, lini, higheri: the number of logarithmic, linear and higher order poles respectively
  #  P*l*h*: output from the decomposition, read by subandexpand*l*h*.m, of the form
  #  
  #  variables: 
  #  dieflag: indicates to subandexpand*l*h*.m whether further action is to be taken (ie whether there is any input
  #   from the sector decomposition of this particular pole structure.
  #    
  #  RESULT
  #  integrandfunctionlist is formed, where each element contains a list of exponents of the integration variables,
  #  and the number of subsectors corresponding to that list of exponents. store[*,*] is formed, where store[p,q] is
  #  the integrand relating to the qth subsector with exponents matching the pth element in integrandfunctionlist.
  #    
  #  
  #  SEE ALSO
  #  subandexpand*l*h*.m, symbsub.m, formfortran.m
  #   
  #****
  *)
  (*populates the list 'plist[logi,lini]', which makes stores info in fstore,ustore,nstore*)
(*ready for symbolic subtraction/eps expansion*)

myclear[varname_]:=Clear[varname];

(* exponents in the form of integer part, eps part, base *)
refexps[expl_]:=Module[{newexp},
 newexp=expl;
 newexp=Table[{(newexp[[tabi]])/.eps->0,D[newexp[[tabi]],eps],z[tabi]},{tabi,n}]];

xtoz[expr_]:=expr/.x[a_]->z[a];

(* the list elements of rsec are the ones of [graph]P*.out: 
exponent list of z-factors, exponent list of 1-z factors, transformed 1-z factors, decomposed factorlist *)
(* ns2 is the function to integrate, including the 1-z factors *)

reform[rsec_]:=Block[{newsec,ns1,ns2},
		     newsec=xtoz/@rsec;
		     ns1=refexps[newsec[[1]]];
		     ns2=Product[newsec[[3,i]]^newsec[[2,i]],{i,n}]*Product[newsec[[4,j,1]]^newsec[[4,j,2]],{j,Length[newsec[[4]]]}];
		     {ns1,ns2}];

Print["Recasting input for subtraction"];
recasttime=AbsoluteTiming[
		  listname=StringJoin["P",polestring];
		  plist=Symbol[listname];
		  myclear[listname];
		  plist=reform/@plist;
		  (* debug 
-                 Print["plist=",plist]; *)
		  If[plist=={},dieflag=1,dieflag=0];
		  ][[1]];
Print["Recasting done, time taken = ",recasttime," seconds"];
Print["Integrand takes up ",pbytes=ByteCount[plist]," bytes"]; 
If[dieflag==0,
   ordersector[osec_]:=Block[{osect,osexp,osecreps,tvar},
			     osect=osec;
			     osexp=osect[[1]];
			     (* sorts exponents in order of decreasing complexity *)
			     osexp=Reverse[Sort[osexp]];
			     osect[[1]]=osexp;
			     (* perform relabelling of variables accordingly *)
			     osecreps=Table[osexp[[tvar,3]]->z[tvar],{tvar,n}];
			     osect/.osecreps
			     ];
   
   orderlist[oplist_]:=Module[{ifl},ifl=oplist;ordersector/@ifl];
   
   ordertime=AbsoluteTiming[plist=orderlist[plist];][[1]];
   Print["Integrand list ordered, time taken = ",ordertime," seconds"];
   
   (* fudegn is function degeneracy *)
   populatestore[popsec_]:=Block[{},
				 fudegn++;
				 store[iflcount,fudegn]=popsec[[2]];
				 (* debug 
			         Print["integrand=",store[iflcount,fudegn]];*)
				 ];
   newifl[nfl_]:=Block[{},iflcount++;fudegn=0;populatestore/@nfl;{nfl[[1,1]],fudegn}];
   
   collatelist[cplist_]:=Block[{integrandfunctionlist},
			       integrandfunctionlist=Sort[cplist];
			       (* put into the same list if first element is the same; 
			          this groups functions which have the same exponents together *)
			       tempintegrandfunctionlist=Split[integrandfunctionlist, #1[[1]] == #2[[1]]&];
			       iflcount=0;
			       integrandfunctionlist=newifl/@tempintegrandfunctionlist];
   
   Print["Collating integrand list"];
   collatetime=AbsoluteTiming[plist=collatelist[plist];][[1]];
   Print["Integrand list collated, time taken = ",collatetime,"seconds"];
   integrandfunctionlist=plist;
   Clear[plist]
   ];



