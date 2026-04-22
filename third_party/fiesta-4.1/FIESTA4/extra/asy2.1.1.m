ASYVERSION="Asy2.1.1";



(* BadTermsAsy, in AdvancedVarDiffReplaceAsyFindN - last select *)

(*******************************************************************************)
(* QHull[pts,dim]: simplistic interface to QHull package

   Parameters:
     dim -- dimension of space (e.g., "2"),
     pts -- list of dim-dimensional points
       (e.g., "{{1,0},{0,1},{1,1},{0,0}}").
   Returns:
     list of convex hull faces, each represented by a
     list of point indices that are incident to the face
     (e.g., "{{3,2},{1,3},{2,4},{4,1}}").
   Note: necessary options from qhull manual:
   >
   > Fv - print vertices for each facet
   >
   > The first line is the number of facets. Then each facet is printed,
   > one per line. Each line is the number of vertices followed by the
   > corresponding point ids. Vertices are listed in the order they were
   > added to the hull (the last one added is the first listed).
*)

(*
ClearAll[QHull];

Options[QHull] = {
  Verbose    -> False,
  Executable -> "./qhull",
  Mode       -> "Fv",
  InFile     -> "./_qhi.tmp",
  OutFile    -> "./_qho.tmp" };
*)
  
QHull[pts_List, dim_Integer, ops___Rule] :=
  Module[{vb,ex,md,fi,fo,str,np,nf,fs,tm,i,s},

  vb = Verbose    /. {ops} /. Options[QHull];
  ex = Executable /. {ops} /. Options[QHull];
  md = Mode       /. {ops} /. Options[QHull];
  fi = InFile     /. {ops} /. Options[QHull];
  fo = OutFile    /. {ops} /. Options[QHull];

  np = Length[pts]; (* number of points *)

  (* write input file *)
  str = OpenWrite[fi];
  WriteString[str,ToString[dim] <> " # dimension\n"];
  WriteString[str,ToString[np] <> " # number of points\n"];
  For[i = 1, i <= np, i++,
    s = StringJoin[Riffle[ToString /@ pts[[i]],{" "}]];
    WriteString[str, s <> "\n"]];
  Close[str];

  (* run qhull program *)
  If[vb, Print["running qhull..."]];
  tm = Timing[Run[ex <> " " <> md <> " < " <> fi <> " > " <> fo]];
  If[vb, Print["done: ",tm[[1]]," seconds"]];

  (* read qhull output *)
  str = OpenRead[fo];
  nf = Read[str,Number]; (* number of facets *)
  fs = ReadList[str,Number,RecordLists->True];
  Close[str];

  (* adjust facet notations for Mathematica: *)
  (* - remove vertex counter (first element) from every entry *)
  (* - increment vertex indices (qhull assumes first index 0) *)
  Return[Drop[# + 1,1]& /@ fs]]

(*******************************************************************************)
Scalar[a_ + b_, c_] := Scalar[a, c] + Scalar[b, c];
Scalar[a_, b_ + c_] := Scalar[a, b] + Scalar[a, c];
Scalar[a_*b_, c_] := b Scalar[a, c] /; NumberQ[b];
Scalar[a_*b_, c_] := a Scalar[b, c] /; NumberQ[a];
Scalar[a_, b_*c_] := b Scalar[a, c] /; NumberQ[b];
Scalar[a_, b_*c_] := c Scalar[a, b] /; NumberQ[c];
Scalar[a_, a_] := Scalar2[a];
Scalar2[a_ + b_] := Scalar2[a] + 2 Scalar[a, b] + Scalar2[b];
Scalar2[a_*b_] := Power[a, 2]*Scalar2[b] /; NumberQ[a];
Scalar2[a_*b_] := Power[b, 2]*Scalar2[a] /; NumberQ[b];
Scalar2[-a_] := Scalar2[a];
Vector /: Vector[a_]*Vector[b_] := Scalar[a, b] ;
Vector /: Power[Vector[a_], 2] := Scalar2[a];
ScalarExponent[a_, x_] := 
  Exponent[PowerExpand[
    a /. {Scalar[x, _] -> x, Scalar[_, x] -> x, Scalar2[x] -> x^2}], 
   x];
ScalarCoefficient[a_, x_] := ScalarCoefficient[a, x, 0];
ScalarCoefficient[a_, x_, i_] := Module[{temp},
  If[i (i - 1) (i - 2) =!= 0, Print["Scalar coefficient error"]; 
   Abort[]];
  temp = Expand[a];
  If[Head[temp] === Plus, temp = List @@ temp, temp = {temp}];
  temp = Select[temp, (ScalarExponent[##, x] === i) &];
  If[i == 1, 
   temp = temp /. {Scalar[x, b_] :> Vector[b], 
      Scalar[b_, x] :> Vector[b]}];
  If[i == 2, 
   temp = temp /. {Scalar[x, b_] :> Indeterminate, 
      Scalar[b_, x] :> Indeterminate, Scalar2[x] :> 1}];
  Plus @@ temp
  ]
ScalarUF[xx_, yy_, z_] := 
  Module[{degree, coeff, i, t2, t1, t0, zz},
  zz = Map[Rationalize[##, 0] &, z, {0, Infinity}];
  degree = -Sum[yy[[i]]*x[i], {i, 1, Length[yy]}];
  coeff = 1;
  For[i = 1, i <= Length[xx], i++,
   t2 = ScalarCoefficient[degree, xx[[i]], 2];
   t1 = ScalarCoefficient[degree, xx[[i]], 1];
   t0 = ScalarCoefficient[degree, xx[[i]], 0];
    coeff = coeff*t2;
   degree = Together[Expand[(t0 - ((t1^2)/(4 t2)))] //. zz];
  ];
  degree = Together[-coeff*degree] //. zz;
  coeff = Together[coeff] //. zz;
  {coeff, Expand[degree], Length[xx]}]
RawPrintLn[x__] := WriteString[$Output, x, "\n"];

UF[xx_, yy_, z_] := Module[{temp, ynew, znew},
  temp = Union[Variables[(##[[1]] & /@ z)], xx];
  RawPrintLn["Variables for UF: ", temp];
  temp = Rule[##, Vector[##]] & /@ temp;
  ynew = Expand[yy /. temp] /. Prod[a_, b_] :> a*b;
  znew = Expand[z /. temp];
  ScalarUF[xx, ynew, znew]
]

(*******************************************************************************)
(* PExpand[fp,xs,sm]: main entry, expansion regions of a polynomial fp
     of variables xs, with small parameter x
   Parameters:
     fp -- polynomial (e.g. "x[1]*x[2]*m^2*y^2 + x[2]^2*M^2")
     xs -- variables (e.g. "{x[1],x[2]}")
     sm -- small parameter (e.g., "y")
   Returns:
     list of n-dimensional vectors (n -- number of ds),
     each entry corresponding to one region.
*)

ClearAll[PExpand];

Options[PExpand] = {
  Verbose -> False,
  IntegralDim -> Default
};



PExpand[fp_,xs_,sm_,ops___Rule] :=
  Module[{vb,id,nx,fm,cc,rm,rs,pr,re,qb,vs,vv,sy,sl,x,i,v,temp},
  vb = Verbose /. {ops} /. Options[PExpand];
  id = IntegralDim /. {ops} /. Options[PExpand];
  nx = Length[xs];
  If[id === Default, id = nx];

  If[vb,Print["integral dimension: ",id]];
  (* polynomial -> list of rules *)
  fm = CoefficientRules[fp,xs];
  (* find GCD of coefficients *)
  cc = PolynomialGCD @@ (#[[2]] & /@ fm);
  (* remove common factors, normalize, sort *)
  rm = Sort[Prepend[#[[1]], Simplify[#[[2]]/cc]]& /@ fm];
  (* coefficients -> scaling powers of small parameter *)
  rs=Flatten[(temp = Drop[##, 1]; 
    Prepend[temp, ##[[1]][[1]]] & /@ 
     CoefficientRules[##[[1]], sm]) & /@ rm, 1];

   If[vb,Print["points: ",rs]]; 
 
  (* aux function to determine rank of a set of points *)
  PRank[ps_List] := If[Length[ps] <= 1, 0, 
    MatrixRank @ Map[# - ps[[1]]&, Drop[ps,1]]];

  pr = PRank[rs];
  If[vb,Print["rank: ",pr, " id: ",id]];

  If[id != pr - 1,
    If[vb,Print["scaleless polynomial"]];
    Return[{}]];

  (* attempt to build projection (works for alpha-representation) *)
  rp = Drop[#,id - nx]& /@ rs;

  (* if this does not work, must introduce local variables, etc *)
  If[pr != PRank[rp],
    Print["projection does not work, alternative methods not implemented."];
    Return[{}]];

  qh = QHull[rp,pr,ops]; (* convex hull of projection *)
   If[vb,Print["convex hull: ",qh]]; 
  If[vb,Print["convex hull has ",Length[qh]," facets"]];

  (* normal vector composition: independent variables *)
  vs = v[#]& /@ Range[id];
  (* (nx+1)-dimensional   *)
  vv = Join[{1},ConstantArray[0,nx-id],vs];
  If[vb,Print["generic normal vector: ",vv]];

  For[i = 1; re = {}; qb = {}, i <= Length[qh], i++,
    sy = Join[
      # == v& /@ (rs[[qh[[i]]]].vv), (* facet normal, pointing up *)
      # >= v& /@ (rs.vv)]; (* other points lie above facet *)
    sl = FindInstance[sy,Append[vs,v]];
    If[Length[sl] != 0,
      re = Append[re, vv /. sl[[1]]];
      qb = Append[qb,i]]];

  If[vb,Print["bottom facets: ", qb]];

  (* remove artificial zeroth component '1' *)
  Return[Drop[#,1]& /@ re]]

(*******************************************************************************)
(* PApply[re,fp,xs,sm]: apply scaling re to a polynomial fp of variables xs
   Parameters:
     re -- region scaling set (e.g. "{-1,-2}")
     fp -- polynomial (e.g. "x[1]*x[2]^2*y*m + x[2]^3*M^2")
     xs -- variables (e.g. "{x[1],x[2]}")
     sm -- small parameter (e.g. "y")
   Returns:
     {pw,fe,sc},
     fe -- leading terms of fp
     pw -- scaling power of fe
     sc -- True if scaleless, False if scaleful
*)

ClearAll[PApply];

Options[PApply] = {
  Verbose -> False
};

PApply[re_List,fp_,xs_List,sm_,ops___Rule] :=
  Module[{i,ex,pw,fe,px,fl,vb,y},

  vb = Verbose /. {ops} /. Options[PApply];

  (* introduce explicit powers of small parameter *)
  ex = PowerExpand[Expand[fp /.
    Table[xs[[i]] -> xs[[i]]*sm^re[[i]],
    {i,Length[xs]}]]];

  px = Union[
    Cases[ex /. x^a_. :> y^a, c_. * y^a_. :> a /; FreeQ[c,y]],
    Cases[ex /. x^a_. :> y^a, c_ :> 0 /; FreeQ[c,y]]];

  (* extract leading terms *)
  pw = Min[px];
  fe = Coefficient[ex,x,pw];

  (* check scalefulness wrt each variable *)
  fl = Table[
    px = #[[1]][[1]]& /@ CoefficientRules[fe,xs[[i]]];
    Max[px]-Min[px], {i,1,Length[xs]}];


  Return[{pw,fe,MemberQ[fl,0]}]]

(*******************************************************************************)
(* AlphaRepExpand[ks,ds,cs,hi]: expansion in alpha-representation
   Parameters:
     ks -- list of loop momenta (e.g. "{v1}")
     ds -- list of denominators (e.g. "{v1^2 + m^2, (v1+p0)^2 + m^2}")
     cs -- kinematic constraints (e.g. "{p0^2 -> -M^2}")
     hi -- scalings wrt small parameter x (e.g. "{m -> m*x^1, M -> M*x^0 }")
   Returns:
   Note:
     uses global symbols x (as "x,x[1],x[2],...")
*)

ClearAll[AlphaRepExpand];


(*  a matrix 

    1    1/(mult+1)

    0    mult/(mult+1)

of size n


*)

FullRepMatrixAsy[i_, j_, n_,mult_] := 
 Normal[SparseArray[
   Append[Table[{l, l} -> If[l === j, 1/(mult+1), 1], {l, n}], {i, j} -> 
     mult/(mult+1)], {n, n}]]

AsySignRules[x_] := Module[{temp = {}, i},
  For[i = 1, i <= Length[x], i++,
   AppendTo[temp, Rule[x[[i]][[1]], x[[i]][[2]]*(2+i)^(5*(i+1))]];
   ];
  temp
  ]


(*the "bad terms" of an expression, have to be killed before determining regions*)
BadTermsAsy[0, _, _] := {}
BadTermsAsy[xx_, sm_, asysigns_] := Module[{temp,temp2},
  temp=Replace[xx,Join[AsySignRules[asysigns],{sm -> 0}],-1];
  temp=Expand[temp];
  If[Head[temp]===Plus,temp=List@@temp,temp={temp}];
 temp2=Select[temp, ((## /. {x[ii_] -> 1, y[ii_] -> 1}) < 0) &];
  If[Length[temp2]*2>Length[temp],temp2=Complement[temp,temp2]];
  temp2
]

(*a variable replacement for a function*)
MatrixReplaceAsy[xx_,MATRIX_]:=Module[{n,temp,rule,y},
  n=Length[MATRIX];
  rule = Apply[Rule, Transpose[{Array[x,n], MATRIX.Array[y,n]}], {1}];
    temp = xx /. rule;
    If[Head[xx] === List, 
      temp[[1]] = temp[[1]].MATRIX;
      temp[[2]] = temp[[2]]/Det[MATRIX];
    ];
    temp=Map[Together,temp,{2}];
    Return[Expand[temp /. y -> x]];

]

(* xx - function or a triple - function, matrix, determinant
yy - a pair of variables
sm - small parameter
searches for a possible replacement with these variables, parametrized by number n*)
AdvancedVarDiffReplaceAsyFindN[xx_, yy_, sm_, asysigns_] := Module[{temp, table, rule,temp2,yyy,n,current,numbers},
  Check[
   n=Last[Sort[Variables[xx]]][[1]];
   temp = If[Head[xx] === List, xx[[3]][[2]], xx];
   temp = BadTermsAsy[temp, sm, asysigns];
   current=Length[temp];
   temp = Variables[temp];
   temp = 
    If[Head[xx] === List, xx[[3]][[2]], 
      xx] /. {x[i_] :> If[MemberQ[temp, x[i]], x[i], 0]};
   temp = {Coefficient[Coefficient[Replace[temp,{sm -> 0},-1], x[yy[[1]]]], x[yy[[2]]]],
     Coefficient[Replace[temp,{sm -> 0},-1], x[yy[[1]]], 2] /. {x[yy[[1]]] -> 0, 
       x[yy[[2]]] -> 0},
     Coefficient[Replace[temp,{sm -> 0},-1], x[yy[[2]]], 2] /. {x[yy[[1]]] -> 0, 
       x[yy[[2]]] -> 0}};
   temp = Expand /@ temp;


   If[And[temp[[3]] =!= 0, temp[[2]] =!= 0],
    (* we have non-zero coefficients at yy1 yy2, yy2^2*)
    If[NumberQ[Together[temp[[1]]^2/(temp[[2]]*temp[[3]])]],
     temp = Sqrt[Together[temp[[3]]/temp[[2]]]];
      (*we can cancel out a full square product*)
     temp=Simplify[temp, And @@ (If[##[[2]] > 0, (##[[1]] > 0), (##[[1]] < 0)] & /@ asysigns)];
     If[Or[Head[temp/.AsySignRules[asysigns]] === Rational, Head[temp/.AsySignRules[asysigns]] === Integer],
      temp2=temp;
      Return[temp2];
      ,
      Print[temp];
      Print["STRANGE SQUARE ROOT"];
      ]
     ,
      Return[1];
     ]
    , (*it's linear by these variables*)
      fff = If[Head[xx] === List, xx[[3]][[2]], xx];
      numbers=-Select[Union[(##[[1]]/##[[2]]) & /@ Tuples[Union[Last /@ CoefficientRules[Replace[fff,{sm->0},-1], Array[x, n]]], 2]],((##/.AsySignRules[asysigns])<0)&];
      (*looking for all possible n that might kill some terms*)
(*
Print[numbers];

Print[{FullRepMatrixAsy[yy[[1]],yy[[2]],n,##],
       FullRepMatrixAsy[yy[[2]],yy[[1]],n,1/##],
      ##}]&/@numbers;


Print[{MatrixReplaceAsy[fff,FullRepMatrixAsy[yy[[1]],yy[[2]],n,##]],
       MatrixReplaceAsy[fff,FullRepMatrixAsy[yy[[2]],yy[[1]],n,1/##]],
      ##}]&/@numbers;

*)
      numbers={Length[BadTermsAsy[MatrixReplaceAsy[fff,FullRepMatrixAsy[yy[[1]],yy[[2]],n,##]],sm,asysigns]]
              +Length[BadTermsAsy[MatrixReplaceAsy[fff,FullRepMatrixAsy[yy[[2]],yy[[1]],n,1/##]],sm,asysigns]],##}&/@numbers;
      temp=Min@@(##[[1]]&/@numbers);
      (*making replacements, searching for one resulting in less bad terms*)
      If[temp<2*current,
	temp=Position[##[[1]]&/@numbers,temp][[1]][[1]];	
	Return[numbers[[temp]][[2]]];
      ,
	Return[1];
      ];
    ]; (*not equal to zero both*)



   ,(*check*)
   Print["AdvancedVarDiffReplaceAsyFindN"];
   Print[xx];
   Print[yy];
   Print[sm];
   Print[asysigns];
   Abort[];
   ] (*check*)
  ]


(*recursive function trying to kill bad terms*)
AdvancedKillNegTerms3Asy[ZZ_, level_, sm_,asysigns_] := 
 Module[{temp,temp2, vars, subsets, U, F, UF, i, mins, rs, r1, r2, pairs, 
   variants, min,MM,CC,MatrixN,Matrix,n,yy},
Check[
  {MM,CC,UF} = ZZ;
   n=Last[Sort[Variables[UF]]][[1]];
  temp = BadTermsAsy[UF[[2]], sm,asysigns];
  temp2=DeleteCases[DeleteCases[Variables[UF[[2]]],x[_]],sm];
  temp2=Complement[temp2,##[[1]]&/@asysigns];
  If[Length[temp2]>0,
	RawPrintLn["WARNING: some of the variables are left (",temp2,"), preresolution might work incorrectly"];
  ];     
  If[temp === {},    
      Return[{{{ZZ}, 0}}]
  ];
  vars = #[[1]] & /@ Cases[Variables[UF[[2]]], x[_]];
  subsets = Subsets[vars, {2}];
  variants = {};




(*all possible pairs of variables*)
  For[i = 1, i <= Length[subsets], i++, 
   MatrixN=AdvancedVarDiffReplaceAsyFindN[UF[[2]], subsets[[i]], sm,asysigns];
    (*found the best N for this pair*)
    yy=subsets[[i]];
    (* if it simplifies, recursively running itself*)
   If[And[Length[BadTermsAsy[MatrixReplaceAsy[UF[[2]],FullRepMatrixAsy[yy[[1]],yy[[2]],n,MatrixN]],sm,asysigns]]<Length[temp],
	  Length[BadTermsAsy[MatrixReplaceAsy[UF[[2]],FullRepMatrixAsy[yy[[2]],yy[[1]],n,1/MatrixN]],sm,asysigns]]<Length[temp]
      ],
      MATRIX=FullRepMatrixAsy[yy[[1]],yy[[2]],n,MatrixN];    
     r1 = 
      AdvancedKillNegTerms3Asy[
       MatrixReplaceAsy[{MM, CC, UF},MATRIX], 
       level + 1, sm,asysigns];
      MATRIX=FullRepMatrixAsy[yy[[2]],yy[[1]],n,1/MatrixN];    
     r2 = 
      AdvancedKillNegTerms3Asy[
       MatrixReplaceAsy[{MM, CC, UF},MATRIX], 
      level + 1, sm,asysigns];
     pairs = Tuples[{r1, r2}];
     variants = 
      Join[variants, {Join[##[[1]][[1]], ##[[2]][[1]]], ##[[1]][[2]] \
+ ##[[2]][[2]]} & /@ pairs];
     ];];
  If[Length[variants] == 0, 
    If[level === 1, Print["WARNING: preresolution failed"]];
      Return[{{{ZZ}, Length[temp]}}]
  ];
  If[level === 1,
   min = Min @@ ((##[[2]]) & /@ variants);
   i = Position[((##[[2]]) & /@ variants), min][[1]][[1]];
   RawPrintLn["Total number of negative terms remaining in subexpressions: \
", variants[[i]][[2]]];
    If[variants[[i]][[2]]>0,RawPrintLn["WARNING: possibly not all regions will be revealed"]];
   RawPrintLn["Total number of subexpressions: ", 
    Length[variants[[i]][[1]]]];
   Return[{variants[[i]]}];,
   Return[variants];
   ];
,
  Print[ZZ];
  Print[level];
  Print[sm];
  Print[asysigns];
  Abort[];
];

  ]

Options[AlphaRepExpand] = {
  PreResolve->False,
  Scalar->False,
  GenericPowers->False,
  AsySigns->{}
};


AlphaRepExpand[ks_List,ds_List,cs_List,hi_List,ops___Rule] :=
         Module[{up,fp,nl,xs,re,all,temp,temp2,yy,pre,scalar,genpow},

  Print[ASYVERSION];

  pre = PreResolve    /. {ops} /. Options[AlphaRepExpand];
  scalar = Scalar    /. {ops} /. Options[AlphaRepExpand];
  genpow = GenericPowers /. {ops} /. Options[AlphaRepExpand];
  asysigns = AsySigns /. {ops} /. Options[AlphaRepExpand];

If[scalar,
  {up,fp,nl} = ScalarUF[ks,ds,cs],
{up,fp,nl} = UF[ks,ds,cs]
];

If[Length[Cases[fp, Vector[_], {0, Infinity}]]>0,
  Print["Error in revealing vectors"];
  Print[fp];
  Abort[];
];

  (* multiply U with monomials for considering generic propagator powers *)
  If[genpow, up *= Product[x[i], {i,1,Length[ds]}]];

  If[pre,
  
    (* produce alpha-parametrization *)
    
  
    all={up,fp,nl};
    all=AdvancedKillNegTerms3Asy[{IdentityMatrix[Length[ds]],1,Take[all,2]//.hi},1,x,asysigns][[1]][[1]];
    all=(temp=##[[1]];temp2=##[[2]];{temp,temp2,##}&/@AlphaRepExpandFunction[{##[[3]][[1]],##[[3]][[2]],nl},Length[ds],hi,ops])&/@all;
    all=Flatten[all,1];
    all={yy=Range[Length[##[[1]][[1]]]];temp=##[[1]];Apply[Rule,Transpose[{(x[##] & /@ yy), temp.(y[##] & /@ yy)}], {1}],##[[2]],##[[3]]}&/@all;
    Return[all]
  ,
    Return[AlphaRepExpandFunction[{up,fp,nl},Length[ds],hi,ops]];
  ];

  ]

AlphaRepExpandFunction[{up_,fp_,nl_},lds_,hi_List,ops___Rule] :=
  Module[{xs,re},

  (* alpha-parameters *)
  xs = Table[x[i],{i,1,lds}];

  re = PExpand[up * fp /. hi, xs, x, ops, IntegralDim -> lds-1];

  (* only unique regions *)
  re = Union[re];

  Return[re]]

(*******************************************************************************)
(* WilsonExpand[fp,up,xs,hi]: expand polynomials related to Wilson line integrals
   Parameters:
     fp -- polynomial
     up -- polynomial
     xs -- variables
     hi -- scalings wrt small parameter x
   Note:
     uses global symbol x
*)

Options[WilsonExpand] = {
  Delta->False
};

WilsonExpand[fp_,up_,xs_List,hi_List,ops___Rule] :=
  Module[{re,fr,ufr,i,delta},

  delta = Delta /. {ops} /. Options[WilsonExpand];

  (* expand both polynomials, dimension = Length[xs]
     (or dimension = Length[xs]-1 if with delta function *)
  If[delta,
    re = PExpand[up*fp /. hi, xs, x, ops, IntegralDim -> Length[xs]-1],
    re = PExpand[up*fp /. hi, xs, x, ops]];

  (* properties of each region *)
  Do[
    fr = PApply[re[[i]],fp /. hi,xs,x, ops];
    ufr = PApply[re[[i]],up*fp /. hi,xs,x, ops];
    Print[">>> ",re[[i]],
      If[ufr[[3]]," !!! scaleless !!!",""],"\n",
        "  F (~x^",fr[[1]],") -> ",fr[[2]]];
  , {i,1,Length[re]}];

  Return[re]];

WilsonExpandDelta[fp_,up_,xs_List,hi_List,ops___Rule] :=
  WilsonExpand[fp, up, xs, hi, ops, Delta->True]


(*******************************************************************************)



AsyLoaded=True;
