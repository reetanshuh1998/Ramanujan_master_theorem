(*
#****m* SecDec/general/src/deco/split.m
# NAME
#  split.m
# USED BY
#  subdir/graph/graph.m
# INPUT
# output of collecteps in prepareinput.m
# PURPOSE
#  for variable x with singularities at both x->0 and x->1, the integration is split
#  in two at x=1/2, such that all singularities now occur at x'->0
# NOTE
# list of  indices of variables to be split has to be given in Template.m
# spi is index of variable which will be split
# Nn is global
#****
*)

split[inlist_,spi_]:=Module[{u,t,history,Nloc,
                             varexpos,oneminvarexpos,
                             varlist,oneminvarlist,
			     integrand,den,catflag,nfus1,nfus2,
			     rem,repl1,repl2,limits,
			     newden1,newnum1,newjaco1,
			     newden2,newnum2,newjaco2,
			     newvarlist1,newEx1,detjac1,
			     oneminvarexpos1,oneminvarlist1,history1,
			     newvarlist2,newEx2,detjac2,
			     oneminvarexpos2,oneminvarlist2,history2,
			     countpole1,iex1,minew1,
			     catflag1,newcatflag1,newint1,
			     countpole2,iex2,minew2,
			     catflag2,newcatflag2,newint2,
			     catlist,numnewsecs,outlist,splitres},

Nloc=Nn;
history=inlist[[1]];
varexpos=inlist[[2]];
varlist=inlist[[3]];
oneminvarexpos=inlist[[4]];
oneminvarlist=inlist[[5]];
integrand=inlist[[6]];
catflag=inlist[[7]];

(* replace x[i] by local variables *)

Do[x[l]=u[l], {l,Nloc}];

(* subst u=1/2*x in I_< and u=1-x/2 in I_> *)
(* newvarlist is only an info about transformations of original z[i]s, 
   actual powers of u[i] monomials are coded in varexpos  *)

(* replacements for I_< : *)

rem=Complement[Table[j,{j,Nloc}],{spi}];

repl1=Append[Table[u[rem[[l]]]->t[rem[[l]]],{l,Nloc-1}],u[spi]->t[spi]/2]; 


newvarlist1=Factor[varlist/. repl1];

(*detjac1=2^Simplify[-1-varexpos[[spi]]];*)
newint1=Append[(integrand/.repl1),{2,Simplify[-1-varexpos[[spi]]]}];
nfus1=Length[newint1];


(* if varlist is used as replacement rule for numerator function,
   factor 1/2 has to be kept. Nevertheless it also has to 
   be included in detjac1 because in eps expansion x[i]
   are assumed to have no factors 1/2  *)
 
newEx1=varexpos;
oneminvarexpos1=oneminvarexpos;
oneminvarlist1=oneminvarlist/. repl1;
history1=Append[history,1];


(* replacements for I_> : *)

repl2=Append[Table[u[rem[[l]]]->t[rem[[l]]],{l,Nloc-1}],
             u[spi]->1-t[spi]/2]; 

newvarlist2=Factor[varlist/. repl2];

newint2=Append[(integrand/.repl2),{2,Simplify[-1-oneminvarexpos[[spi]]]}];
nfus2=Length[newint2];

   
oneminvarlist2=oneminvarlist/. repl2;
(* oneminvarlist2 gives 1-var terms, no matter if they have been
   1-var's originally or if they come from trafo *)
oneminvarlist2[[spi]]=1-t[spi]/2;
oneminvarexpos2=oneminvarexpos;
oneminvarexpos2[[spi]]=varexpos[[spi]];
newEx2=varexpos;
newEx2[[spi]]=oneminvarexpos[[spi]];
history2=Append[history,2];

countpole1=0;
iex1=newEx1/.{eps->0};
Do[If[Ceiling[iex1[[k]]]<0,countpole1=countpole1+1], {k,Nloc}];
countpole2=0;
iex2=newEx2/.{eps->0};
Do[If[Ceiling[iex2[[k]]]<0,countpole2=countpole2+1], {k,Nloc}];

limits=Join[Table[t[l]->0,{l,Nloc}],{eps->0.001}];

minew1=Table[1,{i,nfus1}];
minew2=Table[1,{i,nfus2}];

Do[
minew1[[r]]=Factor[newint1[[r,1]]/. limits];
If[minew1[[r]]==0, catflag1[r]=B,catflag1[r]=A,catflag1[r]=A];
,{r,nfus1}];

Do[
minew2[[r]]=Factor[newint2[[r,1]]/. limits];
If[minew2[[r]]==0, catflag2[r]=B,catflag2[r]=A,catflag2[r]=A];
,{r,nfus2}];


newcatflag1=Table[catflag1[r],{r,nfus1}];
newcatflag2=Table[catflag2[r],{r,nfus2}];

Clear[x];
Clear[u];
Do[t[l]=x[l], {l,Nloc}];

(* create list of new exponents and F's *)
 
outlist[1]={history1,newEx1,newvarlist1,oneminvarexpos1,oneminvarlist1,newint1,newcatflag1}; 
outlist[2]={history2,newEx2,newvarlist2,oneminvarexpos2,oneminvarlist2,newint2,newcatflag2}; 

splitres=Table[outlist[i],{i,2}];
(* contains the two summands of I after splitting at 1/2 *)
Return[splitres]

(* close Module *)
]
