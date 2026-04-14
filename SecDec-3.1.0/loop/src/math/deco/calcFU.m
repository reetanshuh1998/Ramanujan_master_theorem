(*
#****
# NAME
#  calcFU.m
# USAGE
#  called from subdir/graph/graph.m, via makeFU.pl
# INPUT: 
#        momlist:  list of loop momenta
#         proplist:   list of propagators
#	  numerator:  list of  contracted loop momenta in numerator                             
#	  ScalarProductRules:   list of replacements                                  
#  from miscel.m: several functions like allcombs, whichprefactor, hgmn 
#
# PURPOSE
#  calculates the functions  F, U and N (numerator)
# makes some default replacements for the invariants, and in addition uses the 
# onshell conditions defined in template.m
# The functions F,U,N are written to subdir/graph/FUN.m
#****
*)

(* conventions all momenta incoming *)

Attributes[SP]={Orderless};
SP[-a_,b_]:=-SP[a,b];SP[-a_,-b_]:=SP[a,b];

(* default replacements for general diagrams if repl is not given by the user: *)
If[Head[ExternalMomenta]==List,
   spreplace=Flatten[Table[Table[ExternalMomenta[[i]]*
	     ExternalMomenta[[j]]->SP[ExternalMomenta[[i]],
	     ExternalMomenta[[j]]], {i,Length[ExternalMomenta]}],
             {j,Length[ExternalMomenta]}]];
   ];
If[MatchQ[MomentumConservation,none]==False, momconserv=MomentumConservation,momconserv={}];

masslist={};
lorentzlist={};
mandelstamlist={};
Do[lorentzlist=Append[lorentzlist,KinematicInvariants[[i]]],{i,Length[KinematicInvariants]}];

Do[masslist=Append[masslist,Masses[[i]]],{i,Length[Masses]}];
Do[mandelstamlist=Append[mandelstamlist,Mandelstamrelations[[i]]],{i,Length[Mandelstamrelations]}];

(* translate names for masses and invariants into internal names *)
(* invariants built from Lorentz vectors are all named sp[i] *)

localm=Table[masslist[[i]]->ms[i],{i,Length[masslist]}];
localinv=Table[lorentzlist[[i]]->ssp[i],{i,Length[lorentzlist]}];

repall=Join[localm,localinv];
mandelstamlist=Flatten[{mandelstamlist,-mandelstamlist}]/.repall;
mandelstamrepl=Table[mandelstamlist[[i]]->0,{i,Length[mandelstamlist]}];
Print["renaming of kinematic invariants in calcFU.m: \n"];
Print["replacements=",repall];
Print["mandelstamlist=",mandelstamrepl];

(* ************** Module which will be called from main program: ******************** *)
(* returns  functions U,F,Num,rank,ltilde  as a list , ltilde is needed for tensor integrals only        *)
(* ltilde is a vector, see eq.(8) of Int.J.Mod.Phys.A23:1457 (2008)   *)

(* NOTE: for non-planar boxes, replacement s13->-s12-s23 can NOT be done 
                because it assumes physical kinematics  
		However, naive calculation of F[z] yields a result which differs from 
		the one obtained by "cutting rules" by a term ~ (s12+s23+s13).
		This additional term leads to the wrong result (because some poles are not seen)
		for unphysical kinematics.
		The solution is to first make the replacement s13->-s12-s23
		and then undo it for all invariants coming with a negative sign.
		This leads to the result obtained by "cutting rules"
		*)

calcFU[momlist_,proplist_,powerlist_,numerator_,repl_,invprops_]:=
  Block[{loops,props,deno,iterator,
	 reploc,rem,ex1,ex2,ex3,exn1,exn2,co1,coij,tmu1,tmu2,coim,con1,conij,rankall,
	 he,Mm,Nvec,Fhe,Ff,Uu,Num,ltilde,Fh1,Fh2,Fh3,Fh4,Fh5,
	 listcoefki,external,r,ltil,tensorprefac,dotloc,lvec,le,
	 mulist,ext,contractextint,prefaclist,prenumb,
	 nontensornumerator,loopmomcheck,kchanged,indexlist,inctens2,inctens,tenslist,hgchanged,
	 nonposprops,nonposindices,derivatives,PowF,PowU,Quot,DQuot,FUFactors,UFunc,FFunc,
	 setzero,renamevars,tt}
    ,
    
    reploc=repl;
    loops=Length[momlist];
    props=Length[proplist];
    deno=Sum[tt[i]*proplist[[i]],{i,props}];
    (*Print["calcFU.m: reploc=",reploc];Print["calcFU.m: deno=",deno];*)
    
    (* needed for numerator: *)
    
    (* BEGIN initialize *)
    rankall=0;
    
    (* construct list of contracting (external) vectors for each loop momentum *)
    
    Do[listcoefki[i]={},{i,loops}];
    external={};
    Do[r[i]=0,{i,props}];
    nontensornumerator=1;
    (*Transformation rules where all loop momenta are replaced by 0:*)
    loopmomcheck=Table[momlist[[i]]->0,{i,Length[momlist]}];

    (* END initialize *)

    Do[
       kchanged=False;
       For[i=1,i<=loops,i++,
	   exn1=Expand[numerator[[iterator]], momlist[[i]]];
	   For[j=1,j<=i,j++,
	       exn2=Expand[exn1,momlist[[j]]];
	       conij[i,j]=Coefficient[exn2, momlist[[i]]*momlist[[j]]];
	       (*Coefficients conij[i,j] of numerator list entries such as 3*k1*k2 where 
		k1 and k2 are the loop momenta and 3 is a prefactor arbitrarily chosen 
		by the user are NOT extracted*) 
	       If[conij[i,j]=!=0, 
		  kchanged=True;
		  (*Construct correct double indices for contraction of metric tensors 
		   with Mtilde^-1 (=Fhe) and multiplication with vectors ltilde*)
		  r[i]=r[i]+1;
		  tmu1=mu[i,r[i]];
		  r[j]=r[j]+1;
		  tmu2=mu[j,r[j]];
		  (* Double indices containing the loop momentum and the corresponding 
		   Lorentz index written to external *)
		  external=Append[external,hgmn[tmu1,tmu2]];
		  ];
	       ]; (* end loop over j *)
	   con1=Coefficient[exn1,momlist[[i]]];
	   (*In following if statement coefficients con1 for numerator list 
	    entries such as 3*p1*k1 where k1 is a loop momentum, p1 an external 
	    one and 3 a prefactor arbitrarily chosen by the user are extracted:*)
	   If[MatchQ[con1/.loopmomcheck,0]==False,
	      kchanged=True;
	      r[i]=r[i]+1;
	      (*SB-01/23/2013: This line seems to be outdated: listcoefki[i]=Append[listcoefki[i],con1];*)
	      external=Append[external,extvec[con1,mu[i,r[i]]]];
	      ];
	   ]; (* end loop over i *)
       (*In following if statement constants/contracted external momenta/etc 
	independent of any loop momenta are extracted:*)
       If[kchanged==False,
	  nontensornumerator=nontensornumerator*(numerator[[iterator]]//.spreplace//.reploc/.repall);
	 ];
       ,{iterator,Length[numerator]}
       ];
	  
       (* the mu[i,r[i]]] are the Gamma_i: r is r-th Lorentz index belonging to the ith loop momentum *)
       
    Do[looprank[i]=r[i],{i,loops}];
    rankall=Sum[looprank[i],{i,loops}];
    Print["rankall=",rankall];
    pp=Floor[rankall/2];
    
       
    (* *********** Denominator ************* *)
    
    rem=deno;
    For[i=1,i<=loops,i++,
	ex1=Expand[rem, momlist[[i]]];
	For[j=1,j<=loops,j++,
	    ex2=Expand[ex1,momlist[[j]]];
	    coij[i,j]=Coefficient[ex2, momlist[[i]]*momlist[[j]]];
	    If[i<j , coim[i,j]=1/2*coij[i,j],
	       coim[i,j]=coij[i,j] ];
	    rem=Factor[rem-coim[i,j]*momlist[[i]]*momlist[[j]]];
	    ];
	]; 
    Mm=Table[Table[coim[i,j],{i,loops}],{j,loops}];
    For[i=1,i<=loops,i++,
	ex3=Expand[rem, momlist[[i]]];
	co1[i]=Coefficient[ex3, momlist[[i]],1];
	rem=rem-co1[i]*momlist[[i]];
	];

    (* Nvec corresponds to Qvec of Int.J.Mod.Phys.A23:1457 (2008), 
     Fhe corresponds to Mtilde^-1, rem corresponds to J, Fh1 to F(x), 
     Uu to U(x)*)

    rem=Expand[rem];
    Nvec=Cancel[-1/2*Table[co1[i],{i,loops}]];
    Uu=Collect[Det[Mm],Table[tt[i],{i,props}]];
    Fhe=Cancel[Uu*Inverse[Mm]];
    ltilde=Simplify[Expand[Fhe.Nvec],TimeConstraint->7];
    Fh1=Expand[Nvec.Fhe.Nvec-rem*Uu];
    Fh2=Expand[Fh1]//.spreplace;
    Fh3=Simplify[Fh2//.reploc/.repall,TimeConstraint->7];
    Ff=Simplify[Collect[Fh3,tt/@Range[props]]/.mandelstamrepl,TimeConstraint->7];
			
    (* ************* Numerator: ********************* *)

    If[!invprops,
    (* Numerator given in terms of scalar products *)
		       
    ltil[kloop_]:=ltilde[[kloop]];

    (*tensorprefac computes the prefactor (-1/2)^m Gamma[N_nu-m-L*D/2] F^m *)
    tensorprefac[dd_]:=Block[{res},
			     pp=Simplify[(rankall-dd)]/2;
			     res=(-1/2)^pp/(Product[Simplify[sumpow-loops*Dim/2-m],{m,1,pp}])*(Ff//.spreplace//.reploc/.repall)^pp;
                             Return[res];
			     ];
		       
    dotloc[x_,y__]:=Block[{ex},
			  ex=Expand[x*y]//.spreplace//.reploc/.repall;
			  Return[ex]
			  ];
			  
    If[rankall>0, (*tensor structure in numerator*)
       mulist=Flatten[Table[Table[mu[i,r],{r,looprank[i]}],{i,loops}]];

       (*All possible combinations of double indices containing the loop momentum 
	and the corresponding Lorentz index, definition of allcombs in miscel.m*)
       indexlist=allcombs[mulist];
       inctens2[{ic2_}]:=lt[ic2];
       inctens2[{ic2a_,ic2b_}]:=hgmn[ic2a,ic2b];
       inctens[inclist_]:=Times@@(inctens2/@inclist);
       (*Make tensor list with either products of vectors ltilde or Fhe*gmunu or 
	both, depending on tensor structure*)
       tenslist=inctens/@indexlist;
       tenslist=tenslist//.hgmn[mu[aa_,b_],mu[c_,d_]]:>Fhe[[aa,c]]hgchanged[mu[aa,b],mu[c,d]];
       tenslist=tenslist//.hgchanged->hgmn;
       (*Find correct prefactor for each summand in numerator, dependent on m*)
       ext=Times@@external;
       (* contract the tensor parts with all necessary gmunu`s *)
       contractextint=contractmunu[ext,tenslist];
        prefaclist=whichprefactor/@contractextint;
        prenumb=(contractextint.prefaclist)/.{extdot->dot, intdot->dot};
        prenumb=prenumb//.{lt->ltil}/.{dot -> dotloc};
	(* note that the Factor command does not allow a TimeConstraint *)
        Num=nontensornumerator*Simplify[prenumb/.{tensorprefactor->tensorprefac},TimeConstraint->3];
       (* changed 18.6.15 by GH, to avoid Factor command takes forever on whole numerator: *)
       (* expansion is done later in formPC.m, formContourPC.m 
       ordmax=Floor[rankall/2+2*loops];
       Print["ordmax=",ordmax];
       Numpre=Series[nontensornumerator*prenumb/.{tensorprefactor->tensorprefac},{eps,0,ordmax}];
       Do[Nume[i]=Factor[SeriesCoefficient[Numpre,i]];(*Print["Nume[",i,"]=",Nume[i]]*),{i,0,ordmax}];
       Num=Sum[eps^i*Nume[i],{i,0,ordmax}];*)
       ,
       Num=nontensornumerator;
       ];  (* endif rankall > 0 *)
	,

	(* Numerator given in terms of inverse propagators *)

	If[Or@@(MemberQ[numerator, #, Infinity]& /@momlist),
	   nontensornum=1; 
	   Print["WARNING: Numerator contains loop momenta although there are inverse propagators and will be ignored."],
	   nontensornum=Times@@numerator];

	nonposprops = Position[powerlist, _Integer?NonPositive,1];
	nonposindices = Extract[powerlist, nonposprops];
	derivatives = Partition[Riffle[tt/@ Flatten[nonposprops], -nonposindices], 2];

	PowF = Simplify[Plus@@powerlist - loops*Dim/2];
	PowU = Simplify[Plus@@powerlist - (loops+1)*Dim/2];

	Quot[F_, U_] = (U[##]^PowU/F[##]^PowF)& @@ Table[tt[i], {i, 1, Length[powerlist]}];
	DQuot[F_, U_] = Together[(D[Quot[F, U], ##]) & @@ derivatives];

	FUFactors[F_, U_] = (U[##]^Simplify[PowU+Plus@@nonposindices]
		      	    /F[##]^Simplify[PowF-Plus@@nonposindices])& 
		      	    @@ Table[tt[i], {i, 1, Length[powerlist]}];

	Num[F_,U_] = Together[DQuot[F,U]/FUFactors[F,U]];
	
	UFunc = (Evaluate[Uu /. Table[Rule[tt[i], Slot[i]], {i, 1, Length[powerlist]}]]) &;
	FFunc = (Evaluate[Ff /. Table[Rule[tt[i], Slot[i]], {i, 1, Length[powerlist]}]]) &;

	setzero = Rule[tt[#], 0] & /@ Flatten[nonposprops];
	renamevars =  MapIndexed[Rule[tt[#1], tt[First[#2]]] &, 
	              Complement[Table[i, {i, 1, Length[powerlist]}],Flatten[nonposprops]]];

	Num = (Num[FFunc, UFunc]/.Union[setzero,renamevars])*nontensornum;
	Uu = Uu/.Union[setzero,renamevars];
	Ff = Ff/.Union[setzero,renamevars];
	rankall = -2*Plus@@nonposindices;
	];

     (* Impose replacements of invariants on Numerator *)
	Num=Num//.spreplace//.reploc/.repall;
       If[MatchQ[reploc,{}]==False,Num=Num//.spreplace//.reploc/.repall];				
       tt[a_Integer] := z[a];
       he={Uu,Ff,Num,rankall,ltilde}/.{0.->0};			       				 
       Return[he];				
];
		       
	
(* ******************** with cutconstruct=1 ******************************** *)		      		       
		       
calcFUcut[graphlistin_,numexternallines_,numloops_,numerator_,onshell_:none]:=
    Block[{numvert,extprops,graphlist,nps,vertjoin,vertmatrix,
	   internalprops,iterator,posstreecuts,poss2treecuts,validtreecut,
	   valid2treecut,treecuts,twotreecuts,tt,NOTATREE,NOTA2TREE,
	   U,F,F0,Fmass,Fterm,nontensornum},
      (*sp[a_]:=ssp[a];*)
      sp[a_]:=Distribute[SP[ExternalMomenta[[a]],ExternalMomenta[[a]]]];
      sp[a_,b_]:=Distribute[SP[ExternalMomenta[[a]],ExternalMomenta[[a]]]]+
                 Distribute[SP[ExternalMomenta[[b]],ExternalMomenta[[b]]]]+
	       2*Distribute[SP[ExternalMomenta[[a]],ExternalMomenta[[b]]]]; 
      numvert=Max[#[[2]]&/@graphlistin];
      extprops=Table[{nul,{i,i+numvert}},{i,numexternallines}];
      numvert=numvert+numexternallines;
      graphlist=Join[extprops,graphlistin];
      
      
      nps=Length[graphlist];
      Attributes[vertjoin]={Orderless};
      Do[
	 If[i==j,vertjoin[i,j]=1,
	    vertjoin[i,j]=Sum[If[Or@@(graphlist[[iterator,2]]==#&/@{{i,j},{j,i}}),pr[iterator],0],{iterator,nps}]]
	 ,{i,numvert},{j,i,numvert}];
      vertmatrix=Table[vertjoin[i,j],{i,numvert},{j,numvert}];
      (* vertmatrix is an un-normalised transition matrix representation of the graph*)
      
      
      internalprops=Table[i,{i,numexternallines+1,nps}];
      posstreecuts=Subsets[internalprops,{numloops}]; (* all subsets of the internal propagators*)
      poss2treecuts=Subsets[internalprops,{numloops+1}];(* with the required length to define a tree/2-tree resp*)
      
      validtreecut[vlist_List]:=
      Module[{cutrep,newmatrix,test},
	     (* checks whether a given set of propagators, when removed from the graph, define a tree*)
	     cutrep=pr[#]->0&/@vlist;
	     newmatrix=(vertmatrix/.cutrep)/.pr[_]->1;
	     (* newmatrix is the transition matrix of the graph with the specified propagators removed *)
	     (* the specified propagators define a tree iff the resulting graph is connected *)
	     Do[newmatrix=newmatrix.newmatrix,{i,Floor[Log[2,numvert]+1]}];
	     (* if newmatrix^numvert has any zero entries, then the graph is unconnected, and thus not a tree*)
	     test=And@@(MatchQ[#,0]==False&/@Flatten[newmatrix]);
	     If[test,Return[vlist],Return[NOTATREE]]];
      
      valid2treecut[vlist_List]:=
      Block[{cutrep,newmatrix,j21,nj21,nj21i,valid2tree},
	    (* checks whether a given set of propagators, when removed from the graph, define a 2-tree*)
	    cutrep=pr[#]->0&/@vlist;
	    newmatrix=(vertmatrix/.cutrep)/.pr[_]->1;
	    (* newmatrix is the transition matrix of the graph with the specified propagators removed *)
	    (* the specified propagators define a 2-tree iff the resulting graph has exactly 2 connected components *)
	    Do[newmatrix=newmatrix.newmatrix,{i,Floor[Log[2,numvert]+1]}];
	    j21={1};nj21={};nj21i={};
	    Do[If[MatchQ[newmatrix[[1,j]],0],nj21=Append[nj21,j],j21=Append[j21,j]],{j,2,numexternallines}];
	    Do[If[MatchQ[newmatrix[[1,j]],0],nj21i=Append[nj21i,j]],{j,numexternallines+1,numvert}];
	    valid2tree=True;
	    (* the propagators define a 2-tree iff all vertices not joined to vertex 1 are joined to each other *)
	    If[nj21=={},valid2tree=False,
	       testvertex=nj21[[1]];valid2tree=And@@(MatchQ[newmatrix[[testvertex,#]],0]==False&/@Join[nj21,nj21i])];
	    If[valid2tree,Return[{vlist,If[Length[j21]<=Length[nj21],j21,nj21]}],Return[NOTA2TREE]]
	    ];
      
      
      treecuts=(validtreecut/@posstreecuts)//.{AA___,NOTATREE,BB___}->{AA,BB};
      twotreecuts=(valid2treecut/@poss2treecuts)//.{AA___,NOTA2TREE,BB___}->{AA,BB};
      Attributes[tt]={Listable};
      (* f@@expr replaces the head of expr by f, equal to Apply[f,expr] *)
      U=Plus@@(Times@@tt[#]&/@treecuts);
      Fterm[flist_List]:=-sp@@flist[[2]]*Times@@(tt[flist[[1]]]);
      F0=Plus@@(Fterm/@twotreecuts);
      Fmass=U Sum[graphlist[[i,1]]tt[i],{i,numexternallines+1,nps}];
      F=F0+Fmass;
      If[MatchQ[onshell,none]==False,F=Simplify[F//.spreplace//.onshell/.repall,TimeConstraint->7],F=F//.spreplace];
      tt[a_Integer]:=z[a-numexternallines];
      nontensornum=(Times@@numerator)//.spreplace//.onshell/.repall;
      Return[{U,F,nontensornum,0}]
      ];
	 
calcUserFunc[funclist_,scalarprodruls_,feynpars_] := 
	 Block[{tloc,funcrepl,sprodr={},prepl={}},
	       If[Head[scalarprodruls]==List, sprodr=scalarprodruls];
	       If[Head[spreplace]==List, prepl=spreplace];
	       funcrepl=funclist/.{z[i_] :> tloc[i]};
	       funcrepl=funcrepl//.sprodr//.prepl/.repall;
	       funcrepl=funcrepl//.{tloc->t};
	       Return[funcrepl];
	       ];

(* Returns True if integral is scaleless else False *)
scaleless[U_, F_, Nn_] :=
	 Block[{vecs, diffs, rank},
           If[MatchQ[F[z], 0], Return[True]]; (* Massless tadpole *)
           vecs =GroebnerBasis`DistributedTermsList[U[z]*F[z], z /@ Range[Nn]][[1,All, 1]];
           If[MatchQ[Length[vecs],1] && MatchQ[Length[vecs], Nn], Return[False]]; (* Massive tadpole *)
           diffs = (Delete[vecs, 1] - Table[vecs[[1]], {i, 1, Length[vecs] - 1}]);
           rank = MatrixRank[diffs];
           If[MatchQ[rank, Nn-1], Return[False], Return[True]];
	   ];
