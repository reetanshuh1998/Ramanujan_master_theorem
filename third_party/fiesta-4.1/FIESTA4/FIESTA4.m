(*
    Copyright (C) Alexander Smirnov and Mikhail Tentyukov.
    The program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 2 as
    published by the Free Software Foundation.

    The program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
*)
Group;
If[TrueQ[$VersionNumber>=8.0],
  Off[General::compat];
  Needs["Combinatorica`"];
  On[General::compat];
,
  <<Combinatorica`;
];

(* hack for strange Series stored in the database *)
Unprotect[Series];
Series[_, {_, _, -Infinity}] := 0;
Protect[Series];


Unprotect[Combinatorica`EmptyQ];
Remove[Combinatorica`EmptyQ];
Unprotect[SeriesCoefficient];
SeriesCoefficient[x_, y_Integer] := 0 /; And[NumberQ[x], y =!= 0]
pm;
ep;
z;
delta;

AllEntriesDebug;
WatchOnly;
NoDatabaseLock;
KillSmall;

StartingStage;
AbortStage;
ConservativeComplexShift;

If[Not[ValueQ[AsyLoaded]],
  AsyLoaded=False;
];


If[Not[ValueQ[OnlyPrepare]],
    OnlyPrepare=False; 
];


	    If[TrueQ[$VersionNumber>=9.0],
	      SetSystemOptions[CacheOptions -> Symbolic -> Cache -> False];
	      SetSystemOptions[CacheOptions -> Numeric -> Cache -> False];
	      SetSystemOptions[CacheOptions -> Developer -> Cache -> False];
	      SetSystemOptions[CacheOptions -> ParametricFunction -> Cache -> False];
	      SetSystemOptions[CacheOptions -> Quantity -> Cache -> False];
	    ,
	      SetSystemOptions[CacheOptions -> Symbolic -> False];
	      SetSystemOptions[CacheOptions -> Numeric -> False];
	      SetSystemOptions[CacheOptions -> Constants -> False];
	      SetSystemOptions[CacheOptions -> CacheKeyMaxBytes -> 1];
	      SetSystemOptions[CacheOptions -> CacheResultMaxBytes -> 1];
	    ];

If[Not[ValueQ[SeparateTerms]],
    SeparateTerms=False;
];





If[Not[ValueQ[DigitsLimit]],
    DigitsLimit=6;
];
	    


RegMode:=ValueQ[RegVar];

If[Not[ValueQ[BisectionVariables]],
    BisectionVariables={};
];

If[Not[ValueQ[BisectionPoint]],
    BisectionPoint=1/2;
];
BisectionPoints;


If[Not[ValueQ[PreResolve]],
    PreResolve=False;
];


If[Not[ValueQ[FixSectors]],
    FixSectors=True;
];


If[Not[ValueQ[TestF1]],
    TestF1=False;
];


If[Not[ValueQ[LambdaSplit]],
    LambdaSplit=4;
];

If[Not[ValueQ[LambdaIterations]],
    LambdaIterations=1000;
];


If[Not[ValueQ[ComplexMode]],
    ComplexMode=False;
];

If[Not[ValueQ[MaxComplexShift]],
    MaxComplexShift=1;
];

ComplexShift;
If[Not[ValueQ[AnalyticIntegration]],
    AnalyticIntegration=True;
];


If[Not[ValueQ[NegativeTermsHandling]],
    NegativeTermsHandling="Auto";
]; (* "AdvancedSquares", "AdvancedSquares2", "AdvancedSquares3", "Squares", "None", "Auto" *)

If[Not[ValueQ[ExactIntegrationOrder]],
    ExactIntegrationOrder=-Infinity;
];

If[Not[ValueQ[BucketSize]],
    BucketSize=25;
];


If[Not[ValueQ[OnlyPrepareRegions]],
    OnlyPrepareRegions=False;
];


If[Not[ValueQ[ExactIntegrationTimeout]],
    ExactIntegrationTimeout=10;
];


If[Not[ValueQ[IntegrationRule]],
    IntegrationRule={};
];

If[Not[ValueQ[ResolutionMode]],
    ResolutionMode="Taylor";
]; (* "Taylor", "IBP0", "IBP1" *)

If[Not[ValueQ[SmallNumberMultiplyers]],
    SmallNumberMultiplyers={3,300};
];


If[Not[ValueQ[NumberOfSubkernels]],
    NumberOfSubkernels=0;
];

If[Not[ValueQ[ReturnErrorWithBrackets]],
    ReturnErrorWithBrackets=False
];

If[Not[ValueQ[MemoryDebug]],
    MemoryDebug=False
];


If[Not[ValueQ[FastASY]],
    FastASY=False;
];

CPUCores;

CurrentIntegratorSettings;
MathematicaBinary;
If[Not[ValueQ[GPUIntegration]],
  GPUIntegration = False;
];

If[Not[ValueQ[d0]],
    d0=4;
];
If[Not[ValueQ[UsingC]],
    UsingC=True;
];

If[Not[ValueQ[FIESTAPath]],
    FIESTAPath=".";
];

CIntegratePath;

CurrentAsyPath[]:=FIESTAPath<>"/extra/asy2.1.1.m";

If[Not[ValueQ[NumberOfLinks]],
    NumberOfLinks=1;
];
If[Not[ValueQ[UsingQLink]],
    UsingQLink=True;
];


If[Not[ValueQ[DataPath]],
    DataPath=FIESTAPath<>"/temp/db";
];
If[Not[ValueQ[MixSectors]],
    MixSectors=0;
];
If[Not[ValueQ[CurrentIntegrator]],
    CurrentIntegrator="vegasCuba";
]


SmallX;   (* evaluation should be possible at {SmallX,...,SmallX} *)
MPThreshold;    (*  going to high precision if the Monom is less than MPThreshhold *)
MPPrecision;
MPMin;
PrecisionShift;   (* additional bits in multiprecision *)


STRATEGY_A;
STRATEGY_B;
STRATEGY_S;
STRATEGY_X;
STRATEGY_0;
STRATEGY_SS;
STRATEGY_KU0;
STRATEGY_KU;
STRATEGY_KU2;
PrimarySectorCoefficients;
PolesMultiplicity;

If[Not[ValueQ[STRATEGY]],
    STRATEGY=STRATEGY_S;
]; (*might be STRATEGY_0, STRATEGY_A, STRATEGY_B, STRATEGY_S, STRATEGY_X, STRATEGY_KU0, STRATEGY_KU, STRATEGY_KU2*)


If[Not[ValueQ[PMCounter]],
    PMCounter=1;
];

If[Not[ValueQ[RemoveDatabases]],
    RemoveDatabases=True;
];

If[Not[ValueQ[QHullPath]],
    QHullPath="qhull";
]


Begin["FIESTA`"];



ZREPLACEMENT:={z->-0.2};

MyWorstPower[x_Power, z_] := 
  If[Head[x[[1]]] === y, Min[##, 0] & /@ Exponent[x, z], 
   Abs[x[[2]]]*MyWorstPower[x[[1]], z]];
MyWorstPower[x_Plus, z_] := 
  Apply[Min, Transpose[MyWorstPower[##, z] & /@ List @@ x], {1}];
MyWorstPower[x_Times, z_] := 
  Apply[Plus, Transpose[MyWorstPower[##, z] & /@ List @@ x], {1}];
MyWorstPower[x_Integer, z_] := 0 & /@ z;
MyWorstPower[x_Rational, z_] := 0 & /@ z;
MyWorstPower[x_Log, z_] := 0 & /@ z;
MyWorstPower[x_y, z_] := 0 & /@ z;
MyWorstPower[x_, {}] := {};
MyWorstPower[EulerGamma, z_] := 0 & /@ z;
MyWorstPower[Pi, z_] := 0 & /@ z;
MyWorstPower[PolyGamma[_,_], z_] := 0 & /@ z;
MyWorstPower[Gamma[_], z_] := 0 & /@ z;
MyWorstPower[ExV, z_] := 0 & /@ z;
MyWorstPower[x_, z_] := 0 & /@ z /; NumberQ[x];


ZeroCheck[x_] := Module[{vars, i, temp},
  vars = Variables[x];
  For[i = 1, i <= 10, i++,
   temp = 
    Expand[x /. (Rule[##, 1/RandomInteger[{2, 10}]] & /@ vars)];
   If[temp =!= 0, Return[False]];
   ];
  True
  ]




MyToString[x__]:=If[UsingQLink,ToString[x,InputForm],x]
MyToExpression[x__]:=If[UsingQLink,ToExpression[x],x]
MyStringLength[x__]:=If[UsingQLink,StringLength[x],ByteCount[x]]

MyMemoryInUse[]:=If[NumberOfSubkernels>0,MaxMemoryUsed[]+Plus@@(ParallelEvaluate[MaxMemoryUsed[]]),MaxMemoryUsed[]]





CommandOptions:=Module[{temp="",i},
    If[ValueQ[CIntegratePath],
	temp=temp<>" -CIntegratePath "<>CIntegratePath;
    ];
    If[Not[CurrentIntegrator==="vegasCuba"],
	temp=temp<>" -integrator "<>CurrentIntegrator;
    ];
    If[ValueQ[MPPrecision],
        temp=temp<>" -MPPrecision "<>ToString[MPPrecision,CForm];
    ];
    If[ValueQ[SmallX],
	temp=temp<>" -SmallX "<>ToString[SmallX,CForm];
    ];
    If[ValueQ[MPThreshold],
	temp=temp<>" -MPThreshold "<>ToString[MPThreshold,CForm];
    ];
    If[ValueQ[MPMin],
        temp=temp<>" -MPMin "<>ToString[MPMin,CForm];
    ];
    If[ValueQ[PrecisionShift],
	temp=temp<>" -PrecisionShift "<>ToString[PrecisionShift,CForm];
    ];
    If[ValueQ[CurrentIntegratorSettings],
	 For[i=1,i<=Length[CurrentIntegratorSettings],i++,
	      temp=temp<>" -intpar "<>CurrentIntegratorSettings[[i]][[1]]<>" "<>CurrentIntegratorSettings[[i]][[2]];
	 ]
    ];
    If[ValueQ[CPUCores],
    	temp=temp<>" -cpu_used_per_worker "<>ToString[CPUCores];
    ];
    If[ValueQ[MathematicaBinary],
	temp=temp<>" -math "<>MathematicaBinary;
    ];
    If[ComplexMode,
	temp=temp<>" -complex";
    ];
    If[GPUIntegration,
	temp=temp<>" -gpu";    
    ];
    If[SeparateTerms,
	temp=temp<>" -separate_terms";
    ];    
    temp
]



InitializeQLink[Databases_]:=Module[{temp},
  If[UsingQLink,
        If[Head[QLink]===Symbol,
            QLink=Install[FIESTAPath<>"/bin/KLink"];
            If[Not[Head[QLink]===LinkObject],
                Print["Could not start QLink"];
                Abort[];
            ];            
            If[Not[TrueQ[QSetCompressionOn[]]],
                Print["Could not set database compression"];
                Abort[];            
            ];
            If[Not[TrueQ[QSetAutoBucketOn[]]],
                Print["Could not set automatic bucket"];
                Abort[];            
            ];
            If[Not[TrueQ[QSetBucketSize[BucketSize]]],
                Print["Could not set initial bucket"];                
                Abort[];            
            ];
            If[NoDatabaseLock,
                If[Not[TrueQ[QSetNoLock[]]],
		    Print["Could not turn database lock off"];                
		    Abort[];            
		];
	    ];
        ];
            (
            If[Not[QOpen[DataPath<>##]],
                Print["Could not open database ",##];
                Abort[];
            ];
            )&/@Databases;                            
    ];
]

TestIntegration[]:=Module[{temp},
    If[UsingC,
	If[Not[UsingQLink],
	    Print["UsingC=True can be used only with UsingQLink=True"];
	    Abort[];
	];
	RawPrintLn["Current integrator: ",CurrentIntegrator];
	
	command=FIESTAPath<>"/bin/CIntegratePool -test"<>CommandOptions;		
	res=ReadList["!"<>command,String];
	If[Not[And[Length[res]===2,res[[1]]==="Ok"]],
	    Print["CIntegratePool test failed"];	    
	    Print[command];
	    Print/@res;
	    Abort[];
	];
	RawPrintLn["CurrentIntegratorSettings: ",res[[2]]];
	RawPrintLn["Integration test passed"];	
    ];

]

StartSubkernels[restart_]:=Module[{temp},
    If[Or[Not[IntegerQ[NumberOfSubkernels]],NumberOfSubkernels<0],
        Print["Incorrect number of Subkernels"];
        Abort[];
    ];
    
	If[And[Length[Kernels[]]>0,Nor[restart]],
	    Return[];
	];
        
	If[Length[Kernels[]]>0,
	  ParallelEvaluate[Abort[]];
	  Parallel`Developer`ClearKernels[];
	  Parallel`Developer`ResetQueues[];
	  CloseKernels[];	
	];
	
	RawPrintLn["Starting ",Max[NumberOfSubkernels,1]," subkernels"];
	
        LaunchKernels[Max[NumberOfSubkernels,1]];
        DistributeDefinitions["FIESTA`"];
        If[NumberOfSubkernels==0,
	   RawPrintLn["Subkernel will be used for launching external programs, all evaluations go on main kernel."];
        ];
        
        ParallelEvaluate[
	     If[TrueQ[$VersionNumber>=8.0],
	
		Off[General::compat,SetDelayed::write];
		(*Print["oon"];*)
		Needs["Combinatorica`"];
		(*Print["ooff"];      *)
		On[General::compat,SetDelayed::write];
	      ,
		<<Combinatorica`;
	      ];
	
	    If[TrueQ[$VersionNumber>=9.0],
	      SetSystemOptions[CacheOptions -> Symbolic -> Cache -> False];
	      SetSystemOptions[CacheOptions -> Numeric -> Cache -> False];
	      SetSystemOptions[CacheOptions -> Developer -> Cache -> False];
	      SetSystemOptions[CacheOptions -> ParametricFunction -> Cache -> False];
	      SetSystemOptions[CacheOptions -> Quantity -> Cache -> False];
	    ,
	      SetSystemOptions[CacheOptions -> Symbolic -> False];
	      SetSystemOptions[CacheOptions -> Numeric -> False];
	      SetSystemOptions[CacheOptions -> Constants -> False];
	      SetSystemOptions[CacheOptions -> CacheKeyMaxBytes -> 1];
	      SetSystemOptions[CacheOptions -> CacheResultMaxBytes -> 1];
	    ];
        ];
 


]


InitializeAllLinks[]:=Module[{temp,i,j},
    
    If[Not[TrueQ[$VersionNumber>=7.0]],
      Print["This program only supports Mathematica 7 or higher"];
      Abort[];
    ];
    
    
    If[UsingQLink,
	If[FileExistsQ[DataPath<>"in.kch"],DeleteFile[DataPath<>"in.kch"]];
	If[FileExistsQ[DataPath<>"out.kch"],DeleteFile[DataPath<>"out.kch"]];
	If[FileExistsQ[DataPath<>"1.kch"],DeleteFile[DataPath<>"1.kch"]];
	If[FileExistsQ[DataPath<>"2.kch"],DeleteFile[DataPath<>"2.kch"]];
    ,
	Clear[Evaluate[ToExpression["dbin"]]];
	Clear[Evaluate[ToExpression["dbout"]]];	
	Clear[Evaluate[ToExpression["db1"]]];
	Clear[Evaluate[ToExpression["db2"]]];	
    ];   

    Options[Global`QHull] = {Global`Executable -> QHullPath, Global`InFile -> DataPath<>"_qhi.tmp", Mode -> "Fv", Global`OutFile -> DataPath<>"_qho.tmp"};
    
    TestIntegration[];

    StartSubkernels[True];

    CodeInfo[];

]




UF[xx_, yy_, z_] := Module[{degree, coeff, i, t2, t1, t0, zz},
    zz = Map[Rationalize[##,0]&, z, {0, Infinity}];
    degree = -Sum[yy[[i]]*x[i], {i, 1, Length[yy]}];
    coeff = 1;
    For[i = 1, i <= Length[xx], i++,
        t2 = Coefficient[degree, xx[[i]], 2];
        t1 = Coefficient[degree, xx[[i]], 1];
        t0 = Coefficient[degree, xx[[i]], 0];
        coeff = coeff*t2;
        degree = Together[t0 - ((t1^2)/(4 t2))];
    ];
    degree = Together[-coeff*degree] //. zz;
    coeff = Together[coeff] //. zz;
    {coeff, Expand[degree], Length[xx]}
]


VersionString:="FIESTA 4.1";
CodeInfo[]:=Module[{temp},
    RawPrintLn["UsingC: ",UsingC];
    RawPrintLn["NumberOfLinks: ",NumberOfLinks];
    RawPrintLn["UsingQLink: ",UsingQLink];
    RawPrintLn["Strategy: ",STRATEGY];
    If[And[Not[STRATEGY===STRATEGY_SS],GraphUsed===True],
        RawPrintLn["WARNING: a graph has been specified -> STRATEGY_SS recomended"];
    ]; 
    If[And[STRATEGY===STRATEGY_SS,Not[GraphUsed===True]],
        RawPrintLn["Error: STRATEGY_SS chosen -> SDEvaluateG or SDExpandG modes accepted only"];
        Abort[];
    ]; 
]



KillSmall[x_] := Module[{temp, main, add},
  temp = Variables[x];
  main = x /. ((## -> 0) & /@ temp);
  add = (x - main) /. ((## -> 1) & /@ temp);
  If[TrueQ[Or[And[Abs[main] < 3 Abs[add], Abs[main] < SmallNumberMultiplyers[[2]] * 10^-DigitsLimit],Abs[main]<SmallNumberMultiplyers[[1]]*10^-DigitsLimit]], 0, x]
 ]


CutExtraDigits[xx_]:=Map[If[And[NumberQ[##],Not[IntegerQ[##]]], Chop[N[Round[##,10^-DigitsLimit]],10^-DigitsLimit], ##] &,xx,{0,Infinity}];
DoubleCutExtraDigits[xx_]:=Module[{temp},
    If[xx===Indeterminate,Return[Indeterminate]];
    temp=DeleteCases[DeleteCases[Variables[xx],ExV],Log[ExV]];
    If[Length[temp]>1,Return[xx]];
    If[Length[temp]==0,Return[CutExtraDigits[xx]]];
    CutExtraDigits[xx/.(temp[[1]]->0)]+CutExtraDigits[(xx-(xx/.(temp[[1]]->0)))/.(temp[[1]]->1)]*temp[[1]]
]

PMSymbol:=If[$FrontEnd===Null,"+-","±"]

PMForm[xx_]:=Module[{temp},
    If[xx===Indeterminate,Return["INDETERMINATE"]];
    temp=DeleteCases[DeleteCases[Variables[xx],ExV],Log[ExV]];
    If[Length[temp]>1,Return[ToString[xx,InputForm]]];
    If[Length[temp]==0,Return[ToString[xx,InputForm]]];
    ToString[xx/.(temp[[1]]->0),InputForm]<>" "<>PMSymbol<>" "<>ToString[(xx-(xx/.(temp[[1]]->0)))/.(temp[[1]]->1),InputForm]
]







RawPrint[x__]:=WriteString[$Output,x];
RawPrintLn[x__]:=WriteString[$Output,x,"\n"];
RawPrintLn[]:=WriteString[$Output,"\n"];
PrepareDots[n_]:=Module[{temp},gn=n;gl={};For[gi=1,gi<=10,gi++,AppendTo[gl,Quotient[gi*gn,10]]];gi=0;]
Dots[]:=(gi++;While[And[Length[gl]>0,gi>=gl[[1]]],gl=Drop[gl,1];RawPrint["."]];)


CC[m_]:=(If[Mod[gi,m]===0,ClearSystemCache[]])
MyTimingForm[xx_]:=ToString[Chop[N[Round[xx,10^-4]],10^-4],InputForm]


If[Not[TrueQ[$VersionNumber>=6.0]],
  Print["ERROR!!! This program only supports Mathematica 7 or higher"];
];




FactorMonom[xxx_]:=Module[{xx,vars,i,monom,temp,var},
    xx=xxx;
    If[xx===0,Return[{0,0}]];
    vars=Union[Cases[xx, y[_], {0, Infinity}]];
    (*vars=Sort[Cases[Variables[xx],y[_]]];*)
    If[Head[xx]===Times,xx=List@@xx,xx={xx}];
    temp=-(var=##;Plus@@(Exponent[##,var^-1]&/@xx))&/@vars;
    monom=Times@@(vars^temp);
    {monom,Expand[Times@@xx/(monom)]}
]

FactorLogMonom[xxx_]:=Module[{xx,vars,i,monom,temp},
    xx=xxx;
    If[xx===0,Return[{0,0}]];
    vars=Sort[Cases[Variables[xx],Log[y[_]]]];
    temp=-Exponent[xx,##^-1]&/@vars;
    monom=Times@@(vars^temp);
    {monom,Expand[xx/(monom)]}
]


ConstructTerm[xx_]:=Module[{temp,i},
                temp=xx;
	      If[RegMode,temp[[1]]=If[##>0,2,0]&/@temp[[1]]]; (*strange fix???????*)
                If[Or[ExpandMode,RegMode],temp[[1]]=Drop[temp[[1]],-1];temp[[2]]=Drop[temp[[2]],-1];temp[[3]]=Drop[temp[[3]],-1]];  (*powers of ex var *)
               temp=  {Flatten[Position[Table[If[FreeQ[temp[[2]][[i]],z],temp[[1]][[i]],0],{i,Length[temp[[1]]]}],2]],
                        Inner[(#1^#2)&,Array[x,Length[temp[[1]]]],temp[[2]],Times]*
                        Inner[(Log[#1]^#2)&,Array[x,Length[temp[[1]]]],temp[[3]],Times]*
                        xx[[4]],If[Or[ExpandMode,RegMode],{Last[xx[[2]]],Last[xx[[3]]]},{0,0}],
                        xx[[5]]
                        };
               temp
]



MyExpandDenominator[x_] := Module[{part1, part2,temp},
  If[Head[x] === Power,
      temp={x};
  ];
  If[Head[x] === Times,
      temp=List@@x;
  ];
  If[Head[temp]=!=List,
    Return[x];
  ];
  part1 = Select[temp, (And[Head[##] === Power, ##[[2]] < 0]) &];
  part2 = Select[temp, Not[TrueQ[(And[Head[##] === Power, ##[[2]] < 0])]] &];
  part2=Times@@part2;
  part1=ExpandAll[##,ep]&/@part1;
  part1=Times@@part1;
  Return[part1*part2];
]


ZPosExpand[xx_]:=Module[{temp, result, shift, i},
    Check[
	shift=0;
	
	
	
	temp={xx[[1]], xx[[2]], xx[[3]],  xx[[4]]/.MBshiftRules[z], xx[[5]], xx[[6]]};
	
	While[Quiet[Check[z=0;Evaluate[temp[[4]]],False]===False],
	    Clear[z];
	    If[shift < -20,
		Print["big shift in ZPosExpand"];
		Print[xx];
		Abort[];
	    ];
	    shift--;
	    temp[[4]] = Expand[temp[[4]]*z,z];
	];
	shift=-shift;
	Clear[z];
	result = Reap[
	    der={temp};
	    j=0;
	    While[j<=shift,
		Sow[Append[##,j-shift]]&/@der;
		If[j==shift,Break[]];
		der=Flatten[(
		    DeleteCases[
			Append[
			    Table[
			      If[D[##[[2]][[i]],z]===0,
				  {},		
				  {##[[1]],##[[2]],ReplacePart[##[[3]],i->(##[[3]][[i]]+1)],##[[4]]*D[##[[2]][[i]],z],##[[5]],##[[6]]}
			      ]
				,
			    {i,Length[##[[1]]]}]
			,
			    {##[[1]],##[[2]],##[[3]],D[##[[4]],z],##[[5]],##[[6]]} (*differentiating the expression*)
			]
		    ,{}] (*variable has no power*)
		)&/@der,1];
		j++;
		der={##[[1]],##[[2]],##[[3]],##[[4]]/j,##[[5]],##[[6]]}&/@der;
	    ];
        ][[2]][[1]];
        z = 0;
        result = result;
        result=DeleteCases[result,{_,_,_,0,_,_,_}];
        Clear[z];
    ,
	Print["ZPosExpand error"];
	Print[xx];
	Abort[];
    ];
    result={Append[##[[1]],0],Append[##[[2]],##[[7]]],Append[##[[3]],0],##[[4]],##[[5]],##[[6]]}&/@result;
    If[Or@@((##[[4]]===ComplexInfinity)&/@result),
      Print["ZPosExpand error resulted in ComplexInfinity"];
      Print[xx];
      Abort[];
    ];
    (* now putting external var power to ind powers*)
    result 
]

EpPosExpand[xx_, extra_, inshift_, order_] := Module[{temp, shift, i, der, result},
    Check[shift = 0; temp = MyExpandDenominator[xx] /. MBshiftRules[ep];
        While[Quiet[Check[ep=0;Evaluate[temp],False]===False],
            Clear[ep];
            temp = Expand[temp*ep,ep];
            shift++;
            If[shift > 20,Print["big shift"]; Print[xx];
                Print[extra];
		Print[inshift];
                Print[order];
                Abort[];
            ];
        ];
        Clear[ep];
	If[inshift-shift>order,Return[{}]];
        result = Reap[
            Sow[{-shift + inshift, {temp, extra}}];
            der = {{temp, extra}};
            For[i = 1, i <= order -inshift + shift, i++,
                der = Flatten[If[
                    D[##[[2]][[1]], ep] =!= 0,
                    {{D[##[[1]], ep], ##[[2]]}, {##[[1]]*D[##[[2]][[1]], ep], {##[[2]][[1]], ##[[2]][[2]] + 1}}},
                    {{D[##[[1]], ep], ##[[2]]}}
                ] & /@ der, 1];
                Sow[{-shift + i + inshift, {##[[1]]/Factorial[i], ##[[2]]}}] & /@ der
            ]
        ][[2]][[1]];
        ep = 0;
        result = result;
        result=DeleteCases[result,{uu_,{0,vv_}}];
        Clear[ep];
   ,
   Print["ep pos expand"]; Print[xx];Print[extra];Print[inshift]; Print[order]; Abort[]];
   result
]




MyExponent[xxx_, yy_] := Module[{temp},
    xx=Expand[xxx/(xxx/.x[aaa_]->1)];
  temp = Exponent[xx /. ep -> 0, yy];
  Expand[(Exponent[xx /. ep -> 1, yy] - temp)ep + temp]
  ]



GroupTerms[xx_] := Module[{temp},
   temp =
    Reap[Sow[##[[3]], {{##[[1]], ##[[2]], ##[[4]]}}] & /@ xx, _,
      List][[2]];
   temp = {##[[1]][[1]], ##[[1]][[2]], (Plus @@ ##[[2]])*##[[1]][[3]]} & /@ temp;
   temp
   ];



FirstVars[xx__]:=Module[{vars},
  vars = Union[Cases[xx,x[aaa_],{0,Infinity}]];
  {xx/.Apply[Rule,Transpose[{vars,Array[y,Length[vars]]}],{1}],Length[vars]}
]

CountVars[xx__]:=Module[{vars},
  vars = Union[Cases[xx,y[aaa_],{0,Infinity}]];
  {xx,Max@@((##[[1]])&/@vars),(*Length[vars]*)10}
]


AdvancedFirstVars[{yyy_,xx_,zz_,uu_},second_]:=Module[{yy=x/@yyy,vars,rules},
   vars = Union[Cases[{xx,second},x[aaa_],{0,Infinity}]];
  vars=Sort[vars,(If[TrueQ[MemberQ[yy,#1]],If[TrueQ[MemberQ[yy,#2]],#1[[1]]<#2[[1]],True],False])&];
  rules=Apply[Rule,Transpose[{vars,Array[y,Length[vars]]}],{1}];
(*  {Sort[(##[[1]])&/@(yy/.rules)],xx/.rules,zz,uu}*)
  {xx/.rules,zz,uu,second//.rules}
]








UnsortedUnion[xx_] := Reap[Sow[1, xx], _, #1 &][[2]]

Format[if[x1_, x2_, x3_], InputForm] :=
  "if(" <> ToString[x1, InputForm] <> ")>(f[1])(" <>
   ToString[x2, InputForm] <> ")(" <> ToString[x3, InputForm] <> ")";


MyString[xx_]:=StringReplace[ToString[xx/.{Power->p,Log->l,y->x,Pi->P,EulerGamma->G},InputForm],{"\\"->"","\""->""}];

DoIntegrate[xx_,tryexact_] := Module[{temp2,vars, temp,i,rules,met,res},saved=xx;
    If[NumberQ[xx],Return[{True,xx}]];

    
vars =
Union[Cases[xx,y[aaa_],{0,Infinity}],Cases[xx,x[aaa_],{0,Infinity}]];
If[Length[vars]===0,Return[{True,Plus@@xx}]];
If[Plus@@xx===0,Return[{True,0}]];


        temp= Join[{Plus@@(xx)},{##, 0,1} & /@ vars];
        
        If[tryexact,
            res=Quiet[TimeConstrained[Integrate@@temp,ExactIntegrationTimeout,$Timeout]];
            If[And[Head[res]=!=Integrate,res=!=$Timeout],
                Return[{True,res}];
            ]
        ];
        temp=Join[temp,
            {Method -> AdaptiveQuasiMonteCarlo,
             Compiled->True,
             MinRecursion -> 100,
             MaxRecursion -> 10000,
             MaxPoints -> 100000,
             PrecisionGoal -> 4}];
        res=Apply[NIntegrate, temp, {0}];

        {False,res}
]



ZNegExpand[xx_]:=Module[{i,j,deg,ders,der,result},
Check[
    i=1;
    If[ExpandMode,
        For[j=1,j<=Length[xx[[1]]],j++,
            If[And[xx[[1]][[j]]===1,
		Coefficient[xx[[2]][[j]],z]<0,		
		(xx[[2]][[j]]/.{ep->0,z->0})<=0,-xx[[7]][[3]]+(xx[[2]][[j]]/.{ep->0,z->0} )<0]
	    ,
                i=j
            ]
        ]
    ];
    For[Null,i<=Length[xx[[1]]],i++,
        If[Or[xx[[1]][[i]]=!=1,Coefficient[xx[[2]][[i]],z]===0],Continue[]];
        If[Or[xx[[1]][[i]]=!=1,And[ExpandMode,Coefficient[xx[[2]][[i]],z]>0]],Continue[]];
        If[ExpandMode,
            deg=-xx[[7]][[3]]+(xx[[2]][[i]]/.{ep->0,z->0} ),
            deg=1+(xx[[2]][[i]]//.Flatten[{ep->0,ZREPLACEMENT}]);
        ];
	If[RegMode,deg=0.1+(xx[[2]][[i]]//.{ep->Indeterminate,z->0})];
        If[deg<0,
            Return[Flatten[ZNegExpand/@Reap[
                If[xx[[2]][[i]]-deg==0,Print["Impossible degree (z)"];Abort[]];
                ders={};(*vvv={};*)
                For[j=0,j+deg<0,j++,
                    If[j===0,der=xx[[4]],der=D[der,x[i]]/j];
                    (*AppendTo[vvv,(xx[[2]][[i]]+j+1)];*)
                    AppendTo[ders,der/.x[i]->0];
	      If[Expand[ders[[j+1]]]=!=0,
                    Sow[{ReplacePart[xx[[1]],0,i],
                         ReplacePart[xx[[2]],0,i],
                         xx[[3]],
                         ders[[j+1]]/(xx[[2]][[i]]+j+1),
                         xx[[5]],
                         xx[[6]]/.x[i]->0,
                         {xx[[7]][[1]],Append[xx[[7]][[2]],(xx[[2]][[i]]+j+1)],xx[[7]][[3]]-If[Length[Position[xx[[2]],xx[[2]][[i]]]]>0,0,j]}
                    }];
	      ];
                ];
	      If[Expand[xx[[4]]-(ders.Table[x[i]^(j-1),{j,Length[ders]}])]=!=0,
                Sow[{ReplacePart[xx[[1]],2,i],
                    xx[[2]],
                    xx[[3]],
                    xx[[4]]-(ders.Table[x[i]^(j-1),{j,Length[ders]}]),
                    xx[[5]],
                    xx[[6]],
                    xx[[7]]
                }];
	      ]
            ][[2]][[1]],1]];
        ];



    ];
,Print[xx];Abort[]];
{xx}

];


EpNegExpand[xx2_]:=Module[{i,j,deg,ders,der,HasDelta,temp,xx},
(*Check[*)
    xx=Take[xx2,6];
    For[i=1,i<=Length[xx[[1]]],i++,
        If[xx[[2]][[i]]===0,Continue[]];
	HasDelta=MemberQ[Variables[xx[[2]][[i]]],delta[_]];
	If[HasDelta,DeltaPower=Cases[Variables[xx[[2]][[i]]],delta[_]][[1]][[1]]];
	temp=xx[[2]];
	temp[[i]]=temp[[i]]/.delta[_]->0;
	xx[[2]]=temp;
        deg=(xx[[2]][[i]]/.Flatten[{ep->0,ZREPLACEMENT}]);
        If[And[xx[[1]][[i]]===1,deg<=0],
            Return[Flatten[EpNegExpand/@Reap[
            If[And[xx[[3]][[i]]===0,ResolutionMode==="IBP0"],
		If[HasDelta,Print["Resolution mode does not work with delta"];Abort[]];
                der=xx[[4]];
                For[j=0,j+deg<0,j++,
                    der=der/(j+1+xx[[2]][[i]]);
                    Sow[{ReplacePart[xx[[1]],0,i],
                         ReplacePart[xx[[2]],0,i],
                         ReplacePart[xx[[3]],0,i],
                         der/.(x[i]->0),
                         xx[[5]],
                         xx[[6]]/.(x[i]->0)
                    }];
                    der=-D[der,x[i]];
                    Sow[{ReplacePart[xx[[1]],2,i],
                         ReplacePart[xx[[2]],0,i],
                         ReplacePart[xx[[3]],0,i],
                         -der,
                         xx[[5]],
                         xx[[6]]/.(x[i]->0)
                    }];
                ];

                Sow[{ReplacePart[xx[[1]],2,i],
                    ReplacePart[xx[[2]],xx[[2]][[i]]+j,i],
                    xx[[3]],
                    der,
                    xx[[5]],
                    xx[[6]]
                }];
          ];
          If[And[xx[[3]][[i]]===0,ResolutionMode==="IBP1"],
		If[HasDelta,Print["Resolution mode does not work with delta"];Abort[]];
                ders={};
                der=xx[[4]];
                For[j=0,j+deg<0,j++,
                    der=der/(j+1+xx[[2]][[i]]);
                    AppendTo[ders,der/.x[i]->1];
                    Sow[{ReplacePart[xx[[1]],0,i],
                         ReplacePart[xx[[2]],0,i],
                         ReplacePart[xx[[3]],0,i],
                         Last[ders],
                         xx[[5]],
                         xx[[6]]/.(x[i]->1)
                    }];
                    der=D[der,x[i]]/i;
                    der=-der*i;
                ];
                Sow[{ReplacePart[xx[[1]],2,i],
                    ReplacePart[xx[[2]],xx[[2]][[i]]+j,i],
                    xx[[3]],
                    der,
                    xx[[5]],
                    xx[[6]]
                }];
          ];
          If[Or[xx[[3]][[i]]=!=0,ResolutionMode==="Taylor"],
                           ders={};
                For[j=0,If[HasDelta,j<DeltaPower,j+deg<0],j++,
                    If[j===0,der=xx[[4]],der=D[der,x[i]]/j];
                    AppendTo[ders,der/.x[i]->0];
		  If[Not[HasDelta],
                    Sow[{ReplacePart[xx[[1]],0,i],
                         ReplacePart[xx[[2]],0,i],
                         ReplacePart[xx[[3]],0,i],
                    If[((xx[[2]][[i]]+j+1)/.ep->0)===0,
                        ders[[j+1]] * ((-1)^xx[[3]][[i]]) * (xx[[3]][[i]]!)/(
                                                ((Coefficient[xx[[2]][[i]]+j+1,ep])^(xx[[3]][[i]]+1))
                                                )
                    ,
                            ders[[j+1]] * ((-1)^xx[[3]][[i]]) * (xx[[3]][[i]]!)/(
                                                ((xx[[2]][[i]]+j+1)^(xx[[3]][[i]]+1))
                                                )
                    ],
                    If[((xx[[2]][[i]]+j+1)/.ep->0)===0,
                            xx[[5]]-xx[[3]][[i]]-1,
                         xx[[5]]
                    ],
                    xx[[6]]/.(x[i]->0)
                    }];
		  ];
                ];
                Sow[{ReplacePart[xx[[1]],2,i],
                    xx[[2]],
                    xx[[3]],
                    xx[[4]]-(ders.Table[x[i]^(j-1),{j,Length[ders]}]),
                    xx[[5]],
                    xx[[6]]
                }];

          ];



            ][[2]][[1]],1]];
        ];



    ];
(*
,Print[xx2];Abort[]];    
*)
    {xx}

];


KillE[xx_] := Module[{deg, val},
  If[MemberQ[Variables[xx], e],
   deg = xx /. e -> 0;
   val = Cancel[(xx - deg)/e];
   If[deg < -3, 0, val*(10^deg)]
   ,
   xx
   ]
  ]

PMSimplify[xx_]:=PMSimplify[xx,ReturnErrorWithBrackets]
PMSimplify[xx_,MakeBrackets_] := Module[{temp},
  If[Length[Variables[xx]]===0,Return[xx]];
  temp = Sort[DeleteCases[DeleteCases[Variables[Expand[xx]],ExV],Log[ExV]]];
  If[MemberQ[temp,Indeterminate],Return[Indeterminate]];
  (xx /. (Rule[##, 0] & /@
       temp)) + ((Plus @@ (Abs[(Coefficient[xx, ##]/.Log[ExV]->0 )/.ExV->0]^2 & /@ temp))^(1/2))*
    If[MakeBrackets,pm[PMCounter++],ToExpression["pm" <> ToString[PMCounter++]]]
  ]



VarDiffReplace[xx_, yy_] := Module[{temp},
  temp = xx /. VarDiffRule[yy];
  Expand[temp /. y -> x]
]

VarDiffRule[xx_] := Module[{temp, i, j},
  temp =
   Table[If[i === j, If[i < Length[xx], 1, 2],
     If[j === Length[xx], -1, 0]], {i, 1, Length[xx]}, {j, 1,
     Length[xx]}];
  temp = Inverse[temp];
  Apply[Rule,
   Transpose[{(x[##] & /@ xx), temp.(y[##] & /@ xx)}], {1}]
]

AdvancedVarDiffReplace[xx_, yy_] := Module[{temp, table,rule},
Check[
  temp = If[Head[xx]===List,xx[[3]][[2]],xx];
  temp = NegTerms[temp];
  temp = Variables[temp];
  temp = If[Head[xx]===List,xx[[3]][[2]],xx] /. {x[i_] :> If[MemberQ[temp, x[i]], x[i], 0]};
  temp = {Coefficient[Coefficient[temp, x[yy[[1]]]], x[yy[[2]]]],
    Coefficient[temp, x[yy[[1]]], 2] /. {x[yy[[1]]] -> 0, 
      x[yy[[2]]] -> 0},
    Coefficient[temp, x[yy[[2]]], 2] /. {x[yy[[1]]] -> 0, 
      x[yy[[2]]] -> 0}
    };
  temp=Expand/@temp;
  If[And[temp[[3]]=!=0,temp[[2]]=!=0],
  If[NumberQ[Together[temp[[1]]^2/(temp[[2]]*temp[[3]])]],
   temp = Sqrt[Together[temp[[3]]/temp[[2]]]];
   If[Or[Head[temp] === Rational, Head[temp] === Integer],
    temp = {{1, temp/2}, {0, 1/2}};
    rule=Apply[Rule, 
      Transpose[{(x[##] & /@ yy), temp.(y[##] & /@ yy)}], {1}];
    temp = xx /. rule;
    Return[Expand[temp /. y -> x]];
    ,
    RawPrintLn["STRANGE SQUARE ROOT!"];
    ]
   ]];
  Return[VarDiffReplace[xx, yy]];
,
Print[xx];
Print[yy];
Abort[];
]
]


MyDot[xx_,yy_]:=(xx.##)&/@yy

BlockMatrix[MatrixList_, pos_, n_] :=
 Normal[SparseArray[
        Join[Rule[{##,##},1]&/@Complement[Range[n],pos],
     Flatten[Map[Rule[##[[1]][[1]], ##[[2]][[1]]] &, Map[UU, Outer[List, pos, pos], {2}] + Map[VV,##,{2}], {2}], 1]], {n,n}
        ]] &/@MatrixList

MatrixPart[MatrixList_, pos_] :=
 Transpose[Transpose[##[[pos]]][[pos]]] & /@ MatrixList



VariableSeries[xx_,var_]:=Module[{temp,shift,s,result,i},

Check[
    temp=xx/.(Log[var]->CCCC);
    temp=temp/.(Log[aaa_]->Normal[Series[Log[aaa],{var,0,VarExpansionDegree}]]);
    temp=Expand[temp];
    shift=0;
    While[TrueQ[MemberQ[{ComplexInfinity,Indeterminate},Quiet[(temp) /. var -> 0]]],
        temp=Expand[temp*var,var];
        shift++;
    ];
    s=shift;
    While[shift>0,
        temp=D[temp,var];
        shift--;
    ];
    temp=temp/(s!);
    result=0;
    For[i=0,i<=VarExpansionDegree,i++,
        result=result+ (var^i)*(temp/.var->0)*(s!/((s+i)!));
        temp=D[temp,var];
    ];
    result/.(CCCC->Log[var])
   (* ((temp/.var->0)+var((D[temp,var]/.var->0)-s(temp/.var->0)))/.(CCCC->Log[var])*)
,Print[xx];Abort[]]
]



ClearDatabase[index_,reopen_]:=Module[{name},
    name=RemoveFIESTAName[DataPath<>ToString[index]];
    QClose[name];
    DeleteFile[name<>".kch"];
    If[reopen,QOpen[name]];
]

RemoveFIESTAName[xx_]:=If[UsingQLink,StringReplace[xx,{"FIESTA`"->""}],xx];





MyParallelize[x_]:=If[NumberOfSubkernels>0,Parallelize[x(*,Method->"FinestGrained"*)],x];
SetAttributes[MyParallelize,HoldFirst];

SectorDecomposition[zs_,U_,intvars_,n_,j_,Z_]:=Module[{res,pol,active,SDDone,i,temp,degs},
  rules=Rule[x[##],1]&/@(zs);
            If[STRATEGY===STRATEGY_0,
                res={IdentityMatrix[n]};
                Goto[SDDone];
            ];
            If[STRATEGY===STRATEGY_SS,
                pol=Expand[Times@@U]/.rules;
                active=x[##]&/@Range[Length[intvars]];
                res=FindSD[{MyDegrees[pol,active]},MyDeleteEdges[CurrentGraph,zs]];
                active=##[[1]]&/@active;
                res=BlockMatrix[res,active,n];
                Goto[SDDone];
            ];
            If[STRATEGY===STRATEGY_X,
                pol=Expand[##/.rules]&/@U;
                active=(Union@@(Sort[Cases[Variables[##],x[_]]]&/@pol));
                res=FindSD[MyDegrees[##,active]&/@pol];
                active=##[[1]]&/@active;
                res=BlockMatrix[res,active,n];
                Goto[SDDone];
            ];
	    If[Or[STRATEGY===STRATEGY_KU0,STRATEGY===STRATEGY_KU,STRATEGY===STRATEGY_KU2],
		pol=Expand[Times@@U]/.rules;
		active=##[[1]]&/@Sort[Cases[Variables[pol],x[_]]];
		degs=MyDegrees[pol];
		res=Reap[
		  For[i=1,i<=Length[degs],i++,
		    temp=(##-degs[[i]])&/@degs;
		    temp=Join[temp,IdentityMatrix[Length[active]]];
		    temp=SimplexCones[temp];
		    Sow/@temp;
		  ];
		][[2]][[1]];
		res=Map[(##/(GCD@@##))&,res,{2}];
		res=(If[Det[##]>0,##,Join[{##[[2]],##[[1]]},Drop[##,2]]])&/@res;
                res=BlockMatrix[res,active,n];
		Goto[SDDone];
	    ];
            (* other strategies *)
                pol=Expand[Times@@U]/.rules;
                active=##[[1]]&/@Sort[Cases[Variables[pol],x[_]]];
                res=FindSD[{MyDegrees[pol]}];
                res=BlockMatrix[res,active,n];
            Label[SDDone];

            RawPrintLn["Primary sector ",j," resulted in ",Length[res]," sectors."];
            {res,{zs,U,intvars,n,j,Z}}
]


RequiredResidues[gamm_,var_]:=Module[{gammas,temp,temp1,temp2,gam},

Check[
    gam=gamm//. (Power[aa_, bb_] :> Timess @@ (Table[aa, {Abs[bb]}]));
    gammas = Cases[gam,  Gamma[aa__], Infinity];
    gammas = Select[gammas, (Length[Cases[##[[1]], z, Infinity]] > 0) &];

    temp1=Flatten[(res = {};
            i=0;
            
	    If[Coefficient[##[[1]], z] < 0,
		While[i>=-ExpandOrder,                               
		    AppendTo[res,{((i-(##[[1]]/.{z->0}))/Coefficient[##[[1]],z]),Sign[Coefficient[##[[1]],z]]}];i--;
		];
	    ];		
	
	res
    ) & /@ gammas, 1];


    temp2=Flatten[(res = {};
        If[(Coefficient[##[[1]], z] /. {ep->0})==0,Continue[]];
        i=0;
            AppendTo[res,{((i-(##[[1]]/.{z->0}))/Coefficient[##[[1]],z]),Sign[Coefficient[##[[1]],z]]}];i--;
        res
    ) & /@ ({##}&/@var), 1];


    temp=Join[temp1,temp2];



    temp=ExpandAll[temp];

    If[Not[And@@(Reap[Sow[HHH[##[[2]]],##[[1]]]&/@temp,_,(Length[Union[#2]]===1)&][[2]])],
	Print["something wrong in RequiredResidues"];
	Print[gam];Print[var];Abort[];
    ];
    
    temp=##[[1]] & /@ Reap[Sow[##, ##[[1]]] & /@ temp][[2]];

    temp=Append[##,tt=##[[1]];Length[Join[Select[gammas,And[IntegerQ[Expand[##[[1]]/.z->tt]],
			    Expand[##[[1]]/.z->tt]<=0
			      ]&],
			Select[var,(Expand[##/.z->tt]===0)&]
		    ]]
		  ]&/@temp;
		  
    (*Print[temp];*)
  ,
    Print[gam];Print[var];Abort[];
  ];
    
    temp
]

(*
MyExpand[f_,var_]:=f//. RuleDelayed[
  var^(aa_: 1)*(bb_:1)*expr_Plus, bb*((var^aa*##) & /@ expr)]*)

MyExpand[f_,var_]:=f//. RuleDelayed[
  var^(aa_: 1)*expr_Plus, ((var^aa*##) & /@ expr)]


MyResidue[vardegrees_,xx_,x0_,maxorder_]:=Module[{temp,i,j},
(*TimeConstrained[*)
        
    Check[
	If[Head[vardegrees]===Pair,
	  terms={{vardegrees[[1]],vardegrees[[2]],xx}}
	,
	  terms={{vardegrees,Table[0,{Length[vardegrees]}],xx}}
	];
(*Print[Timing[*)
        terms=terms //. ((aa_:1) z :> Expand[aa x0] + aa dx);
        terms=terms/. MBshiftRules[dx];

        terms={##[[1]],##[[2]],Distribute[(dx^maxorder)*##[[3]]]}&/@terms;

        terms = terms /. MBexpansionRules[dx, -1+maxorder];
      
(*]];*)


        For[i=1,i<=-1+maxorder,i++,
            terms=Append[Table[{##[[1]],ReplacePart[##[[2]],#[[2]][[j]]+1,j],##[[3]]*D[##[[1]][[j]],dx]},{j,Length[##[[1]]]}],
                        {##[[1]],##[[2]],D[##[[3]],dx]}]&/@terms;
            terms=Flatten[terms,1];
            terms=DeleteCases[terms,{aa_,bb_,0}];
        ];

        terms=({##[[1]],##[[2]],Expand[##[[3]],dx]/(-1+maxorder)!}&/@terms) /. (dx -> 0);

	terms=DeleteCases[terms,{aa_,bb_,0}];
        temp=terms;
        ,
        Print[vardegrees];Print[xx];Print[x0];Print[maxorder];Abort[]
    ];
(*Print[temp];*)
(*
,300,    Print[timeout];Print[vardegrees];Print[xx];Print[x0];Print[maxorder];Abort[]
];
*)
    Return[temp];
]


DefinedFor[x_] := (ReleaseHold[Apply[List, ##[[1]], 1]]) & /@ DownValues[x]
QPutWrapper[dbase_,key_,value_]:=If[UsingQLink,QPut[RemoveFIESTAName[DataPath<>dbase<>"/"],TaskPrefix<>"-"<>key,value],Evaluate[ToExpression["db"<>dbase]][TaskPrefix,key]=value]
QGetWrapper[dbase_,key_]:=If[UsingQLink,QGet[RemoveFIESTAName[DataPath<>dbase<>"/"],TaskPrefix<>"-"<>key],Evaluate[ToExpression["db"<>dbase]][TaskPrefix,key]]
QSafeGetWrapper[dbase_,key_,none_]:=Module[{temp},
    If[UsingQLink,
	temp=QCheck[RemoveFIESTAName[DataPath<>dbase<>"/"],TaskPrefix<>"-"<>key];
	If[temp,QGet[RemoveFIESTAName[DataPath<>dbase<>"/"],TaskPrefix<>"-"<>key],none]
    ,
	temp=Evaluate[ToExpression["db"<>dbase]][TaskPrefix,key];
	If[Head[temp]===Evaluate[ToExpression["db"<>dbase]],none,temp]
    ]
]
QSizeWrapper[dbase_]:=If[UsingQLink,QSize[RemoveFIESTAName[DataPath<>dbase<>"/"]],1000]
QListWrapper[dbase_]:=If[UsingQLink,QList[RemoveFIESTAName[DataPath<>dbase<>"/"]],(##[[1]])&/@DefinedFor[Evaluate[ToExpression["db"<>dbase]]]]
ClearDatabaseWrapper[dbase_]:=ClearDatabaseWrapper[dbase,True];
ClearDatabaseWrapper[dbase_,reopen_]:=If[UsingQLink,ClearDatabase[dbase,reopen],Clear[Evaluate[ToExpression["db"<>dbase]]]]


    PerformStage[s_,termss_,d_,prefix_,flatten_]:=Module[{temp,result,ev,terms},tasks={};
            RawPrint[MyTimingForm[AbsoluteTiming[
                terms=termss;
                If[terms===0,(*If[UsingQLink,terms=0;terms=Length[DefinedFor[ToExpression["db"<>ToString[s]]]]]*)
                    terms=Length[QListWrapper[s]]
                ];
                If[Not[d==="in"],ClearDatabaseWrapper[d]];
                PrepareDots[terms];
                For[runS=1;runD=1,runS<=terms,runS++,
                    Dots[];CC[100];
                    temp=ReadFunction[s,prefix,runS];
                    If[NumberOfSubkernels===0,
                        result=EvalFunction[temp];
                        If[flatten,result=result,result={result}];
                        WriteFunction[d,##,prefix]&/@result;
                    ,
                        If[Length[tasks]===NumberOfSubkernels,
                            finished={};
                            Parallel`Developer`QueueRun[];
                            finished=Select[tasks,(Head[##[[4]]]===Parallel`Developer`finished)&];
                            working=Select[tasks,(Head[##[[4]]]=!=Parallel`Developer`finished)&];
                            If[Length[finished]===0,
                                {result,ev,tasks}=WaitNext[tasks];
                                result={result};
                            ,
                                result=WaitAll[finished];
                                tasks=working;
                            ];
                            AppendTo[tasks,ParallelSubmit[{temp},EvalFunction[temp]]];
                            Parallel`Developer`QueueRun[];
                            If[flatten,result=Flatten[result,1]];
                            WriteFunction[d,##,prefix]&/@result;
                        ,
                            AppendTo[tasks,ParallelSubmit[{temp},EvalFunction[temp]]];
                            Parallel`Developer`QueueRun[];
                        ];
                    ]
                ];
                If[And[NumberOfSubkernels>0,Length[tasks]>0],
                    Parallel`Developer`QueueRun[];
                    result=WaitAll[tasks];
                    If[flatten,result=Flatten[result,1]];
                    WriteFunction[d,##,prefix]&/@result;
                ];
            ][[1]]]," seconds"];
            If[runD-1===0,
		RawPrintLn["."];
	    ,
		RawPrintLn["; ",runD-1," terms."];
	    ];
            If[MemoryDebug,RawPrintLn[MyMemoryInUse[]]];
            Return[runD-1];
    ]



PrintAllEntries[n_]:=Module[{temp},
		  list=MyToExpression[FIESTA`QGetWrapper[n,StringDrop[##,2]]]&/@Sort[FIESTA`QListWrapper[n],(MyToExpression[#1]<MyToExpression[#2])&];
		  If[ValueQ[WatchOnly],list=Cases[list,{WatchOnly,_}]];
		  Print[list];
			]

  
SDIntegrate[]:=Module[{time,stagetime,temp,UsingCDatabase,SCounter,ForEvaluation,runorder,SHIFT,EXTERNAL,iii},
time=MyTimingForm[AbsoluteTiming[
    (*If[Head[TaskPrefix]==Symbol,TaskPrefix="0"];*)

    If[NumberOfSubkernels>0,
	   DistributeDefinitions[DataPath,QHullPath,ResolutionMode,UsingQLink,RegVar,RegMode,ExpandOrder,ExV,ZREPLACEMENT,n,x,y,3rect,ExpandMode,UsingC,IntegrationRule];
    ];
    
    
    InitializeQLink[{"in","out"}];
    StartSubkernels[False];
    
    TaskPrefix="0";    
    TaskPrefixes=QSafeGetWrapper["in","","{}"];
    QPutWrapper["out","",TaskPrefixes];	
    RegVar=MyToExpression[QSafeGetWrapper["in","RegVar",MyToString[RegVar]]];
    SmallVar=MyToExpression[QSafeGetWrapper["in","SmallVar",MyToString[SmallVar]]];
    RequestedOrders=MyToExpression[QSafeGetWrapper["in","RequestedOrders",MyToString[RequestedOrders]]];
    QPutWrapper["out","RegVar",MyToString[RegVar]];
    QPutWrapper["out","SmallVar",MyToString[SmallVar]];
    QPutWrapper["out","RequestedOrders",MyToString[RequestedOrders]];	
    TaskPrefixes=ToExpression[TaskPrefixes];
    
    


    	  
    Clear[terms,terms0,nov];  
	  
	  
	  
    
    
    
    For[iii=1,iii<=Length[TaskPrefixes],iii++,  (* preparation cycle on prefixes *)
	TaskPrefix=ToString[TaskPrefixes[[iii]]];
   
    
	Check[
	  UsingCDatabase=MyToExpression[QGetWrapper["in","UsingC"]];
	 ,
	   Print["Database does not contain required info"];
	   Abort[];
	];
	If[UsingCDatabase=!=UsingC,
	    Print["The database was created with another UsingC setting"];
	    Abort[];
	];
	HasExact[TaskPrefix]=MyToExpression[QGetWrapper["in","Exact"]];
	QPutWrapper["out","Exact",MyToString[HasExact[TaskPrefix]]];
	ExternalExponent[TaskPrefix]=MyToExpression[QGetWrapper["in","ExternalExponent"]];
	QPutWrapper["out","ExternalExponent",MyToString[ExternalExponent[TaskPrefix]]];
	  
	If[HasExact[TaskPrefix],
	  ExactValue[TaskPrefix]=MyToExpression[QGetWrapper["in","ExactValue"]];
	  QPutWrapper["out","ExactValue",MyToString[ExactValue[TaskPrefix]]];	  
	,
	  SCounterAll[TaskPrefix]=MyToExpression[QGetWrapper["in","SCounter"]];
	  ForEvaluationAll[TaskPrefix]=MyToExpression[QGetWrapper["in","ForEvaluation"]];
	  minAll[TaskPrefix]=Min@@((##[[1]])&/@ForEvaluationAll[TaskPrefix]);
	  runorderAll[TaskPrefix]=MyToExpression[QGetWrapper["in","runorder"]];
	  SHIFTAll[TaskPrefix]=MyToExpression[QGetWrapper["in","SHIFT"]];
	  EXTERNALAll[TaskPrefix]=MyToExpression[QGetWrapper["in","EXTERNAL"]];
	  ExpandVariableAll[TaskPrefix]=MyToExpression[QGetWrapper["in","ExpandVariable"]];
	  QPutWrapper["out","ForEvaluation",MyToString[ForEvaluationAll[TaskPrefix]]];	    
	  QPutWrapper["out","runorder",MyToString[runorderAll[TaskPrefix]]];
	  QPutWrapper["out","SHIFT",MyToString[SHIFTAll[TaskPrefix]]];		
	  QPutWrapper["out","EXTERNAL",MyToString[EXTERNALAll[TaskPrefix]]];
	  QPutWrapper["out","ExpandVariable",MyToString[ExpandVariableAll[TaskPrefix]]];	
	  For[i=-SHIFTAll[TaskPrefix],i<=runorderAll[TaskPrefix]-SHIFTAll[TaskPrefix]-minAll[TaskPrefix],i++,		
		QPutWrapper["out","EXTERNAL-"<>ToString[i]<>"E",QGetWrapper["in","EXTERNAL-"<>ToString[i]<>"E"]];
		QPutWrapper["out","EXTERNAL-"<>ToString[i],QGetWrapper["in","EXTERNAL-"<>ToString[i]]];
	  ];
	    
	
	
	

	  If[UsingC,	  
	    For[EvC=1,EvC<=Length[ForEvaluationAll[TaskPrefix]],EvC++,
	      CurrentOrder=ForEvaluationAll[TaskPrefix][[EvC]][[1]];
	      CurrentVarDegree=ForEvaluationAll[TaskPrefix][[EvC]][[2]];
	      For[i=0,i<10,i++,
		  If[FileExistsQ[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-"<>ToString[i]],
		    DeleteFile[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-"<>ToString[i]]
		  ]
	      ];		      
	      If[FileExistsQ[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-R"],
		    DeleteFile[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-R"]
	      ];
	      terms[TaskPrefix,CurrentOrder,CurrentVarDegree]=ToExpression[QGetWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-T"]];
	      terms0[TaskPrefix,CurrentOrder,CurrentVarDegree]=ToExpression[QSafeGetWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-T0",terms[TaskPrefix,CurrentOrder,CurrentVarDegree]]];
	      nov[TaskPrefix,CurrentOrder,CurrentVarDegree]=ToExpression[QGetWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-N"]];
	    ];

	  ];  
	  
        ](*using C*)
     ];  (* preparation cycle on prefixes *)
	  
	  
      If[UsingC,  
      	  QClose[DataPath<>"in"];
	  command=FIESTAPath<>"/bin/CIntegratePool -in "<>DataPath<>"in -from_mathematica -threads "<>ToString[NumberOfLinks]<>CommandOptions;
	  If[NumberOfSubkernels == 0,
	    ReadList["!"<>command,String];
	    task = {0,0,0,0};
	  ,
	    DistributeDefinitions[command];	        	  
	    task=ParallelSubmit[(ReadList["!"<>command,String])];
	    Parallel`Developer`QueueRun[];  
	  ];
      ];  (* in case of C we started the program and closed the input database *)
	  
	  
	  
	  
	  

	  
    For[iii=1,iii<=Length[TaskPrefixes],iii++,
	TaskPrefix=ToString[TaskPrefixes[[iii]]];
	
	If[Or[Length[TaskPrefixes]>1,Not[ExternalExponent[TaskPrefix]===0]],
	    If[ExternalExponent[TaskPrefix]===0,
	      RawPrintLn["Integrating task ",TaskPrefix];
	    ,
	      RawPrintLn["Integrating task ",TaskPrefix," (multiplied by ",ToString[SmallVar],"^(",ToString[ExternalExponent[TaskPrefix],InputForm],"))"];
	    ];
	];
	
	If[HasExact[TaskPrefix],
	    RawPrintLn["We have an exact answer: ",ToString[ExactValue[TaskPrefix],InputForm]];
	    Continue[];
	];
	
	
	stagetime=MyTimingForm[AbsoluteTiming[
	
	
	SCounter=SCounterAll[TaskPrefix];
	ForEvaluation=ForEvaluationAll[TaskPrefix];
	min=minAll[TaskPrefix];
	runorder=runorderAll[TaskPrefix];
	SHIFT=SHIFTAll[TaskPrefix];
	EXTERNAL=EXTERNALAll[TaskPrefix];
	ExpandVariable=ExpandVariableAll[TaskPrefix];
	
	
	(*If[Length[TaskPrefixes]>1,RawPrintLn["Integrating task ",TaskPrefix]];*)
	
	
	
	If[UsingC,
	  For[EvC=1,EvC<=Length[ForEvaluation],EvC++,
            CurrentOrder=ForEvaluation[[EvC]][[1]];
            CurrentVarDegree=ForEvaluation[[EvC]][[2]];
            If[Union[(##[[2]])&/@ForEvaluation]=!={{0,0}},
                RawPrint["Terms of ep order ",CurrentOrder," and ",ExpandVariable," order ",ToString[CurrentVarDegree,InputForm],": "],
                RawPrint["Terms of order ",CurrentOrder,": "]
            ];
            If[SeparateTerms,
		RawPrint[terms[TaskPrefix,CurrentOrder,CurrentVarDegree]]
	    ,
		RawPrint[terms0[TaskPrefix,CurrentOrder,CurrentVarDegree]]
	    ];
            RawPrintLn[", max vars: ",nov[TaskPrefix,CurrentOrder,CurrentVarDegree]];                        
            RawPrint["Integrating"];            
	
	    RawPrintLn[MyTimingForm[AbsoluteTiming[     				
		i=0;
		While[i<10,		  
		  While[And[i<10,FileExistsQ[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-"<>ToString[i]]],
		    DeleteFile[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-"<>ToString[i]];
		    RawPrint["."];
		    i++;
		  ];
		  If[i==10,Break[]];
		  Parallel`Developer`QueueRun[];
		  If[Head[task[[4]]]===Parallel`Developer`finished,		    		    		  
		    Break[];
		  ];
		  Pause[1];
		];	
	      ][[1]]]," seconds."];
		While[True,
		   If[FileExistsQ[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-R"],		     
		      Break[];
		   ];
		   Parallel`Developer`QueueRun[];
		   If[Head[task[[4]]]===Parallel`Developer`finished,		    		    		      
		      Break[];
		   ];
		   Pause[1];
		];
		If[Head[task[[4]]]===Parallel`Developer`finished,		    		    		      
		    If[task[[4]][[1]]=!={},
			Print["CIntegratePool produced output. It means that an error was encountered. The received output follows:"];
			Print[task[[4]][[1]]];
			Abort[];
		    ];
		];

		temp=ReadList[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-R",String];

		DeleteFile[DataPath<>"out.kch-"<>TaskPrefix<>"-"<>ToString[CurrentOrder]<>"-"<>StringReplace[ToString[CurrentVarDegree,InputForm], "/" -> "|"]<>"-R"];
		
		If[Length[temp]=!=1,
		    Print["Incorrect result!"];
		    Abort[];
		];
		temp=temp[[1]];
		temp=StringReplace[temp,{"e"->"*10^"}];
		temp=MyToExpression[temp];
		
		result3=temp;
		(*result3={result3[[1]]+I*result3[[3]],Sqrt[result3[[2]]*result3[[2]]+result3[[4]]*result3[[4]]]};*)

		    temp=DoubleCutExtraDigits[result3];		    
		RawPrintLn["Returned answer: ",ToString[temp[[1]]+I*temp[[3]],InputForm]," + pm* ",ToString[temp[[2]]+I*temp[[4]],InputForm]];
		
            (*RawPrintLn["Returned answer: ",ToString[result3,InputForm]];            *)
            QPutWrapper["out",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-R",MyToString[result3]];
            QPutWrapper["out",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-E",MyToString[False]];
            QPutWrapper["out","MaxEvaluatedOrder",MyToString[CurrentOrder]];
            result3=InternalGenerateAnswer[]; 
            For[j=1,j<=Length[result3],j++,
                RawPrint["(",ToString[result3[[j]][[1]],InputForm],")*",ToString[result3[[j]][[2]],InputForm]];
                If[j<Length[result3],RawPrint["+"],RawPrintLn[""]];
            ];
	  ]; (*for EvC*)	
			  
	  
	,   (*UsingC - not UsingC*)
	
	    EvalFunction[value_]:=Module[{temp,result,iii},
		temp=value;
		If[temp==={},Return[{0,0,True}]];
    		temp=IntegrateHere[{temp},CurrentIntegralExact];    		
    		If[temp[[3]]>0,CurrentIntegralExact=False];				   		
		temp
	    ];
		
	    WriteFunction[d_,value_,prefix_]:=(If[value[[3]]>0,CurrentIntegralExact=False];
	      (*result3+=(value[[1]]+value[[2]]*ToExpression["pm"<>ToString[PMCounter++]])*)
	    result3+={value[[1]],Power[value[[2]],2]};
	    );
					
	    ReadFunction[s_,prefix_,runS_]:=Module[{temp,i,res},
		res={};
		temp=MyToExpression[QGetWrapper[s,prefix<>ToString[runS]]];
		For[i=1,i<=temp,i++,
		    AppendTo[res,MyToExpression[QGetWrapper[s,prefix<>ToString[runS]<>"-"<>ToString[i]]]]			  
		];
		res
	    ];
		    
				
	    If[NumberOfSubkernels>0,
                DistributeDefinitions[ExactIntegrationTimeout,EvalFunction,CurrentIntegralExact];
            ];
	
	    For[EvC=1,EvC<=Length[ForEvaluation],EvC++,
		CurrentOrder=ForEvaluation[[EvC]][[1]];
		CurrentVarDegree=ForEvaluation[[EvC]][[2]];
		If[Union[(##[[2]])&/@ForEvaluation]=!={{0,0}},
		    RawPrint["Terms of ep order ",CurrentOrder," and ",ExpandVariable," order ",ToString[CurrentVarDegree,InputForm],": "],
		    RawPrint["Terms of order ",CurrentOrder,": "]
		];
		terms=ToExpression[QGetWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-T"]];
		terms0=ToExpression[QSafeGetWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-T0",terms]];
		nov=ToExpression[QGetWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-N"]];
		RawPrintLn[terms,", max vars: ",nov];                        
		RawPrint["Integrating"];
		CurrentIntegralExact=(CurrentOrder<=ExactIntegrationOrder);	
		DistributeDefinitions[CurrentIntegralExact];

		result3=0;         
                PerformStage["in",SCounter,"in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-",False]; 
					(* we do not really write in that database, but in is here to avoid reoping*)
                result3={result3[[1]],Power[result3[[2]],1/2],0,0};
                If[CurrentIntegralExact,
		    temp=FullSimplify[result3];
		 ,
		    temp=DoubleCutExtraDigits[result3];		    
		  ];
		RawPrintLn["Returned answer: ",ToString[temp[[1]],InputForm]," + pm* ",ToString[temp[[2]],InputForm]];
		QPutWrapper["out",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-R",MyToString[result3]];
		QPutWrapper["out",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-E",MyToString[CurrentIntegralExact]];            
		QPutWrapper["out","MaxEvaluatedOrder",MyToString[CurrentOrder]];
		result3=InternalGenerateAnswer[]; 
		For[j=1,j<=Length[result3],j++,
		    RawPrint["(",ToString[result3[[j]][[1]],InputForm],")*",ToString[result3[[j]][[2]],InputForm]];
		    If[j<Length[result3],RawPrint["+"],RawPrintLn[""]];
		];
	    ]; (*for EvC*)	

	    
	    
	]; (*not using C*)
	
	][[1]]];
	If[Length[TaskPrefixes]>1,RawPrintLn["Task integration time: ",stagetime]];
    ]; (*big for*)

    
    If[UsingC,
    	  If[NumberOfSubkernels =!= 0,res=WaitAll[task], res = {}];
		
	  If[Not[res==={}],
	      Print["CIntegratePool evaluation failed"];
	      Print/@res;
	      Abort[];
	  ];
    ,
	If[UsingQLink,QClose[DataPath<>"in"]];
    ];
    
	
    result3=(TaskPrefix=ToString[##];InternalGenerateAnswer[])&/@TaskPrefixes;
    
    QClose[DataPath<>"out"];    
    result3=Apply[Times,result3,{2}]; (*multiplying coeff and ext var deg*)
    result3=Apply[Plus,result3,{1}];  (*summing all up*)    
    ][[1]]];
    RawPrintLn["Total integration time: ",time];
    result3


];
  
  
SDPrepareAndIntegrate[intvars_,ZZ_,runorder_Integer,deltas_,SHIFT_,EXTERNAL_,ExternalExponent_]:=Module[{temp,timecounter},

    (*If[Head[TaskPrefix]==Symbol,TaskPrefix="0"];*)

    (* the databases and kernels were opened earlier by InitializeLinks[]*)

    (*Print[SDPrepareAndIntegrate2[intvars,ZZ,runorder,deltas,SHIFT,EXTERNAL,ExternalExponent]];*)
    temp=Series[EXTERNAL,{ep,0,runorder-SHIFT}];
    If[Not[TrueQ[And[NumberQ[Normal[temp]],SHIFT==0]]],
     If[Not[temp[[4]]===-SHIFT],
	  Print["Incorrect order shift"];
	  Print[EXTERNAL];
	  Print[temp];
	  Print[Normal[temp]];
	  Print[temp[[4]]];
	  Print[-SHIFT];
	  Abort[];
      ];
    ];
    
    
    timecounter=AbsoluteTime[];

    temp=SDPrepare[intvars,ZZ,runorder,deltas,SHIFT,EXTERNAL,ExternalExponent];
    
    If[DMode,Return[{temp}]]; (*{temp} because SDPrepareAndIntegrate returns first *)
    
      
    RawPrintLn["Database ready for integration."];
    
    
    (* both databases are closed, database out is empty *)
    
    If[OnlyPrepare,        
	If[UsingC,
	    command=FIESTAPath<>"/bin/CIntegratePool -in "<>DataPath<>"in -threads "<>ToString[NumberOfLinks]<>CommandOptions;
	    If[Not[AsyMode===True],RawPrintLn[command]];
	];
	RawPrintLn["Total time used: ",CutExtraDigits[AbsoluteTime[]-timecounter]," seconds."];
	Return[{"Prepared"}];
    ,
        temp=SDIntegrate[];  (* it will open and close databases in and out*)
    ];
      
    RawPrintLn["Total time used: ",CutExtraDigits[AbsoluteTime[]-timecounter]," seconds."];
    If[RemoveDatabases,    
        If[UsingQLink,
	    DeleteFile[DataPath<>"in.kch"];
	    DeleteFile[DataPath<>"out.kch"];
	,
	    Clear[Evaluate[ToExpression["dbin"]]];
	    Clear[Evaluate[ToExpression["dbout"]]]	
	];  
    ];
       
    temp
]
  
  
FindMaxLa[f_,n_,var_] := Module[{ff,coeffs, temp, i,min},

  
  min=MaxComplexShift;
  
  ff={Coefficient[f, var, 1], 
        Coefficient[f, var, 3]};
  For[i = 1, i <= LambdaIterations, i++,
   temp = 
    ff /. Apply[Rule, 
      Transpose[{Array[x, n], 
        Table[Rationalize[RandomReal[1]], {n}]}], {1}];
  
      coeffs=Norm /@ (temp//. {Complex[a_, b_] -> b});
      If[coeffs[[2]]<=0.00001,coeffs=Infinity,coeffs=Sqrt[coeffs[[1]]/coeffs[[2]]]];
      
      min=Min[min,coeffs];
      
    
   ];
  
  
  Rationalize[min,0.001]
]
  
  
FindBestLa[f_,n_,var_,valuemax_]:=Module[{ff,temp,i,mins,curva,coeffs,max,temp2,la2,la3,real,im,tempreal,tempim,temprealV,tempimV,ff2},
    (*Return[valuemax/2];*)
       
    ff=Collect[f,var];    
    la2/:Power[la2,a_]:=0/;OddQ[a];
    la2/:Power[la2,a_]:=la3^a/;EvenQ[a];
    ff2=ff/.var->la2;
    real=ff2/.la2->0;
    im=((ff-real)/.{var->la3})/.Complex[a_,b_]->b;
                
    (*Print[real];
    Print[im];*)
    

    
    mins=Table[Infinity,{LambdaSplit}];
    
    For[j=1,j<=LambdaIterations,j++,
	{tempreal,tempim}={real,im}/. Apply[Rule, Transpose[{Array[x, n], Table[Rationalize[RandomReal[1]], {n}]}], {1}];
	For[i=1,i<=LambdaSplit,i++,
	    If[mins[[i]]===0,Continue[]];
	    curva=valuemax*i/LambdaSplit;	    
    
	    {temprealV,tempimV}={tempreal,tempim}/.{la3->curva};
	    
	    If[TrueQ[tempimV<0],
		mins[[i]]=Min[mins[[i]],tempimV^2+temprealV^2];
	    ,
		mins[[i]]=0;
	    ];
	];	
    ];
    
    (*Print[mins];*)
    
    max=Max@@mins;
    
    
    If[max===0,Print["Can't find lambda!"];Print[f];Print[n];Print[var];Print[valuemax];Abort[]];
    
    Return[Position[mins,max][[1]][[1]]*valuemax/LambdaSplit];
]

FindMaxShifts[shifts_,n_]:=Module[{temp,max,i,j},
  max=Table[0,{n}];
  For[j=1,j<=LambdaIterations,j++,
      temp=shifts/. Apply[Rule, Transpose[{Array[x, n], Table[Rationalize[RandomReal[1]], {n}]}], {1}];
      For[i=1,i<=n,i++,
	  max[[i]]=Max[max[[i]],Abs[temp[[i]]]];
      ]
  ];
  Return[max];
];

  
TransformContour[expr_] := 
 Module[{temp, n, F, F2, temp2, newvarsmult, newvars, rules, la,lavalue,lavaluemax,shifts},
 
  n = Length[expr[[1]]];
  F = expr[[6]];
  
  If[TrueQ[NumberQ[F]],
      If[F<0,
	  Print["WARNING: F is completely negative! Consider global sign change! Answers can be incorrect!"];
      ];
      Return[expr]
  ];

  
  shifts=((1 - x[##])*x[##]*D[F, x[##]]) & /@ Range[n];
  shifts=FindMaxShifts[shifts,n];
  shifts=Rationalize[##,0.001]&/@shifts;
  shifts=If[##<=1,1,1/##]&/@shifts;
  
  newvarsmult = (1 - I * la * shifts[[##]] * (1 - x[##])*D[F, x[##]]) & /@ Range[n];
    
  newvars= newvarsmult*Array[x,n];
  
  rules = Apply[Rule, Transpose[{Array[y, n], newvars}], {1}];

  F2=Replace[F, x -> y, {0, Infinity}, Heads -> True]//.rules;
 
  If[TrueQ[ValueQ[ComplexShift]],
    lavalue=ComplexShift;
  ,
    lavaluemax=FindMaxLa[F2,n,la];
  
    lavaluemax=Min[lavaluemax,MaxComplexShift];
  
    lavalue=FindBestLa[F2,n,la,lavaluemax];
    
    If[ConservativeComplexShift,
      lavalue = lavalue/2;
    ];
    
  ];

   
  temp={
      expr[[1]], 
      expr[[2]], 
      expr[[3]],
      (Replace[expr[[4]], x -> y, {0, Infinity}, Heads -> True] //. rules)*Det[Outer[D[#1, #2] &, newvars, Array[x, n]]]*Inner[Power,newvarsmult,expr[[2]],Times],
      expr[[5]],
      F2,
      Replace[expr[[7]], x -> y, {0, Infinity}, Heads -> True] //.rules
   };
  
   temp /. la -> lavalue
]
  
  
TakeResidues[temp000_]:=Module[{temp,num,temp1,temp0,temp2,ReqR,res1},
    temp=temp000;
              
    temp[[4]]=Take[temp[[4]],2];
    
    ReqR=RequiredResidues@@(temp[[4]]);    
    
    temp2=Flatten[MyResidue[Pair[temp[[1]],temp[[2]]],##[[2]]*temp[[3]],##[[1]],##[[3]]]&/@ReqR,1];
    
    temp2=Select[temp2,(##[[3]]=!=0)&];
    
    temp2=temp2/. Gamma[garg_] :> Gamma[Expand[garg]];
    temp2=temp2/. Power[garg1_,garg2_] :> Power[Expand[garg1],Expand[garg2]];     
                        
    temp2
]
  
LocateBadEnds[expr_] := Module[{vars, badvars, temp, i, j, n, subs, F},
  vars = x /@ Flatten[Position[expr[[1]], 1]];
  badvars = {};
  F = expr[[6]];
  n = Length[vars];
  For[j = 1, j <= n, j++,
   subs = Subsets[vars, {j}];
   For[i = 1, i <= Length[subs], i++,
    temp = F /. (Rule[##, 1] & /@ (subs[[i]]));
    If[(temp /. (Rule[##, 0] & /@ vars)) === 0,
     badvars = Append[badvars, subs[[i]]];
     ];
    ];
   F = F /. (Rule[##, 0] & /@ Flatten[badvars]);
   If[F === 0, Break[]];
   ];
  badvars
  ]  
  
  
SDPrepare[intvars_,ZZ_,runorder_Integer,deltas_,SHIFT_,EXTERNAL_,ExternalExponent_]:=Module[{Z,U,F,SD,f,forsd,ii,i,vars,n,m,j,l,rule,Z3,Z2,U2,F2,coeff,k,Jac,res,result,md,result2,pol,active,zsets,SDCoeffs,timecounter,HasExtra,ForEvaluation,temp,BisectionPointsHere},   
    
    
    If[Length[intvars]==0,
	  (*temp=Plus @@ ((##[[1]]) & /@ (Flatten[(##[[1]]) & /@ ZZ, 1]));*)
	  temp = Transpose[{##[[1]], Table[##[[2]], {Length[##[[1]]]}]}] & /@ ZZ;
	  temp = Flatten[temp, 1];	  
	  temp = Apply[Append, temp , {1}];     
	  temp = {##[[1]], Inner[Power, ##[[3]], ##[[2]], Times]} & /@ temp;
	  temp = Apply[Times, temp, {1}];
	  temp = Plus @@ temp;
	  temp*=EXTERNAL;
	  InitializeQLink[{"in"}];
	  OldTaskPrefix=TaskPrefix;
	  TaskPrefix="0";	   
	  TaskPrefixes=ToExpression[QSafeGetWrapper["in","","{}"]];
	  QPutWrapper["in","",ToString[Append[TaskPrefixes,OldTaskPrefix]]];
	  TaskPrefix=OldTaskPrefix;
	  QPutWrapper["in","Exact",MyToString[True]];
	  temp=temp/.{z->RegVar};
	  (*temp=N[Normal[Series[temp, {RegVar, 0, 0}, {ep, 0, runorder-SHIFT}]]]*);
	  QPutWrapper["in","ExactValue",MyToString[temp]];
	  QPutWrapper["in","UsingC",MyToString[UsingC]];	    
	  QPutWrapper["in","ExternalExponent",MyToString[ExternalExponent]];
	  If[UsingQLink,QClose[DataPath<>"in"]];
	  Return[];
    ];
    
    

    If[NumberOfSubkernels>0,
	DistributeDefinitions[LambdaSplit,LambdaIterations];
    ];
    
    
    CurrentTaskPrefix=TaskPrefix;
    TaskPrefix="0";
    InitializeQLink[{"in","1","2"}];
    TaskPrefixes=ToExpression[QSafeGetWrapper["in","","{}"]];
    If[MemberQ[TaskPrefixes,CurrentTaskPrefix],
      Print["Task results with this prefix already exist in database!"];
      Abort[];
    ];
    QPutWrapper["in","RequestedOrders",MyToString[{runorder-SHIFT,ExpandOrder}]];
    If[ExpandMode,
      QPutWrapper["in","SmallVar",MyToString[ExpandVariable]];
    ];
    QPutWrapper["in","RegVar",MyToString[RegVar]];
    If[UsingQLink,QClose[DataPath<>"in"]];
    TaskPrefix=CurrentTaskPrefix;


    Clear[NumberOfVariables,PSector];
    MixSectorCounter=-1;    

    n=Length[intvars];
    
    If[NumberOfSubkernels>0,
       DistributeDefinitions[DataPath,QHullPath,ResolutionMode,UsingQLink,RegVar,RegMode,ExpandOrder,ExV,ZREPLACEMENT,n,x,y,ExpandMode,UsingC,IntegrationRule];
    ];
    Terms=0;                    
                
                
    If[StartingStage>1,        
        Goto[StartingStage]
    ];

    ClearDatabaseWrapper["1"];
    run1=1;

    
    
For[l=1,l<=Length[ZZ],l++,
 {Z,U}=ZZ[[l]];
      (*Print[Z];*)
 If[Times@@U===0,Continue[]];

    vars=Apply[x, Position[intvars, 1], {1}];

If[Length[vars]>0,

    zsets=Tuples[deltas];
    
    (* {deltas, U, intvars, n, primary number, Z} *)
    
    
    
    SD=Transpose[{zsets,Table[U,{Length[zsets]}],Table[intvars,{Length[zsets]}],Table[n,{Length[zsets]}],Range[Length[zsets]],Table[Z,{Length[zsets]}]}]/.Log[_]->1;
    
 (*   Print[SD];*)
    
    If[ValueQ[PrimarySectorCoefficients],SDCoeffs=PrimarySectorCoefficients, SDCoeffs=Table[1,{Length[SD]}]];
    
    SD=Delete[SD,Position[SDCoeffs,0]];
    
    If[ValueQ[BisectionPoints],BisectionPointsHere=BisectionPoints,BisectionPointsHere=Table[BisectionPoint,{Length[BisectionVariables]}]];
    
    For[i=1,i<=Length[BisectionVariables],i++,
	var=BisectionVariables[[i]];
	SD=If[TrueQ[MemberQ[##[[1]],var]],
	  {##}  (*variable set to 1, not bisecting*)
	,
	  {{##[[1]],Expand[(##[[2]]/.{x[var]->x[var]*BisectionPointsHere[[i]]})],##[[3]],##[[4]],##[[5]],
		{(##[[1]]/.{x[var]->x[var]*BisectionPointsHere[[i]]})*BisectionPointsHere[[i]],##[[2]]}&/@(##[[6]])},
	  {##[[1]],Expand[(##[[2]]/.{x[var]->1-x[var]*(1-BisectionPointsHere[[i]])})],##[[3]],##[[4]],##[[5]],
		{(##[[1]]/.{x[var]->1-x[var]*(1-BisectionPointsHere[[i]])})*(1-BisectionPointsHere[[i]]),##[[2]]}&/@(##[[6]])}
	  }   
	]&/@SD;
	SD=Flatten[SD,1];
    ];

   
    
    
(*Print[SD];*)

    If[Or[STRATEGY===STRATEGY_KU,STRATEGY===STRATEGY_KU0,STRATEGY===STRATEGY_KU2],
      If[Not[AsyLoaded],
	RawPrintLn["Loading ASY"];
	Get[CurrentAsyPath[]];
      ];
    ];
   
    RawPrintLn["Sector decomposition - ",Length[SD]," sectors"];
    RawPrintLn["Totally: ",MyTimingForm[AbsoluteTiming[
        If[NumberOfSubkernels>0,
            DistributeDefinitions[STRATEGY];
            SetSharedFunction[RawPrintLn];
        ];
       SD=MyParallelize[(SectorDecomposition@@##)&/@SD];
        If[NumberOfSubkernels>0,
            UnsetShared[RawPrintLn];
        ];

    ][[1]]]," seconds; ",Total[Length/@SD]," sectors."];

	(* {matrices, {deltas, U, intvars, n, primary number, Z} }*)

	If[AllEntriesDebug,Print["Sector decomposition"];
	    If[ValueQ[WatchOnly],Print[Flatten[(temp = ##[[2]]; {##, temp} & /@ ##[[1]]) & /@ SD, 1][[WatchOnly]]],Print[SD]];
	];
	
        RawPrint["Preparing database: "];
        RawPrintLn[MyTimingForm[AbsoluteTiming[
            For[i=1,i<=Length[SD],i++,
                For[j=1,j<=Length[SD[[i]][[1]]],j++,
                    QPutWrapper["1",ToString[run1,InputForm],MyToString[{SD[[i]][[1]][[j]],SDCoeffs[[SD[[i]][[2]][[5]]]],SD[[i]][[2]][[1]],SD[[i]][[2]][[6]],SD[[i]][[2]][[2]],SD[[i]][[2]][[3]],SD[[i]][[2]][[4]],deltas}]];run1++;
                ];
            ];
        ][[1]]]," seconds. "];
,
    QPutWrapper["1",ToString[run1,InputForm],MyToString[{{},{},{},Times@@U,0}]];run1++;
];

];Terms=run1-1;


(*

	If[AllEntriesDebug,Print["Sector decomposition"];PrintAllEntries["1"]];
*)
        If[AbortStage===2,Abort[]];


     
    RawPrint["Variable substitution"];
        SCounter=1;

	dbin="1";
	dbout="2";

	
	
	
        EvalFunction[value_]:=Module[{temp,ThisSD,rules,reps,rule,Jac,U2,Z2,Z3,U3,NewDegrees,power,powers,i,deltass,vars},(ClearSystemCache[];
                    ThisSD=MyToExpression[value];
                    (*Print[ThisSD];*)
                    
                    (* 1=matrix, 2= coeff, 3 =zset, 4 = Z = coeff and powers, 5 = functions, 6 = allvars, 7 = n, 8 = deltas *)
                    (* if we want SDEvaluateDirect to work properly with deltas,
		       we have to add a transformation here
		       calculate the power of variables in ThisSD[[3]] for each part of Z independently
		       that is the sum of product of powers and degree of functions (we assume them to be homogeneous)
		       + n (1 for delta, n-1 for jacobian)
		       if this power is not equal to 0
		       we introduce a new function equal to sum of variables in delta and -power
                    *)
                                        
		    If[Length[ThisSD]===5,Return[{ThisSD}]];
		    n=ThisSD[[7]];
                    If[ThisSD[[2]]===0,{},
			deltass = ThisSD[[8]];
                    
                        rules=Rule[x[##],1]&/@ThisSD[[3]];
                        reps=Inner[Power[#2, #1] &, Transpose[ThisSD[[1]]], Array[y,n],Times];
                        rule=Apply[Rule,Transpose[{Array[x,n],reps}],{1}];
                        Jac=Det[Outer[D,reps,Array[y,n]]];
                        
                        power[a_,vars_]:=(temp = Expand[a]; temp = If[Head[temp] === Plus, temp[[1]], temp];
			    temp = temp /. (Rule@@@Transpose[{x/@(deltas[[i]]),Table[x,{Length[deltas[[i]]]}]}]); Exponent[temp, x]
			);
                        
                        For[i=1,i<=Length[deltas],++i,
			  vars=x/@(deltass[[i]]);
			  powers = power[##,vars] & /@ ThisSD[[5]];                        
			  powers = Expand[(Length[deltass[[i]]]+power[##[[1]],vars] + ##[[2]].powers)]&/@(ThisSD[[4]]);                        
			  If[Or@@(Not[##===0]&/@powers),
			    (*Print["Introducing a new factor"];*)
			    
			    AppendTo[ThisSD[[5]],Plus@@(x/@(deltass[[i]]))];
			    temp = Transpose[ThisSD[[4]]];
			    temp[[2]] = Transpose[temp[[2]]];
			    temp[[2]] = Append[temp[[2]],-powers];
			    temp[[2]] = Transpose[temp[[2]]];
			    ThisSD[[4]] = Transpose[temp];
			    
			    (*Print[ThisSD];*)
                          ];
                       
                        ];
                        
                        
                        
                        Z2=(ThisSD[[4]]/.rules)//.rule;
                        U2=(ThisSD[[5]]/.rules)//.rule;
                        (
                            NewDegrees=Table[0,{n}];
			    NewLogDegrees=Table[0,{n}];
                            Z3=##;                            
                            For[m=1,m<=Length[U2],m++,
                                temp=FactorMonom[U2[[m]] /. {0.->0}];
                                U3[m]=temp[[2]];
                                NewDegrees=NewDegrees+Z3[[2]][[m]]*Table[Exponent[temp[[1]],y[i]],{i,n}];
				temp=FactorLogMonom[U3[m] /. {0.->0}];
                                U3[m]=temp[[2]];
                                NewLogDegrees=NewLogDegrees+Z3[[2]][[m]]*Table[Exponent[temp[[1]],Log[y[i]]],{i,n}];
                            ];
                            NewDegrees=NewDegrees+Table[Exponent[Jac,y[i]],{i,n}];  
                            
                            (*Print[Z3[[1]]];
                            Print[FactorMonom[Z3[[1]]]];*)
                            
                            Z3[[1]]=FactorMonom[PowerExpand[Z3[[1]]]];
                            NewDegrees=NewDegrees+Table[Exponent[Z3[[1]][[1]],y[i]],{i,n}];
                            Z3[[1]]=Z3[[1]][[2]];

                            temp=Exponent[Z3[[1]],ExV] // Simplify ;
                            Z3[[1]]=Expand[Z3[[1]]/Power[ExV,temp]];
                            
                            f={
			      ReplacePart[ThisSD[[6]],0,List/@ThisSD[[3]]],
			      Expand[NewDegrees],
			      NewLogDegrees,
			      Z3[[1]]*ThisSD[[2]]*(Jac/.y[aaa_]->1)*Times@@Table[((U3[m]-If[And[m===2,ComplexMode===True],I/1000000,0])^(Z3[[2]][[m]])),{m,Length[U2]}],
			      0,
			      If[Length[U2]===0,0,U3[2]],
			      {Z3[[1]],{},ExpandOrder}
			    };
			    
			  
			    If[NumberQ[f[[4]]],f[[4]]*=(1+1/1000000)^ep];
			    
			    If[ExpandMode,
			      AppendTo[f[[1]],2];
			      AppendTo[f[[2]],temp];
			      AppendTo[f[[3]],0];			    
			    ];
			    
                            f=f//.y->x;
                            f
                        )&/@Z2
                    ])];
        
        WriteFunction[d_,value_,prefix_]:=(MixSectorCounter++;
                 If[MixSectorCounter>MixSectors,SCounter++;MixSectorCounter=0];
                 QPutWrapper[d,ToString[runD,InputForm],MyToString[{SCounter,value}]];runD++);
	ReadFunction[s_,prefix_,runS_]:=QGetWrapper[s,prefix<>ToString[runS]];
	DistributeDefinitions[EvalFunction];
	
	If[FixSectors,NumberOfSubkernelsOld=NumberOfSubkernels;NumberOfSubkernels=0;];
	
	Terms=PerformStage[dbin,Terms,dbout,"",True];
	
	If[FixSectors,NumberOfSubkernels=NumberOfSubkernelsOld;];
	
	If[AllEntriesDebug,Print["Variable substitution"];PrintAllEntries[dbout]];
	
	dbtemp=dbin;dbin=dbout;dbout=dbtemp;
 
        (* {vars, indices, log degrees, expression, ep degree, F, {gammas,{}}}   *)       
    	
	If[AbortStage===3,Abort[]];	
	
	
	If[DMode,  (* return possible d. Program stops here *)  
	  result=Flatten[MyToExpression[QGetWrapper[dbin,ToString[##]]][[2]][[2]]&/@Range[Terms],1];
	  result=Union[result];
	  result=result/.{ep->(d0-d)/2};
	  result=Expand/@result;
	  result=Select[result,(Variables[##]=!={})&];
	  result={##,Sort[{##/.d->DMIN,##/.d->DMAX}]}&/@result;
	  result={##[[1]],{Ceiling[##[[2]][[1]]],Min[Floor[##[[2]][[2]]],-1]}}&/@result;
	  result=Select[result,(##[[2]][[1]]<=##[[2]][[2]])&];
	  result = {##[[1]], Range @@ (##[[2]])} & /@ result;
	  result={Table[##[[1]],{Length[##[[2]]]}],##[[2]]}&/@result;
	  result=Transpose/@result;
	  result=Flatten[result,1];
	  result=((##[[2]]-(##[[1]]/.d->0))/Coefficient[##[[1]],d])&/@result;
	  If[TrueQ[PolesMultiplicity],
	      result=Reap[Sow[##, ##] & /@ result, _, {#1, Length[#2]} &][[2]]
	  ,
	      result=Union[result];
	  ];
	  Return[result];
	];

	If[ComplexMode,
	    RawPrint["Performing contour transformation"];

	    EvalFunction[value_]:=Module[{temp,num,bad},
                    ClearSystemCache[];
                    temp=MyToExpression[value];
                    num=temp[[1]];                    
                    temp=temp[[2]];
     
                    If[ComplexMode,
			If[TestF1,
			  bad=LocateBadEnds[temp];
			  If[Length[bad]>0,
			    Print["Bad integration ends found (for sector ",num,"): ",bad];
			  ];
			];
			temp=TransformContour[temp];  (* here we use a formula:  x_i -> x_i - x_i (1-x_i) i la dF/dx_i             *)
                    ];
               
                    MyToString[{num,temp}]
                ];
                DistributeDefinitions[EvalFunction,ComplexMode,MaxComplexShift];
	    WriteFunction[d_,value_,prefix_]:=(QPutWrapper[d,ToString[runD,InputForm],value];runD++);	    
    
	    Terms=PerformStage[dbin,Terms,dbout,"",False];
	    
	    If[AllEntriesDebug,Print["Contour transformation"];PrintAllEntries[dbout]];
	    
	    dbtemp=dbin;dbin=dbout;dbout=dbtemp;
        
	    (* {vars, indices, log degrees, expression, ep degree, F, {gammas,{}}}   *)

	];
	
	If[AbortStage===4,Abort[]];
    

    
    If[Or[RegMode,ExpandMode],

      RawPrint["Pole resolution"];

      EvalFunction[value_]:=Module[{temp,num},
                    ClearSystemCache[];
                    temp=MyToExpression[value];
                    num=temp[[1]];
                    temp=temp[[2]];
                    temp=ZNegExpand[temp];
      		    MyToString[{num,##}]&/@temp
                ];
                DistributeDefinitions[EvalFunction];
       WriteFunction[d_,value_,prefix_]:=(QPutWrapper[d,ToString[runD,InputForm],value];runD++);

       Terms=PerformStage[dbin,Terms,dbout,"",True];
      
      If[AllEntriesDebug,Print["Pole resolution"];PrintAllEntries[dbout]];
      	
      dbtemp=dbin;dbin=dbout;dbout=dbtemp;  

       (* {vars, indices, log degrees, expression, ep degree, F, {gammas,{}}}   *)

    
    ];
   
    If[AbortStage===5,Abort[]];

    If[Or[RegMode,ExpandMode],
    
      If[RegMode,  (* normally used in SDExpandAsy *)

	RawPrint["Z expansion"];

        EvalFunction[value_]:=Module[{temp,num},
                    ClearSystemCache[];
                    temp=MyToExpression[value];
                    num=temp[[1]];
                    temp=temp[[2]];                                        
                    temp=ZPosExpand[temp];
		    MyToString[{num,##}]&/@temp
                ];
                DistributeDefinitions[EvalFunction];
        WriteFunction[d_,value_,prefix_]:=(QPutWrapper[d,ToString[runD,InputForm],value];runD++);

        Terms=PerformStage[dbin,Terms,dbout,"",True];
	
	If[AllEntriesDebug,Print["Z expansion"];PrintAllEntries[dbout]];
	
	dbtemp=dbin;dbin=dbout;dbout=dbtemp;
       

    ,	(* variant of ExpandMode and not RegMode *)
	(* normally used in SDExpand *)

	RawPrint["Taking residues"];


        EvalFunction[value_]:=Module[{temp,num,temp1,temp0,temp2,ReqR,res1},

                        ClearSystemCache[];
                        temp=MyToExpression[value];
                        num=temp[[1]];
                        temp=temp[[2]];
                        temp2=TakeResidues[{temp[[2]],temp[[3]],temp[[4]],temp[[7]]}];                                                
                        (*TakeResidues works with degrees, log degrees, expression and extra info *)
                        (*vars and ep order are not changed*)
                        MyToString[{num, {temp[[1]],ExpandAll[##[[1]]],ExpandAll[##[[2]]],##[[3]],temp[[5]],temp[[6]]}}]& /@ temp2
                ];
                DistributeDefinitions[EvalFunction];
        WriteFunction[d_,value_,prefix_]:=(QPutWrapper[d,ToString[runD,InputForm],value];runD++);

       Terms=PerformStage[dbin,Terms,dbout,"",True];
       
       If[AllEntriesDebug,Print["Taking residues"];PrintAllEntries[dbout]];
       
       dbtemp=dbin;dbin=dbout;dbout=dbtemp;
              	  
    ] (* variant of ExpandMode and not RegMode ended*) 


  ];  (*ExpandMode or RegMode*)


    (* {vars, indices, log indices, expression, ep degree, F} *)

    If[AbortStage===6,Abort[]];

    RawPrint["Pole resolution"];

        EvalFunction[value_]:=Module[{temp,num},
                    ClearSystemCache[];
                    temp=MyToExpression[value];
                    num=temp[[1]];
                    temp=temp[[2]];       
                    Check[
		      temp=EpNegExpand[temp],
		      Print["EpNegExpand error"];
		      Print["Expr is: ",MyToExpression[value][[2]]];
		      Print["Num is: ", num];
		      Abort[];
		    ];
                    temp=DeleteCases[temp,{_,_,_,0,_,_}]; 
                    MyToString[{num,##}]&/@temp
                ];

                DistributeDefinitions[EvalFunction];
        WriteFunction[d_,value_,prefix_]:=(QPutWrapper[d,ToString[runD,InputForm],value];runD++);

    Terms=PerformStage[dbin,Terms,dbout,"",True];
    
    
    If[AllEntriesDebug,Print["Pole resolution"];PrintAllEntries[dbout]];  
    
    dbtemp=dbin;dbin=dbout;dbout=dbtemp;
       
    (* {vars, indices, log indices, expression, ep degree, F} *)
    (* for external variable vars, indices, log indices will be one place longer and contain its powers *)

    
    If[AbortStage===7,Abort[]];

    RawPrint["Expression preparation"];

        EvalFunction[value_]:=Module[{temp,num},
                    ClearSystemCache[];                    
                    temp=MyToExpression[value];   
                    num=temp[[1]];
                    temp=temp[[2]];
                    temp=AdvancedFirstVars[ConstructTerm[temp],Last[temp]];
                    MyToString[{num,temp}]
                ];
                DistributeDefinitions[EvalFunction];
        WriteFunction[d_,value_,prefix_]:=(QPutWrapper[d,ToString[runD,InputForm],value];runD++);

    Terms=PerformStage[dbin,Terms,dbout,"",False];
    
    If[AllEntriesDebug,Print["Expression preparation"];PrintAllEntries[dbout]];
    
    dbtemp=dbin;dbin=dbout;dbout=dbtemp;
       
    (* {expression, {ExpandVar degree, ExpandLog degree}, ep degree, F} *)

    If[AbortStage===8,Abort[]];

    RawPrint["Epsilon expansion"];

        EvalFunction[value_]:=Module[{temp,num,FF},
                    ClearSystemCache[];                            
                    temp=MyToExpression[value];
                    num=temp[[1]];
                    temp=temp[[2]];  
                    FF=temp[[4]]; (* no need to expand F here *)
                    temp=EpPosExpand[temp[[1]],temp[[2]],temp[[3]],runorder];                    
                    temp=MyToString[{num,{##[[2]][[1]],##[[1]],##[[2]][[2]],FF}}]&/@temp	  
                ];
                DistributeDefinitions[EvalFunction];
        WriteFunction[d_,value_,prefix_]:=(QPutWrapper[d,ToString[runD,InputForm],value];runD++);

     Terms=PerformStage[dbin,Terms,dbout,"",True];
     
     If[AllEntriesDebug,Print["Epsilon expansion"];PrintAllEntries[dbout]];
     
     dbtemp=dbin;dbin=dbout;dbout=dbtemp;
       
     (*  {expression, ep degree, ext var degrees, FF}         *)


     If[AbortStage===9,Abort[]];


        RawPrint["Preparing integration strings"];


        
        
        EvalFunction[value_]:=Module[{temp,temp1,num,temp2,temp3,vars,FF},
                            ClearSystemCache[];
                            temp=MyToExpression[value];
                            num=temp[[1]];
			     temp1=temp[[2]][[2]];temp3=temp[[2]][[3]]; (*degrees*)
			     FF=temp[[2]][[4]];
                            temp=temp[[2]][[1]];
                            temp=temp/.IntegrationRule;
			    If[ZeroCheck[temp],
				{}
			    ,
			    vars=CountVars[Cases[Variables[Variables[temp]/.Log->List],y[_]]];		
			    temp2=MyWorstPower[temp,vars[[1]]];
			    temp2=Ceiling[Abs[##]]&/@temp2;
		(*	    Print[{{num,                            
			      If[vars[[2]]<=0, (*it can be -Infinity *)
				    If[UsingC,MyString[Chop[N[Round[temp,10^-6]],10^-6]]<>";",MyToString[temp]]
			      , 																		
				    If[UsingC,"("<>MyString[temp]<>")*("<>MyString[Inner[Power,vars[[1]],temp2,Times]]<>")*("<>MyString[Inner[Power,vars[[1]],-temp2,Times]]<>");",MyToString[temp]]
			      ],
			      vars[[2]],temp1,temp3}}];*)
                            {{num,                            
			      If[vars[[2]]<=0, (*it can be -Infinity *)
				    If[UsingC,MyString[Chop[N[Round[temp,10^-6]],10^-5]]<>";",MyToString[temp]]
			      , 																		
				    If[UsingC,"("<>MyString[temp]<>")*("<>MyString[Inner[Power,vars[[1]],temp2,Times]]<>")*("<>MyString[Inner[Power,vars[[1]],-temp2,Times]]<>");",MyToString[temp]]
			      ],
			      vars[[2]],temp1,temp3,
			      If[vars[[2]]<=0, (*it can be -Infinity *)
				    If[UsingC,MyString[Chop[N[Round[FF,10^-6]],10^-5]]<>";",MyToString[FF]]
			      , 																		
				    If[UsingC,MyString[FF]<>";",MyToString[temp]]
			      ]			      
			      }}
			      (* num, value, number of vars, deg1, deg2,FF*)
                           ]
                        ];
            DistributeDefinitions[ZeroCheck,CountVars,MyWorstPower,EvalFunction,MyString];

	    WriteFunction[d_,value_,prefix_]:=(
		  If[Head[NumberOfVariables[value[[4]],value[[5]]]]===NumberOfVariables,NumberOfVariables[value[[4]],value[[5]]]=0;];
		  If[Head[PSector[value[[4]],value[[5]],value[[1]]]]===PSector,PSector[value[[4]],value[[5]],value[[1]]]=0];
		   NumberOfVariables[value[[4]],value[[5]]]=Max[NumberOfVariables[value[[4]],value[[5]]],value[[3]]];
                   QPutWrapper[d,ToString[value[[4]]]<>"-"<>ToString[value[[5]],InputForm]<>"-"<>ToString[value[[1]]]<>"-"<>ToString[++PSector[value[[4]],value[[5]],value[[1]]]],RemoveFIESTAName[value[[2]]]];
                   QPutWrapper[d,ToString[value[[4]]]<>"-"<>ToString[value[[5]],InputForm]<>"-"<>ToString[value[[1]]]<>"-"<>ToString[PSector[value[[4]],value[[5]],value[[1]]]]<>"F",RemoveFIESTAName[value[[6]]]];
                   runD++
             );

             
        InitializeQLink[{"in"}];
        ClearDatabaseWrapper[dbout,False];
        
        
        
	PerformStage[dbin,Terms,"in","",True];

       (*If[AllEntriesDebug,PrintAllEntries["in"]];*)
	
	
	
	
	
        If[AbortStage===10,Abort[]];


	If[MemoryDebug,RawPrintLn[MyMemoryInUse[]]];

	
	
	
	
	ForEvaluation=Union[{##[[1]], ##[[2]]} & /@DefinedFor[PSector]];
	ForEvaluation=Select[ForEvaluation,(##[[1]]<=runorder)&];
	(*ForEvaluation=Sort[ForEvaluation, (#1[[1]] < #2[[1]]) &];*)
    
	    QPutWrapper["in","Exact",MyToString[False]];
	    QPutWrapper["in","SCounter",MyToString[SCounter]];
	    QPutWrapper["in","UsingC",MyToString[UsingC]];	    
	    QPutWrapper["in","ExternalExponent",MyToString[ExternalExponent]];	
	    QPutWrapper["in","ForEvaluation",MyToString[ForEvaluation]];	    
	    QPutWrapper["in","runorder",MyToString[runorder]];
	    QPutWrapper["in","SHIFT",MyToString[SHIFT]];
	    min=Min@@((##[[1]])&/@ForEvaluation);
	    QPutWrapper["in","ExpandVariable",MyToString[ExpandVariable]];
	    If[min=!=Infinity,
	      ser=Series[EXTERNAL,{ep,0,runorder-SHIFT-min}];
	      QPutWrapper["in","EXTERNAL",MyToString[ser]];	    	
	      For[i=-SHIFT,i<=runorder-SHIFT-min,i++,
		QPutWrapper["in","EXTERNAL-"<>ToString[i]<>"E",MyToString[SeriesCoefficient[ser,i]]]; (*exact*)
		QPutWrapper["in","EXTERNAL-"<>ToString[i],MyToString[CutExtraDigits[N[SeriesCoefficient[ser,i]]]]];
	      ];
	    ,  
	      QPutWrapper["in","EXTERNAL",MyToString[0]];	    		      
	    ];
	    
	    QPutWrapper["in","ForEvaluationString",StringJoin@@((ToString[##[[1]]]<>"-"<>ToString[##[[2]],InputForm]<>"|")&/@ForEvaluation)];	    
	    For[EvC=1,EvC<=Length[ForEvaluation],EvC++,
		CurrentOrder=ForEvaluation[[EvC]][[1]];
		CurrentVarDegree=ForEvaluation[[EvC]][[2]];
		terms=0;
		terms0=0;
		(If[Head[PSector[CurrentOrder,CurrentVarDegree,##]]===PSector,PSector[CurrentOrder,CurrentVarDegree,##]=0])&/@Range[SCounter];
		For[j=1,j<=SCounter,j++,
		    QPutWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-"<>ToString[j],MyToString[PSector[CurrentOrder,CurrentVarDegree,j]]];
		    terms+=PSector[CurrentOrder,CurrentVarDegree,j];
		    If[PSector[CurrentOrder,CurrentVarDegree,j]>0,terms0++];
		];
		QPutWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-T",MyToString[terms]];
		QPutWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-T0",MyToString[terms0]];
		QPutWrapper["in",ToString[CurrentOrder]<>"-"<>ToString[CurrentVarDegree,InputForm]<>"-N",MyToString[NumberOfVariables[CurrentOrder,CurrentVarDegree]]];		
	    ];
	    
	    OldTaskPrefix=TaskPrefix;
	    TaskPrefix="0";	   
	    TaskPrefixes=ToExpression[QSafeGetWrapper["in","","{}"]];
	    QPutWrapper["in","",ToString[Append[TaskPrefixes,OldTaskPrefix]]];
	    TaskPrefix=OldTaskPrefix;

	ClearDatabaseWrapper[dbin,False];  
	If[UsingQLink,QClose[DataPath<>"in"]];
	
	   (* all databases are closed *) 
	Clear[PSector];    
	
        
	(*If[AllEntriesDebug,PrintAllEntries["2"]];*)
        If[AbortStage===11,Abort[]];


	If[MemoryDebug,RawPrintLn[MyMemoryInUse[]]];

	
        
        
        
];


IntegrateHere[expression_,tryexact_]:=Module[{ff,result,result2},
    If[expression=={},Return[{0,0,True}]];
                ff = expression;
                ff=DeleteCases[ff,{aa_,{}}];
                Localresult3=
                    (
                    result2=Reap[Block[{$MessagePrePrint = Sow,$Messages = {}},
                        Quiet[
                            result=DoIntegrate[##,tryexact];
                        ,{Power::infy, Power::indet, Infinity::indet,General::stop}
                    ];
                    ]][[2]];
                    If[result[[1]],
                        Localresult3={result[[2]],0,0}
                    ,
                        result=result[[2]];
                        result2=DeleteCases[##, HoldForm[$MessageList]] & /@result2;
			result2=DeleteCases[##, HoldForm[y]] & /@result2;
			result2=DeleteCases[##, HoldForm[y[_]]] & /@result2;
			result2=DeleteCases[result2,{}];
                        Good=False;
			If[And[Length[$MessageList]>=1,Last[$MessageList]===HoldForm[NIntegrate::"maxp"],Length[result2]===1,
                            ReleaseHold[result2[[1]][[2]]]===result],
                            Good=True;
                            Localresult3=Append[ReleaseHold/@Drop[result2[[1]],1],1];
                        ];
			If[Length[result2]===0,
                            Good=True;
                            Localresult3={result,0,1};
                        ];
                        If[Not[Good],
                            RawPrintLn[PMForm[result]];
                            RawPrintLn["Something went wrong"];
                            RawPrintLn[$MessageList];
                            RawPrintLn[result2];
                            Abort[];
                        ];
                    ];
                    Localresult3
                    )&/@ff;
                 Plus@@Localresult3
]


MyDelta[xx_,yy_]:=Table[If[iii===xx,1,0],{iii,yy}]

NegTerms[0] := {}

NegTerms[xx_] := If[TrueQ[NumberQ[xx]],{},
 Select[List @@
   Expand[xx], ((## /. {x[ii_] -> 1, y[ii_] -> 1}) < 0) &]]

KillNegTerms[ZZ_]:=Module[{temp,vars,subsets,U,F,UF,Z,i},
(*Return[{ZZ}];*)

    {Z,MM,UF}=ZZ;
    temp=NegTerms[UF[[2]]];
    If[temp==={},Return[{ZZ}]];
    RawPrintLn["Negative terms encountered: ",InputForm[temp]];
    vars=#[[1]]&/@Cases[Variables[temp],x[_]];
    subsets=Subsets[vars,{2}];
    For[i=1,i<=Length[subsets],i++,
        If[And[Length[NegTerms[VarDiffReplace[UF[[2]],subsets[[i]]]]]<Length[temp],
               Length[NegTerms[VarDiffReplace[UF[[2]],{subsets[[i]][[2]],subsets[[i]][[1]]}]]]<Length[temp]]
                ,
            RawPrintLn["Decomposing into two sectors corresponding to ",subsets[[i]]];
            Z={#[[1]]/2,#[[2]]}&/@Z;
            Return[{VarDiffReplace[{Z,MM,UF},subsets[[i]]],VarDiffReplace[{Z,MM,UF},{subsets[[i]][[2]],subsets[[i]][[1]]}]}]
        ];
    ];
    Return[{ZZ}]
]

AdvancedKillNegTerms[ZZ_,level_]:=Module[{temp,vars,subsets,U,F,UF,Z,i,mins,rs,r1,r2},
(*Return[{ZZ}];*)    
  (*  If[level===1,RawPrintLn["Advanced netative terms resolution"]];*)
    {Z,MM,UF}=ZZ;
    temp=NegTerms[UF[[2]]];
    If[temp==={},Return[{{ZZ},0}]];
  (*  RawPrintLn["Negative terms encountered: ",InputForm[temp]];*)
    vars=#[[1]]&/@Cases[Variables[temp],x[_]];
    subsets=Subsets[vars,{2}];
    mins=Table[Infinity,{Length[subsets]}];
    rs=Table[{},{Length[subsets]}];
    For[i=1,i<=Length[subsets],i++,
        If[And[Length[NegTerms[VarDiffReplace[UF[[2]],subsets[[i]]]]]<Length[temp],
               Length[NegTerms[VarDiffReplace[UF[[2]],{subsets[[i]][[2]],subsets[[i]][[1]]}]]]<Length[temp]]
                ,
	  (*Print[subsets[[i]]];*)
            r1=AdvancedKillNegTerms[VarDiffReplace[{{#[[1]]/2,#[[2]]}&/@Z,MM,UF},subsets[[i]]],level+1];
            r2=AdvancedKillNegTerms[VarDiffReplace[{{#[[1]]/2,#[[2]]}&/@Z,MM,UF},{subsets[[i]][[2]],subsets[[i]][[1]]}],level+1];
            rs[[i]]=Join[r1[[1]],r2[[1]]];
            mins[[i]]=r1[[2]]+r2[[2]];
        ];
    ];
    

    i=Position[mins,Min[mins],{1}][[1]][[1]];
    If[mins[[i]]===Infinity,
       (*If[Length[temp]>0,Print[ZZ];Print[temp];Abort[]];*)
      (*  Print["Recursion level ",level,": ",Length[temp]," negative terms remaining"];*)
        Return[{{ZZ},Length[temp]}],
(*        Print["Recursion level ",level,": total number of negative terms below =",mins[[i]]];*)
        If[level===1,RawPrintLn["Total number of negative terms remaining in subexpressions: ",mins[[i]]]];
        If[level===1,RawPrintLn["Total number of subexpressions: ",Length[rs[[i]]]]];
        Return[{rs[[i]],mins[[i]]}];  
    ];
]

AdvancedKillNegTerms2[ZZ_,level_]:=Module[{temp,vars,subsets,U,F,UF,Z,i,mins,rs,r1,r2,pairs,variants},
(*Return[{ZZ}];*)    
    (*If[level===1,RawPrintLn["Advanced netative terms resolution, version 2"]];*)
    {Z,MM,UF}=ZZ;
    temp=NegTerms[UF[[2]]];
    If[temp==={},Return[{{{ZZ},0}}]];
  (*  RawPrintLn["Negative terms encountered: ",InputForm[temp]];*)
    vars=#[[1]]&/@Cases[Variables[temp],x[_]];
    subsets=Subsets[vars,{2}];
    variants={};
    (*mins=Table[Infinity,{Length[subsets]}];
    rs=Table[{},{Length[subsets]}];*)
    For[i=1,i<=Length[subsets],i++,
        If[And[Length[NegTerms[VarDiffReplace[UF[[2]],subsets[[i]]]]]<Length[temp],
               Length[NegTerms[VarDiffReplace[UF[[2]],{subsets[[i]][[2]],subsets[[i]][[1]]}]]]<Length[temp]]
                ,
(*Print[subsets[[i]]];
Print["in"];*)
            r1=AdvancedKillNegTerms2[VarDiffReplace[{{#[[1]]/2,#[[2]]}&/@Z,MM,UF},subsets[[i]]],level+1];
            r2=AdvancedKillNegTerms2[VarDiffReplace[{{#[[1]]/2,#[[2]]}&/@Z,MM,UF},{subsets[[i]][[2]],subsets[[i]][[1]]}],level+1];
(*If[level==1,AAAr1=r1;
AAAr2=r2;Abort[]];*)



(*Print["out"];*)
	    pairs=Tuples[{r1,r2}];
	    variants=Join[variants,{Join[##[[1]][[1]],##[[2]][[1]]],##[[1]][[2]]+##[[2]][[2]]}&/@pairs];
(*If[level==1,Print[Length[variants[[1]][[1]]]];Abort[];];*)

        ];
    ];
      If[Length[variants]==0,Return[{{{ZZ},Length[temp]}}]];
	If[level===1,
	  min=Min@@((##[[2]])&/@variants);
	  i=Position[((##[[2]])&/@variants),min][[1]][[1]];	
          RawPrintLn["Total number of negative terms remaining in subexpressions: ",variants[[i]][[2]]];
	  RawPrintLn["Total number of subexpressions: ",Length[variants[[i]][[1]]]];
	  Return[{variants[[i]]}];	
	,
	  Return[variants];
	];  
   
]


AdvancedKillNegTerms3[ZZ_,level_]:=Module[{temp,vars,subsets,U,F,UF,Z,i,mins,rs,r1,r2,pairs,variants,MM},
(*Return[{ZZ}];*)    
    (*If[level===1,RawPrintLn["Advanced netative terms resolution, version 3"]];*)
    {Z,MM,UF}=ZZ;
    If[Length[UF]<2,Return[{{{ZZ},0}}]];
    temp=NegTerms[UF[[2]]];
    If[temp==={},Return[{{{ZZ},0}}]];
  (*  RawPrintLn["Negative terms encountered: ",InputForm[temp]];*)
    vars=#[[1]]&/@Cases[Variables[temp],x[_]];
    subsets=Subsets[vars,{2}];
    variants={};
    (*mins=Table[Infinity,{Length[subsets]}];
    rs=Table[{},{Length[subsets]}];*)
    For[i=1,i<=Length[subsets],i++,
        If[And[Length[NegTerms[AdvancedVarDiffReplace[UF[[2]],subsets[[i]]]]]<Length[temp],
               Length[NegTerms[AdvancedVarDiffReplace[UF[[2]],{subsets[[i]][[2]],subsets[[i]][[1]]}]]]<Length[temp]]
                ,
(*Print[subsets[[i]]];
Print["in"];*)
            r1=AdvancedKillNegTerms3[AdvancedVarDiffReplace[{{#[[1]]/2,#[[2]]}&/@Z,MM,UF},subsets[[i]]],level+1];
            r2=AdvancedKillNegTerms3[AdvancedVarDiffReplace[{{#[[1]]/2,#[[2]]}&/@Z,MM,UF},{subsets[[i]][[2]],subsets[[i]][[1]]}],level+1];
(*If[level==1,AAAr1=r1;
AAAr2=r2;Abort[]];*)



(*Print["out"];*)
	    pairs=Tuples[{r1,r2}];
	    variants=Join[variants,{Join[##[[1]][[1]],##[[2]][[1]]],##[[1]][[2]]+##[[2]][[2]]}&/@pairs];
(*If[level==1,Print[Length[variants[[1]][[1]]]];Abort[];];*)

        ];
    ];
      If[Length[variants]==0,Return[{{{ZZ},Length[temp]}}]];
	If[level===1,
	  min=Min@@((##[[2]])&/@variants);
	  i=Position[((##[[2]])&/@variants),min][[1]][[1]];	
          RawPrintLn["Total number of negative terms remaining in subexpressions: ",variants[[i]][[2]]];
	  RawPrintLn["Total number of subexpressions: ",Length[variants[[i]][[1]]]];
	  Return[{variants[[i]]}];	
	,
	  Return[variants];
	];  
   
]



DecomposeF[ZZ_]:=Module[{temp,vars,subsets,U,F,UF,Z,i,shift},

    {Z,MM,UF}=ZZ;
    temp=Expand[UF[[2]]];
    temp1=Coefficient[temp,ExV,1];
    temp1=Expand[temp1];
    temp2=Coefficient[temp,ExV,2];
    temp=If[Head[temp]===Plus,List@@temp,{temp}];
    temp1=If[Head[temp1]===Plus,List@@temp1,{temp1}];
    temp2=If[Head[temp2]===Plus,List@@temp2,{temp2}];


    If[And[Length[temp1]>0,Length[temp]>Length[temp1]],
        RawPrintLn["Expansion variable found"];
	shift=0;
	While[Expand[UF[[1]]/.(ExV->0)]===0,
	  shift+=1;
	  UF[[1]]=Expand[UF[[1]]/ExV];
	];
    MM*=ExV^shift;
        
        MM=MM*(ExV^(z));
	If[temp2==={0},
	  UF=Join[{UF[[1]]/.(ExV->0),Expand[UF[[2]]-(ExV* Plus@@temp1)]//.(ExV->0),Plus@@temp1},Drop[UF,2]];  
	  Z={##[[1]]*Gamma[-##[[2]][[2]]+z]*Gamma[-z]/Gamma[-##[[2]][[2]]], Join[{##[[2]][[1]], ##[[2]][[2]]-z,z},Drop[##[[2]],2]]} & /@Z;	  
	,
	  Print["Can't handle higher t powers with SDExpand, please try SDExpandAsy"];
	  Abort[];
	];

       
    ];

    {Z,MM,UF}
]


UseEpMonom[ZZ_]:=Module[{temp,vars,subsets,U,F,Z,MM,i,UF},
    {Z,MM,UF}=ZZ;
    MM=Expand[MM];
    If[And[Head[MM]===Power,Head[Expand[MM[[1]]]]===Plus],
        {{#[[1]],Prepend[#[[2]],MM[[2]]]}&/@Z,Prepend[UF,MM[[1]]]}
    ,
        {{#[[1]]*MM,#[[2]]}&/@Z,UF}
    ]
]


KillNegativeIndices[ZZ1_,deltas1_,degrees1_,epdegrees1_]:=Module[{temp,i,j,var,ZZ,degrees,epdegrees,result},
    ZZ=ZZ1;
    deltas=deltas1;
    degrees=degrees1;
    epdegrees=epdegrees1;
    For[i=1,i<=Length[degrees],i++,var=x[i];
        If[epdegrees[[i]]===0,
            While[degrees[[i]]<0,
                ZZ[[1]]=Flatten[
                    Append[
                        Table[
                            {-##[[1]]*D[ZZ[[2]][[j]],var]*##[[2]][[j]],##[[2]]-MyDelta[j,Length[ZZ[[2]]]]},
                            {j,1,Length[ZZ[[2]]]}
                        ],
                        {-D[##[[1]],var],##[[2]]}
                   ]&/@ZZ[[1]],1];

                degrees[[i]]=degrees[[i]]+1;
            ];
            If[degrees[[i]]===0,
                ZZ=Expand[ZZ/.var->0];
                deltas=DeleteCases[##,i]&/@deltas;
                If[GraphUsed,
                    CurrentGraph=ContractEdge[CurrentGraph,i];
                    If[CurrentGraph===False,
                        RawPrintLn["WARNING: loop contracted, possible zero in the answer"];
                        Abort[];
                    ];
                ];
            ];
        ]
    ];
    ZZ[[1]]=Expand[ZZ[[1]]];
    ZZ[[1]]=DeleteCases[ZZ[[1]],{0,{aaa1_,aaa2_}}];
    Return[{ZZ,deltas,degrees,epdegrees}];
];



SDExpandG[{graph_,external_},{U_,F_,h_},degrees1_,order_,exv_,exo_]:=Module[{temp},
    AsyMode=False;
    ExpandMode=True;
    DMode=False;
    ExpandVariable=exv;
    ExpandOrder=exo;
    SDEvaluateG1[{graph,external},{U,F,h},degrees1,order]
]

SDExpand[{U_,F_,h_},degrees1_,order_,exv_,exo_]:=Module[{temp},
    AsyMode=False;
    ExpandMode=True;
    DMode=False;
    ExpandVariable=exv;
    ExpandOrder=exo;
    GraphUsed=False;
    SDEvaluate1[{U,F,h},degrees1,order]
]

SDExpandAsy[{U_,F_,h_},degrees1_,order_,exv_,exo_]:=SDExpandAsy[{U,F,h},{},degrees1,order,exv,exo];


ParseReplacement[rep_] := 
 If[Head[rep] === Rule, {"rule", rep}, 
  If[And[Head[rep] === Greater, 
    rep[[2]] === 0], {"ineq", {rep[[1]], 1}}, 
   If[And[Head[rep] === Smaller, 
     rep[[2]] === 0], {"ineq", {rep[[1]], -1}}, {"error", rep}]]];

SDExpandAsy[{U_,F_,h_},ExtraAll_,degrees1_,order_,exv_,exo_]:=Module[{ExtraReplacements,ExtraSigns,i,shift,temp,j,ZZ,result={},l,n,deg,temp1,all,temp2,outside,ll,times,U1,F1,degrees2,min,var,pos,ii,found,jj,zeros,vars},
    temp=ParseReplacement/@ExtraAll;
    If[Length[Cases[temp,{"error",_}]]>0,
	Print["Incorrect replacements or signs"];
	Print[Last/@Cases[temp,{"error",_}]];
	Abort[];
    ];
    
    ExtraReplacements = Last/@Cases[temp,{"rule",_}];
    ExtraSigns = Last/@Cases[temp,{"ineq",_}];

    AsyMode=True;
    RawPrintLn[VersionString];
    ExpandMode=False;
    DMode=False;
    n=Length[degrees1];
    
    zeros = Flatten[Position[(## <= 0) & /@ degrees1, True]];
    vars = x/@ Complement[Range[n], zeros];
    
    If[Length[zeros]>0, RawPrintLn["Active variables: ",vars]];
    
    {U1,F1}=Map[Rationalize[##,0]&, {U,F}, {0, Infinity}] /. (Rule[x[##], 0] & /@ zeros);

    InitializeAllLinks[];
    
    If[Not[AsyLoaded],
	RawPrintLn["Loading ASY"];
	Get[CurrentAsyPath[]];
    ];
    
    
    If[PreResolve,
	regions = {U1,F1}//.ExtraReplacements;
	regions = Global`AdvancedKillNegTerms3Asy[{IdentityMatrix[Last[Sort[Variables[U1*F1]]][[1]]], 1, regions}, 1, exv, ExtraSigns][[1]][[1]];	
	regions=(temp=##[[1]];temp2=##[[2]];{temp,temp2,##}&/@PExpand[(##[[3]][[1]]*##[[3]][[2]]),vars,exv,IntegralDim -> Length[vars]-1])&/@regions;
	regions=Flatten[regions,1];
	regions={yy=Range[Length[##[[1]][[1]]]];temp=##[[1]];Apply[Rule,Transpose[{(x[##] & /@ yy), temp.(y[##] & /@ yy)}], {1}],##[[2]],##[[3]]}&/@regions;
    ,
	If[FastASY,
	  regions=PExpand[F1//.ExtraReplacements,vars,exv,PreResolve->False,IntegralDim->Length[vars]-1];
	  If[regions=={},
	    RawPrintLn["Fast ASY mode failed."];
	    regions=PExpand[(U1*F1)//.ExtraReplacements,vars,exv,PreResolve->False,IntegralDim->Length[vars]-1];
	  ,
	    RawPrintLn["Warning: fast ASY mode used. Some regions may be undetected."];
	  ];
	,  
	  regions=PExpand[(U1*F1)//.ExtraReplacements,vars,exv,PreResolve->False,IntegralDim->Length[vars]-1];
	];
	regions = {Rule @@@ Transpose[{vars, vars /. x -> y}],1,##}&/@regions;
    ];
    

        
    DeleteFile[Global`InFile/.Options[Global`QHull]];
    DeleteFile[Global`OutFile/.Options[Global`QHull]];
    
    regions=({##[[1]],##[[2]],##[[3]]-Min@@(##[[3]])})&/@regions;
    

    PutAtPositions[x_, y_, n_] :=(*technical*)
	  Normal[SparseArray[Apply[Rule, Transpose[{x, y}], {1}], {n}]];
 
    regions = {##[[1]],##[[2]],PutAtPositions[Complement[Range[n], zeros],##[[3]],n]}&/@regions;

    
    If[PreResolve,
	RawPrintLn["Regions: ",ToString[regions,InputForm]];
    ,
	RawPrintLn["Regions: ",ToString[##[[3]]&/@regions,InputForm]];
    ];
    
    
    
    
    
    
    
If[Not[OnlyPrepareRegions],
    
 
 InitializeQLink[{"in"}];
 
 
 
 TaskPrefix="0";
 QPutWrapper["in","RegVar",MyToString[RegVar]];
 QPutWrapper["in","SmallVar",MyToString[exv]];
 QPutWrapper["in","RequestedOrders",MyToString[{order,exo}]];
 If[UsingQLink,QClose[DataPath<>"in"]];
 
 ];
 
 OldOnlyPrepare=OnlyPrepare;
 OnlyPrepare=True;
    
    
    If[Or@@(Not[IntegerQ[##]]&/@Flatten[##[[3]]&/@regions]),Print["Can't continue with fractional regions. Please consider changing the small variable"];Abort[]];
    
    
    
For[j=1,j<=Length[regions],j++,
    If[PreResolve,
	RawPrintLn["Working in region ",ToString[regions[[j]],InputForm]];    
    ,
	RawPrintLn["Working in region ",ToString[regions[[j]][[3]],InputForm]];    
    ];
   
    

    temp = Map[Rationalize[##,0]&, {U,F}, {0, Infinity}];
    
    (* created powers *)
    ZZ={{Gamma[Expand[Plus@@degrees1-h(d0/2-ep)]]/regions[[j]][[2]],{Plus@@degrees1-(h+1)(d0/2-ep),-(Plus@@degrees1-h(d0/2-ep))}}};

    (* degrees to start with *)
    degrees2=degrees1;

    ZZ={ZZ,temp};

    
    (*killing negative indices*)
    (* here we diffirentiate only for negative indices, they are indepentent from positive - with region replacements *)

    For[i=1,i<=Length[degrees2],i++,var=x[i];
            While[TrueQ[degrees2[[i]]<0],
                ZZ[[1]]=Flatten[
                    Append[
                        Table[
                            {-##[[1]]*D[ZZ[[2]][[j]],var]*##[[2]][[j]],##[[2]]-MyDelta[j,Length[ZZ[[2]]]]},
                            {j,1,Length[ZZ[[2]]]}
                        ],
                        {-D[##[[1]],var],##[[2]]}
                   ]&/@ZZ[[1]],1];
                degrees2[[i]]=degrees2[[i]]+1;
            ];
            If[degrees2[[i]]===0,
                ZZ=Expand[ZZ/.var->0];
            ];
    ];

    temp=ZZ[[2]];
    ZZ=ZZ[[1]];

    
    (* region replacement for functions - PreResolve*)
    temp=temp //. regions[[j]][[1]];
    temp=ExpandAll[temp  //. {y[a_]:>x[a]}];
    ZZ=ZZ //. regions[[j]][[1]];
    ZZ=ExpandAll[ZZ  //. {y[a_]:>x[a]}];
  (*Print[ZZ];  *)
    If[Or@@((##==0)&/@temp),Return[0]];
  
    (* region replacement for degrees - PreResolve*)
    If[PreResolve,
      For[i=1,i<=Length[degrees2],i++,var=x[i];
	If[And[Not[TrueQ[degrees2[[i]]===1]],Not[TrueQ[degrees2[[i]]===0]]],
	   ZZ ={##[[1]], Append[##[[2]],degrees2[[i]]-1]}&/@ZZ;
	   AppendTo[temp,ExpandAll[(var//. regions[[j]][[1]])  //. {y[a_]:>x[a]}]];
	   degrees2[[i]]=1;
	];
      ];
    ];
 
   (* Print[ZZ];
    Print[temp];*)
    
    (* region replacement for functions - exv multiplication*)
    temp=temp /. {x[i_] :>  x[i] exv^regions[[j]][[3]][[i]] } //. a__^b__ :> Factor[a]^Expand[b] // PowerExpand;
    ZZ=ZZ /. {x[i_] :>  x[i] exv^regions[[j]][[3]][[i]] } //. a__^b__ :> Factor[a]^Expand[b] // PowerExpand;	
    ZZ=Append[##,0]&/@ZZ;
    (*factoring out power of exv from functions*)
    For[i=1,i<=Length[temp],i++,
      While[(temp[[i]]/.{exv->0})==0,
	  temp[[i]]=Together[temp[[i]]/exv];
	  ZZ={##[[1]],##[[2]],##[[3]]+##[[2]][[i]]}&/@ZZ;	  
      ]
    ];

    ZZ=ExpandAll[ZZ];
    ZZ=DeleteCases[ZZ,{0,_,_}];

    (*factoring out power of exv from ZZ*)
    ZZ=(temp2=##;While[(temp2[[1]]/.{exv->0})==0,temp2={Together[temp2[[1]]/exv],temp2[[2]],temp2[[3]]+1}];temp2)&/@ZZ;

    (* region replacement for degrees - exv multiplication*)
    (* x[i] is in power degrees2[[i]]-1; 
       however the Jacobian is the product of exv^regions[[j]][[3]][[i]]
       hence the power of exv appearing is Sum[regions[[j]][[3]][[i]]*(degrees2[[i]])];
    *)
    shift=Sum[regions[[j]][[3]][[i]]*(degrees2[[i]]), {i, 1, Length[degrees2]}];

    (*taking out min*)
  
    min=Min@@((##[[3]]/.{exv->0,ep->0,RegVar->0})&/@ZZ);
    pos=Position[((##[[3]]/.{exv->0,ep->0,RegVar->0})&/@ZZ),min][[1]][[1]];
 
    shift+=ZZ[[pos]][[3]];
    ZZ={exv^(##[[3]]-ZZ[[pos]][[3]])*##[[1]],##[[2]]}&/@ZZ;

    (*done cancelling*)


    n=Max@@((##[[1]])&/@Cases[Variables[Plus@@temp],x[_]]);

    shift=Expand[shift];
    
    (*Print[ZZ];*)
    
    RawPrintLn["External degree: ",ToString[shift,InputForm]];
    If[(shift/.{ep->0,RegVar->0})<=exo,
	 
	 outside=(E^(h EulerGamma ep));
	 
	 i=0;
	 While[(shift/.{ep->0,RegVar->0})+i<=exo,
	    
	    RawPrintLn["Evaluating at order ",ToString[(shift/.{ep->0,RegVar->0})+i,InputForm]];
	    temp2={Expand[({##[[1]]/(Factorial[i]),##[[2]]}&/@ZZ)/.{exv->0}],temp/.{exv->0}};
	    temp2[[1]]=DeleteCases[temp2[[1]],{0,_}];
	  If[Length[temp2[[1]]]>0,
	    (* here we will work in this region, otherwise only continue to next order*)

	    If[OnlyPrepareRegions,
		temp3=temp2;
		temp2={temp2[[1]],Table[temp2[[2]],{Length[temp2[[1]]]}]};
		temp2=Transpose[temp2];
		temp2={Append[##[[2]],##[[1]][[1]]],Append[##[[1]][[2]],1]}&/@temp2;
		temp2=Transpose/@temp2;
		temp2=Apply[Power,temp2,{2}];
		temp2=Apply[Times,temp2,{1}];
		temp2=Apply[Plus,temp2,{0}];
		(*AppendTo[result,{regions[[j]][[3]],temp2*outside*exv^(shift+i)}];*)
		RawPrintLn[ToString[Inner[(Power[#1,#2-1]/If[Not[TrueQ[#2<=0]],Gamma[#2],1])&,Array[x,Length[degrees2]],degrees2,Times]*temp2*outside*exv^(shift+i),InputForm]];
		temp2=temp3;
	    ];


	    deg=degrees2;
	    times=1;

	    For[l=1,l<=Length[deg],l++,
	      While[And@@(((##[[1]]/.{x[l]->0})===0)&/@(temp2[[1]])),
		 temp2[[1]]={Together[##[[1]]/x[l]]*(Gamma[deg[[l]]+1]/Gamma[deg[[l]]]),##[[2]]}&/@(temp2[[1]]);
		 deg[[l]]++;
	      ]
	    ];
  
    (* here we start integrating, label used*)

    Label[go];
(*Print[temp2];*)
        n=Length[deg];
    For[l=1,l<=n,l++,
      If[deg[[l]]==0,Continue[]];

      found=False;

      (*searching for single function depending on first power of x[l]*)

      For[ii=1,ii<=Length[temp2[[2]]],ii++,
	  If[And[
	      Cases[Variables[{Delete[temp2[[2]],ii]}],x[l]]==={},
	      Coefficient[temp2[[2]][[ii]],x[l],2]===0
	    ]
	  ,
	    found=True;
	    Break[]
	  ]
      ];

      (*If[False, *)(* !!!!!!!!!!!!!!!!!! *)
      If[And[AnalyticIntegration,found],
	(*Print[l];*)
	RawPrintLn["Integrating by x[",l,"] and changing variables"];

	(*transforming z - third member is the degree of deg[[l]]*)
	temp2[[1]] = {CoefficientRules[##[[1]], x[l]], ##[[2]]} & /@ (temp2[[1]]);
	temp2[[1]] = {##[[1]][[2]], ##[[2]], ##[[1]][[1]][[1]]} & /@ 
	      Flatten[Transpose[{##[[1]], Table[##[[2]], {Length[##[[1]]]}]}] & /@ (temp2[[1]]), 1];

	(*integrating*)
	AppendTo[temp2[[2]],Together[(temp2[[2]][[ii]]-(temp2[[2]][[ii]]/.{x[l]->0}))/x[l]]];
	temp2[[2]][[ii]]=temp2[[2]][[ii]]/.{x[l]->0};
	temp2[[1]]={(1/Gamma[deg[[l]]])*##[[1]]*Gamma[Expand[-##[[2]][[ii]]-(deg[[l]]+##[[3]])]]*Gamma[deg[[l]]+##[[3]]]/Gamma[-##[[2]][[ii]]],
			Append[ReplacePart[##[[2]],ii->##[[2]][[ii]]+(deg[[l]]+##[[3]])],-(deg[[l]]+##[[3]])]
		   }&/@temp2[[1]];
	deg[[l]]=0;
(*
	(*shifting*)
	For[ll=l+1,ll<=n,ll++,
	  temp2=temp2//.{x[ll]->x[ll-1]};
	];
	deg=Delete[deg,l];
	n=Length[deg];
*)
	
	pos = Complement[Range[n],Flatten[Position[deg,0]]];
	
	If[Length[pos]==1,
	(*Break[];*)
	    RawPrintLn["Delta function used"];
	    temp2[[1]]={##[[1]]/Gamma[deg[[First[pos]]]],##[[2]]}&/@(temp2[[1]]);
	    temp2=temp2/.{x[First[pos]]->1};
	    deg={};
	];


	For[l=1,l<=Length[temp2[[2]]],l++,(*factoring out*)
	   If[Length[Union[(##[[2]][[l]])&/@(temp2[[1]])]]===1,
		For[ll=1,ll<=Length[deg],ll++,
		   While[And[(temp2[[2]][[l]] /. {x[ll] -> 0}) == 0, temp2[[2]][[l]] =!= 0],
			temp2[[2]][[l]]=Together[temp2[[2]][[l]]/x[ll]];
			temp2[[1]]={##[[1]]*(Gamma[Expand[deg[[ll]]+temp2[[1]][[1]][[2]][[l]]]]/Gamma[deg[[ll]]]),##[[2]]}&/@(temp2[[1]]);
			deg[[ll]]+=temp2[[1]][[1]][[2]][[l]];
		   ]
		]
	   ];
	];


	(*factoring functions*)
	For[ii = 1, ii <= Length[temp2[[2]]], ii++,
	  ttt = FactorList[temp2[[2]][[ii]]];
	  ttt = DeleteCases[ttt, {1, 1}];
	  If[Length[ttt] === 0, Continue[]];
	  temp2[[2]] = Join[temp2[[2]], (##[[1]]) & /@ Drop[ttt, 1]];
	  temp2[[2]][[ii]] = ttt[[1]][[1]];
	  temp2[[1]] = {##[[1]], Join[##[[2]], ((##[[2]]) & /@ Drop[ttt, 1])*##[[2]][[ii]]]} & /@ (temp2[[1]]);
	  temp2[[1]] = {##[[1]],ReplacePart[##[[2]], ii -> ttt[[1]][[2]]*##[[2]][[ii]]]} & /@ (temp2[[1]]);
	];

	(*factoring free term*)
	For[ii = 1, ii <= Length[temp2[[1]]], ii++,
	  ttt = FactorList[temp2[[1]][[ii]][[1]]];
	  ttt = DeleteCases[ttt, {1, 1}];
	  If[Length[ttt] === 0, Continue[]];
	  jj = 1;
	  While[jj <= Length[ttt],
	    If[MemberQ[temp2[[2]], ttt[[jj]][[1]]],
	      pos = Position[temp2[[2]], ttt[[jj]][[1]], {1}][[1]][[1]];
	      temp2[[1]][[ii]][[2]][[pos]] += ttt[[jj]][[2]];
	      ttt = Delete[ttt, jj];
	    ,
	      jj++
	    ];
	  ];
	  temp2[[1]][[ii]][[1]] = Times @@ Power @@@ ttt;
	];
	(*joining equal*)
	For[ii = 1, ii <= Length[temp2[[2]]], ii++,
	  jj = ii + 1;
	  While[jj <= Length[temp2[[2]]],
	    If[temp2[[2]][[ii]] === temp2[[2]][[jj]],
	      temp2[[1]] = {##[[1]], Delete[ReplacePart[##[[2]], ii -> ##[[2]][[ii]] + ##[[2]][[jj]]], jj]} & /@ (temp2[[1]]);
	      temp2[[2]] = Delete[temp2[[2]], jj];
	    ,
	      jj++;
	    ];
	  ];
	];

	l=1;   
	While[l<=Length[temp2[[2]]],  (*removing ones*)
	  If[temp2[[2]][[l]]===1,
	     temp2[[2]]=Delete[temp2[[2]],l];
	     temp2[[1]]={##[[1]],Delete[##[[2]],l]}&/@(temp2[[1]]);
	  ,
	     l++;
	  ];
	];    

	If[Length[temp2[[2]]]===1,   (*has to be at least length two*)
	    temp2[[2]]=Prepend[temp2[[2]],1];
	    temp2[[1]]={##[[1]],Prepend[##[[2]],1]}&/@(temp2[[1]]);
	];

	times++;
	If[Length[deg]===0,Break[]];
	Goto[go];
      ];  (*if analytic integration and found *)

    ];  (* the cycle *)




(*Print[temp2];*)


	    (*If[OnlyPrepareRegions,
		temp2={temp2[[1]],Table[temp2[[2]],{Length[temp2[[1]]]}]};
		temp2=Transpose[temp2];
		temp2={Append[##[[2]],##[[1]][[1]]],Append[##[[1]][[2]],1]}&/@temp2;
		temp2=Transpose/@temp2;
		temp2=Apply[Power,temp2,{2}];
		temp2=Apply[Times,temp2,{1}];
		temp2=Apply[Plus,temp2,{0}];
		AppendTo[result,{regions[[j]][[3]],Inner[(Power[#1,#2-1]/If[Not[TrueQ[#2<=0]],Gamma[#2],1])&,Array[x,Length[deg]],deg,Times]*temp2*outside*exv^(shift+i)}];
	    ,*)
		TaskPrefix=ToString[ToExpression[TaskPrefix]+1];
		(*Print[SDEvaluate22[temp2,h,deg,order,order,outside,shift+i]];*)
		GraphUsed=False;
		(*Print[SDEvaluate222[temp2,h,deg,order,order,outside,shift+i]];*)
		temp0=SDEvaluate2[temp2,h,deg,order,order,outside,shift+i];
		If[OnlyPrepareRegions,
		    temp2 = temp0[[2]];
		    temp2 = {##[[1]], Table[##[[2]], {Length[##[[1]]]}]} & /@ temp2;
		    temp2 = Transpose[##] & /@ temp2;
		    temp2 = Map[{Append[##[[2]], ##[[1]][[1]]], Append[##[[1]][[2]], 1]} &, temp2, {2}];
		    temp2 = Map[Transpose, temp2, {2}];
		    temp2 = Apply[Power, temp2, {3}];
		    temp2 = Apply[Times, temp2, {2}];
		    temp2 = Apply[Plus, temp2, {1}];
		    temp2 = Apply[Plus, temp2, {0}];
		    temp2 = Inner[Power[#1,If[#2===0,0,#2-1]]&, Array[x, Length[temp0[[1]]]], temp0[[1]], Times] *temp2* temp0[[6]]* Times @@ (Delta /@ Apply[Plus, Map[x, temp0[[4]], {2}], {1}]) * exv^temp0[[7]];
		    AppendTo[result,{regions[[j]][[3]],temp2}];
(*		    RawPrintLn[ToString[temp2,InputForm]];		    *)
		];
		(*AppendTo[result,exv^(shift+i)];*)
	    (*];	    *)
	    
	    ];(*end of big if (integration needed for this order)*)
	    
	    
	    If[(shift/.{ep->0,RegVar->0})+i<exo,
		(*ZZ transformation *)
		ZZ=Flatten[
                    Append[
			 Table[
                            {##[[1]]*D[temp[[j]],exv]*##[[2]][[j]],##[[2]]-MyDelta[j,Length[temp]]},
                            {j,1,Length[temp]}
                        ],
                       {D[##[[1]],exv],##[[2]]}
                   ]&/@ZZ,1];
		ZZ=DeleteCases[ZZ,{0,_}];
		If[ZZ=={},
		  RawPrintLn["Nothing from this region"];
		  Break[];
		]
	    ];
	    i++;
	 ]  (*big while *)
    ,
      RawPrintLn["Nothing from this region"];
    ];

];
    

OnlyPrepare=OldOnlyPrepare;
    
    If[OnlyPrepareRegions,Return[Reap[Sow[##[[2]], 
     G[##[[1]]]] & /@ result, _, {{##}[[1]][[1]], {##}[[2]]} &][[2]]]];

If[OnlyPrepare,
	If[UsingC,
	    command=FIESTAPath<>"/bin/CIntegratePool -in "<>DataPath<>"in -threads "<>ToString[NumberOfLinks]<>CommandOptions;
	    RawPrintLn[command];
	];
    Return[];
];
     
(*RawPrintLn["Integrating ",Length[result]," tasks."];*)

SDIntegrate[];
result2=GenerateAnswer[];


If[RemoveDatabases,    
        If[UsingQLink,
	    DeleteFile[DataPath<>"in.kch"];
	    DeleteFile[DataPath<>"out.kch"];
	,
	    Clear[Evaluate[ToExpression["dbin"]]];
	    Clear[Evaluate[ToExpression["dbout"]]]	
	];  
    ];

result2

]

SDEvaluateG[{graph_,external_},{U_,F_,h_},degrees1_,order_]:=Module[{temp},
    AsyMode=False;    
    ExpandMode=False;
    DMode=False;
    SDEvaluateG1[{graph,external},{U,F,h},degrees1,order]
]


SDEvaluate[{U_,F_,h_},degrees1_,order_]:=SDEvaluate[{U,F,h},degrees1,order,0]

SDEvaluate[{U_,F_,h_},degrees1_,order_,diff_]:=Module[{temp},
    AsyMode=False;
    ExpandMode=False;
    DMode=False;
    GraphUsed=False;
    SDEvaluate1[{U,F,h},degrees1,order,diff]
]

SDAnalyze[{U_,F_,h_},degrees1_,dmin_,dmax_]:=Module[{temp},
    AsyMode=False;
    ExpandMode=False;
    DMode=True;
    DMIN=dmin;
    DMAX=dmax;
    GraphUsed=False;
    SDEvaluate1[{U,F,h},degrees1,0]
]



SDEvaluateG1[{graph_,external_},{U_,F_,h_},degrees1_,order_]:=Module[{temp},
    GraphUsed=True;
    InfinityVertex=Apply[Max,graph,{0,Infinity}]+1;
    CurrentGraph=MyGraph[Join[graph,{##,InfinityVertex}&/@external]];
    Exte=Length[external];
    External=external;
    SDEvaluate1[{U,F,h},degrees1,order]
]

(* creating external gamma *)

SDEvaluate1[{U_,F_,h_},degrees1_,order_]:=SDEvaluate1[{U,F,h},degrees1,order,0]

SDEvaluate1[{U_,F_,h_},degrees1_,order_,diff_]:=Module[{temp,ZZ,degrees,a1,outside,result,runorder},
    RawPrintLn[VersionString];
    degrees=degrees1/.{ep->0};
    a1=Plus@@degrees1;
    outside=(E^(h EulerGamma ep));
    outside=outside*Gamma[a1-h(d0/2-ep)];
    runorder=order;
    If[And[((a1-(h)(d0/2-ep))/.ep->0)<=0,IntegerQ[((a1-(h)(d0/2-ep))/.ep->0)]],
	runorder++
    ];
    ZZ={{1,{a1-(h+1)(d0/2-ep),-(a1-h(d0/2-ep))}}};
    temp = {ZZ,{U,F}};
    If[diff=!=0,
	temp[[1,1,1]] = temp[[1,1,1]] * temp[[1,1,2,2]] * (D[F,diff]/.{diff->0});
	temp[[1,1,2,2]] = temp[[1,1,2,2]] - 1;
	temp[[2,2]] = temp[[2,2]] /.{diff->0};
    ];
    InitializeAllLinks[];
    TaskPrefix=  "1";
    result=SDEvaluate2[temp,h,degrees1,order,runorder,outside,0][[1]];
    result
]


(* stage 2; used by SDExpandAsy; we deal with negative indices, create runorder and deltas *)
SDEvaluate2[ZZ0_,h_,degrees1_,order_,runorder2_,outside_,ExternalExponent_]:=Module[{ZZ,n,degrees,epdegrees,a1,deltas,runorder},

    runorder=runorder2;
    
    degrees=degrees1/.{ep->0};
    epdegrees=Expand[degrees1-(degrees1/.{ep->0})]/ep;
    a1=Plus@@degrees1;

    ZZ=ZZ0;
    
    n=Length[degrees1];
    If[GraphUsed,
        If[Not[M[CurrentGraph]-Exte===Length[degrees1]],
            RawPrintLn["ERROR: length of indices is different from the number of lines in the graph"];
            Abort[];
        ];
    ];
    
    If[And[Not[NegativeTermsHandling==="None"],Length[degrees]>0],    
      If[Length[NegTerms[ZZ[[2]]]]==Length[Expand[ZZ[[2]]]],
	RawPrintLn["All terms in F are negative. Please consider to change the sign of all propagators"];
      ,
	If[Length[NegTerms[ZZ[[2]]]]>Length[Expand[ZZ[[2]]]]/2,
	  RawPrintLn["There are more negative terms in F than positive ones. Please consider to change the sign of all propagators"]
	]
      ];
    ];
    
    For[j=1,j<=Length[degrees],j++,
        If[And[degrees[[j]]<=0,Not[epdegrees[[j]]==0]],runorder--]
    ];

    deltas={Range[n]};
    
    {ZZ,deltas,degrees,epdegrees}=KillNegativeIndices[ZZ,deltas,degrees,epdegrees];

    If[RegMode,
	{ZZ,deltas,degrees,epdegrees}={ZZ,deltas,degrees,epdegrees}/.{RegVar->z};
	ExpandVariable=RegVar;
    ];

    SDEvaluate3[ZZ,degrees,epdegrees,runorder,order,outside,deltas,ExternalExponent]
]
SDEvaluateDirect[var_, functions_, degrees_, order_] := SDEvaluateDirect[var, functions, degrees, order,{}];

SDEvaluateDirect[var_, functions_, degrees_, order_,deltas_] :=  Module[{temp, n, ZZ, result, intvars,i},
    ExpandMode=False;
    AsyMode=False;    
    DMode=False;
    VariablesHere = Sort[Union[Cases[functions, var[_], {0, Infinity}]]];
    If[Length[VariablesHere]===0,
      n=0,
      n = Last[VariablesHere][[1]]
    ];
    temp = Transpose[{functions, degrees}];
    ZZ = {{{Times @@ ((##[[1]]) & /@ Select[temp, (##[[2]] === 1) &]), DeleteCases[degrees, 1]}}, 
                 Rationalize[(##[[1]]) & /@ Select[temp, (##[[2]] =!= 1) &]]}/.var->x;

    InitializeAllLinks[];
    TaskPrefix=  "1";          
    GraphUsed=False;
    
    SDEvaluate3[ZZ,Table[1,{n}],Table[0,{n}],order,order,1,deltas,0][[1]]

]

SDExpandDirect[var_, functions_, degrees_, order_, exv_, exo_]:=SDExpandDirect[var, functions, degrees, exv,{}]


SDExpandDirect[var_, functions_, degrees_, order_, exv_, exo_, deltas_] :=  Module[{temp, VVariables, n, ZZ, result, intvars,i},
    RawPrintLn[VersionString];
    AsyMode=False;
    ExpandMode=True;
    DMode=False;
    ExpandVariable=exv;
    ExpandOrder=exo;
    
    VariablesHere = Sort[Union[Cases[functions, var[_], {0, Infinity}]]];
    If[Length[VariablesHere]===0,
      n=0,
      n = Last[VariablesHere][[1]]
    ];
    temp = Transpose[{functions, degrees}];
    ZZ = {{{Times @@ ((##[[1]]) & /@ Select[temp, (##[[2]] === 1) &]), DeleteCases[degrees, 1]}}, 
                 Rationalize[(##[[1]]) & /@ Select[temp, (##[[2]] =!= 1) &]]/.var->x};
                 
    InitializeAllLinks[];
    TaskPrefix=  "1";          
    GraphUsed=False;
    
    SDEvaluate3[ZZ,Table[1,{n}],Table[0,{n}],order,order,1,deltas,0][[1]]             
]


(* stage 3; used by the direct syntax; external Gamma-function already created; function simplifications performed *)
SDEvaluate3[ZZ1_,degrees_,epdegrees_,runorder_,order_,outside_,deltas_,ExternalExponent_]:=Module[{temp,i,j,var,ZZ,aaa,denom},
   
    If[And[ValueQ[RegVar],ExpandMode],
	Print["Can't continue together with SDExpand and RegVar"];
	Abort[];
    ];
    
    (* here ZZ is a pair; first argument is a list of pairs - monomial and list of powers, second - list of functions *)
    
    ZZ=ZZ1;
    If[Length[ZZ[[1]]]===0,Return[{0}]];
    n=Length[degrees];
    intvars=Table[(If[Or[Variables[degrees[[i]]]=!={},degrees[[i]]>0,Not[epdegrees[[i]]===0]],1,0]),{i,1,n}];
    ZZ[[1]]={#[[1]]*(Times@@Table[x[i]^(If[TrueQ[degrees[[i]]>0],degrees[[i]]-1,0]),{i,1,n}])
	    /(Times@@Table[If[TrueQ[MemberQ[Variables[degrees[[i]]],z]],Gamma[degrees[[i]]+ep*epdegrees[[i]]],1],{i,Length[degrees]}])
	,#[[2]]}&/@ZZ[[1]];
    ZZ={{ZZ[[1]],(Times@@Table[x[i]^(If[intvars[[i]]===1,epdegrees[[i]]*ep+If[Not[TrueQ[degrees[[i]]>0]],degrees[[i]]-1,0],0]),{i,1,n}]),ZZ[[2]]}};


    (* we used indices, inserted a middle argument (weird monomial), put everything in a list *)
   
    
    If[Length[degrees]>0,

	If[NegativeTermsHandling==="Squares",
	  While[True,
	      ZZOld=ZZ;
	      ZZ=Flatten[KillNegTerms/@ZZ,1];
	      If[ZZ===ZZOld,Break[]];
	  ];
	];
    
	If[NegativeTermsHandling==="AdvancedSquares",
	  ZZ=Flatten[AdvancedKillNegTerms[##,1][[1]]&/@ZZ,1]
	];

	If[NegativeTermsHandling==="AdvancedSquares2",
	  ZZ=Flatten[AdvancedKillNegTerms2[##,1][[1]][[1]]&/@ZZ,1]
	];    

	If[Or[NegativeTermsHandling==="AdvancedSquares3",And[NegativeTermsHandling==="Auto",Not[ComplexMode]]],
	  ZZ=Flatten[AdvancedKillNegTerms3[##,1][[1]][[1]]&/@ZZ,1]
	];    
	
    ];
 
    If[Not[RegMode],
        ZZ=ZZ/.ExpandVariable->ExV;
    ];
    If[ExpandMode,
        ZZ=DecomposeF/@ZZ
    ];

    ZZ=UseEpMonom/@ZZ;

    (* middle argument is gone *)
    
    denom=Times@@Table[If[TrueQ[Or[And[degrees[[i]]<=0,epdegrees[[i]]==0],MemberQ[Variables[degrees[[i]]],z]]],1,Gamma[degrees[[i]]+ep*epdegrees[[i]]]],{i,Length[degrees]}];
    RawPrintLn["Integration has to be performed up to order ",runorder];
    
    If[OnlyPrepareRegions,
      Return[{intvars,ZZ,runorder,deltas,runorder-order,outside/denom,ExternalExponent}]; 
    ,
      Return[SDPrepareAndIntegrate[intvars,ZZ,runorder,deltas,runorder-order,outside/denom,ExternalExponent]]; 
    ];
]

IntegrationCommand[]:=Module[{result3},    	
    InitializeQLink[{"out"}];    
    TaskPrefix="0";    
    result3=QSafeGetWrapper["out","IntegrationCommand","Missing integration command"];
    If[UsingQLink,QClose[DataPath<>"out"]];
    result3
]

GenerateAnswer[]:=GenerateAnswer[True];

GenerateAnswer[ExpandResult_]:=Module[{result3,temp},    	
    InitializeQLink[{"out"}];
    
    TaskPrefix="0";    
    TaskPrefixes=ToExpression[QGetWrapper["out",""]]; (*do not add my*)
    RegVar=MyToExpression[QSafeGetWrapper["out","RegVar",MyToString[RegVar]]];
    SmallVar=MyToExpression[QSafeGetWrapper["out","SmallVar",MyToString[SmallVar]]];
    RequestedOrders=MyToExpression[QSafeGetWrapper["out","RequestedOrders",MyToString[RequestedOrders]]];    
    
    
    result3=(TaskPrefix=ToString[##];
	    temp=InternalGenerateAnswer[];
	    temp=Append[##,Power[SmallVar,MyToExpression[QGetWrapper["out","ExternalExponent"]]]]&/@temp;	   
	    temp
	    )&/@TaskPrefixes;
(*	 Print[result3];*)
    result3=Apply[Times,result3,{2}]; (*multiplying coeff and ext var deg*)
    result3=Apply[Plus,result3,{1}];  (*summing all up*)
    
    If[UsingQLink,QClose[DataPath<>"out"]];
    
    (*If[Length[result3]===1,Return[result3[[1]]]];*)

    (*Print[result3];*)
    
    If[ExpandResult,
	result3=Collect[Normal[Series[Series[Plus @@ result3, {RegVar, 0, 0}], {ep, 0, RequestedOrders[[1]]}]], {ep, SmallVar, Log[SmallVar],RegVar}, DoubleCutExtraDigits[KillSmall[PMSimplify[##]]]&];
	If[Head[RequestedOrders]===List,
	  temp=Exponent[result3,ep];
	  If[And[temp=!=RequestedOrders[[1]],temp=!=-Infinity],
	      Print["WARNING: requested ep order is ",RequestedOrders[[1]],", but result is up to ",temp];
	  ];
	];
	result3
    ,
	result3
    ]
]


InternalGenerateAnswer[]:=Module[{temp,i,j,min,degs,result,SHIFT,EXTERNAL,ForEvaluation,order,lastexact,HasExact},  (*returns a list of pairs - second term is extvar degree*)


    HasExact=MyToExpression[QGetWrapper["out","Exact"]];
    If[HasExact,
	Return[{{MyToExpression[QGetWrapper["out","ExactValue"]]}}];
    ];

	ForEvaluation=MyToExpression[QGetWrapper["out","ForEvaluation"]];
	runorder=MyToExpression[QSafeGetWrapper["out","MaxEvaluatedOrder",MyToString[-Infinity]]];
	SHIFT=MyToExpression[QGetWrapper["out","SHIFT"]];
	EXTERNAL=MyToExpression[QGetWrapper["out","EXTERNAL"]];
	ExpandVariable=MyToExpression[QGetWrapper["out","ExpandVariable"]];

    degs=Union[##[[2]]&/@ForEvaluation];
    result=Flatten[(
        min=Min@@((##[[1]])&/@Cases[ForEvaluation,{_,##}]);
	    (*min<=runorder, that's for sure*)
            (*temp=Series[EXTERNAL,{ep,0,runorder-min}];   -> it was till MaxEvaluatedOrder - min, that can be maximum runorder-min*)
            (*runorder is maximally order + SHIFT*)
            (*series coefficients are from -SHIFT to runorder-SHIFT-min  =  order-min*)
            (*but it should be checked that the pole of EXTERNAL is -SHIFT *)
            
        lastexact=min;
        While[lastexact<=runorder,
	  If[Not[MyToExpression[QSafeGetWrapper["out",ToString[lastexact]<>"-"<>ToString[##,InputForm]<>"-E",False]]],Break[]];
	  lastexact++;
        ];
        lastexact--;
        temp=Table[{
		      If[j+SHIFT<=lastexact,
		        FullSimplify[
			  Plus@@Table[{##[[1]],##[[2]]*##[[2]],##[[3]],##[[4]]*##[[4]]}&[(MyToExpression[QSafeGetWrapper["out",ToString[i]<>"-"<>ToString[##,InputForm]<>"-R",MyToString[{0,0,0,0}]]]
			  * MyToExpression[QGetWrapper["out","EXTERNAL-"<>ToString[j-i]<>"E"]])]
			  ,{i,min,j+SHIFT}]   (* exact coefficients from j-min to -SHIFT  *)	    
			]
		      ,
			DoubleCutExtraDigits[
			  Plus@@Table[{##[[1]],##[[2]]*##[[2]],##[[3]],##[[4]]*##[[4]]}&[(MyToExpression[QSafeGetWrapper["out",ToString[i]<>"-"<>ToString[##,InputForm]<>"-R",MyToString[{0,0,0,0}]]]
			  * MyToExpression[QGetWrapper["out","EXTERNAL-"<>ToString[j-i]]])]
			  ,{i,min,j+SHIFT}]   (* coefficients from j-min to -SHIFT  *)	    
			//{##[[1]],Sqrt[##[[2]]],##[[3]],Sqrt[##[[4]]]}&]//{##[[1]],##[[2]]*##[[2]],##[[3]],##[[4]]*##[[4]]}&
		      ],
	            ep^j*(ExpandVariable^##[[1]])*(Log[ExpandVariable]^##[[2]])
		    }
		    ,
		{j,min-SHIFT,runorder-SHIFT}];  (* coefficients from(back) -SHIFT or (order-min) to -SHIFT  *)    

            temp={KillSmall[CutExtraDigits[##[[1]][[1]]+I*##[[1]][[3]]]+CutExtraDigits[Power[##[[1]][[2]],1/2]+I*Power[##[[1]][[4]],1/2]]*ToExpression["pm"<>ToString[PMCounter++]]],##[[2]]}&/@temp;
            
            temp
        
   )&/@degs,1];
    Return[result];

]























MyRank[xx_] := MatrixRank[(## - xx[[1]]) & /@ xx]
VNorm[xx_] := Times @@ ((## + 1) & /@ xx);
PointOver[xx_, yy_] := And @@ ((## >= 0) & /@ (xx - yy));
MinVector[v_] := v/(GCD @@ v)
OnlyLowPoints[xx_] := Module[{temp, i, j, Good},
   temp = {};
   For[i = 1, i <= Length[xx], i++,
    j = 1;
    Good = True;
    While[j <= Length[temp],
     If[PointOver[xx[[i]], temp[[j]]], Good = False; Break[]];
     If[PointOver[temp[[j]], xx[[i]]], temp = Delete[temp, j];
      Continue[]];
     j++
     ];
    If[Good, AppendTo[temp, xx[[i]]]];
    ];
   temp
   ];

MyDegrees[pol_]:=MyDegrees[pol,Sort[Cases[Variables[pol],x[_]]]];

MyDegrees[pol_,var_] := Module[{rule, temp, degrees, i},
(*    var=Array[x,n];*)
  rule = Rule[##, 1] & /@ var;
  temp = Expand[pol/.(0.->0)];
  If[Head[temp]===Plus,temp = List @@ temp,temp={temp}];
  
  temp = Union[(##/(## /. rule)) & /@ temp];
  degrees =
   Table[Exponent[##, var[[i]]], {i, Length[var]}] & /@ temp;
  degrees = OnlyLowPoints[degrees];
  degrees
]

SubSpace[xxx_] :=
  Module[{av, m, n, k, i, j, ind, facet, vector, temp, scalar, pr,
    newpoint, symplex, xx, sbs, km},
    If[Length[xxx[[1]]]===1,Return[{1}]];
   xx = Sort[xxx, (VNorm[#1] < VNorm[#2]) &];
   n = Length[xx[[1]]];
   k = n;
   m = MyRank[OnlyLowPoints[xx]];
   sbs = Subsets[Range[n], {2, Max[m + 1, n]}];
   sbs = Sort[sbs, (Plus @@ #1 > Plus @@ #2) &];
   For[i = 1, i <= Length[sbs], i++,
    av =
     Normal[SparseArray[Apply[Rule, (({##, 1}) & /@ sbs[[i]]), {1}],n]];
    If[MyRank[OnlyLowPoints[(##*av) & /@ xx]] >= Length[sbs[[i]]] - 1,
     Return[av];
     ];
    ];
   RawPrintLn["No subspace found"];
   Return[Table[0, {n}]];
   ];
Facet[xxx_] :=
 Module[{av, aa, bb, m, n, k, i, j, ind, pos, facet, vector, temp,
   scalar, pr, newpoint, symplex, xx, sbs, km, yy},
  xx = xxx;
  n = Length[xx[[1]]];
  If[n===1,Return[{{1},{1}}]];
  av = SubSpace[xx];
  Label[avlabel];
  xx = Sort[xx, (VNorm[#1*av] < VNorm[#2*av]) &];
  yy = {};
  For[i = 1, i <= Length[xx], i++,
   If[And[Length[yy] > 0,
     MyRank[(##*av) & /@ yy] ==
      MyRank[(##*av) & /@ Append[yy, xx[[i]]]]], Continue[]];
   AppendTo[yy, xx[[i]]];
   yy = OnlyLowPoints[yy];
   If[MyRank[(##*av) & /@ yy] < Total[av], Continue[]];
   aa = Table[0, {Length[yy]}];
   bb = Table[0, {Length[yy]}];
   If[Length[yy] == 1, Continue[]];
   For[j = 1, j <= Length[yy], j++,
    facet = Delete[##, Position[av, 0]] & /@ yy;
    newpoint = facet[[j]];
    facet = Delete[facet, j];
    pr = MyNullSpace[(## - facet[[1]]) & /@ facet];
    If[Length[pr] === 1,
     vector = pr[[1]];
     If[vector.facet[[1]] < 0, vector = -vector];
  (*   If[Or @@ ((## < 0) & /@ vector), Continue[]];*)
     If[vector.newpoint >= vector.facet[[1]], aa[[j]] = 1(*,aa[[j]]=2*)];
      bb[[j]] = vector;
     ];
    ];
   pos = Flatten[Position[aa, 1]];
   If[Length[pos] == 0,
        pos = Flatten[Position[aa, 2]];
        If[Length[pos] == 0,
           (* RawPrintLn["No facet found"]; RawPrintLn[yy]; Abort[]*)
           RawPrintLn[xxx];
           Return[False];
        ];
   ];

   j=Last[pos];
  (*j = Sort[pos, (Total[bb[[#1]]] > Total[bb[[#2]]]) &][[1]];*)
  (* j = Sort[pos, (VP[bb[[#1]]] < VP[bb[[#2]]]) &][[1]];*)
   yy = Delete[yy, j];
   ];
   If[Length[yy] == 1, Return[False]];
  facet = Delete[##, Position[av, 0]] & /@ yy;
  pr = MyNullSpace[(## - facet[[1]]) & /@ facet];
  pr = Normal[
      SparseArray[
       Apply[Rule, Transpose[{Flatten[Position[av, 1]], ##}], {1}],
       n]] & /@ pr;
  pr = pr[[1]];
  pr = If[## < 0, 0, ##] & /@ pr;
  If[Total[pr] == 1, av[[Flatten[Position[pr, 1]]]] = 0;
   Goto[avlabel]];
  pr
  ]

VP[xx_]:=(Length[Select[xx,(## > 0) &]])*10000+Total[xx]

 NormShift[xx_] := Module[{temp},
  temp = Apply[Min, Transpose[xx], {1}];
  (## - temp) & /@ xx
  ]

(*WD[aaa_,{}]:=Infinity;
WTilda[{}]:={};*)
  WMinVector[xx_] := Apply[Min, Transpose[xx], {1}];
WTilda[xx_] := Module[{temp = WMinVector[xx]}, (## - temp) & /@ xx];
WD[ind_, xx_] := Min @@ (ind.## & /@ xx);
WBSequence[xx_] :=
 Module[{n = Length[xx[[1]]], result = {}, ind, delta, d, H, temp,
   indN},
  ind = Table[1, {n}];
  delta = xx;
  result = {};
  While[True,
   AppendTo[result, {ind, delta}];
   If[delta == {}, Break[]];
   temp = WTilda[delta];
   d = WD[Table[1, {n}], temp];
   If[d == 0, Break[]];
   temp = Select[temp, ((ind.##) === d) &];
   H = If[##>0,1,0] & /@ Apply[Max, Transpose[temp], {1}];
   ind = Max[##, 0] & /@ (ind - H);
   temp = Union[(##/d) & /@ WTilda[delta], delta];
   temp = Select[temp, (H.## < 1) &];
   delta = Union[((##*ind)/(1 - ##.H)) & /@ temp];
   ];
  result
  ]

  WBNSequence[xx_]:= Module[{n = Length[xx[[1]]],temp=WBSequence[xx]},
    Append[Flatten[{Length[##[[1]]],WD[Table[1, {n}], WTilda[##[[2]]]]}&/@temp],WD[Table[1, {n}],Last[temp][[2]]]]
  ]

  WFindA[ind_, delta_] := Module[{temp, i, n, restart, temp2},
  n = Length[ind];
  temp = ind;
  Label[restart];
  For[i = 1, i <= n, i++,
   If[temp[[i]] == 1,
    temp2 = temp;
    temp2[[i]] = 0;
    If[And @@ ((temp2.## >= 1) & /@ delta),
     temp = temp2;
     Goto[restart];
     ]
    ]
   ];
  temp
  ]
WBSet[xx_] := Module[{n = Length[xx[[1]]], temp, ind, delta},
  temp = WBSequence[xx];
  {ind, delta} = Last[temp];
  If[delta === {}, Return[Table[1, {n}] - ind]];
  Return[Table[1, {n}] - ind + WFindA[ind,delta]]
  ]



MakeOneStep[xx_,facet_]:=MakeOneStep[xx,facet,Table[xx[[3]],{Length[facet]-Length[Position[facet,0]]}]]

MakeOneStep[xx_,facet_,graphs_]:=Module[{res,n},

n=Length[xx[[1]][[1]]];
  active = Complement[Range[n], Flatten[Position[facet, 0]]];
  res = {};
  For[i = 1, i <= Length[active], i++,
        Matrix=ReplacePart[IdentityMatrix[n],facet,active[[i]]];
        AppendTo[res, {(Matrix.##) & /@ xx[[1]],Matrix.xx[[2]],graphs[[i]]}];
  ];
  res = {NormShift[#[[1]]],#[[2]],#[[3]]}&/@ res;
  res = {OnlyLowPoints[#[[1]]],#[[2]],#[[3]]}&/@ res;
    res
];


MLN[xx_] := Module[{n, vectors, i, j, ll, nn,l,v},
  n = Length[xx];
  If[n===1,Return[{0,0,0}]];
  vectors =
   DeleteCases[
    Flatten[Table[xx[[i]] - xx[[j]], {i, 1, n}, {j, 1, n}], 1],
    Evaluate[Table[0, {Length[xx[[1]]]}]]];
  ll = (Max @@ ## - Min @@ ##) & /@ vectors;
  nn = (Length[Cases[##, Max @@ ##]] +
       Length[Cases[##, Min @@ ##]]) & /@ vectors;
  l=Min @@ ll;
  m=Min @@ ((##[[2]])&/@Cases[Transpose[{ll,nn}],{l,a_}]);

(*  m=Min@@Table[If[ll[[i]]===l,nn[[i]],Infinity],{i,Length[vectors]}];*)
  v=vectors[[Position[Transpose[{ll,nn}],{l,m}][[1]][[1]]]];
  {n, l, m, Position[v,Min@@v][[1]][[1]], Position[v,Max@@v][[1]][[1]]}
]

TriLower[xx_, yy_] := 
 If[xx[[1]] < yy[[1]], True, 
  If[xx[[1]] > yy[[1]], False, 
   If[xx[[2]] < yy[[2]], True, 
    If[xx[[2]] > yy[[2]], False, 
     If[xx[[3]] < yy[[3]], True, False]]]]]


 MakeOneStep[xxx_] := Module[{xx,temp, active, n,m, sbs,i,j, res,Matrix,newfacet,restarted=False},
 xx={xxx[[1]][[1]],xxx[[2]],xxx[[3]]};
 If[STRATEGY==STRATEGY_SS,
    n=Length[xx[[1]][[1]]];
    temp=GraphStep[xxx[[3]]];
    If[temp===True,
        Print["ERROR: strategy failed"];
        Print[{{{{xx[[1]][[1]]}},xx[[2]],xx[[3]]}}];
        Print[GetEdgeWeights[xxx[[3]]]];
        Abort[];
        Return[{{{{xx[[1]][[1]]}},xx[[2]],xx[[3]]}}];
    ];
    res=MakeOneStep[xx,Normal[SparseArray[Apply[Rule, (({##, 1}) & /@ temp[[1]]), {1}],n]],temp[[2]]];
  (*  Print[temp[[1]]];
    If[temp[[1]]==={2,5,3,4},res={res[[4]]}];*)
    Return[({{##[[1]]},##[[2]],##[[3]]}&/@res)]
 ];
 If[STRATEGY==STRATEGY_B,
    res=MakeOneStep[xx,WBSet[xx[[1]]]];
    Return[{{##[[1]]},##[[2]],##[[3]]}&/@res]
 ];
 If[STRATEGY==STRATEGY_S,
  n=Length[xx[[1]][[1]]];
  facet = TimeConstrained[Facet[xx[[1]]],1000,False];
  If[Not[facet===False],res=MakeOneStep[xx,facet]];
  If[Or[facet===False,Not[And@@((Length[##[[1]]]<Length[xx[[1]]])&/@res)]],
      {m0,l0,n0,vmin,vmax}=MLN[xx[[1]]];
      If[Or[facet===False,Not[And@@(TriLower[MLN[##[[1]]],{m0,l0,n0}]&/@res)]],
        facet=Normal[SparseArray[(##->1)&/@{vmin,vmax},n]];
        res=MakeOneStep[xx,facet];
        If[And@@(TriLower[MLN[##[[1]]],{m0,l0,n0}]&/@res),
            If[NumberQ[StopCounter],StopCounter++];
            If[StopCounter<0,Abort[]];
            Return[{{##[[1]]},##[[2]],##[[3]]}&/@res]
        ];
        RawPrintLn["Failed to resolve"];
        RawPrintLn[xx[[1]]];
        Abort[];
      ];
  ];
  Return[{{##[[1]]},##[[2]],##[[3]]}&/@res]
  ];



  If[STRATEGY==STRATEGY_A,
    n=Length[xx[[1]][[1]]];
    {m0,l0,n0,vmin,vmax}=MLN[xx[[1]]];
    facet=Normal[SparseArray[(##->1)&/@{vmin,vmax},n]];
    res=MakeOneStep[xx,facet];
    If[And@@(TriLower[MLN[##[[1]]],{m0,l0,n0}]&/@res),
         Return[{{##[[1]]},##[[2]],##[[3]]}&/@res]
    ];
    RawPrintLn["Failed to resolve"];
    RawPrintLn[xx[[1]]];
    Abort[];
  ];
  If[STRATEGY==STRATEGY_X,
    n=Length[xx[[1]][[1]]];
    For[j=1,j<=Length[xxx[[1]]],j++,

       For[m=2,m<=n,m++,
            sbs=Subsets[Range[n],{m}];
            For[i=1,i<=Length[sbs],i++,
                facet=Normal[SparseArray[(##->1)&/@sbs[[i]],n]];
                If[And@@((Not[(facet.##)===0])&/@(xxx[[1]][[j]])),
                    res=MakeOneStep[##,facet]&/@({##,xxx[[2]],xxx[[3]]}&/@(xxx[[1]]));
                    res=Transpose[res];
                    res=Transpose/@res;
                    res={##[[1]],##[[2]][[1]],##[[3]][[1]]}&/@res;
                    Return[res]
                ];
            ]
        ];


     ];


  ];




]











MyNullSpace[xx_]:=Module[{temp},
    If[xx==={},Return[{{1}}]];
    temp=NullSpace[xx];
    If[Plus@@##>=0,##,-##]&/@temp
]

FindSD[xxx_]:=FindSD[xxx,False];
FindSD[xxx_,Extra_]:=Module[{temp,i}, yy = {};
    
    If[xxx==={{{}}},Return[{{}}]];


  xx = {{OnlyLowPoints/@xxx,IdentityMatrix[Length[xxx[[1]][[1]]]],Extra}};
   temp=xx;
   yy = Join[yy, Select[temp, (Times@@(Length/@(##[[1]])) === 1) &]];
   xx = Select[temp, Not[Times@@(Length/@(##[[1]])) === 1] &];

  While[True,
   temp = MakeOneStep /@ xx;
   temp = Flatten[temp, 1];
   yy = Join[yy, Select[temp, (Times@@(Length/@(##[[1]])) === 1) &]];
   xx = Select[temp, Not[Times@@(Length/@(##[[1]])) === 1] &];

   If[Length[xx] === 0,
       yy=#[[2]]&/@yy;
       Return[yy]
   ];
   ];

 ]

(* Graph compinatorics *)

MyGraph[edges_] := Module[{temp},
  temp = FromUnorderedPairs[edges];
  Graph[Transpose[{Edges[temp], (EdgeWeight -> ##) & /@
      Range[Length[Edges[temp]]]}], {##} & /@ Vertices[temp]
   ]
  ]
MyEdges[graph_] := {##[[1]], ##[[2]][[2]]} & /@ graph[[1]];
MyDeleteEdge[graph_, weight_] :=
  Graph[DeleteCases [graph[[1]], {aa_, EdgeWeight -> weight}],
   graph[[2]]];
MyDeleteEdges[graph_, {}] := graph;
MyDeleteEdges[graph_, weights_] :=
  Graph[Intersection @@ (DeleteCases [
        graph[[1]], {aa_, EdgeWeight -> ##}] & /@ weights),
   graph[[2]]];
MyBiconnectedComponents[graph_] :=
 InduceSubgraph[graph, DeleteCases[##,InfinityVertex]] & /@ BiconnectedComponents[graph]
CleanGraph[graph_] := Module[{g, temp},
  g = RemoveSelfLoops[graph];
  temp = MyBiconnectedComponents[g];
  temp = Select[temp, (M[##] <= 1) &];
  temp = Union @@ (GetEdgeWeights /@ temp);
  MyDeleteEdges[g, temp]
  ]

ExternalNotConnected[graph_, external_] := Module[{temp},
  temp = ConnectedComponents[graph];
  temp = Union[(##[[1]]) & /@ Position[temp, ##] & /@ external];
  Or[temp === {{}}, Length[temp] =!= 1]
]

GraphStep[graph_] := Module[{g, temp},
  g = CleanGraph[graph];
  If[M[g] === Exte, Return[True]];
  If[Not[ExternalNotConnected[DeleteVertex[graph,InfinityVertex],External]],
      temp = Sort[DeleteCases[##, InfinityVertex] & /@ BiconnectedComponents[g], (Length[#1] > Length[#2]) &];
  ,
      temp = Sort[BiconnectedComponents[DeleteVertex[graph,InfinityVertex]], (Length[#1] > Length[#2]) &];
  ];
  temp = GetEdgeWeights[InduceSubgraph[g,temp[[1]]]];
  temp=Sort[temp];
  Return[{temp, (MyDeleteEdge[g, ##] & /@ temp)}];
]
ContractEdge[graph_, weight_] := Module[{temp},
  temp =
   Rule @@ Cases [graph[[1]], {aa_, EdgeWeight -> weight}][[1]][[1]];
  If[temp[[1]] === temp[[2]], Return[False]];
  MyDeleteEdge[
   Graph[ReplacePart[##, ##[[1]] /. temp, 1] & /@ graph[[1]],
    graph[[2]]], weight]
  ]
ContractEdges[graph_, weights_] := Module[{temp, i},
  temp = graph;
  For[i = 1, i <= Length[weights], i++,
   If[temp === False, Return[False]];
   temp = ContractEdge[temp, weights[[i]]];
   ];
  temp
  ]


(* Graph compinatorics end *)



MBshiftRules[dx_] := {
  Gamma[m_.+a_.*dx] :> Gamma[1+a*dx]/Product[a*dx-i, {i,0,-m}] /;
  IntegerQ[m] && m <= 0,

  PolyGamma[n_, m_.+a_.*dx] :> (-a*dx)^(-n-1)*
  ((-a*dx)^(n+1)*PolyGamma[n, 1+a*dx] + n!*Sum[(a*dx/(a*dx-i))^(n+1),
  {i,0,-m}]) /; IntegerQ[m] && m <= 0};

MBexpansionRules::series = "exhausted precomputed expansion of Gamma's (`1`)";

MBexpansionRules[dx_, order_] := {
  Gamma[m_+a_.*dx] :> If[order <= 20,
  Gamma[m]*Sum[(a*dx)^i/i!*MBexpGam[m, i], {i,0,order}],
  Message[MBexpansionRules::series, order];
  Normal[Series[Gamma[m+a*dx], {dx,0,order}]]] /; !IntegerQ[m] || m > 0,

  PolyGamma[n_, m_+a_.*dx] :> Sum[(a*dx)^i/i!*PolyGamma[n+i, m],
  {i,0,order}] /; !IntegerQ[m] || m > 0};





(* generated automatically with MATHEMATICA *)

MBexpGam[a_, 0] = 1;

MBexpGam[a_, 1] = PolyGamma[0, a];

MBexpGam[a_, 2] = PolyGamma[0, a]^2 + PolyGamma[1, a];

MBexpGam[a_, 3] = PolyGamma[0, a]^3 + 3*PolyGamma[0, a]*PolyGamma[1, a] +
     PolyGamma[2, a];

MBexpGam[a_, 4] = PolyGamma[0, a]^4 + 6*PolyGamma[0, a]^2*PolyGamma[1, a] +
     3*PolyGamma[1, a]^2 + 4*PolyGamma[0, a]*PolyGamma[2, a] + PolyGamma[3, a];

MBexpGam[a_, 5] = PolyGamma[0, a]^5 + 10*PolyGamma[0, a]^3*PolyGamma[1, a] +
     15*PolyGamma[0, a]*PolyGamma[1, a]^2 + 10*PolyGamma[0, a]^2*
      PolyGamma[2, a] + 10*PolyGamma[1, a]*PolyGamma[2, a] +
     5*PolyGamma[0, a]*PolyGamma[3, a] + PolyGamma[4, a];

MBexpGam[a_, 6] = PolyGamma[0, a]^6 + 15*PolyGamma[0, a]^4*PolyGamma[1, a] +
     45*PolyGamma[0, a]^2*PolyGamma[1, a]^2 + 15*PolyGamma[1, a]^3 +
     20*PolyGamma[0, a]^3*PolyGamma[2, a] + 60*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a] + 10*PolyGamma[2, a]^2 +
     15*PolyGamma[0, a]^2*PolyGamma[3, a] + 15*PolyGamma[1, a]*
      PolyGamma[3, a] + 6*PolyGamma[0, a]*PolyGamma[4, a] + PolyGamma[5, a];

MBexpGam[a_, 7] = PolyGamma[0, a]^7 + 21*PolyGamma[0, a]^5*PolyGamma[1, a] +
     105*PolyGamma[0, a]^3*PolyGamma[1, a]^2 + 105*PolyGamma[0, a]*
      PolyGamma[1, a]^3 + 35*PolyGamma[0, a]^4*PolyGamma[2, a] +
     210*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a] +
     105*PolyGamma[1, a]^2*PolyGamma[2, a] + 70*PolyGamma[0, a]*
      PolyGamma[2, a]^2 + 35*PolyGamma[0, a]^3*PolyGamma[3, a] +
     105*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a] +
     35*PolyGamma[2, a]*PolyGamma[3, a] + 21*PolyGamma[0, a]^2*
      PolyGamma[4, a] + 21*PolyGamma[1, a]*PolyGamma[4, a] +
     7*PolyGamma[0, a]*PolyGamma[5, a] + PolyGamma[6, a];

MBexpGam[a_, 8] = PolyGamma[0, a]^8 + 28*PolyGamma[0, a]^6*PolyGamma[1, a] +
     210*PolyGamma[0, a]^4*PolyGamma[1, a]^2 + 420*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3 + 105*PolyGamma[1, a]^4 + 56*PolyGamma[0, a]^5*
      PolyGamma[2, a] + 560*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a] + 840*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a] + 280*PolyGamma[0, a]^2*PolyGamma[2, a]^2 +
     280*PolyGamma[1, a]*PolyGamma[2, a]^2 + 70*PolyGamma[0, a]^4*
      PolyGamma[3, a] + 420*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a] + 210*PolyGamma[1, a]^2*PolyGamma[3, a] +
     280*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a] +
     35*PolyGamma[3, a]^2 + 56*PolyGamma[0, a]^3*PolyGamma[4, a] +
     168*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a] +
     56*PolyGamma[2, a]*PolyGamma[4, a] + 28*PolyGamma[0, a]^2*
      PolyGamma[5, a] + 28*PolyGamma[1, a]*PolyGamma[5, a] +
     8*PolyGamma[0, a]*PolyGamma[6, a] + PolyGamma[7, a];

MBexpGam[a_, 9] = PolyGamma[0, a]^9 + 36*PolyGamma[0, a]^7*PolyGamma[1, a] +
     378*PolyGamma[0, a]^5*PolyGamma[1, a]^2 + 1260*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3 + 945*PolyGamma[0, a]*PolyGamma[1, a]^4 +
     84*PolyGamma[0, a]^6*PolyGamma[2, a] + 1260*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a] + 3780*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a] + 1260*PolyGamma[1, a]^3*
      PolyGamma[2, a] + 840*PolyGamma[0, a]^3*PolyGamma[2, a]^2 +
     2520*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^2 +
     280*PolyGamma[2, a]^3 + 126*PolyGamma[0, a]^5*PolyGamma[3, a] +
     1260*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[3, a] +
     1890*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[3, a] +
     1260*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[3, a] +
     1260*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a] +
     315*PolyGamma[0, a]*PolyGamma[3, a]^2 + 126*PolyGamma[0, a]^4*
      PolyGamma[4, a] + 756*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[4, a] + 378*PolyGamma[1, a]^2*PolyGamma[4, a] +
     504*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[4, a] +
     126*PolyGamma[3, a]*PolyGamma[4, a] + 84*PolyGamma[0, a]^3*
      PolyGamma[5, a] + 252*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[5, a] +
     84*PolyGamma[2, a]*PolyGamma[5, a] + 36*PolyGamma[0, a]^2*
      PolyGamma[6, a] + 36*PolyGamma[1, a]*PolyGamma[6, a] +
     9*PolyGamma[0, a]*PolyGamma[7, a] + PolyGamma[8, a];

MBexpGam[a_, 10] = PolyGamma[0, a]^10 + 45*PolyGamma[0, a]^8*
      PolyGamma[1, a] + 630*PolyGamma[0, a]^6*PolyGamma[1, a]^2 +
     3150*PolyGamma[0, a]^4*PolyGamma[1, a]^3 + 4725*PolyGamma[0, a]^2*
      PolyGamma[1, a]^4 + 945*PolyGamma[1, a]^5 + 120*PolyGamma[0, a]^7*
      PolyGamma[2, a] + 2520*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[2, a] + 12600*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[2, a] + 12600*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[2, a] + 2100*PolyGamma[0, a]^4*PolyGamma[2, a]^2 +
     12600*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2 +
     6300*PolyGamma[1, a]^2*PolyGamma[2, a]^2 + 2800*PolyGamma[0, a]*
      PolyGamma[2, a]^3 + 210*PolyGamma[0, a]^6*PolyGamma[3, a] +
     3150*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[3, a] +
     9450*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[3, a] +
     3150*PolyGamma[1, a]^3*PolyGamma[3, a] + 4200*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a] + 12600*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a] + 2100*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 1575*PolyGamma[0, a]^2*PolyGamma[3, a]^2 +
     1575*PolyGamma[1, a]*PolyGamma[3, a]^2 + 252*PolyGamma[0, a]^5*
      PolyGamma[4, a] + 2520*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[4, a] + 3780*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[4, a] + 2520*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[4, a] + 2520*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a] + 1260*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 126*PolyGamma[4, a]^2 + 210*PolyGamma[0, a]^4*
      PolyGamma[5, a] + 1260*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[5, a] + 630*PolyGamma[1, a]^2*PolyGamma[5, a] +
     840*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[5, a] +
     210*PolyGamma[3, a]*PolyGamma[5, a] + 120*PolyGamma[0, a]^3*
      PolyGamma[6, a] + 360*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[6, a] +
     120*PolyGamma[2, a]*PolyGamma[6, a] + 45*PolyGamma[0, a]^2*
      PolyGamma[7, a] + 45*PolyGamma[1, a]*PolyGamma[7, a] +
     10*PolyGamma[0, a]*PolyGamma[8, a] + PolyGamma[9, a];

MBexpGam[a_, 11] = PolyGamma[0, a]^11 + 55*PolyGamma[0, a]^9*
      PolyGamma[1, a] + 990*PolyGamma[0, a]^7*PolyGamma[1, a]^2 +
     6930*PolyGamma[0, a]^5*PolyGamma[1, a]^3 + 17325*PolyGamma[0, a]^3*
      PolyGamma[1, a]^4 + 10395*PolyGamma[0, a]*PolyGamma[1, a]^5 +
     165*PolyGamma[0, a]^8*PolyGamma[2, a] + 4620*PolyGamma[0, a]^6*
      PolyGamma[1, a]*PolyGamma[2, a] + 34650*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[2, a] + 69300*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[2, a] + 17325*PolyGamma[1, a]^4*
      PolyGamma[2, a] + 4620*PolyGamma[0, a]^5*PolyGamma[2, a]^2 +
     46200*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]^2 +
     69300*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]^2 +
     15400*PolyGamma[0, a]^2*PolyGamma[2, a]^3 + 15400*PolyGamma[1, a]*
      PolyGamma[2, a]^3 + 330*PolyGamma[0, a]^7*PolyGamma[3, a] +
     6930*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[3, a] +
     34650*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[3, a] +
     34650*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[3, a] +
     11550*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[3, a] +
     69300*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a] + 34650*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a] + 23100*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 5775*PolyGamma[0, a]^3*PolyGamma[3, a]^2 +
     17325*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]^2 +
     5775*PolyGamma[2, a]*PolyGamma[3, a]^2 + 462*PolyGamma[0, a]^6*
      PolyGamma[4, a] + 6930*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[4, a] + 20790*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[4, a] + 6930*PolyGamma[1, a]^3*PolyGamma[4, a] +
     9240*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[4, a] +
     27720*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a] +
     4620*PolyGamma[2, a]^2*PolyGamma[4, a] + 6930*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a] + 6930*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 1386*PolyGamma[0, a]*PolyGamma[4, a]^2 +
     462*PolyGamma[0, a]^5*PolyGamma[5, a] + 4620*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[5, a] + 6930*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[5, a] + 4620*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[5, a] + 4620*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a] + 2310*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 462*PolyGamma[4, a]*PolyGamma[5, a] +
     330*PolyGamma[0, a]^4*PolyGamma[6, a] + 1980*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[6, a] + 990*PolyGamma[1, a]^2*
      PolyGamma[6, a] + 1320*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[6, a] + 330*PolyGamma[3, a]*PolyGamma[6, a] +
     165*PolyGamma[0, a]^3*PolyGamma[7, a] + 495*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[7, a] + 165*PolyGamma[2, a]*PolyGamma[7, a] +
     55*PolyGamma[0, a]^2*PolyGamma[8, a] + 55*PolyGamma[1, a]*
      PolyGamma[8, a] + 11*PolyGamma[0, a]*PolyGamma[9, a] + PolyGamma[10, a]

MBexpGam[a_, 12] = PolyGamma[0, a]^12 + 66*PolyGamma[0, a]^10*
      PolyGamma[1, a] + 1485*PolyGamma[0, a]^8*PolyGamma[1, a]^2 +
     13860*PolyGamma[0, a]^6*PolyGamma[1, a]^3 + 51975*PolyGamma[0, a]^4*
      PolyGamma[1, a]^4 + 62370*PolyGamma[0, a]^2*PolyGamma[1, a]^5 +
     10395*PolyGamma[1, a]^6 + 220*PolyGamma[0, a]^9*PolyGamma[2, a] +
     7920*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a] +
     83160*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[2, a] +
     277200*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[2, a] +
     207900*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a] +
     9240*PolyGamma[0, a]^6*PolyGamma[2, a]^2 + 138600*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]^2 + 415800*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2 + 138600*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2 + 61600*PolyGamma[0, a]^3*PolyGamma[2, a]^3 +
     184800*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^3 +
     15400*PolyGamma[2, a]^4 + 495*PolyGamma[0, a]^8*PolyGamma[3, a] +
     13860*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[3, a] +
     103950*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[3, a] +
     207900*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[3, a] +
     51975*PolyGamma[1, a]^4*PolyGamma[3, a] + 27720*PolyGamma[0, a]^5*
      PolyGamma[2, a]*PolyGamma[3, a] + 277200*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a] +
     415800*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a] + 138600*PolyGamma[0, a]^2*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 138600*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 17325*PolyGamma[0, a]^4*PolyGamma[3, a]^2 +
     103950*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[3, a]^2 +
     51975*PolyGamma[1, a]^2*PolyGamma[3, a]^2 + 69300*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 5775*PolyGamma[3, a]^3 +
     792*PolyGamma[0, a]^7*PolyGamma[4, a] + 16632*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[4, a] + 83160*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[4, a] + 83160*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[4, a] + 27720*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[4, a] + 166320*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a] +
     83160*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[4, a] +
     55440*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[4, a] +
     27720*PolyGamma[0, a]^3*PolyGamma[3, a]*PolyGamma[4, a] +
     83160*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     27720*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     8316*PolyGamma[0, a]^2*PolyGamma[4, a]^2 + 8316*PolyGamma[1, a]*
      PolyGamma[4, a]^2 + 924*PolyGamma[0, a]^6*PolyGamma[5, a] +
     13860*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[5, a] +
     41580*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[5, a] +
     13860*PolyGamma[1, a]^3*PolyGamma[5, a] + 18480*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[5, a] + 55440*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[5, a] + 9240*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 13860*PolyGamma[0, a]^2*PolyGamma[3, a]*
      PolyGamma[5, a] + 13860*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 5544*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 462*PolyGamma[5, a]^2 + 792*PolyGamma[0, a]^5*
      PolyGamma[6, a] + 7920*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[6, a] + 11880*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[6, a] + 7920*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[6, a] + 7920*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[6, a] + 3960*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[6, a] + 792*PolyGamma[4, a]*PolyGamma[6, a] +
     495*PolyGamma[0, a]^4*PolyGamma[7, a] + 2970*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[7, a] + 1485*PolyGamma[1, a]^2*
      PolyGamma[7, a] + 1980*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[7, a] + 495*PolyGamma[3, a]*PolyGamma[7, a] +
     220*PolyGamma[0, a]^3*PolyGamma[8, a] + 660*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[8, a] + 220*PolyGamma[2, a]*PolyGamma[8, a] +
     66*PolyGamma[0, a]^2*PolyGamma[9, a] + 66*PolyGamma[1, a]*
      PolyGamma[9, a] + 12*PolyGamma[0, a]*PolyGamma[10, a] + PolyGamma[11, a]

MBexpGam[a_, 13] = PolyGamma[0, a]^13 + 78*PolyGamma[0, a]^11*
      PolyGamma[1, a] + 2145*PolyGamma[0, a]^9*PolyGamma[1, a]^2 +
     25740*PolyGamma[0, a]^7*PolyGamma[1, a]^3 + 135135*PolyGamma[0, a]^5*
      PolyGamma[1, a]^4 + 270270*PolyGamma[0, a]^3*PolyGamma[1, a]^5 +
     135135*PolyGamma[0, a]*PolyGamma[1, a]^6 + 286*PolyGamma[0, a]^10*
      PolyGamma[2, a] + 12870*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[2, a] + 180180*PolyGamma[0, a]^6*PolyGamma[1, a]^2*
      PolyGamma[2, a] + 900900*PolyGamma[0, a]^4*PolyGamma[1, a]^3*
      PolyGamma[2, a] + 1351350*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[2, a] + 270270*PolyGamma[1, a]^5*PolyGamma[2, a] +
     17160*PolyGamma[0, a]^7*PolyGamma[2, a]^2 + 360360*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[2, a]^2 + 1801800*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2 + 1801800*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]^2 + 200200*PolyGamma[0, a]^4*
      PolyGamma[2, a]^3 + 1201200*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]^3 + 600600*PolyGamma[1, a]^2*PolyGamma[2, a]^3 +
     200200*PolyGamma[0, a]*PolyGamma[2, a]^4 + 715*PolyGamma[0, a]^9*
      PolyGamma[3, a] + 25740*PolyGamma[0, a]^7*PolyGamma[1, a]*
      PolyGamma[3, a] + 270270*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[3, a] + 900900*PolyGamma[0, a]^3*PolyGamma[1, a]^3*
      PolyGamma[3, a] + 675675*PolyGamma[0, a]*PolyGamma[1, a]^4*
      PolyGamma[3, a] + 60060*PolyGamma[0, a]^6*PolyGamma[2, a]*
      PolyGamma[3, a] + 900900*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a] + 2702700*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a] +
     900900*PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[3, a] +
     600600*PolyGamma[0, a]^3*PolyGamma[2, a]^2*PolyGamma[3, a] +
     1801800*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 200200*PolyGamma[2, a]^3*PolyGamma[3, a] +
     45045*PolyGamma[0, a]^5*PolyGamma[3, a]^2 + 450450*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[3, a]^2 + 675675*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[3, a]^2 + 450450*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 450450*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 75075*PolyGamma[0, a]*
      PolyGamma[3, a]^3 + 1287*PolyGamma[0, a]^8*PolyGamma[4, a] +
     36036*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[4, a] +
     270270*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[4, a] +
     540540*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[4, a] +
     135135*PolyGamma[1, a]^4*PolyGamma[4, a] + 72072*PolyGamma[0, a]^5*
      PolyGamma[2, a]*PolyGamma[4, a] + 720720*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a] +
     1081080*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[4, a] + 360360*PolyGamma[0, a]^2*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 360360*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 90090*PolyGamma[0, a]^4*PolyGamma[3, a]*
      PolyGamma[4, a] + 540540*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 270270*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a] + 360360*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     45045*PolyGamma[3, a]^2*PolyGamma[4, a] + 36036*PolyGamma[0, a]^3*
      PolyGamma[4, a]^2 + 108108*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[4, a]^2 + 36036*PolyGamma[2, a]*PolyGamma[4, a]^2 +
     1716*PolyGamma[0, a]^7*PolyGamma[5, a] + 36036*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[5, a] + 180180*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[5, a] + 180180*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[5, a] + 60060*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[5, a] + 360360*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[5, a] +
     180180*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[5, a] +
     120120*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[5, a] +
     60060*PolyGamma[0, a]^3*PolyGamma[3, a]*PolyGamma[5, a] +
     180180*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     60060*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     36036*PolyGamma[0, a]^2*PolyGamma[4, a]*PolyGamma[5, a] +
     36036*PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     6006*PolyGamma[0, a]*PolyGamma[5, a]^2 + 1716*PolyGamma[0, a]^6*
      PolyGamma[6, a] + 25740*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[6, a] + 77220*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[6, a] + 25740*PolyGamma[1, a]^3*PolyGamma[6, a] +
     34320*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[6, a] +
     102960*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[6, a] +
     17160*PolyGamma[2, a]^2*PolyGamma[6, a] + 25740*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[6, a] + 25740*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[6, a] + 10296*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 1716*PolyGamma[5, a]*PolyGamma[6, a] +
     1287*PolyGamma[0, a]^5*PolyGamma[7, a] + 12870*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[7, a] + 19305*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[7, a] + 12870*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[7, a] + 12870*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[7, a] + 6435*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 1287*PolyGamma[4, a]*PolyGamma[7, a] +
     715*PolyGamma[0, a]^4*PolyGamma[8, a] + 4290*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[8, a] + 2145*PolyGamma[1, a]^2*
      PolyGamma[8, a] + 2860*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[8, a] + 715*PolyGamma[3, a]*PolyGamma[8, a] +
     286*PolyGamma[0, a]^3*PolyGamma[9, a] + 858*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[9, a] + 286*PolyGamma[2, a]*PolyGamma[9, a] +
     78*PolyGamma[0, a]^2*PolyGamma[10, a] + 78*PolyGamma[1, a]*
      PolyGamma[10, a] + 13*PolyGamma[0, a]*PolyGamma[11, a] +
     PolyGamma[12, a]

MBexpGam[a_, 14] = PolyGamma[0, a]^14 + 91*PolyGamma[0, a]^12*
      PolyGamma[1, a] + 3003*PolyGamma[0, a]^10*PolyGamma[1, a]^2 +
     45045*PolyGamma[0, a]^8*PolyGamma[1, a]^3 + 315315*PolyGamma[0, a]^6*
      PolyGamma[1, a]^4 + 945945*PolyGamma[0, a]^4*PolyGamma[1, a]^5 +
     945945*PolyGamma[0, a]^2*PolyGamma[1, a]^6 + 135135*PolyGamma[1, a]^7 +
     364*PolyGamma[0, a]^11*PolyGamma[2, a] + 20020*PolyGamma[0, a]^9*
      PolyGamma[1, a]*PolyGamma[2, a] + 360360*PolyGamma[0, a]^7*
      PolyGamma[1, a]^2*PolyGamma[2, a] + 2522520*PolyGamma[0, a]^5*
      PolyGamma[1, a]^3*PolyGamma[2, a] + 6306300*PolyGamma[0, a]^3*
      PolyGamma[1, a]^4*PolyGamma[2, a] + 3783780*PolyGamma[0, a]*
      PolyGamma[1, a]^5*PolyGamma[2, a] + 30030*PolyGamma[0, a]^8*
      PolyGamma[2, a]^2 + 840840*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[2, a]^2 + 6306300*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2 + 12612600*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2 + 3153150*PolyGamma[1, a]^4*PolyGamma[2, a]^2 +
     560560*PolyGamma[0, a]^5*PolyGamma[2, a]^3 + 5605600*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]^3 + 8408400*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]^3 + 1401400*PolyGamma[0, a]^2*
      PolyGamma[2, a]^4 + 1401400*PolyGamma[1, a]*PolyGamma[2, a]^4 +
     1001*PolyGamma[0, a]^10*PolyGamma[3, a] + 45045*PolyGamma[0, a]^8*
      PolyGamma[1, a]*PolyGamma[3, a] + 630630*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[3, a] + 3153150*PolyGamma[0, a]^4*
      PolyGamma[1, a]^3*PolyGamma[3, a] + 4729725*PolyGamma[0, a]^2*
      PolyGamma[1, a]^4*PolyGamma[3, a] + 945945*PolyGamma[1, a]^5*
      PolyGamma[3, a] + 120120*PolyGamma[0, a]^7*PolyGamma[2, a]*
      PolyGamma[3, a] + 2522520*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a] + 12612600*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a] +
     12612600*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a] + 2102100*PolyGamma[0, a]^4*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 12612600*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 6306300*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 2802800*PolyGamma[0, a]*
      PolyGamma[2, a]^3*PolyGamma[3, a] + 105105*PolyGamma[0, a]^6*
      PolyGamma[3, a]^2 + 1576575*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[3, a]^2 + 4729725*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[3, a]^2 + 1576575*PolyGamma[1, a]^3*PolyGamma[3, a]^2 +
     2102100*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     6306300*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 1051050*PolyGamma[2, a]^2*PolyGamma[3, a]^2 +
     525525*PolyGamma[0, a]^2*PolyGamma[3, a]^3 + 525525*PolyGamma[1, a]*
      PolyGamma[3, a]^3 + 2002*PolyGamma[0, a]^9*PolyGamma[4, a] +
     72072*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[4, a] +
     756756*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[4, a] +
     2522520*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[4, a] +
     1891890*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[4, a] +
     168168*PolyGamma[0, a]^6*PolyGamma[2, a]*PolyGamma[4, a] +
     2522520*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a] + 7567560*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a] + 2522520*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[4, a] + 1681680*PolyGamma[0, a]^3*
      PolyGamma[2, a]^2*PolyGamma[4, a] + 5045040*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[4, a] +
     560560*PolyGamma[2, a]^3*PolyGamma[4, a] + 252252*PolyGamma[0, a]^5*
      PolyGamma[3, a]*PolyGamma[4, a] + 2522520*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     3783780*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 2522520*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 2522520*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     630630*PolyGamma[0, a]*PolyGamma[3, a]^2*PolyGamma[4, a] +
     126126*PolyGamma[0, a]^4*PolyGamma[4, a]^2 + 756756*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[4, a]^2 + 378378*PolyGamma[1, a]^2*
      PolyGamma[4, a]^2 + 504504*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[4, a]^2 + 126126*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     3003*PolyGamma[0, a]^8*PolyGamma[5, a] + 84084*PolyGamma[0, a]^6*
      PolyGamma[1, a]*PolyGamma[5, a] + 630630*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[5, a] + 1261260*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[5, a] + 315315*PolyGamma[1, a]^4*
      PolyGamma[5, a] + 168168*PolyGamma[0, a]^5*PolyGamma[2, a]*
      PolyGamma[5, a] + 1681680*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[5, a] + 2522520*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[5, a] +
     840840*PolyGamma[0, a]^2*PolyGamma[2, a]^2*PolyGamma[5, a] +
     840840*PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[5, a] +
     210210*PolyGamma[0, a]^4*PolyGamma[3, a]*PolyGamma[5, a] +
     1261260*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 630630*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[5, a] + 840840*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 105105*PolyGamma[3, a]^2*
      PolyGamma[5, a] + 168168*PolyGamma[0, a]^3*PolyGamma[4, a]*
      PolyGamma[5, a] + 504504*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 168168*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 42042*PolyGamma[0, a]^2*
      PolyGamma[5, a]^2 + 42042*PolyGamma[1, a]*PolyGamma[5, a]^2 +
     3432*PolyGamma[0, a]^7*PolyGamma[6, a] + 72072*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[6, a] + 360360*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[6, a] + 360360*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[6, a] + 120120*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[6, a] + 720720*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[6, a] +
     360360*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[6, a] +
     240240*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[6, a] +
     120120*PolyGamma[0, a]^3*PolyGamma[3, a]*PolyGamma[6, a] +
     360360*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     120120*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     72072*PolyGamma[0, a]^2*PolyGamma[4, a]*PolyGamma[6, a] +
     72072*PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     24024*PolyGamma[0, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     1716*PolyGamma[6, a]^2 + 3003*PolyGamma[0, a]^6*PolyGamma[7, a] +
     45045*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[7, a] +
     135135*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[7, a] +
     45045*PolyGamma[1, a]^3*PolyGamma[7, a] + 60060*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[7, a] + 180180*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[7, a] +
     30030*PolyGamma[2, a]^2*PolyGamma[7, a] + 45045*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[7, a] + 45045*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 18018*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[7, a] + 3003*PolyGamma[5, a]*PolyGamma[7, a] +
     2002*PolyGamma[0, a]^5*PolyGamma[8, a] + 20020*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[8, a] + 30030*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[8, a] + 20020*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[8, a] + 20020*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[8, a] + 10010*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 2002*PolyGamma[4, a]*PolyGamma[8, a] +
     1001*PolyGamma[0, a]^4*PolyGamma[9, a] + 6006*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[9, a] + 3003*PolyGamma[1, a]^2*
      PolyGamma[9, a] + 4004*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[9, a] + 1001*PolyGamma[3, a]*PolyGamma[9, a] +
     364*PolyGamma[0, a]^3*PolyGamma[10, a] + 1092*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[10, a] + 364*PolyGamma[2, a]*
      PolyGamma[10, a] + 91*PolyGamma[0, a]^2*PolyGamma[11, a] +
     91*PolyGamma[1, a]*PolyGamma[11, a] + 14*PolyGamma[0, a]*
      PolyGamma[12, a] + PolyGamma[13, a]

MBexpGam[a_, 15] = PolyGamma[0, a]^15 + 105*PolyGamma[0, a]^13*
      PolyGamma[1, a] + 4095*PolyGamma[0, a]^11*PolyGamma[1, a]^2 +
     75075*PolyGamma[0, a]^9*PolyGamma[1, a]^3 + 675675*PolyGamma[0, a]^7*
      PolyGamma[1, a]^4 + 2837835*PolyGamma[0, a]^5*PolyGamma[1, a]^5 +
     4729725*PolyGamma[0, a]^3*PolyGamma[1, a]^6 + 2027025*PolyGamma[0, a]*
      PolyGamma[1, a]^7 + 455*PolyGamma[0, a]^12*PolyGamma[2, a] +
     30030*PolyGamma[0, a]^10*PolyGamma[1, a]*PolyGamma[2, a] +
     675675*PolyGamma[0, a]^8*PolyGamma[1, a]^2*PolyGamma[2, a] +
     6306300*PolyGamma[0, a]^6*PolyGamma[1, a]^3*PolyGamma[2, a] +
     23648625*PolyGamma[0, a]^4*PolyGamma[1, a]^4*PolyGamma[2, a] +
     28378350*PolyGamma[0, a]^2*PolyGamma[1, a]^5*PolyGamma[2, a] +
     4729725*PolyGamma[1, a]^6*PolyGamma[2, a] + 50050*PolyGamma[0, a]^9*
      PolyGamma[2, a]^2 + 1801800*PolyGamma[0, a]^7*PolyGamma[1, a]*
      PolyGamma[2, a]^2 + 18918900*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2 + 63063000*PolyGamma[0, a]^3*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2 + 47297250*PolyGamma[0, a]*PolyGamma[1, a]^4*
      PolyGamma[2, a]^2 + 1401400*PolyGamma[0, a]^6*PolyGamma[2, a]^3 +
     21021000*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]^3 +
     63063000*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]^3 +
     21021000*PolyGamma[1, a]^3*PolyGamma[2, a]^3 +
     7007000*PolyGamma[0, a]^3*PolyGamma[2, a]^4 + 21021000*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]^4 + 1401400*PolyGamma[2, a]^5 +
     1365*PolyGamma[0, a]^11*PolyGamma[3, a] + 75075*PolyGamma[0, a]^9*
      PolyGamma[1, a]*PolyGamma[3, a] + 1351350*PolyGamma[0, a]^7*
      PolyGamma[1, a]^2*PolyGamma[3, a] + 9459450*PolyGamma[0, a]^5*
      PolyGamma[1, a]^3*PolyGamma[3, a] + 23648625*PolyGamma[0, a]^3*
      PolyGamma[1, a]^4*PolyGamma[3, a] + 14189175*PolyGamma[0, a]*
      PolyGamma[1, a]^5*PolyGamma[3, a] + 225225*PolyGamma[0, a]^8*
      PolyGamma[2, a]*PolyGamma[3, a] + 6306300*PolyGamma[0, a]^6*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a] +
     47297250*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a] + 94594500*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a] + 23648625*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[3, a] + 6306300*PolyGamma[0, a]^5*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 63063000*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[3, a] +
     94594500*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 21021000*PolyGamma[0, a]^2*PolyGamma[2, a]^3*
      PolyGamma[3, a] + 21021000*PolyGamma[1, a]*PolyGamma[2, a]^3*
      PolyGamma[3, a] + 225225*PolyGamma[0, a]^7*PolyGamma[3, a]^2 +
     4729725*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[3, a]^2 +
     23648625*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[3, a]^2 +
     23648625*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[3, a]^2 +
     7882875*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     47297250*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 23648625*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 15765750*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]^2 + 2627625*PolyGamma[0, a]^3*PolyGamma[3, a]^3 +
     7882875*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]^3 +
     2627625*PolyGamma[2, a]*PolyGamma[3, a]^3 + 3003*PolyGamma[0, a]^10*
      PolyGamma[4, a] + 135135*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[4, a] + 1891890*PolyGamma[0, a]^6*PolyGamma[1, a]^2*
      PolyGamma[4, a] + 9459450*PolyGamma[0, a]^4*PolyGamma[1, a]^3*
      PolyGamma[4, a] + 14189175*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[4, a] + 2837835*PolyGamma[1, a]^5*PolyGamma[4, a] +
     360360*PolyGamma[0, a]^7*PolyGamma[2, a]*PolyGamma[4, a] +
     7567560*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a] + 37837800*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a] + 37837800*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[4, a] +
     6306300*PolyGamma[0, a]^4*PolyGamma[2, a]^2*PolyGamma[4, a] +
     37837800*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 18918900*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 8408400*PolyGamma[0, a]*PolyGamma[2, a]^3*
      PolyGamma[4, a] + 630630*PolyGamma[0, a]^6*PolyGamma[3, a]*
      PolyGamma[4, a] + 9459450*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 28378350*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[4, a] +
     9459450*PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[4, a] +
     12612600*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 37837800*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     6306300*PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[4, a] +
     4729725*PolyGamma[0, a]^2*PolyGamma[3, a]^2*PolyGamma[4, a] +
     4729725*PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[4, a] +
     378378*PolyGamma[0, a]^5*PolyGamma[4, a]^2 + 3783780*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[4, a]^2 + 5675670*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[4, a]^2 + 3783780*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 3783780*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 1891890*PolyGamma[0, a]*
      PolyGamma[3, a]*PolyGamma[4, a]^2 + 126126*PolyGamma[4, a]^3 +
     5005*PolyGamma[0, a]^9*PolyGamma[5, a] + 180180*PolyGamma[0, a]^7*
      PolyGamma[1, a]*PolyGamma[5, a] + 1891890*PolyGamma[0, a]^5*
      PolyGamma[1, a]^2*PolyGamma[5, a] + 6306300*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[5, a] + 4729725*PolyGamma[0, a]*
      PolyGamma[1, a]^4*PolyGamma[5, a] + 420420*PolyGamma[0, a]^6*
      PolyGamma[2, a]*PolyGamma[5, a] + 6306300*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[5, a] +
     18918900*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[5, a] + 6306300*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[5, a] + 4204200*PolyGamma[0, a]^3*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 12612600*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 1401400*PolyGamma[2, a]^3*
      PolyGamma[5, a] + 630630*PolyGamma[0, a]^5*PolyGamma[3, a]*
      PolyGamma[5, a] + 6306300*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 9459450*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     6306300*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 6306300*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 1576575*PolyGamma[0, a]*
      PolyGamma[3, a]^2*PolyGamma[5, a] + 630630*PolyGamma[0, a]^4*
      PolyGamma[4, a]*PolyGamma[5, a] + 3783780*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     1891890*PolyGamma[1, a]^2*PolyGamma[4, a]*PolyGamma[5, a] +
     2522520*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 630630*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 210210*PolyGamma[0, a]^3*PolyGamma[5, a]^2 +
     630630*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[5, a]^2 +
     210210*PolyGamma[2, a]*PolyGamma[5, a]^2 + 6435*PolyGamma[0, a]^8*
      PolyGamma[6, a] + 180180*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[6, a] + 1351350*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[6, a] + 2702700*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[6, a] + 675675*PolyGamma[1, a]^4*PolyGamma[6, a] +
     360360*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[6, a] +
     3603600*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[6, a] + 5405400*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[6, a] + 1801800*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 1801800*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 450450*PolyGamma[0, a]^4*
      PolyGamma[3, a]*PolyGamma[6, a] + 2702700*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     1351350*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[6, a] +
     1801800*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[6, a] + 225225*PolyGamma[3, a]^2*PolyGamma[6, a] +
     360360*PolyGamma[0, a]^3*PolyGamma[4, a]*PolyGamma[6, a] +
     1081080*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 360360*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 180180*PolyGamma[0, a]^2*PolyGamma[5, a]*
      PolyGamma[6, a] + 180180*PolyGamma[1, a]*PolyGamma[5, a]*
      PolyGamma[6, a] + 25740*PolyGamma[0, a]*PolyGamma[6, a]^2 +
     6435*PolyGamma[0, a]^7*PolyGamma[7, a] + 135135*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[7, a] + 675675*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[7, a] + 675675*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[7, a] + 225225*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[7, a] + 1351350*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[7, a] +
     675675*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[7, a] +
     450450*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[7, a] +
     225225*PolyGamma[0, a]^3*PolyGamma[3, a]*PolyGamma[7, a] +
     675675*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     225225*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     135135*PolyGamma[0, a]^2*PolyGamma[4, a]*PolyGamma[7, a] +
     135135*PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     45045*PolyGamma[0, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     6435*PolyGamma[6, a]*PolyGamma[7, a] + 5005*PolyGamma[0, a]^6*
      PolyGamma[8, a] + 75075*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[8, a] + 225225*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[8, a] + 75075*PolyGamma[1, a]^3*PolyGamma[8, a] +
     100100*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[8, a] +
     300300*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[8, a] +
     50050*PolyGamma[2, a]^2*PolyGamma[8, a] + 75075*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[8, a] + 75075*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 30030*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[8, a] + 5005*PolyGamma[5, a]*PolyGamma[8, a] +
     3003*PolyGamma[0, a]^5*PolyGamma[9, a] + 30030*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[9, a] + 45045*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[9, a] + 30030*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[9, a] + 30030*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[9, a] + 15015*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[9, a] + 3003*PolyGamma[4, a]*PolyGamma[9, a] +
     1365*PolyGamma[0, a]^4*PolyGamma[10, a] + 8190*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[10, a] + 4095*PolyGamma[1, a]^2*
      PolyGamma[10, a] + 5460*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[10, a] + 1365*PolyGamma[3, a]*PolyGamma[10, a] +
     455*PolyGamma[0, a]^3*PolyGamma[11, a] + 1365*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[11, a] + 455*PolyGamma[2, a]*
      PolyGamma[11, a] + 105*PolyGamma[0, a]^2*PolyGamma[12, a] +
     105*PolyGamma[1, a]*PolyGamma[12, a] + 15*PolyGamma[0, a]*
      PolyGamma[13, a] + PolyGamma[14, a]

MBexpGam[a_, 16] = PolyGamma[0, a]^16 + 120*PolyGamma[0, a]^14*
      PolyGamma[1, a] + 5460*PolyGamma[0, a]^12*PolyGamma[1, a]^2 +
     120120*PolyGamma[0, a]^10*PolyGamma[1, a]^3 + 1351350*PolyGamma[0, a]^8*
      PolyGamma[1, a]^4 + 7567560*PolyGamma[0, a]^6*PolyGamma[1, a]^5 +
     18918900*PolyGamma[0, a]^4*PolyGamma[1, a]^6 +
     16216200*PolyGamma[0, a]^2*PolyGamma[1, a]^7 +
     2027025*PolyGamma[1, a]^8 + 560*PolyGamma[0, a]^13*PolyGamma[2, a] +
     43680*PolyGamma[0, a]^11*PolyGamma[1, a]*PolyGamma[2, a] +
     1201200*PolyGamma[0, a]^9*PolyGamma[1, a]^2*PolyGamma[2, a] +
     14414400*PolyGamma[0, a]^7*PolyGamma[1, a]^3*PolyGamma[2, a] +
     75675600*PolyGamma[0, a]^5*PolyGamma[1, a]^4*PolyGamma[2, a] +
     151351200*PolyGamma[0, a]^3*PolyGamma[1, a]^5*PolyGamma[2, a] +
     75675600*PolyGamma[0, a]*PolyGamma[1, a]^6*PolyGamma[2, a] +
     80080*PolyGamma[0, a]^10*PolyGamma[2, a]^2 + 3603600*PolyGamma[0, a]^8*
      PolyGamma[1, a]*PolyGamma[2, a]^2 + 50450400*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2 + 252252000*PolyGamma[0, a]^4*
      PolyGamma[1, a]^3*PolyGamma[2, a]^2 + 378378000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^4*PolyGamma[2, a]^2 + 75675600*PolyGamma[1, a]^5*
      PolyGamma[2, a]^2 + 3203200*PolyGamma[0, a]^7*PolyGamma[2, a]^3 +
     67267200*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]^3 +
     336336000*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]^3 +
     336336000*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[2, a]^3 +
     28028000*PolyGamma[0, a]^4*PolyGamma[2, a]^4 +
     168168000*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^4 +
     84084000*PolyGamma[1, a]^2*PolyGamma[2, a]^4 +
     22422400*PolyGamma[0, a]*PolyGamma[2, a]^5 + 1820*PolyGamma[0, a]^12*
      PolyGamma[3, a] + 120120*PolyGamma[0, a]^10*PolyGamma[1, a]*
      PolyGamma[3, a] + 2702700*PolyGamma[0, a]^8*PolyGamma[1, a]^2*
      PolyGamma[3, a] + 25225200*PolyGamma[0, a]^6*PolyGamma[1, a]^3*
      PolyGamma[3, a] + 94594500*PolyGamma[0, a]^4*PolyGamma[1, a]^4*
      PolyGamma[3, a] + 113513400*PolyGamma[0, a]^2*PolyGamma[1, a]^5*
      PolyGamma[3, a] + 18918900*PolyGamma[1, a]^6*PolyGamma[3, a] +
     400400*PolyGamma[0, a]^9*PolyGamma[2, a]*PolyGamma[3, a] +
     14414400*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a] + 151351200*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a] + 504504000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[3, a] +
     378378000*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[3, a] + 16816800*PolyGamma[0, a]^6*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 252252000*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 756756000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a] +
     252252000*PolyGamma[1, a]^3*PolyGamma[2, a]^2*PolyGamma[3, a] +
     112112000*PolyGamma[0, a]^3*PolyGamma[2, a]^3*PolyGamma[3, a] +
     336336000*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^3*
      PolyGamma[3, a] + 28028000*PolyGamma[2, a]^4*PolyGamma[3, a] +
     450450*PolyGamma[0, a]^8*PolyGamma[3, a]^2 + 12612600*PolyGamma[0, a]^6*
      PolyGamma[1, a]*PolyGamma[3, a]^2 + 94594500*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[3, a]^2 + 189189000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[3, a]^2 + 47297250*PolyGamma[1, a]^4*
      PolyGamma[3, a]^2 + 25225200*PolyGamma[0, a]^5*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 252252000*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 378378000*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     126126000*PolyGamma[0, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a]^2 +
     126126000*PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[3, a]^2 +
     10510500*PolyGamma[0, a]^4*PolyGamma[3, a]^3 +
     63063000*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[3, a]^3 +
     31531500*PolyGamma[1, a]^2*PolyGamma[3, a]^3 +
     42042000*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]^3 +
     2627625*PolyGamma[3, a]^4 + 4368*PolyGamma[0, a]^11*PolyGamma[4, a] +
     240240*PolyGamma[0, a]^9*PolyGamma[1, a]*PolyGamma[4, a] +
     4324320*PolyGamma[0, a]^7*PolyGamma[1, a]^2*PolyGamma[4, a] +
     30270240*PolyGamma[0, a]^5*PolyGamma[1, a]^3*PolyGamma[4, a] +
     75675600*PolyGamma[0, a]^3*PolyGamma[1, a]^4*PolyGamma[4, a] +
     45405360*PolyGamma[0, a]*PolyGamma[1, a]^5*PolyGamma[4, a] +
     720720*PolyGamma[0, a]^8*PolyGamma[2, a]*PolyGamma[4, a] +
     20180160*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a] + 151351200*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a] + 302702400*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[4, a] +
     75675600*PolyGamma[1, a]^4*PolyGamma[2, a]*PolyGamma[4, a] +
     20180160*PolyGamma[0, a]^5*PolyGamma[2, a]^2*PolyGamma[4, a] +
     201801600*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 302702400*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[4, a] + 67267200*PolyGamma[0, a]^2*
      PolyGamma[2, a]^3*PolyGamma[4, a] + 67267200*PolyGamma[1, a]*
      PolyGamma[2, a]^3*PolyGamma[4, a] + 1441440*PolyGamma[0, a]^7*
      PolyGamma[3, a]*PolyGamma[4, a] + 30270240*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     151351200*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 151351200*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[3, a]*PolyGamma[4, a] + 50450400*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     302702400*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 151351200*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     100900800*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 25225200*PolyGamma[0, a]^3*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 75675600*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 25225200*PolyGamma[2, a]*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 1009008*PolyGamma[0, a]^6*
      PolyGamma[4, a]^2 + 15135120*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[4, a]^2 + 45405360*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[4, a]^2 + 15135120*PolyGamma[1, a]^3*PolyGamma[4, a]^2 +
     20180160*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[4, a]^2 +
     60540480*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]^2 + 10090080*PolyGamma[2, a]^2*PolyGamma[4, a]^2 +
     15135120*PolyGamma[0, a]^2*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     15135120*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     2018016*PolyGamma[0, a]*PolyGamma[4, a]^3 + 8008*PolyGamma[0, a]^10*
      PolyGamma[5, a] + 360360*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[5, a] + 5045040*PolyGamma[0, a]^6*PolyGamma[1, a]^2*
      PolyGamma[5, a] + 25225200*PolyGamma[0, a]^4*PolyGamma[1, a]^3*
      PolyGamma[5, a] + 37837800*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[5, a] + 7567560*PolyGamma[1, a]^5*PolyGamma[5, a] +
     960960*PolyGamma[0, a]^7*PolyGamma[2, a]*PolyGamma[5, a] +
     20180160*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a] + 100900800*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[5, a] + 100900800*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[5, a] +
     16816800*PolyGamma[0, a]^4*PolyGamma[2, a]^2*PolyGamma[5, a] +
     100900800*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 50450400*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 22422400*PolyGamma[0, a]*PolyGamma[2, a]^3*
      PolyGamma[5, a] + 1681680*PolyGamma[0, a]^6*PolyGamma[3, a]*
      PolyGamma[5, a] + 25225200*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 75675600*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     25225200*PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[5, a] +
     33633600*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 100900800*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     16816800*PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     12612600*PolyGamma[0, a]^2*PolyGamma[3, a]^2*PolyGamma[5, a] +
     12612600*PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[5, a] +
     2018016*PolyGamma[0, a]^5*PolyGamma[4, a]*PolyGamma[5, a] +
     20180160*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 30270240*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[5, a] + 20180160*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     20180160*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 10090080*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 1009008*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 840840*PolyGamma[0, a]^4*PolyGamma[5, a]^2 +
     5045040*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[5, a]^2 +
     2522520*PolyGamma[1, a]^2*PolyGamma[5, a]^2 + 3363360*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[5, a]^2 + 840840*PolyGamma[3, a]*
      PolyGamma[5, a]^2 + 11440*PolyGamma[0, a]^9*PolyGamma[6, a] +
     411840*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[6, a] +
     4324320*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[6, a] +
     14414400*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[6, a] +
     10810800*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[6, a] +
     960960*PolyGamma[0, a]^6*PolyGamma[2, a]*PolyGamma[6, a] +
     14414400*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[6, a] + 43243200*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[6, a] + 14414400*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[6, a] + 9609600*PolyGamma[0, a]^3*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 28828800*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[6, a] +
     3203200*PolyGamma[2, a]^3*PolyGamma[6, a] + 1441440*PolyGamma[0, a]^5*
      PolyGamma[3, a]*PolyGamma[6, a] + 14414400*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     21621600*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[6, a] + 14414400*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[6, a] + 14414400*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     3603600*PolyGamma[0, a]*PolyGamma[3, a]^2*PolyGamma[6, a] +
     1441440*PolyGamma[0, a]^4*PolyGamma[4, a]*PolyGamma[6, a] +
     8648640*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 4324320*PolyGamma[1, a]^2*PolyGamma[4, a]*
      PolyGamma[6, a] + 5765760*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 1441440*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 960960*PolyGamma[0, a]^3*
      PolyGamma[5, a]*PolyGamma[6, a] + 2882880*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     960960*PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     205920*PolyGamma[0, a]^2*PolyGamma[6, a]^2 + 205920*PolyGamma[1, a]*
      PolyGamma[6, a]^2 + 12870*PolyGamma[0, a]^8*PolyGamma[7, a] +
     360360*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[7, a] +
     2702700*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[7, a] +
     5405400*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[7, a] +
     1351350*PolyGamma[1, a]^4*PolyGamma[7, a] + 720720*PolyGamma[0, a]^5*
      PolyGamma[2, a]*PolyGamma[7, a] + 7207200*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[7, a] +
     10810800*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[7, a] + 3603600*PolyGamma[0, a]^2*PolyGamma[2, a]^2*
      PolyGamma[7, a] + 3603600*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[7, a] + 900900*PolyGamma[0, a]^4*PolyGamma[3, a]*
      PolyGamma[7, a] + 5405400*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[7, a] + 2702700*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[7, a] + 3603600*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     450450*PolyGamma[3, a]^2*PolyGamma[7, a] + 720720*PolyGamma[0, a]^3*
      PolyGamma[4, a]*PolyGamma[7, a] + 2162160*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     720720*PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     360360*PolyGamma[0, a]^2*PolyGamma[5, a]*PolyGamma[7, a] +
     360360*PolyGamma[1, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     102960*PolyGamma[0, a]*PolyGamma[6, a]*PolyGamma[7, a] +
     6435*PolyGamma[7, a]^2 + 11440*PolyGamma[0, a]^7*PolyGamma[8, a] +
     240240*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[8, a] +
     1201200*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[8, a] +
     1201200*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[8, a] +
     400400*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[8, a] +
     2402400*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[8, a] + 1201200*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[8, a] + 800800*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[8, a] + 400400*PolyGamma[0, a]^3*PolyGamma[3, a]*
      PolyGamma[8, a] + 1201200*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[8, a] + 400400*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[8, a] + 240240*PolyGamma[0, a]^2*
      PolyGamma[4, a]*PolyGamma[8, a] + 240240*PolyGamma[1, a]*
      PolyGamma[4, a]*PolyGamma[8, a] + 80080*PolyGamma[0, a]*PolyGamma[5, a]*
      PolyGamma[8, a] + 11440*PolyGamma[6, a]*PolyGamma[8, a] +
     8008*PolyGamma[0, a]^6*PolyGamma[9, a] + 120120*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[9, a] + 360360*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[9, a] + 120120*PolyGamma[1, a]^3*
      PolyGamma[9, a] + 160160*PolyGamma[0, a]^3*PolyGamma[2, a]*
      PolyGamma[9, a] + 480480*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[9, a] + 80080*PolyGamma[2, a]^2*
      PolyGamma[9, a] + 120120*PolyGamma[0, a]^2*PolyGamma[3, a]*
      PolyGamma[9, a] + 120120*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[9, a] + 48048*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[9, a] + 8008*PolyGamma[5, a]*PolyGamma[9, a] +
     4368*PolyGamma[0, a]^5*PolyGamma[10, a] + 43680*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[10, a] + 65520*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[10, a] + 43680*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[10, a] + 43680*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[10, a] + 21840*PolyGamma[0, a]*
      PolyGamma[3, a]*PolyGamma[10, a] + 4368*PolyGamma[4, a]*
      PolyGamma[10, a] + 1820*PolyGamma[0, a]^4*PolyGamma[11, a] +
     10920*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[11, a] +
     5460*PolyGamma[1, a]^2*PolyGamma[11, a] + 7280*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[11, a] + 1820*PolyGamma[3, a]*
      PolyGamma[11, a] + 560*PolyGamma[0, a]^3*PolyGamma[12, a] +
     1680*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[12, a] +
     560*PolyGamma[2, a]*PolyGamma[12, a] + 120*PolyGamma[0, a]^2*
      PolyGamma[13, a] + 120*PolyGamma[1, a]*PolyGamma[13, a] +
     16*PolyGamma[0, a]*PolyGamma[14, a] + PolyGamma[15, a]

MBexpGam[a_, 17] = PolyGamma[0, a]^17 + 136*PolyGamma[0, a]^15*
      PolyGamma[1, a] + 7140*PolyGamma[0, a]^13*PolyGamma[1, a]^2 +
     185640*PolyGamma[0, a]^11*PolyGamma[1, a]^3 + 2552550*PolyGamma[0, a]^9*
      PolyGamma[1, a]^4 + 18378360*PolyGamma[0, a]^7*PolyGamma[1, a]^5 +
     64324260*PolyGamma[0, a]^5*PolyGamma[1, a]^6 +
     91891800*PolyGamma[0, a]^3*PolyGamma[1, a]^7 +
     34459425*PolyGamma[0, a]*PolyGamma[1, a]^8 + 680*PolyGamma[0, a]^14*
      PolyGamma[2, a] + 61880*PolyGamma[0, a]^12*PolyGamma[1, a]*
      PolyGamma[2, a] + 2042040*PolyGamma[0, a]^10*PolyGamma[1, a]^2*
      PolyGamma[2, a] + 30630600*PolyGamma[0, a]^8*PolyGamma[1, a]^3*
      PolyGamma[2, a] + 214414200*PolyGamma[0, a]^6*PolyGamma[1, a]^4*
      PolyGamma[2, a] + 643242600*PolyGamma[0, a]^4*PolyGamma[1, a]^5*
      PolyGamma[2, a] + 643242600*PolyGamma[0, a]^2*PolyGamma[1, a]^6*
      PolyGamma[2, a] + 91891800*PolyGamma[1, a]^7*PolyGamma[2, a] +
     123760*PolyGamma[0, a]^11*PolyGamma[2, a]^2 + 6806800*PolyGamma[0, a]^9*
      PolyGamma[1, a]*PolyGamma[2, a]^2 + 122522400*PolyGamma[0, a]^7*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2 + 857656800*PolyGamma[0, a]^5*
      PolyGamma[1, a]^3*PolyGamma[2, a]^2 + 2144142000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^4*PolyGamma[2, a]^2 + 1286485200*PolyGamma[0, a]*
      PolyGamma[1, a]^5*PolyGamma[2, a]^2 + 6806800*PolyGamma[0, a]^8*
      PolyGamma[2, a]^3 + 190590400*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[2, a]^3 + 1429428000*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[2, a]^3 + 2858856000*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[2, a]^3 + 714714000*PolyGamma[1, a]^4*PolyGamma[2, a]^3 +
     95295200*PolyGamma[0, a]^5*PolyGamma[2, a]^4 +
     952952000*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]^4 +
     1429428000*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]^4 +
     190590400*PolyGamma[0, a]^2*PolyGamma[2, a]^5 +
     190590400*PolyGamma[1, a]*PolyGamma[2, a]^5 + 2380*PolyGamma[0, a]^13*
      PolyGamma[3, a] + 185640*PolyGamma[0, a]^11*PolyGamma[1, a]*
      PolyGamma[3, a] + 5105100*PolyGamma[0, a]^9*PolyGamma[1, a]^2*
      PolyGamma[3, a] + 61261200*PolyGamma[0, a]^7*PolyGamma[1, a]^3*
      PolyGamma[3, a] + 321621300*PolyGamma[0, a]^5*PolyGamma[1, a]^4*
      PolyGamma[3, a] + 643242600*PolyGamma[0, a]^3*PolyGamma[1, a]^5*
      PolyGamma[3, a] + 321621300*PolyGamma[0, a]*PolyGamma[1, a]^6*
      PolyGamma[3, a] + 680680*PolyGamma[0, a]^10*PolyGamma[2, a]*
      PolyGamma[3, a] + 30630600*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a] + 428828400*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a] +
     2144142000*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a] + 3216213000*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[3, a] + 643242600*PolyGamma[1, a]^5*
      PolyGamma[2, a]*PolyGamma[3, a] + 40840800*PolyGamma[0, a]^7*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 857656800*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[3, a] +
     4288284000*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 4288284000*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 476476000*PolyGamma[0, a]^4*
      PolyGamma[2, a]^3*PolyGamma[3, a] + 2858856000*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[3, a] +
     1429428000*PolyGamma[1, a]^2*PolyGamma[2, a]^3*PolyGamma[3, a] +
     476476000*PolyGamma[0, a]*PolyGamma[2, a]^4*PolyGamma[3, a] +
     850850*PolyGamma[0, a]^9*PolyGamma[3, a]^2 + 30630600*PolyGamma[0, a]^7*
      PolyGamma[1, a]*PolyGamma[3, a]^2 + 321621300*PolyGamma[0, a]^5*
      PolyGamma[1, a]^2*PolyGamma[3, a]^2 + 1072071000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[3, a]^2 + 804053250*PolyGamma[0, a]*
      PolyGamma[1, a]^4*PolyGamma[3, a]^2 + 71471400*PolyGamma[0, a]^6*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 1072071000*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     3216213000*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 1072071000*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 714714000*PolyGamma[0, a]^3*PolyGamma[2, a]^2*
      PolyGamma[3, a]^2 + 2144142000*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]^2 + 238238000*PolyGamma[2, a]^3*
      PolyGamma[3, a]^2 + 35735700*PolyGamma[0, a]^5*PolyGamma[3, a]^3 +
     357357000*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[3, a]^3 +
     536035500*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[3, a]^3 +
     357357000*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[3, a]^3 +
     357357000*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]^3 +
     44669625*PolyGamma[0, a]*PolyGamma[3, a]^4 + 6188*PolyGamma[0, a]^12*
      PolyGamma[4, a] + 408408*PolyGamma[0, a]^10*PolyGamma[1, a]*
      PolyGamma[4, a] + 9189180*PolyGamma[0, a]^8*PolyGamma[1, a]^2*
      PolyGamma[4, a] + 85765680*PolyGamma[0, a]^6*PolyGamma[1, a]^3*
      PolyGamma[4, a] + 321621300*PolyGamma[0, a]^4*PolyGamma[1, a]^4*
      PolyGamma[4, a] + 385945560*PolyGamma[0, a]^2*PolyGamma[1, a]^5*
      PolyGamma[4, a] + 64324260*PolyGamma[1, a]^6*PolyGamma[4, a] +
     1361360*PolyGamma[0, a]^9*PolyGamma[2, a]*PolyGamma[4, a] +
     49008960*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a] + 514594080*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a] + 1715313600*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[4, a] +
     1286485200*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[4, a] + 57177120*PolyGamma[0, a]^6*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 857656800*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[4, a] + 2572970400*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[4, a] +
     857656800*PolyGamma[1, a]^3*PolyGamma[2, a]^2*PolyGamma[4, a] +
     381180800*PolyGamma[0, a]^3*PolyGamma[2, a]^3*PolyGamma[4, a] +
     1143542400*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^3*
      PolyGamma[4, a] + 95295200*PolyGamma[2, a]^4*PolyGamma[4, a] +
     3063060*PolyGamma[0, a]^8*PolyGamma[3, a]*PolyGamma[4, a] +
     85765680*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 643242600*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a] + 1286485200*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[4, a] +
     321621300*PolyGamma[1, a]^4*PolyGamma[3, a]*PolyGamma[4, a] +
     171531360*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 1715313600*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     2572970400*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 857656800*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[4, a] +
     857656800*PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 107207100*PolyGamma[0, a]^4*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 643242600*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 321621300*PolyGamma[1, a]^2*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 428828400*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[4, a] +
     35735700*PolyGamma[3, a]^3*PolyGamma[4, a] + 2450448*PolyGamma[0, a]^7*
      PolyGamma[4, a]^2 + 51459408*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[4, a]^2 + 257297040*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[4, a]^2 + 257297040*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[4, a]^2 + 85765680*PolyGamma[0, a]^4*PolyGamma[2, a]*
      PolyGamma[4, a]^2 + 514594080*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 257297040*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 171531360*PolyGamma[0, a]*
      PolyGamma[2, a]^2*PolyGamma[4, a]^2 + 85765680*PolyGamma[0, a]^3*
      PolyGamma[3, a]*PolyGamma[4, a]^2 + 257297040*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     85765680*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     17153136*PolyGamma[0, a]^2*PolyGamma[4, a]^3 +
     17153136*PolyGamma[1, a]*PolyGamma[4, a]^3 + 12376*PolyGamma[0, a]^11*
      PolyGamma[5, a] + 680680*PolyGamma[0, a]^9*PolyGamma[1, a]*
      PolyGamma[5, a] + 12252240*PolyGamma[0, a]^7*PolyGamma[1, a]^2*
      PolyGamma[5, a] + 85765680*PolyGamma[0, a]^5*PolyGamma[1, a]^3*
      PolyGamma[5, a] + 214414200*PolyGamma[0, a]^3*PolyGamma[1, a]^4*
      PolyGamma[5, a] + 128648520*PolyGamma[0, a]*PolyGamma[1, a]^5*
      PolyGamma[5, a] + 2042040*PolyGamma[0, a]^8*PolyGamma[2, a]*
      PolyGamma[5, a] + 57177120*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[5, a] + 428828400*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[5, a] +
     857656800*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[5, a] + 214414200*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[5, a] + 57177120*PolyGamma[0, a]^5*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 571771200*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 857656800*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[5, a] +
     190590400*PolyGamma[0, a]^2*PolyGamma[2, a]^3*PolyGamma[5, a] +
     190590400*PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[5, a] +
     4084080*PolyGamma[0, a]^7*PolyGamma[3, a]*PolyGamma[5, a] +
     85765680*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 428828400*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[5, a] + 428828400*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[5, a] +
     142942800*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 857656800*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     428828400*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 285885600*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]*PolyGamma[5, a] + 71471400*PolyGamma[0, a]^3*
      PolyGamma[3, a]^2*PolyGamma[5, a] + 214414200*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[5, a] +
     71471400*PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[5, a] +
     5717712*PolyGamma[0, a]^6*PolyGamma[4, a]*PolyGamma[5, a] +
     85765680*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 257297040*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[5, a] + 85765680*PolyGamma[1, a]^3*
      PolyGamma[4, a]*PolyGamma[5, a] + 114354240*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     343062720*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 57177120*PolyGamma[2, a]^2*
      PolyGamma[4, a]*PolyGamma[5, a] + 85765680*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     85765680*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 17153136*PolyGamma[0, a]*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 2858856*PolyGamma[0, a]^5*PolyGamma[5, a]^2 +
     28588560*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[5, a]^2 +
     42882840*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[5, a]^2 +
     28588560*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[5, a]^2 +
     28588560*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[5, a]^2 +
     14294280*PolyGamma[0, a]*PolyGamma[3, a]*PolyGamma[5, a]^2 +
     2858856*PolyGamma[4, a]*PolyGamma[5, a]^2 + 19448*PolyGamma[0, a]^10*
      PolyGamma[6, a] + 875160*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[6, a] + 12252240*PolyGamma[0, a]^6*PolyGamma[1, a]^2*
      PolyGamma[6, a] + 61261200*PolyGamma[0, a]^4*PolyGamma[1, a]^3*
      PolyGamma[6, a] + 91891800*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[6, a] + 18378360*PolyGamma[1, a]^5*PolyGamma[6, a] +
     2333760*PolyGamma[0, a]^7*PolyGamma[2, a]*PolyGamma[6, a] +
     49008960*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[6, a] + 245044800*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[6, a] + 245044800*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[6, a] +
     40840800*PolyGamma[0, a]^4*PolyGamma[2, a]^2*PolyGamma[6, a] +
     245044800*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[6, a] + 122522400*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[6, a] + 54454400*PolyGamma[0, a]*PolyGamma[2, a]^3*
      PolyGamma[6, a] + 4084080*PolyGamma[0, a]^6*PolyGamma[3, a]*
      PolyGamma[6, a] + 61261200*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[6, a] + 183783600*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[6, a] +
     61261200*PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[6, a] +
     81681600*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[6, a] + 245044800*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     40840800*PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[6, a] +
     30630600*PolyGamma[0, a]^2*PolyGamma[3, a]^2*PolyGamma[6, a] +
     30630600*PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[6, a] +
     4900896*PolyGamma[0, a]^5*PolyGamma[4, a]*PolyGamma[6, a] +
     49008960*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 73513440*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[6, a] + 49008960*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     49008960*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 24504480*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 2450448*PolyGamma[4, a]^2*
      PolyGamma[6, a] + 4084080*PolyGamma[0, a]^4*PolyGamma[5, a]*
      PolyGamma[6, a] + 24504480*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 12252240*PolyGamma[1, a]^2*
      PolyGamma[5, a]*PolyGamma[6, a] + 16336320*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     4084080*PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     1166880*PolyGamma[0, a]^3*PolyGamma[6, a]^2 + 3500640*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[6, a]^2 + 1166880*PolyGamma[2, a]*
      PolyGamma[6, a]^2 + 24310*PolyGamma[0, a]^9*PolyGamma[7, a] +
     875160*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[7, a] +
     9189180*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[7, a] +
     30630600*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[7, a] +
     22972950*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[7, a] +
     2042040*PolyGamma[0, a]^6*PolyGamma[2, a]*PolyGamma[7, a] +
     30630600*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[7, a] + 91891800*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[7, a] + 30630600*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[7, a] + 20420400*PolyGamma[0, a]^3*
      PolyGamma[2, a]^2*PolyGamma[7, a] + 61261200*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[7, a] +
     6806800*PolyGamma[2, a]^3*PolyGamma[7, a] + 3063060*PolyGamma[0, a]^5*
      PolyGamma[3, a]*PolyGamma[7, a] + 30630600*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     45945900*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[7, a] + 30630600*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[7, a] + 30630600*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     7657650*PolyGamma[0, a]*PolyGamma[3, a]^2*PolyGamma[7, a] +
     3063060*PolyGamma[0, a]^4*PolyGamma[4, a]*PolyGamma[7, a] +
     18378360*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[7, a] + 9189180*PolyGamma[1, a]^2*PolyGamma[4, a]*
      PolyGamma[7, a] + 12252240*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[7, a] + 3063060*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[7, a] + 2042040*PolyGamma[0, a]^3*
      PolyGamma[5, a]*PolyGamma[7, a] + 6126120*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     2042040*PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     875160*PolyGamma[0, a]^2*PolyGamma[6, a]*PolyGamma[7, a] +
     875160*PolyGamma[1, a]*PolyGamma[6, a]*PolyGamma[7, a] +
     109395*PolyGamma[0, a]*PolyGamma[7, a]^2 + 24310*PolyGamma[0, a]^8*
      PolyGamma[8, a] + 680680*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[8, a] + 5105100*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[8, a] + 10210200*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[8, a] + 2552550*PolyGamma[1, a]^4*PolyGamma[8, a] +
     1361360*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[8, a] +
     13613600*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[8, a] + 20420400*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[8, a] + 6806800*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[8, a] + 6806800*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[8, a] + 1701700*PolyGamma[0, a]^4*
      PolyGamma[3, a]*PolyGamma[8, a] + 10210200*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[8, a] +
     5105100*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[8, a] +
     6806800*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 850850*PolyGamma[3, a]^2*PolyGamma[8, a] +
     1361360*PolyGamma[0, a]^3*PolyGamma[4, a]*PolyGamma[8, a] +
     4084080*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[8, a] + 1361360*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[8, a] + 680680*PolyGamma[0, a]^2*PolyGamma[5, a]*
      PolyGamma[8, a] + 680680*PolyGamma[1, a]*PolyGamma[5, a]*
      PolyGamma[8, a] + 194480*PolyGamma[0, a]*PolyGamma[6, a]*
      PolyGamma[8, a] + 24310*PolyGamma[7, a]*PolyGamma[8, a] +
     19448*PolyGamma[0, a]^7*PolyGamma[9, a] + 408408*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[9, a] + 2042040*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[9, a] + 2042040*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[9, a] + 680680*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[9, a] + 4084080*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[9, a] +
     2042040*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[9, a] +
     1361360*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[9, a] +
     680680*PolyGamma[0, a]^3*PolyGamma[3, a]*PolyGamma[9, a] +
     2042040*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[9, a] + 680680*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[9, a] + 408408*PolyGamma[0, a]^2*PolyGamma[4, a]*
      PolyGamma[9, a] + 408408*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[9, a] + 136136*PolyGamma[0, a]*PolyGamma[5, a]*
      PolyGamma[9, a] + 19448*PolyGamma[6, a]*PolyGamma[9, a] +
     12376*PolyGamma[0, a]^6*PolyGamma[10, a] + 185640*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[10, a] + 556920*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[10, a] + 185640*PolyGamma[1, a]^3*
      PolyGamma[10, a] + 247520*PolyGamma[0, a]^3*PolyGamma[2, a]*
      PolyGamma[10, a] + 742560*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[10, a] + 123760*PolyGamma[2, a]^2*
      PolyGamma[10, a] + 185640*PolyGamma[0, a]^2*PolyGamma[3, a]*
      PolyGamma[10, a] + 185640*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[10, a] + 74256*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[10, a] + 12376*PolyGamma[5, a]*PolyGamma[10, a] +
     6188*PolyGamma[0, a]^5*PolyGamma[11, a] + 61880*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[11, a] + 92820*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[11, a] + 61880*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[11, a] + 61880*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[11, a] + 30940*PolyGamma[0, a]*
      PolyGamma[3, a]*PolyGamma[11, a] + 6188*PolyGamma[4, a]*
      PolyGamma[11, a] + 2380*PolyGamma[0, a]^4*PolyGamma[12, a] +
     14280*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[12, a] +
     7140*PolyGamma[1, a]^2*PolyGamma[12, a] + 9520*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[12, a] + 2380*PolyGamma[3, a]*
      PolyGamma[12, a] + 680*PolyGamma[0, a]^3*PolyGamma[13, a] +
     2040*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[13, a] +
     680*PolyGamma[2, a]*PolyGamma[13, a] + 136*PolyGamma[0, a]^2*
      PolyGamma[14, a] + 136*PolyGamma[1, a]*PolyGamma[14, a] +
     17*PolyGamma[0, a]*PolyGamma[15, a] + PolyGamma[16, a]

MBexpGam[a_, 18] = PolyGamma[0, a]^18 + 153*PolyGamma[0, a]^16*
      PolyGamma[1, a] + 9180*PolyGamma[0, a]^14*PolyGamma[1, a]^2 +
     278460*PolyGamma[0, a]^12*PolyGamma[1, a]^3 + 4594590*PolyGamma[0, a]^10*
      PolyGamma[1, a]^4 + 41351310*PolyGamma[0, a]^8*PolyGamma[1, a]^5 +
     192972780*PolyGamma[0, a]^6*PolyGamma[1, a]^6 +
     413513100*PolyGamma[0, a]^4*PolyGamma[1, a]^7 +
     310134825*PolyGamma[0, a]^2*PolyGamma[1, a]^8 +
     34459425*PolyGamma[1, a]^9 + 816*PolyGamma[0, a]^15*PolyGamma[2, a] +
     85680*PolyGamma[0, a]^13*PolyGamma[1, a]*PolyGamma[2, a] +
     3341520*PolyGamma[0, a]^11*PolyGamma[1, a]^2*PolyGamma[2, a] +
     61261200*PolyGamma[0, a]^9*PolyGamma[1, a]^3*PolyGamma[2, a] +
     551350800*PolyGamma[0, a]^7*PolyGamma[1, a]^4*PolyGamma[2, a] +
     2315673360*PolyGamma[0, a]^5*PolyGamma[1, a]^5*PolyGamma[2, a] +
     3859455600*PolyGamma[0, a]^3*PolyGamma[1, a]^6*PolyGamma[2, a] +
     1654052400*PolyGamma[0, a]*PolyGamma[1, a]^7*PolyGamma[2, a] +
     185640*PolyGamma[0, a]^12*PolyGamma[2, a]^2 +
     12252240*PolyGamma[0, a]^10*PolyGamma[1, a]*PolyGamma[2, a]^2 +
     275675400*PolyGamma[0, a]^8*PolyGamma[1, a]^2*PolyGamma[2, a]^2 +
     2572970400*PolyGamma[0, a]^6*PolyGamma[1, a]^3*PolyGamma[2, a]^2 +
     9648639000*PolyGamma[0, a]^4*PolyGamma[1, a]^4*PolyGamma[2, a]^2 +
     11578366800*PolyGamma[0, a]^2*PolyGamma[1, a]^5*PolyGamma[2, a]^2 +
     1929727800*PolyGamma[1, a]^6*PolyGamma[2, a]^2 +
     13613600*PolyGamma[0, a]^9*PolyGamma[2, a]^3 +
     490089600*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a]^3 +
     5145940800*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[2, a]^3 +
     17153136000*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[2, a]^3 +
     12864852000*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a]^3 +
     285885600*PolyGamma[0, a]^6*PolyGamma[2, a]^4 +
     4288284000*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]^4 +
     12864852000*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]^4 +
     4288284000*PolyGamma[1, a]^3*PolyGamma[2, a]^4 +
     1143542400*PolyGamma[0, a]^3*PolyGamma[2, a]^5 +
     3430627200*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^5 +
     190590400*PolyGamma[2, a]^6 + 3060*PolyGamma[0, a]^14*PolyGamma[3, a] +
     278460*PolyGamma[0, a]^12*PolyGamma[1, a]*PolyGamma[3, a] +
     9189180*PolyGamma[0, a]^10*PolyGamma[1, a]^2*PolyGamma[3, a] +
     137837700*PolyGamma[0, a]^8*PolyGamma[1, a]^3*PolyGamma[3, a] +
     964863900*PolyGamma[0, a]^6*PolyGamma[1, a]^4*PolyGamma[3, a] +
     2894591700*PolyGamma[0, a]^4*PolyGamma[1, a]^5*PolyGamma[3, a] +
     2894591700*PolyGamma[0, a]^2*PolyGamma[1, a]^6*PolyGamma[3, a] +
     413513100*PolyGamma[1, a]^7*PolyGamma[3, a] + 1113840*PolyGamma[0, a]^11*
      PolyGamma[2, a]*PolyGamma[3, a] + 61261200*PolyGamma[0, a]^9*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a] +
     1102701600*PolyGamma[0, a]^7*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a] + 7718911200*PolyGamma[0, a]^5*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a] + 19297278000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^4*PolyGamma[2, a]*PolyGamma[3, a] +
     11578366800*PolyGamma[0, a]*PolyGamma[1, a]^5*PolyGamma[2, a]*
      PolyGamma[3, a] + 91891800*PolyGamma[0, a]^8*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 2572970400*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 19297278000*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a] +
     38594556000*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 9648639000*PolyGamma[1, a]^4*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 1715313600*PolyGamma[0, a]^5*PolyGamma[2, a]^3*
      PolyGamma[3, a] + 17153136000*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]^3*PolyGamma[3, a] + 25729704000*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]^3*PolyGamma[3, a] +
     4288284000*PolyGamma[0, a]^2*PolyGamma[2, a]^4*PolyGamma[3, a] +
     4288284000*PolyGamma[1, a]*PolyGamma[2, a]^4*PolyGamma[3, a] +
     1531530*PolyGamma[0, a]^10*PolyGamma[3, a]^2 +
     68918850*PolyGamma[0, a]^8*PolyGamma[1, a]*PolyGamma[3, a]^2 +
     964863900*PolyGamma[0, a]^6*PolyGamma[1, a]^2*PolyGamma[3, a]^2 +
     4824319500*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[3, a]^2 +
     7236479250*PolyGamma[0, a]^2*PolyGamma[1, a]^4*PolyGamma[3, a]^2 +
     1447295850*PolyGamma[1, a]^5*PolyGamma[3, a]^2 +
     183783600*PolyGamma[0, a]^7*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     3859455600*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 19297278000*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 19297278000*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     3216213000*PolyGamma[0, a]^4*PolyGamma[2, a]^2*PolyGamma[3, a]^2 +
     19297278000*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]^2 + 9648639000*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[3, a]^2 + 4288284000*PolyGamma[0, a]*PolyGamma[2, a]^3*
      PolyGamma[3, a]^2 + 107207100*PolyGamma[0, a]^6*PolyGamma[3, a]^3 +
     1608106500*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[3, a]^3 +
     4824319500*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[3, a]^3 +
     1608106500*PolyGamma[1, a]^3*PolyGamma[3, a]^3 +
     2144142000*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]^3 +
     6432426000*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]^3 + 1072071000*PolyGamma[2, a]^2*PolyGamma[3, a]^3 +
     402026625*PolyGamma[0, a]^2*PolyGamma[3, a]^4 +
     402026625*PolyGamma[1, a]*PolyGamma[3, a]^4 + 8568*PolyGamma[0, a]^13*
      PolyGamma[4, a] + 668304*PolyGamma[0, a]^11*PolyGamma[1, a]*
      PolyGamma[4, a] + 18378360*PolyGamma[0, a]^9*PolyGamma[1, a]^2*
      PolyGamma[4, a] + 220540320*PolyGamma[0, a]^7*PolyGamma[1, a]^3*
      PolyGamma[4, a] + 1157836680*PolyGamma[0, a]^5*PolyGamma[1, a]^4*
      PolyGamma[4, a] + 2315673360*PolyGamma[0, a]^3*PolyGamma[1, a]^5*
      PolyGamma[4, a] + 1157836680*PolyGamma[0, a]*PolyGamma[1, a]^6*
      PolyGamma[4, a] + 2450448*PolyGamma[0, a]^10*PolyGamma[2, a]*
      PolyGamma[4, a] + 110270160*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[4, a] + 1543782240*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[4, a] +
     7718911200*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[4, a] + 11578366800*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[4, a] + 2315673360*PolyGamma[1, a]^5*
      PolyGamma[2, a]*PolyGamma[4, a] + 147026880*PolyGamma[0, a]^7*
      PolyGamma[2, a]^2*PolyGamma[4, a] + 3087564480*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[4, a] +
     15437822400*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 15437822400*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2*PolyGamma[4, a] + 1715313600*PolyGamma[0, a]^4*
      PolyGamma[2, a]^3*PolyGamma[4, a] + 10291881600*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[4, a] +
     5145940800*PolyGamma[1, a]^2*PolyGamma[2, a]^3*PolyGamma[4, a] +
     1715313600*PolyGamma[0, a]*PolyGamma[2, a]^4*PolyGamma[4, a] +
     6126120*PolyGamma[0, a]^9*PolyGamma[3, a]*PolyGamma[4, a] +
     220540320*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 2315673360*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a] + 7718911200*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[4, a] +
     5789183400*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[3, a]*
      PolyGamma[4, a] + 514594080*PolyGamma[0, a]^6*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 7718911200*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     23156733600*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 7718911200*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     5145940800*PolyGamma[0, a]^3*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 15437822400*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[4, a] +
     1715313600*PolyGamma[2, a]^3*PolyGamma[3, a]*PolyGamma[4, a] +
     385945560*PolyGamma[0, a]^5*PolyGamma[3, a]^2*PolyGamma[4, a] +
     3859455600*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 5789183400*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 3859455600*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[4, a] +
     3859455600*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 643242600*PolyGamma[0, a]*PolyGamma[3, a]^3*
      PolyGamma[4, a] + 5513508*PolyGamma[0, a]^8*PolyGamma[4, a]^2 +
     154378224*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[4, a]^2 +
     1157836680*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[4, a]^2 +
     2315673360*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[4, a]^2 +
     578918340*PolyGamma[1, a]^4*PolyGamma[4, a]^2 +
     308756448*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[4, a]^2 +
     3087564480*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]^2 + 4631346720*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 1543782240*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[4, a]^2 + 1543782240*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[4, a]^2 + 385945560*PolyGamma[0, a]^4*
      PolyGamma[3, a]*PolyGamma[4, a]^2 + 2315673360*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     1157836680*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     1543782240*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[4, a]^2 + 192972780*PolyGamma[3, a]^2*PolyGamma[4, a]^2 +
     102918816*PolyGamma[0, a]^3*PolyGamma[4, a]^3 +
     308756448*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]^3 +
     102918816*PolyGamma[2, a]*PolyGamma[4, a]^3 + 18564*PolyGamma[0, a]^12*
      PolyGamma[5, a] + 1225224*PolyGamma[0, a]^10*PolyGamma[1, a]*
      PolyGamma[5, a] + 27567540*PolyGamma[0, a]^8*PolyGamma[1, a]^2*
      PolyGamma[5, a] + 257297040*PolyGamma[0, a]^6*PolyGamma[1, a]^3*
      PolyGamma[5, a] + 964863900*PolyGamma[0, a]^4*PolyGamma[1, a]^4*
      PolyGamma[5, a] + 1157836680*PolyGamma[0, a]^2*PolyGamma[1, a]^5*
      PolyGamma[5, a] + 192972780*PolyGamma[1, a]^6*PolyGamma[5, a] +
     4084080*PolyGamma[0, a]^9*PolyGamma[2, a]*PolyGamma[5, a] +
     147026880*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a] + 1543782240*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[5, a] + 5145940800*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[5, a] +
     3859455600*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[5, a] + 171531360*PolyGamma[0, a]^6*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 2572970400*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 7718911200*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[5, a] +
     2572970400*PolyGamma[1, a]^3*PolyGamma[2, a]^2*PolyGamma[5, a] +
     1143542400*PolyGamma[0, a]^3*PolyGamma[2, a]^3*PolyGamma[5, a] +
     3430627200*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^3*
      PolyGamma[5, a] + 285885600*PolyGamma[2, a]^4*PolyGamma[5, a] +
     9189180*PolyGamma[0, a]^8*PolyGamma[3, a]*PolyGamma[5, a] +
     257297040*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 1929727800*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[5, a] + 3859455600*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[5, a] +
     964863900*PolyGamma[1, a]^4*PolyGamma[3, a]*PolyGamma[5, a] +
     514594080*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 5145940800*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     7718911200*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 2572970400*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     2572970400*PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[5, a] + 321621300*PolyGamma[0, a]^4*PolyGamma[3, a]^2*
      PolyGamma[5, a] + 1929727800*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[5, a] + 964863900*PolyGamma[1, a]^2*
      PolyGamma[3, a]^2*PolyGamma[5, a] + 1286485200*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[5, a] +
     107207100*PolyGamma[3, a]^3*PolyGamma[5, a] + 14702688*PolyGamma[0, a]^7*
      PolyGamma[4, a]*PolyGamma[5, a] + 308756448*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     1543782240*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[4, a]*
      PolyGamma[5, a] + 1543782240*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[4, a]*PolyGamma[5, a] + 514594080*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     3087564480*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 1543782240*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     1029188160*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[4, a]*
      PolyGamma[5, a] + 514594080*PolyGamma[0, a]^3*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 1543782240*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     514594080*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 154378224*PolyGamma[0, a]^2*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 154378224*PolyGamma[1, a]*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 8576568*PolyGamma[0, a]^6*PolyGamma[5, a]^2 +
     128648520*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[5, a]^2 +
     385945560*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[5, a]^2 +
     128648520*PolyGamma[1, a]^3*PolyGamma[5, a]^2 +
     171531360*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[5, a]^2 +
     514594080*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a]^2 + 85765680*PolyGamma[2, a]^2*PolyGamma[5, a]^2 +
     128648520*PolyGamma[0, a]^2*PolyGamma[3, a]*PolyGamma[5, a]^2 +
     128648520*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[5, a]^2 +
     51459408*PolyGamma[0, a]*PolyGamma[4, a]*PolyGamma[5, a]^2 +
     2858856*PolyGamma[5, a]^3 + 31824*PolyGamma[0, a]^11*PolyGamma[6, a] +
     1750320*PolyGamma[0, a]^9*PolyGamma[1, a]*PolyGamma[6, a] +
     31505760*PolyGamma[0, a]^7*PolyGamma[1, a]^2*PolyGamma[6, a] +
     220540320*PolyGamma[0, a]^5*PolyGamma[1, a]^3*PolyGamma[6, a] +
     551350800*PolyGamma[0, a]^3*PolyGamma[1, a]^4*PolyGamma[6, a] +
     330810480*PolyGamma[0, a]*PolyGamma[1, a]^5*PolyGamma[6, a] +
     5250960*PolyGamma[0, a]^8*PolyGamma[2, a]*PolyGamma[6, a] +
     147026880*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[6, a] + 1102701600*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[6, a] + 2205403200*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[6, a] +
     551350800*PolyGamma[1, a]^4*PolyGamma[2, a]*PolyGamma[6, a] +
     147026880*PolyGamma[0, a]^5*PolyGamma[2, a]^2*PolyGamma[6, a] +
     1470268800*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[6, a] + 2205403200*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 490089600*PolyGamma[0, a]^2*
      PolyGamma[2, a]^3*PolyGamma[6, a] + 490089600*PolyGamma[1, a]*
      PolyGamma[2, a]^3*PolyGamma[6, a] + 10501920*PolyGamma[0, a]^7*
      PolyGamma[3, a]*PolyGamma[6, a] + 220540320*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     1102701600*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[6, a] + 1102701600*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[3, a]*PolyGamma[6, a] + 367567200*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     2205403200*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[6, a] + 1102701600*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     735134400*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[6, a] + 183783600*PolyGamma[0, a]^3*PolyGamma[3, a]^2*
      PolyGamma[6, a] + 551350800*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[6, a] + 183783600*PolyGamma[2, a]*
      PolyGamma[3, a]^2*PolyGamma[6, a] + 14702688*PolyGamma[0, a]^6*
      PolyGamma[4, a]*PolyGamma[6, a] + 220540320*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     661620960*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[4, a]*
      PolyGamma[6, a] + 220540320*PolyGamma[1, a]^3*PolyGamma[4, a]*
      PolyGamma[6, a] + 294053760*PolyGamma[0, a]^3*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 882161280*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     147026880*PolyGamma[2, a]^2*PolyGamma[4, a]*PolyGamma[6, a] +
     220540320*PolyGamma[0, a]^2*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 220540320*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 44108064*PolyGamma[0, a]*
      PolyGamma[4, a]^2*PolyGamma[6, a] + 14702688*PolyGamma[0, a]^5*
      PolyGamma[5, a]*PolyGamma[6, a] + 147026880*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     220540320*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[5, a]*
      PolyGamma[6, a] + 147026880*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 147026880*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     73513440*PolyGamma[0, a]*PolyGamma[3, a]*PolyGamma[5, a]*
      PolyGamma[6, a] + 14702688*PolyGamma[4, a]*PolyGamma[5, a]*
      PolyGamma[6, a] + 5250960*PolyGamma[0, a]^4*PolyGamma[6, a]^2 +
     31505760*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[6, a]^2 +
     15752880*PolyGamma[1, a]^2*PolyGamma[6, a]^2 +
     21003840*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[6, a]^2 +
     5250960*PolyGamma[3, a]*PolyGamma[6, a]^2 + 43758*PolyGamma[0, a]^10*
      PolyGamma[7, a] + 1969110*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[7, a] + 27567540*PolyGamma[0, a]^6*PolyGamma[1, a]^2*
      PolyGamma[7, a] + 137837700*PolyGamma[0, a]^4*PolyGamma[1, a]^3*
      PolyGamma[7, a] + 206756550*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[7, a] + 41351310*PolyGamma[1, a]^5*PolyGamma[7, a] +
     5250960*PolyGamma[0, a]^7*PolyGamma[2, a]*PolyGamma[7, a] +
     110270160*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[7, a] + 551350800*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[7, a] + 551350800*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[7, a] +
     91891800*PolyGamma[0, a]^4*PolyGamma[2, a]^2*PolyGamma[7, a] +
     551350800*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[7, a] + 275675400*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[7, a] + 122522400*PolyGamma[0, a]*PolyGamma[2, a]^3*
      PolyGamma[7, a] + 9189180*PolyGamma[0, a]^6*PolyGamma[3, a]*
      PolyGamma[7, a] + 137837700*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[7, a] + 413513100*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[7, a] +
     137837700*PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[7, a] +
     183783600*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 551350800*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     91891800*PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[7, a] +
     68918850*PolyGamma[0, a]^2*PolyGamma[3, a]^2*PolyGamma[7, a] +
     68918850*PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[7, a] +
     11027016*PolyGamma[0, a]^5*PolyGamma[4, a]*PolyGamma[7, a] +
     110270160*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[7, a] + 165405240*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[7, a] + 110270160*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     110270160*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[7, a] + 55135080*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[7, a] + 5513508*PolyGamma[4, a]^2*
      PolyGamma[7, a] + 9189180*PolyGamma[0, a]^4*PolyGamma[5, a]*
      PolyGamma[7, a] + 55135080*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[7, a] + 27567540*PolyGamma[1, a]^2*
      PolyGamma[5, a]*PolyGamma[7, a] + 36756720*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     9189180*PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     5250960*PolyGamma[0, a]^3*PolyGamma[6, a]*PolyGamma[7, a] +
     15752880*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[6, a]*
      PolyGamma[7, a] + 5250960*PolyGamma[2, a]*PolyGamma[6, a]*
      PolyGamma[7, a] + 984555*PolyGamma[0, a]^2*PolyGamma[7, a]^2 +
     984555*PolyGamma[1, a]*PolyGamma[7, a]^2 + 48620*PolyGamma[0, a]^9*
      PolyGamma[8, a] + 1750320*PolyGamma[0, a]^7*PolyGamma[1, a]*
      PolyGamma[8, a] + 18378360*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[8, a] + 61261200*PolyGamma[0, a]^3*PolyGamma[1, a]^3*
      PolyGamma[8, a] + 45945900*PolyGamma[0, a]*PolyGamma[1, a]^4*
      PolyGamma[8, a] + 4084080*PolyGamma[0, a]^6*PolyGamma[2, a]*
      PolyGamma[8, a] + 61261200*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[8, a] + 183783600*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[8, a] +
     61261200*PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[8, a] +
     40840800*PolyGamma[0, a]^3*PolyGamma[2, a]^2*PolyGamma[8, a] +
     122522400*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[8, a] + 13613600*PolyGamma[2, a]^3*PolyGamma[8, a] +
     6126120*PolyGamma[0, a]^5*PolyGamma[3, a]*PolyGamma[8, a] +
     61261200*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 91891800*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[8, a] + 61261200*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[8, a] +
     61261200*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 15315300*PolyGamma[0, a]*PolyGamma[3, a]^2*
      PolyGamma[8, a] + 6126120*PolyGamma[0, a]^4*PolyGamma[4, a]*
      PolyGamma[8, a] + 36756720*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[4, a]*PolyGamma[8, a] + 18378360*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[8, a] + 24504480*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[8, a] +
     6126120*PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[8, a] +
     4084080*PolyGamma[0, a]^3*PolyGamma[5, a]*PolyGamma[8, a] +
     12252240*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[5, a]*
      PolyGamma[8, a] + 4084080*PolyGamma[2, a]*PolyGamma[5, a]*
      PolyGamma[8, a] + 1750320*PolyGamma[0, a]^2*PolyGamma[6, a]*
      PolyGamma[8, a] + 1750320*PolyGamma[1, a]*PolyGamma[6, a]*
      PolyGamma[8, a] + 437580*PolyGamma[0, a]*PolyGamma[7, a]*
      PolyGamma[8, a] + 24310*PolyGamma[8, a]^2 + 43758*PolyGamma[0, a]^8*
      PolyGamma[9, a] + 1225224*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[9, a] + 9189180*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[9, a] + 18378360*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[9, a] + 4594590*PolyGamma[1, a]^4*PolyGamma[9, a] +
     2450448*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[9, a] +
     24504480*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[9, a] + 36756720*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[9, a] + 12252240*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[9, a] + 12252240*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[9, a] + 3063060*PolyGamma[0, a]^4*
      PolyGamma[3, a]*PolyGamma[9, a] + 18378360*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[9, a] +
     9189180*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[9, a] +
     12252240*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[9, a] + 1531530*PolyGamma[3, a]^2*PolyGamma[9, a] +
     2450448*PolyGamma[0, a]^3*PolyGamma[4, a]*PolyGamma[9, a] +
     7351344*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[9, a] + 2450448*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[9, a] + 1225224*PolyGamma[0, a]^2*PolyGamma[5, a]*
      PolyGamma[9, a] + 1225224*PolyGamma[1, a]*PolyGamma[5, a]*
      PolyGamma[9, a] + 350064*PolyGamma[0, a]*PolyGamma[6, a]*
      PolyGamma[9, a] + 43758*PolyGamma[7, a]*PolyGamma[9, a] +
     31824*PolyGamma[0, a]^7*PolyGamma[10, a] + 668304*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[10, a] + 3341520*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[10, a] + 3341520*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[10, a] + 1113840*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[10, a] + 6683040*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[10, a] +
     3341520*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[10, a] +
     2227680*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[10, a] +
     1113840*PolyGamma[0, a]^3*PolyGamma[3, a]*PolyGamma[10, a] +
     3341520*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[10, a] + 1113840*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[10, a] + 668304*PolyGamma[0, a]^2*PolyGamma[4, a]*
      PolyGamma[10, a] + 668304*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[10, a] + 222768*PolyGamma[0, a]*PolyGamma[5, a]*
      PolyGamma[10, a] + 31824*PolyGamma[6, a]*PolyGamma[10, a] +
     18564*PolyGamma[0, a]^6*PolyGamma[11, a] + 278460*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[11, a] + 835380*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[11, a] + 278460*PolyGamma[1, a]^3*
      PolyGamma[11, a] + 371280*PolyGamma[0, a]^3*PolyGamma[2, a]*
      PolyGamma[11, a] + 1113840*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[11, a] + 185640*PolyGamma[2, a]^2*
      PolyGamma[11, a] + 278460*PolyGamma[0, a]^2*PolyGamma[3, a]*
      PolyGamma[11, a] + 278460*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[11, a] + 111384*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[11, a] + 18564*PolyGamma[5, a]*PolyGamma[11, a] +
     8568*PolyGamma[0, a]^5*PolyGamma[12, a] + 85680*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[12, a] + 128520*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[12, a] + 85680*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[12, a] + 85680*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[12, a] + 42840*PolyGamma[0, a]*
      PolyGamma[3, a]*PolyGamma[12, a] + 8568*PolyGamma[4, a]*
      PolyGamma[12, a] + 3060*PolyGamma[0, a]^4*PolyGamma[13, a] +
     18360*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[13, a] +
     9180*PolyGamma[1, a]^2*PolyGamma[13, a] + 12240*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[13, a] + 3060*PolyGamma[3, a]*
      PolyGamma[13, a] + 816*PolyGamma[0, a]^3*PolyGamma[14, a] +
     2448*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[14, a] +
     816*PolyGamma[2, a]*PolyGamma[14, a] + 153*PolyGamma[0, a]^2*
      PolyGamma[15, a] + 153*PolyGamma[1, a]*PolyGamma[15, a] +
     18*PolyGamma[0, a]*PolyGamma[16, a] + PolyGamma[17, a]

MBexpGam[a_, 19] = PolyGamma[0, a]^19 + 171*PolyGamma[0, a]^17*
      PolyGamma[1, a] + 11628*PolyGamma[0, a]^15*PolyGamma[1, a]^2 +
     406980*PolyGamma[0, a]^13*PolyGamma[1, a]^3 + 7936110*PolyGamma[0, a]^11*
      PolyGamma[1, a]^4 + 87297210*PolyGamma[0, a]^9*PolyGamma[1, a]^5 +
     523783260*PolyGamma[0, a]^7*PolyGamma[1, a]^6 +
     1571349780*PolyGamma[0, a]^5*PolyGamma[1, a]^7 +
     1964187225*PolyGamma[0, a]^3*PolyGamma[1, a]^8 +
     654729075*PolyGamma[0, a]*PolyGamma[1, a]^9 + 969*PolyGamma[0, a]^16*
      PolyGamma[2, a] + 116280*PolyGamma[0, a]^14*PolyGamma[1, a]*
      PolyGamma[2, a] + 5290740*PolyGamma[0, a]^12*PolyGamma[1, a]^2*
      PolyGamma[2, a] + 116396280*PolyGamma[0, a]^10*PolyGamma[1, a]^3*
      PolyGamma[2, a] + 1309458150*PolyGamma[0, a]^8*PolyGamma[1, a]^4*
      PolyGamma[2, a] + 7332965640*PolyGamma[0, a]^6*PolyGamma[1, a]^5*
      PolyGamma[2, a] + 18332414100*PolyGamma[0, a]^4*PolyGamma[1, a]^6*
      PolyGamma[2, a] + 15713497800*PolyGamma[0, a]^2*PolyGamma[1, a]^7*
      PolyGamma[2, a] + 1964187225*PolyGamma[1, a]^8*PolyGamma[2, a] +
     271320*PolyGamma[0, a]^13*PolyGamma[2, a]^2 +
     21162960*PolyGamma[0, a]^11*PolyGamma[1, a]*PolyGamma[2, a]^2 +
     581981400*PolyGamma[0, a]^9*PolyGamma[1, a]^2*PolyGamma[2, a]^2 +
     6983776800*PolyGamma[0, a]^7*PolyGamma[1, a]^3*PolyGamma[2, a]^2 +
     36664828200*PolyGamma[0, a]^5*PolyGamma[1, a]^4*PolyGamma[2, a]^2 +
     73329656400*PolyGamma[0, a]^3*PolyGamma[1, a]^5*PolyGamma[2, a]^2 +
     36664828200*PolyGamma[0, a]*PolyGamma[1, a]^6*PolyGamma[2, a]^2 +
     25865840*PolyGamma[0, a]^10*PolyGamma[2, a]^3 +
     1163962800*PolyGamma[0, a]^8*PolyGamma[1, a]*PolyGamma[2, a]^3 +
     16295479200*PolyGamma[0, a]^6*PolyGamma[1, a]^2*PolyGamma[2, a]^3 +
     81477396000*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[2, a]^3 +
     122216094000*PolyGamma[0, a]^2*PolyGamma[1, a]^4*PolyGamma[2, a]^3 +
     24443218800*PolyGamma[1, a]^5*PolyGamma[2, a]^3 +
     775975200*PolyGamma[0, a]^7*PolyGamma[2, a]^4 +
     16295479200*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]^4 +
     81477396000*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]^4 +
     81477396000*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[2, a]^4 +
     5431826400*PolyGamma[0, a]^4*PolyGamma[2, a]^5 +
     32590958400*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^5 +
     16295479200*PolyGamma[1, a]^2*PolyGamma[2, a]^5 +
     3621217600*PolyGamma[0, a]*PolyGamma[2, a]^6 +
     3876*PolyGamma[0, a]^15*PolyGamma[3, a] + 406980*PolyGamma[0, a]^13*
      PolyGamma[1, a]*PolyGamma[3, a] + 15872220*PolyGamma[0, a]^11*
      PolyGamma[1, a]^2*PolyGamma[3, a] + 290990700*PolyGamma[0, a]^9*
      PolyGamma[1, a]^3*PolyGamma[3, a] + 2618916300*PolyGamma[0, a]^7*
      PolyGamma[1, a]^4*PolyGamma[3, a] + 10999448460*PolyGamma[0, a]^5*
      PolyGamma[1, a]^5*PolyGamma[3, a] + 18332414100*PolyGamma[0, a]^3*
      PolyGamma[1, a]^6*PolyGamma[3, a] + 7856748900*PolyGamma[0, a]*
      PolyGamma[1, a]^7*PolyGamma[3, a] + 1763580*PolyGamma[0, a]^12*
      PolyGamma[2, a]*PolyGamma[3, a] + 116396280*PolyGamma[0, a]^10*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a] +
     2618916300*PolyGamma[0, a]^8*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a] + 24443218800*PolyGamma[0, a]^6*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a] + 91662070500*PolyGamma[0, a]^4*
      PolyGamma[1, a]^4*PolyGamma[2, a]*PolyGamma[3, a] +
     109994484600*PolyGamma[0, a]^2*PolyGamma[1, a]^5*PolyGamma[2, a]*
      PolyGamma[3, a] + 18332414100*PolyGamma[1, a]^6*PolyGamma[2, a]*
      PolyGamma[3, a] + 193993800*PolyGamma[0, a]^9*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 6983776800*PolyGamma[0, a]^7*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 73329656400*PolyGamma[0, a]^5*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a] +
     244432188000*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 183324141000*PolyGamma[0, a]*PolyGamma[1, a]^4*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 5431826400*PolyGamma[0, a]^6*
      PolyGamma[2, a]^3*PolyGamma[3, a] + 81477396000*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[3, a] +
     244432188000*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]^3*
      PolyGamma[3, a] + 81477396000*PolyGamma[1, a]^3*PolyGamma[2, a]^3*
      PolyGamma[3, a] + 27159132000*PolyGamma[0, a]^3*PolyGamma[2, a]^4*
      PolyGamma[3, a] + 81477396000*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^4*PolyGamma[3, a] + 5431826400*PolyGamma[2, a]^5*
      PolyGamma[3, a] + 2645370*PolyGamma[0, a]^11*PolyGamma[3, a]^2 +
     145495350*PolyGamma[0, a]^9*PolyGamma[1, a]*PolyGamma[3, a]^2 +
     2618916300*PolyGamma[0, a]^7*PolyGamma[1, a]^2*PolyGamma[3, a]^2 +
     18332414100*PolyGamma[0, a]^5*PolyGamma[1, a]^3*PolyGamma[3, a]^2 +
     45831035250*PolyGamma[0, a]^3*PolyGamma[1, a]^4*PolyGamma[3, a]^2 +
     27498621150*PolyGamma[0, a]*PolyGamma[1, a]^5*PolyGamma[3, a]^2 +
     436486050*PolyGamma[0, a]^8*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     12221609400*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 91662070500*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 183324141000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     45831035250*PolyGamma[1, a]^4*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     12221609400*PolyGamma[0, a]^5*PolyGamma[2, a]^2*PolyGamma[3, a]^2 +
     122216094000*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]^2 + 183324141000*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[3, a]^2 + 40738698000*PolyGamma[0, a]^2*
      PolyGamma[2, a]^3*PolyGamma[3, a]^2 + 40738698000*PolyGamma[1, a]*
      PolyGamma[2, a]^3*PolyGamma[3, a]^2 + 290990700*PolyGamma[0, a]^7*
      PolyGamma[3, a]^3 + 6110804700*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[3, a]^3 + 30554023500*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[3, a]^3 + 30554023500*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[3, a]^3 + 10184674500*PolyGamma[0, a]^4*PolyGamma[2, a]*
      PolyGamma[3, a]^3 + 61108047000*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^3 + 30554023500*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^3 + 20369349000*PolyGamma[0, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]^3 + 2546168625*PolyGamma[0, a]^3*
      PolyGamma[3, a]^4 + 7638505875*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[3, a]^4 + 2546168625*PolyGamma[2, a]*PolyGamma[3, a]^4 +
     11628*PolyGamma[0, a]^14*PolyGamma[4, a] + 1058148*PolyGamma[0, a]^12*
      PolyGamma[1, a]*PolyGamma[4, a] + 34918884*PolyGamma[0, a]^10*
      PolyGamma[1, a]^2*PolyGamma[4, a] + 523783260*PolyGamma[0, a]^8*
      PolyGamma[1, a]^3*PolyGamma[4, a] + 3666482820*PolyGamma[0, a]^6*
      PolyGamma[1, a]^4*PolyGamma[4, a] + 10999448460*PolyGamma[0, a]^4*
      PolyGamma[1, a]^5*PolyGamma[4, a] + 10999448460*PolyGamma[0, a]^2*
      PolyGamma[1, a]^6*PolyGamma[4, a] + 1571349780*PolyGamma[1, a]^7*
      PolyGamma[4, a] + 4232592*PolyGamma[0, a]^11*PolyGamma[2, a]*
      PolyGamma[4, a] + 232792560*PolyGamma[0, a]^9*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[4, a] + 4190266080*PolyGamma[0, a]^7*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[4, a] +
     29331862560*PolyGamma[0, a]^5*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[4, a] + 73329656400*PolyGamma[0, a]^3*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[4, a] + 43997793840*PolyGamma[0, a]*
      PolyGamma[1, a]^5*PolyGamma[2, a]*PolyGamma[4, a] +
     349188840*PolyGamma[0, a]^8*PolyGamma[2, a]^2*PolyGamma[4, a] +
     9777287520*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 73329656400*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[4, a] + 146659312800*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[2, a]^2*PolyGamma[4, a] +
     36664828200*PolyGamma[1, a]^4*PolyGamma[2, a]^2*PolyGamma[4, a] +
     6518191680*PolyGamma[0, a]^5*PolyGamma[2, a]^3*PolyGamma[4, a] +
     65181916800*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]^3*
      PolyGamma[4, a] + 97772875200*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]^3*PolyGamma[4, a] + 16295479200*PolyGamma[0, a]^2*
      PolyGamma[2, a]^4*PolyGamma[4, a] + 16295479200*PolyGamma[1, a]*
      PolyGamma[2, a]^4*PolyGamma[4, a] + 11639628*PolyGamma[0, a]^10*
      PolyGamma[3, a]*PolyGamma[4, a] + 523783260*PolyGamma[0, a]^8*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     7332965640*PolyGamma[0, a]^6*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 36664828200*PolyGamma[0, a]^4*PolyGamma[1, a]^3*
      PolyGamma[3, a]*PolyGamma[4, a] + 54997242300*PolyGamma[0, a]^2*
      PolyGamma[1, a]^4*PolyGamma[3, a]*PolyGamma[4, a] +
     10999448460*PolyGamma[1, a]^5*PolyGamma[3, a]*PolyGamma[4, a] +
     1396755360*PolyGamma[0, a]^7*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 29331862560*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     146659312800*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 146659312800*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     24443218800*PolyGamma[0, a]^4*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 146659312800*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[4, a] +
     73329656400*PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 32590958400*PolyGamma[0, a]*PolyGamma[2, a]^3*
      PolyGamma[3, a]*PolyGamma[4, a] + 1222160940*PolyGamma[0, a]^6*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 18332414100*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[4, a] +
     54997242300*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 18332414100*PolyGamma[1, a]^3*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 24443218800*PolyGamma[0, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 73329656400*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[4, a] +
     12221609400*PolyGamma[2, a]^2*PolyGamma[3, a]^2*PolyGamma[4, a] +
     6110804700*PolyGamma[0, a]^2*PolyGamma[3, a]^3*PolyGamma[4, a] +
     6110804700*PolyGamma[1, a]*PolyGamma[3, a]^3*PolyGamma[4, a] +
     11639628*PolyGamma[0, a]^9*PolyGamma[4, a]^2 +
     419026608*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[4, a]^2 +
     4399779384*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[4, a]^2 +
     14665931280*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[4, a]^2 +
     10999448460*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[4, a]^2 +
     977728752*PolyGamma[0, a]^6*PolyGamma[2, a]*PolyGamma[4, a]^2 +
     14665931280*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]^2 + 43997793840*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 14665931280*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 9777287520*PolyGamma[0, a]^3*
      PolyGamma[2, a]^2*PolyGamma[4, a]^2 + 29331862560*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[4, a]^2 +
     3259095840*PolyGamma[2, a]^3*PolyGamma[4, a]^2 +
     1466593128*PolyGamma[0, a]^5*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     14665931280*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[4, a]^2 + 21998896920*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a]^2 + 14665931280*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     14665931280*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[4, a]^2 + 3666482820*PolyGamma[0, a]*PolyGamma[3, a]^2*
      PolyGamma[4, a]^2 + 488864376*PolyGamma[0, a]^4*PolyGamma[4, a]^3 +
     2933186256*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[4, a]^3 +
     1466593128*PolyGamma[1, a]^2*PolyGamma[4, a]^3 +
     1955457504*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[4, a]^3 +
     488864376*PolyGamma[3, a]*PolyGamma[4, a]^3 + 27132*PolyGamma[0, a]^13*
      PolyGamma[5, a] + 2116296*PolyGamma[0, a]^11*PolyGamma[1, a]*
      PolyGamma[5, a] + 58198140*PolyGamma[0, a]^9*PolyGamma[1, a]^2*
      PolyGamma[5, a] + 698377680*PolyGamma[0, a]^7*PolyGamma[1, a]^3*
      PolyGamma[5, a] + 3666482820*PolyGamma[0, a]^5*PolyGamma[1, a]^4*
      PolyGamma[5, a] + 7332965640*PolyGamma[0, a]^3*PolyGamma[1, a]^5*
      PolyGamma[5, a] + 3666482820*PolyGamma[0, a]*PolyGamma[1, a]^6*
      PolyGamma[5, a] + 7759752*PolyGamma[0, a]^10*PolyGamma[2, a]*
      PolyGamma[5, a] + 349188840*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[5, a] + 4888643760*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[5, a] +
     24443218800*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[5, a] + 36664828200*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[5, a] + 7332965640*PolyGamma[1, a]^5*
      PolyGamma[2, a]*PolyGamma[5, a] + 465585120*PolyGamma[0, a]^7*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 9777287520*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[5, a] +
     48886437600*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 48886437600*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 5431826400*PolyGamma[0, a]^4*
      PolyGamma[2, a]^3*PolyGamma[5, a] + 32590958400*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[5, a] +
     16295479200*PolyGamma[1, a]^2*PolyGamma[2, a]^3*PolyGamma[5, a] +
     5431826400*PolyGamma[0, a]*PolyGamma[2, a]^4*PolyGamma[5, a] +
     19399380*PolyGamma[0, a]^9*PolyGamma[3, a]*PolyGamma[5, a] +
     698377680*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[5, a] + 7332965640*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[5, a] + 24443218800*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[5, a] +
     18332414100*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[3, a]*
      PolyGamma[5, a] + 1629547920*PolyGamma[0, a]^6*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 24443218800*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     73329656400*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 24443218800*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     16295479200*PolyGamma[0, a]^3*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[5, a] + 48886437600*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     5431826400*PolyGamma[2, a]^3*PolyGamma[3, a]*PolyGamma[5, a] +
     1222160940*PolyGamma[0, a]^5*PolyGamma[3, a]^2*PolyGamma[5, a] +
     12221609400*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[3, a]^2*
      PolyGamma[5, a] + 18332414100*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[3, a]^2*PolyGamma[5, a] + 12221609400*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[5, a] +
     12221609400*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]^2*
      PolyGamma[5, a] + 2036934900*PolyGamma[0, a]*PolyGamma[3, a]^3*
      PolyGamma[5, a] + 34918884*PolyGamma[0, a]^8*PolyGamma[4, a]*
      PolyGamma[5, a] + 977728752*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 7332965640*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[4, a]*PolyGamma[5, a] +
     14665931280*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[4, a]*
      PolyGamma[5, a] + 3666482820*PolyGamma[1, a]^4*PolyGamma[4, a]*
      PolyGamma[5, a] + 1955457504*PolyGamma[0, a]^5*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 19554575040*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     29331862560*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 9777287520*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[4, a]*PolyGamma[5, a] +
     9777287520*PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[4, a]*
      PolyGamma[5, a] + 2444321880*PolyGamma[0, a]^4*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 14665931280*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     7332965640*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 9777287520*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     1222160940*PolyGamma[3, a]^2*PolyGamma[4, a]*PolyGamma[5, a] +
     977728752*PolyGamma[0, a]^3*PolyGamma[4, a]^2*PolyGamma[5, a] +
     2933186256*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 977728752*PolyGamma[2, a]*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 23279256*PolyGamma[0, a]^7*PolyGamma[5, a]^2 +
     488864376*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[5, a]^2 +
     2444321880*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[5, a]^2 +
     2444321880*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[5, a]^2 +
     814773960*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[5, a]^2 +
     4888643760*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a]^2 + 2444321880*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[5, a]^2 + 1629547920*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[5, a]^2 + 814773960*PolyGamma[0, a]^3*PolyGamma[3, a]*
      PolyGamma[5, a]^2 + 2444321880*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[5, a]^2 + 814773960*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a]^2 + 488864376*PolyGamma[0, a]^2*
      PolyGamma[4, a]*PolyGamma[5, a]^2 + 488864376*PolyGamma[1, a]*
      PolyGamma[4, a]*PolyGamma[5, a]^2 + 54318264*PolyGamma[0, a]*
      PolyGamma[5, a]^3 + 50388*PolyGamma[0, a]^12*PolyGamma[6, a] +
     3325608*PolyGamma[0, a]^10*PolyGamma[1, a]*PolyGamma[6, a] +
     74826180*PolyGamma[0, a]^8*PolyGamma[1, a]^2*PolyGamma[6, a] +
     698377680*PolyGamma[0, a]^6*PolyGamma[1, a]^3*PolyGamma[6, a] +
     2618916300*PolyGamma[0, a]^4*PolyGamma[1, a]^4*PolyGamma[6, a] +
     3142699560*PolyGamma[0, a]^2*PolyGamma[1, a]^5*PolyGamma[6, a] +
     523783260*PolyGamma[1, a]^6*PolyGamma[6, a] + 11085360*PolyGamma[0, a]^9*
      PolyGamma[2, a]*PolyGamma[6, a] + 399072960*PolyGamma[0, a]^7*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[6, a] +
     4190266080*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[6, a] + 13967553600*PolyGamma[0, a]^3*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[6, a] + 10475665200*PolyGamma[0, a]*
      PolyGamma[1, a]^4*PolyGamma[2, a]*PolyGamma[6, a] +
     465585120*PolyGamma[0, a]^6*PolyGamma[2, a]^2*PolyGamma[6, a] +
     6983776800*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[6, a] + 20951330400*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 6983776800*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 3103900800*PolyGamma[0, a]^3*
      PolyGamma[2, a]^3*PolyGamma[6, a] + 9311702400*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[6, a] +
     775975200*PolyGamma[2, a]^4*PolyGamma[6, a] + 24942060*PolyGamma[0, a]^8*
      PolyGamma[3, a]*PolyGamma[6, a] + 698377680*PolyGamma[0, a]^6*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     5237832600*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[6, a] + 10475665200*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[3, a]*PolyGamma[6, a] + 2618916300*PolyGamma[1, a]^4*
      PolyGamma[3, a]*PolyGamma[6, a] + 1396755360*PolyGamma[0, a]^5*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     13967553600*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[6, a] + 20951330400*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     6983776800*PolyGamma[0, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[6, a] + 6983776800*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]*PolyGamma[6, a] + 872972100*PolyGamma[0, a]^4*
      PolyGamma[3, a]^2*PolyGamma[6, a] + 5237832600*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[6, a] +
     2618916300*PolyGamma[1, a]^2*PolyGamma[3, a]^2*PolyGamma[6, a] +
     3491888400*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]^2*
      PolyGamma[6, a] + 290990700*PolyGamma[3, a]^3*PolyGamma[6, a] +
     39907296*PolyGamma[0, a]^7*PolyGamma[4, a]*PolyGamma[6, a] +
     838053216*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 4190266080*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[6, a] + 4190266080*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[4, a]*PolyGamma[6, a] +
     1396755360*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 8380532160*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     4190266080*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 2793510720*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[4, a]*PolyGamma[6, a] + 1396755360*PolyGamma[0, a]^3*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     4190266080*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 1396755360*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     419026608*PolyGamma[0, a]^2*PolyGamma[4, a]^2*PolyGamma[6, a] +
     419026608*PolyGamma[1, a]*PolyGamma[4, a]^2*PolyGamma[6, a] +
     46558512*PolyGamma[0, a]^6*PolyGamma[5, a]*PolyGamma[6, a] +
     698377680*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[5, a]*
      PolyGamma[6, a] + 2095133040*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[5, a]*PolyGamma[6, a] + 698377680*PolyGamma[1, a]^3*
      PolyGamma[5, a]*PolyGamma[6, a] + 931170240*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     2793510720*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 465585120*PolyGamma[2, a]^2*
      PolyGamma[5, a]*PolyGamma[6, a] + 698377680*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     698377680*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[5, a]*
      PolyGamma[6, a] + 279351072*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 23279256*PolyGamma[5, a]^2*
      PolyGamma[6, a] + 19953648*PolyGamma[0, a]^5*PolyGamma[6, a]^2 +
     199536480*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[6, a]^2 +
     299304720*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[6, a]^2 +
     199536480*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[6, a]^2 +
     199536480*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[6, a]^2 +
     99768240*PolyGamma[0, a]*PolyGamma[3, a]*PolyGamma[6, a]^2 +
     19953648*PolyGamma[4, a]*PolyGamma[6, a]^2 + 75582*PolyGamma[0, a]^11*
      PolyGamma[7, a] + 4157010*PolyGamma[0, a]^9*PolyGamma[1, a]*
      PolyGamma[7, a] + 74826180*PolyGamma[0, a]^7*PolyGamma[1, a]^2*
      PolyGamma[7, a] + 523783260*PolyGamma[0, a]^5*PolyGamma[1, a]^3*
      PolyGamma[7, a] + 1309458150*PolyGamma[0, a]^3*PolyGamma[1, a]^4*
      PolyGamma[7, a] + 785674890*PolyGamma[0, a]*PolyGamma[1, a]^5*
      PolyGamma[7, a] + 12471030*PolyGamma[0, a]^8*PolyGamma[2, a]*
      PolyGamma[7, a] + 349188840*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[7, a] + 2618916300*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[7, a] +
     5237832600*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[7, a] + 1309458150*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[7, a] + 349188840*PolyGamma[0, a]^5*PolyGamma[2, a]^2*
      PolyGamma[7, a] + 3491888400*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[7, a] + 5237832600*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[7, a] +
     1163962800*PolyGamma[0, a]^2*PolyGamma[2, a]^3*PolyGamma[7, a] +
     1163962800*PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[7, a] +
     24942060*PolyGamma[0, a]^7*PolyGamma[3, a]*PolyGamma[7, a] +
     523783260*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 2618916300*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[7, a] + 2618916300*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[7, a] +
     872972100*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 5237832600*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     2618916300*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 1745944200*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]*PolyGamma[7, a] + 436486050*PolyGamma[0, a]^3*
      PolyGamma[3, a]^2*PolyGamma[7, a] + 1309458150*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[7, a] +
     436486050*PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[7, a] +
     34918884*PolyGamma[0, a]^6*PolyGamma[4, a]*PolyGamma[7, a] +
     523783260*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[7, a] + 1571349780*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[7, a] + 523783260*PolyGamma[1, a]^3*
      PolyGamma[4, a]*PolyGamma[7, a] + 698377680*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     2095133040*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[7, a] + 349188840*PolyGamma[2, a]^2*
      PolyGamma[4, a]*PolyGamma[7, a] + 523783260*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     523783260*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[7, a] + 104756652*PolyGamma[0, a]*PolyGamma[4, a]^2*
      PolyGamma[7, a] + 34918884*PolyGamma[0, a]^5*PolyGamma[5, a]*
      PolyGamma[7, a] + 349188840*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[7, a] + 523783260*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[5, a]*PolyGamma[7, a] +
     349188840*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[5, a]*
      PolyGamma[7, a] + 349188840*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a]*PolyGamma[7, a] + 174594420*PolyGamma[0, a]*
      PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     34918884*PolyGamma[4, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     24942060*PolyGamma[0, a]^4*PolyGamma[6, a]*PolyGamma[7, a] +
     149652360*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[6, a]*
      PolyGamma[7, a] + 74826180*PolyGamma[1, a]^2*PolyGamma[6, a]*
      PolyGamma[7, a] + 99768240*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[6, a]*PolyGamma[7, a] + 24942060*PolyGamma[3, a]*
      PolyGamma[6, a]*PolyGamma[7, a] + 6235515*PolyGamma[0, a]^3*
      PolyGamma[7, a]^2 + 18706545*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[7, a]^2 + 6235515*PolyGamma[2, a]*PolyGamma[7, a]^2 +
     92378*PolyGamma[0, a]^10*PolyGamma[8, a] + 4157010*PolyGamma[0, a]^8*
      PolyGamma[1, a]*PolyGamma[8, a] + 58198140*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[8, a] + 290990700*PolyGamma[0, a]^4*
      PolyGamma[1, a]^3*PolyGamma[8, a] + 436486050*PolyGamma[0, a]^2*
      PolyGamma[1, a]^4*PolyGamma[8, a] + 87297210*PolyGamma[1, a]^5*
      PolyGamma[8, a] + 11085360*PolyGamma[0, a]^7*PolyGamma[2, a]*
      PolyGamma[8, a] + 232792560*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[8, a] + 1163962800*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[8, a] +
     1163962800*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[8, a] + 193993800*PolyGamma[0, a]^4*PolyGamma[2, a]^2*
      PolyGamma[8, a] + 1163962800*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[8, a] + 581981400*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[8, a] + 258658400*PolyGamma[0, a]*
      PolyGamma[2, a]^3*PolyGamma[8, a] + 19399380*PolyGamma[0, a]^6*
      PolyGamma[3, a]*PolyGamma[8, a] + 290990700*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[8, a] +
     872972100*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[8, a] + 290990700*PolyGamma[1, a]^3*PolyGamma[3, a]*
      PolyGamma[8, a] + 387987600*PolyGamma[0, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[8, a] + 1163962800*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[8, a] +
     193993800*PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[8, a] +
     145495350*PolyGamma[0, a]^2*PolyGamma[3, a]^2*PolyGamma[8, a] +
     145495350*PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[8, a] +
     23279256*PolyGamma[0, a]^5*PolyGamma[4, a]*PolyGamma[8, a] +
     232792560*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[8, a] + 349188840*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[8, a] + 232792560*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[8, a] +
     232792560*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[8, a] + 116396280*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[8, a] + 11639628*PolyGamma[4, a]^2*
      PolyGamma[8, a] + 19399380*PolyGamma[0, a]^4*PolyGamma[5, a]*
      PolyGamma[8, a] + 116396280*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[8, a] + 58198140*PolyGamma[1, a]^2*
      PolyGamma[5, a]*PolyGamma[8, a] + 77597520*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[8, a] +
     19399380*PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[8, a] +
     11085360*PolyGamma[0, a]^3*PolyGamma[6, a]*PolyGamma[8, a] +
     33256080*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[6, a]*
      PolyGamma[8, a] + 11085360*PolyGamma[2, a]*PolyGamma[6, a]*
      PolyGamma[8, a] + 4157010*PolyGamma[0, a]^2*PolyGamma[7, a]*
      PolyGamma[8, a] + 4157010*PolyGamma[1, a]*PolyGamma[7, a]*
      PolyGamma[8, a] + 461890*PolyGamma[0, a]*PolyGamma[8, a]^2 +
     92378*PolyGamma[0, a]^9*PolyGamma[9, a] + 3325608*PolyGamma[0, a]^7*
      PolyGamma[1, a]*PolyGamma[9, a] + 34918884*PolyGamma[0, a]^5*
      PolyGamma[1, a]^2*PolyGamma[9, a] + 116396280*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[9, a] + 87297210*PolyGamma[0, a]*
      PolyGamma[1, a]^4*PolyGamma[9, a] + 7759752*PolyGamma[0, a]^6*
      PolyGamma[2, a]*PolyGamma[9, a] + 116396280*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[9, a] +
     349188840*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[9, a] + 116396280*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[9, a] + 77597520*PolyGamma[0, a]^3*PolyGamma[2, a]^2*
      PolyGamma[9, a] + 232792560*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[9, a] + 25865840*PolyGamma[2, a]^3*
      PolyGamma[9, a] + 11639628*PolyGamma[0, a]^5*PolyGamma[3, a]*
      PolyGamma[9, a] + 116396280*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[9, a] + 174594420*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[9, a] +
     116396280*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[9, a] + 116396280*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[9, a] + 29099070*PolyGamma[0, a]*
      PolyGamma[3, a]^2*PolyGamma[9, a] + 11639628*PolyGamma[0, a]^4*
      PolyGamma[4, a]*PolyGamma[9, a] + 69837768*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[9, a] +
     34918884*PolyGamma[1, a]^2*PolyGamma[4, a]*PolyGamma[9, a] +
     46558512*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[9, a] + 11639628*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[9, a] + 7759752*PolyGamma[0, a]^3*PolyGamma[5, a]*
      PolyGamma[9, a] + 23279256*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[9, a] + 7759752*PolyGamma[2, a]*
      PolyGamma[5, a]*PolyGamma[9, a] + 3325608*PolyGamma[0, a]^2*
      PolyGamma[6, a]*PolyGamma[9, a] + 3325608*PolyGamma[1, a]*
      PolyGamma[6, a]*PolyGamma[9, a] + 831402*PolyGamma[0, a]*
      PolyGamma[7, a]*PolyGamma[9, a] + 92378*PolyGamma[8, a]*
      PolyGamma[9, a] + 75582*PolyGamma[0, a]^8*PolyGamma[10, a] +
     2116296*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[10, a] +
     15872220*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[10, a] +
     31744440*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[10, a] +
     7936110*PolyGamma[1, a]^4*PolyGamma[10, a] + 4232592*PolyGamma[0, a]^5*
      PolyGamma[2, a]*PolyGamma[10, a] + 42325920*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[10, a] +
     63488880*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[10, a] + 21162960*PolyGamma[0, a]^2*PolyGamma[2, a]^2*
      PolyGamma[10, a] + 21162960*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[10, a] + 5290740*PolyGamma[0, a]^4*PolyGamma[3, a]*
      PolyGamma[10, a] + 31744440*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[10, a] + 15872220*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[10, a] + 21162960*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[10, a] +
     2645370*PolyGamma[3, a]^2*PolyGamma[10, a] + 4232592*PolyGamma[0, a]^3*
      PolyGamma[4, a]*PolyGamma[10, a] + 12697776*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[10, a] +
     4232592*PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[10, a] +
     2116296*PolyGamma[0, a]^2*PolyGamma[5, a]*PolyGamma[10, a] +
     2116296*PolyGamma[1, a]*PolyGamma[5, a]*PolyGamma[10, a] +
     604656*PolyGamma[0, a]*PolyGamma[6, a]*PolyGamma[10, a] +
     75582*PolyGamma[7, a]*PolyGamma[10, a] + 50388*PolyGamma[0, a]^7*
      PolyGamma[11, a] + 1058148*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[11, a] + 5290740*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[11, a] + 5290740*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[11, a] + 1763580*PolyGamma[0, a]^4*PolyGamma[2, a]*
      PolyGamma[11, a] + 10581480*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[11, a] + 5290740*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[11, a] + 3527160*PolyGamma[0, a]*
      PolyGamma[2, a]^2*PolyGamma[11, a] + 1763580*PolyGamma[0, a]^3*
      PolyGamma[3, a]*PolyGamma[11, a] + 5290740*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[11, a] +
     1763580*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[11, a] +
     1058148*PolyGamma[0, a]^2*PolyGamma[4, a]*PolyGamma[11, a] +
     1058148*PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[11, a] +
     352716*PolyGamma[0, a]*PolyGamma[5, a]*PolyGamma[11, a] +
     50388*PolyGamma[6, a]*PolyGamma[11, a] + 27132*PolyGamma[0, a]^6*
      PolyGamma[12, a] + 406980*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[12, a] + 1220940*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[12, a] + 406980*PolyGamma[1, a]^3*PolyGamma[12, a] +
     542640*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[12, a] +
     1627920*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[12, a] + 271320*PolyGamma[2, a]^2*PolyGamma[12, a] +
     406980*PolyGamma[0, a]^2*PolyGamma[3, a]*PolyGamma[12, a] +
     406980*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[12, a] +
     162792*PolyGamma[0, a]*PolyGamma[4, a]*PolyGamma[12, a] +
     27132*PolyGamma[5, a]*PolyGamma[12, a] + 11628*PolyGamma[0, a]^5*
      PolyGamma[13, a] + 116280*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[13, a] + 174420*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[13, a] + 116280*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[13, a] + 116280*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[13, a] + 58140*PolyGamma[0, a]*PolyGamma[3, a]*
      PolyGamma[13, a] + 11628*PolyGamma[4, a]*PolyGamma[13, a] +
     3876*PolyGamma[0, a]^4*PolyGamma[14, a] + 23256*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[14, a] + 11628*PolyGamma[1, a]^2*
      PolyGamma[14, a] + 15504*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[14, a] + 3876*PolyGamma[3, a]*PolyGamma[14, a] +
     969*PolyGamma[0, a]^3*PolyGamma[15, a] + 2907*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[15, a] + 969*PolyGamma[2, a]*
      PolyGamma[15, a] + 171*PolyGamma[0, a]^2*PolyGamma[16, a] +
     171*PolyGamma[1, a]*PolyGamma[16, a] + 19*PolyGamma[0, a]*
      PolyGamma[17, a] + PolyGamma[18, a]

MBexpGam[a_, 20] = PolyGamma[0, a]^20 + 190*PolyGamma[0, a]^18*
      PolyGamma[1, a] + 14535*PolyGamma[0, a]^16*PolyGamma[1, a]^2 +
     581400*PolyGamma[0, a]^14*PolyGamma[1, a]^3 +
     13226850*PolyGamma[0, a]^12*PolyGamma[1, a]^4 +
     174594420*PolyGamma[0, a]^10*PolyGamma[1, a]^5 +
     1309458150*PolyGamma[0, a]^8*PolyGamma[1, a]^6 +
     5237832600*PolyGamma[0, a]^6*PolyGamma[1, a]^7 +
     9820936125*PolyGamma[0, a]^4*PolyGamma[1, a]^8 +
     6547290750*PolyGamma[0, a]^2*PolyGamma[1, a]^9 +
     654729075*PolyGamma[1, a]^10 + 1140*PolyGamma[0, a]^17*PolyGamma[2, a] +
     155040*PolyGamma[0, a]^15*PolyGamma[1, a]*PolyGamma[2, a] +
     8139600*PolyGamma[0, a]^13*PolyGamma[1, a]^2*PolyGamma[2, a] +
     211629600*PolyGamma[0, a]^11*PolyGamma[1, a]^3*PolyGamma[2, a] +
     2909907000*PolyGamma[0, a]^9*PolyGamma[1, a]^4*PolyGamma[2, a] +
     20951330400*PolyGamma[0, a]^7*PolyGamma[1, a]^5*PolyGamma[2, a] +
     73329656400*PolyGamma[0, a]^5*PolyGamma[1, a]^6*PolyGamma[2, a] +
     104756652000*PolyGamma[0, a]^3*PolyGamma[1, a]^7*PolyGamma[2, a] +
     39283744500*PolyGamma[0, a]*PolyGamma[1, a]^8*PolyGamma[2, a] +
     387600*PolyGamma[0, a]^14*PolyGamma[2, a]^2 +
     35271600*PolyGamma[0, a]^12*PolyGamma[1, a]*PolyGamma[2, a]^2 +
     1163962800*PolyGamma[0, a]^10*PolyGamma[1, a]^2*PolyGamma[2, a]^2 +
     17459442000*PolyGamma[0, a]^8*PolyGamma[1, a]^3*PolyGamma[2, a]^2 +
     122216094000*PolyGamma[0, a]^6*PolyGamma[1, a]^4*PolyGamma[2, a]^2 +
     366648282000*PolyGamma[0, a]^4*PolyGamma[1, a]^5*PolyGamma[2, a]^2 +
     366648282000*PolyGamma[0, a]^2*PolyGamma[1, a]^6*PolyGamma[2, a]^2 +
     52378326000*PolyGamma[1, a]^7*PolyGamma[2, a]^2 +
     47028800*PolyGamma[0, a]^11*PolyGamma[2, a]^3 +
     2586584000*PolyGamma[0, a]^9*PolyGamma[1, a]*PolyGamma[2, a]^3 +
     46558512000*PolyGamma[0, a]^7*PolyGamma[1, a]^2*PolyGamma[2, a]^3 +
     325909584000*PolyGamma[0, a]^5*PolyGamma[1, a]^3*PolyGamma[2, a]^3 +
     814773960000*PolyGamma[0, a]^3*PolyGamma[1, a]^4*PolyGamma[2, a]^3 +
     488864376000*PolyGamma[0, a]*PolyGamma[1, a]^5*PolyGamma[2, a]^3 +
     1939938000*PolyGamma[0, a]^8*PolyGamma[2, a]^4 +
     54318264000*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[2, a]^4 +
     407386980000*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[2, a]^4 +
     814773960000*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[2, a]^4 +
     203693490000*PolyGamma[1, a]^4*PolyGamma[2, a]^4 +
     21727305600*PolyGamma[0, a]^5*PolyGamma[2, a]^5 +
     217273056000*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]^5 +
     325909584000*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]^5 +
     36212176000*PolyGamma[0, a]^2*PolyGamma[2, a]^6 +
     36212176000*PolyGamma[1, a]*PolyGamma[2, a]^6 +
     4845*PolyGamma[0, a]^16*PolyGamma[3, a] + 581400*PolyGamma[0, a]^14*
      PolyGamma[1, a]*PolyGamma[3, a] + 26453700*PolyGamma[0, a]^12*
      PolyGamma[1, a]^2*PolyGamma[3, a] + 581981400*PolyGamma[0, a]^10*
      PolyGamma[1, a]^3*PolyGamma[3, a] + 6547290750*PolyGamma[0, a]^8*
      PolyGamma[1, a]^4*PolyGamma[3, a] + 36664828200*PolyGamma[0, a]^6*
      PolyGamma[1, a]^5*PolyGamma[3, a] + 91662070500*PolyGamma[0, a]^4*
      PolyGamma[1, a]^6*PolyGamma[3, a] + 78567489000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^7*PolyGamma[3, a] + 9820936125*PolyGamma[1, a]^8*
      PolyGamma[3, a] + 2713200*PolyGamma[0, a]^13*PolyGamma[2, a]*
      PolyGamma[3, a] + 211629600*PolyGamma[0, a]^11*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a] + 5819814000*PolyGamma[0, a]^9*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a] +
     69837768000*PolyGamma[0, a]^7*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a] + 366648282000*PolyGamma[0, a]^5*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[3, a] + 733296564000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^5*PolyGamma[2, a]*PolyGamma[3, a] +
     366648282000*PolyGamma[0, a]*PolyGamma[1, a]^6*PolyGamma[2, a]*
      PolyGamma[3, a] + 387987600*PolyGamma[0, a]^10*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 17459442000*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 244432188000*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a] +
     1222160940000*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[2, a]^2*
      PolyGamma[3, a] + 1833241410000*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 366648282000*PolyGamma[1, a]^5*
      PolyGamma[2, a]^2*PolyGamma[3, a] + 15519504000*PolyGamma[0, a]^7*
      PolyGamma[2, a]^3*PolyGamma[3, a] + 325909584000*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[3, a] +
     1629547920000*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]^3*
      PolyGamma[3, a] + 1629547920000*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[2, a]^3*PolyGamma[3, a] + 135795660000*PolyGamma[0, a]^4*
      PolyGamma[2, a]^4*PolyGamma[3, a] + 814773960000*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]^4*PolyGamma[3, a] +
     407386980000*PolyGamma[1, a]^2*PolyGamma[2, a]^4*PolyGamma[3, a] +
     108636528000*PolyGamma[0, a]*PolyGamma[2, a]^5*PolyGamma[3, a] +
     4408950*PolyGamma[0, a]^12*PolyGamma[3, a]^2 +
     290990700*PolyGamma[0, a]^10*PolyGamma[1, a]*PolyGamma[3, a]^2 +
     6547290750*PolyGamma[0, a]^8*PolyGamma[1, a]^2*PolyGamma[3, a]^2 +
     61108047000*PolyGamma[0, a]^6*PolyGamma[1, a]^3*PolyGamma[3, a]^2 +
     229155176250*PolyGamma[0, a]^4*PolyGamma[1, a]^4*PolyGamma[3, a]^2 +
     274986211500*PolyGamma[0, a]^2*PolyGamma[1, a]^5*PolyGamma[3, a]^2 +
     45831035250*PolyGamma[1, a]^6*PolyGamma[3, a]^2 +
     969969000*PolyGamma[0, a]^9*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     34918884000*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 366648282000*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^2 + 1222160940000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[3, a]^2 +
     916620705000*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[3, a]^2 + 40738698000*PolyGamma[0, a]^6*PolyGamma[2, a]^2*
      PolyGamma[3, a]^2 + 611080470000*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]^2 + 1833241410000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[3, a]^2 +
     611080470000*PolyGamma[1, a]^3*PolyGamma[2, a]^2*PolyGamma[3, a]^2 +
     271591320000*PolyGamma[0, a]^3*PolyGamma[2, a]^3*PolyGamma[3, a]^2 +
     814773960000*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^3*
      PolyGamma[3, a]^2 + 67897830000*PolyGamma[2, a]^4*PolyGamma[3, a]^2 +
     727476750*PolyGamma[0, a]^8*PolyGamma[3, a]^3 +
     20369349000*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[3, a]^3 +
     152770117500*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[3, a]^3 +
     305540235000*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[3, a]^3 +
     76385058750*PolyGamma[1, a]^4*PolyGamma[3, a]^3 +
     40738698000*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[3, a]^3 +
     407386980000*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]^3 + 611080470000*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^3 + 203693490000*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[3, a]^3 + 203693490000*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]^3 + 12730843125*PolyGamma[0, a]^4*
      PolyGamma[3, a]^4 + 76385058750*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a]^4 + 38192529375*PolyGamma[1, a]^2*PolyGamma[3, a]^4 +
     50923372500*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]^4 +
     2546168625*PolyGamma[3, a]^5 + 15504*PolyGamma[0, a]^15*
      PolyGamma[4, a] + 1627920*PolyGamma[0, a]^13*PolyGamma[1, a]*
      PolyGamma[4, a] + 63488880*PolyGamma[0, a]^11*PolyGamma[1, a]^2*
      PolyGamma[4, a] + 1163962800*PolyGamma[0, a]^9*PolyGamma[1, a]^3*
      PolyGamma[4, a] + 10475665200*PolyGamma[0, a]^7*PolyGamma[1, a]^4*
      PolyGamma[4, a] + 43997793840*PolyGamma[0, a]^5*PolyGamma[1, a]^5*
      PolyGamma[4, a] + 73329656400*PolyGamma[0, a]^3*PolyGamma[1, a]^6*
      PolyGamma[4, a] + 31426995600*PolyGamma[0, a]*PolyGamma[1, a]^7*
      PolyGamma[4, a] + 7054320*PolyGamma[0, a]^12*PolyGamma[2, a]*
      PolyGamma[4, a] + 465585120*PolyGamma[0, a]^10*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[4, a] + 10475665200*PolyGamma[0, a]^8*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[4, a] +
     97772875200*PolyGamma[0, a]^6*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[4, a] + 366648282000*PolyGamma[0, a]^4*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[4, a] + 439977938400*PolyGamma[0, a]^2*
      PolyGamma[1, a]^5*PolyGamma[2, a]*PolyGamma[4, a] +
     73329656400*PolyGamma[1, a]^6*PolyGamma[2, a]*PolyGamma[4, a] +
     775975200*PolyGamma[0, a]^9*PolyGamma[2, a]^2*PolyGamma[4, a] +
     27935107200*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 293318625600*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[4, a] + 977728752000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[2, a]^2*PolyGamma[4, a] +
     733296564000*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a]^2*
      PolyGamma[4, a] + 21727305600*PolyGamma[0, a]^6*PolyGamma[2, a]^3*
      PolyGamma[4, a] + 325909584000*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]^3*PolyGamma[4, a] + 977728752000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]^3*PolyGamma[4, a] +
     325909584000*PolyGamma[1, a]^3*PolyGamma[2, a]^3*PolyGamma[4, a] +
     108636528000*PolyGamma[0, a]^3*PolyGamma[2, a]^4*PolyGamma[4, a] +
     325909584000*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^4*
      PolyGamma[4, a] + 21727305600*PolyGamma[2, a]^5*PolyGamma[4, a] +
     21162960*PolyGamma[0, a]^11*PolyGamma[3, a]*PolyGamma[4, a] +
     1163962800*PolyGamma[0, a]^9*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[4, a] + 20951330400*PolyGamma[0, a]^7*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a] + 146659312800*PolyGamma[0, a]^5*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[4, a] +
     366648282000*PolyGamma[0, a]^3*PolyGamma[1, a]^4*PolyGamma[3, a]*
      PolyGamma[4, a] + 219988969200*PolyGamma[0, a]*PolyGamma[1, a]^5*
      PolyGamma[3, a]*PolyGamma[4, a] + 3491888400*PolyGamma[0, a]^8*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     97772875200*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 733296564000*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     1466593128000*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a] + 366648282000*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a] +
     97772875200*PolyGamma[0, a]^5*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a] + 977728752000*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[4, a] +
     1466593128000*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a] + 325909584000*PolyGamma[0, a]^2*
      PolyGamma[2, a]^3*PolyGamma[3, a]*PolyGamma[4, a] +
     325909584000*PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[3, a]*
      PolyGamma[4, a] + 3491888400*PolyGamma[0, a]^7*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 73329656400*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 366648282000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[3, a]^2*PolyGamma[4, a] +
     366648282000*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 122216094000*PolyGamma[0, a]^4*PolyGamma[2, a]*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 733296564000*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[4, a] +
     366648282000*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]^2*
      PolyGamma[4, a] + 244432188000*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]^2*PolyGamma[4, a] + 40738698000*PolyGamma[0, a]^3*
      PolyGamma[3, a]^3*PolyGamma[4, a] + 122216094000*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]^3*PolyGamma[4, a] +
     40738698000*PolyGamma[2, a]*PolyGamma[3, a]^3*PolyGamma[4, a] +
     23279256*PolyGamma[0, a]^10*PolyGamma[4, a]^2 +
     1047566520*PolyGamma[0, a]^8*PolyGamma[1, a]*PolyGamma[4, a]^2 +
     14665931280*PolyGamma[0, a]^6*PolyGamma[1, a]^2*PolyGamma[4, a]^2 +
     73329656400*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[4, a]^2 +
     109994484600*PolyGamma[0, a]^2*PolyGamma[1, a]^4*PolyGamma[4, a]^2 +
     21998896920*PolyGamma[1, a]^5*PolyGamma[4, a]^2 +
     2793510720*PolyGamma[0, a]^7*PolyGamma[2, a]*PolyGamma[4, a]^2 +
     58663725120*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]^2 + 293318625600*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]^2 + 293318625600*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[4, a]^2 +
     48886437600*PolyGamma[0, a]^4*PolyGamma[2, a]^2*PolyGamma[4, a]^2 +
     293318625600*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[4, a]^2 + 146659312800*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[4, a]^2 + 65181916800*PolyGamma[0, a]*PolyGamma[2, a]^3*
      PolyGamma[4, a]^2 + 4888643760*PolyGamma[0, a]^6*PolyGamma[3, a]*
      PolyGamma[4, a]^2 + 73329656400*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[4, a]^2 + 219988969200*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     73329656400*PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     97772875200*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[4, a]^2 + 293318625600*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     48886437600*PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[4, a]^2 +
     36664828200*PolyGamma[0, a]^2*PolyGamma[3, a]^2*PolyGamma[4, a]^2 +
     36664828200*PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[4, a]^2 +
     1955457504*PolyGamma[0, a]^5*PolyGamma[4, a]^3 +
     19554575040*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[4, a]^3 +
     29331862560*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[4, a]^3 +
     19554575040*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[4, a]^3 +
     19554575040*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]^3 +
     9777287520*PolyGamma[0, a]*PolyGamma[3, a]*PolyGamma[4, a]^3 +
     488864376*PolyGamma[4, a]^4 + 38760*PolyGamma[0, a]^14*PolyGamma[5, a] +
     3527160*PolyGamma[0, a]^12*PolyGamma[1, a]*PolyGamma[5, a] +
     116396280*PolyGamma[0, a]^10*PolyGamma[1, a]^2*PolyGamma[5, a] +
     1745944200*PolyGamma[0, a]^8*PolyGamma[1, a]^3*PolyGamma[5, a] +
     12221609400*PolyGamma[0, a]^6*PolyGamma[1, a]^4*PolyGamma[5, a] +
     36664828200*PolyGamma[0, a]^4*PolyGamma[1, a]^5*PolyGamma[5, a] +
     36664828200*PolyGamma[0, a]^2*PolyGamma[1, a]^6*PolyGamma[5, a] +
     5237832600*PolyGamma[1, a]^7*PolyGamma[5, a] +
     14108640*PolyGamma[0, a]^11*PolyGamma[2, a]*PolyGamma[5, a] +
     775975200*PolyGamma[0, a]^9*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a] + 13967553600*PolyGamma[0, a]^7*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[5, a] + 97772875200*PolyGamma[0, a]^5*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[5, a] +
     244432188000*PolyGamma[0, a]^3*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[5, a] + 146659312800*PolyGamma[0, a]*PolyGamma[1, a]^5*
      PolyGamma[2, a]*PolyGamma[5, a] + 1163962800*PolyGamma[0, a]^8*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 32590958400*PolyGamma[0, a]^6*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[5, a] +
     244432188000*PolyGamma[0, a]^4*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[5, a] + 488864376000*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 122216094000*PolyGamma[1, a]^4*
      PolyGamma[2, a]^2*PolyGamma[5, a] + 21727305600*PolyGamma[0, a]^5*
      PolyGamma[2, a]^3*PolyGamma[5, a] + 217273056000*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[5, a] +
     325909584000*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]^3*
      PolyGamma[5, a] + 54318264000*PolyGamma[0, a]^2*PolyGamma[2, a]^4*
      PolyGamma[5, a] + 54318264000*PolyGamma[1, a]*PolyGamma[2, a]^4*
      PolyGamma[5, a] + 38798760*PolyGamma[0, a]^10*PolyGamma[3, a]*
      PolyGamma[5, a] + 1745944200*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 24443218800*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     122216094000*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[3, a]*
      PolyGamma[5, a] + 183324141000*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[3, a]*PolyGamma[5, a] + 36664828200*PolyGamma[1, a]^5*
      PolyGamma[3, a]*PolyGamma[5, a] + 4655851200*PolyGamma[0, a]^7*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     97772875200*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 488864376000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[5, a] +
     488864376000*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a] + 81477396000*PolyGamma[0, a]^4*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     488864376000*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]*PolyGamma[5, a] + 244432188000*PolyGamma[1, a]^2*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[5, a] +
     108636528000*PolyGamma[0, a]*PolyGamma[2, a]^3*PolyGamma[3, a]*
      PolyGamma[5, a] + 4073869800*PolyGamma[0, a]^6*PolyGamma[3, a]^2*
      PolyGamma[5, a] + 61108047000*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[5, a] + 183324141000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[3, a]^2*PolyGamma[5, a] +
     61108047000*PolyGamma[1, a]^3*PolyGamma[3, a]^2*PolyGamma[5, a] +
     81477396000*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[3, a]^2*
      PolyGamma[5, a] + 244432188000*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[5, a] +
     40738698000*PolyGamma[2, a]^2*PolyGamma[3, a]^2*PolyGamma[5, a] +
     20369349000*PolyGamma[0, a]^2*PolyGamma[3, a]^3*PolyGamma[5, a] +
     20369349000*PolyGamma[1, a]*PolyGamma[3, a]^3*PolyGamma[5, a] +
     77597520*PolyGamma[0, a]^9*PolyGamma[4, a]*PolyGamma[5, a] +
     2793510720*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 29331862560*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[5, a] + 97772875200*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[4, a]*PolyGamma[5, a] +
     73329656400*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[4, a]*
      PolyGamma[5, a] + 6518191680*PolyGamma[0, a]^6*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 97772875200*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     293318625600*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 97772875200*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     65181916800*PolyGamma[0, a]^3*PolyGamma[2, a]^2*PolyGamma[4, a]*
      PolyGamma[5, a] + 195545750400*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[4, a]*PolyGamma[5, a] +
     21727305600*PolyGamma[2, a]^3*PolyGamma[4, a]*PolyGamma[5, a] +
     9777287520*PolyGamma[0, a]^5*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[5, a] + 97772875200*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     146659312800*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 97772875200*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[5, a] +
     97772875200*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[5, a] + 24443218800*PolyGamma[0, a]*
      PolyGamma[3, a]^2*PolyGamma[4, a]*PolyGamma[5, a] +
     4888643760*PolyGamma[0, a]^4*PolyGamma[4, a]^2*PolyGamma[5, a] +
     29331862560*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 14665931280*PolyGamma[1, a]^2*PolyGamma[4, a]^2*
      PolyGamma[5, a] + 19554575040*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[4, a]^2*PolyGamma[5, a] + 4888643760*PolyGamma[3, a]*
      PolyGamma[4, a]^2*PolyGamma[5, a] + 58198140*PolyGamma[0, a]^8*
      PolyGamma[5, a]^2 + 1629547920*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[5, a]^2 + 12221609400*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[5, a]^2 + 24443218800*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[5, a]^2 + 6110804700*PolyGamma[1, a]^4*PolyGamma[5, a]^2 +
     3259095840*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[5, a]^2 +
     32590958400*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a]^2 + 48886437600*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[5, a]^2 + 16295479200*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[5, a]^2 + 16295479200*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[5, a]^2 + 4073869800*PolyGamma[0, a]^4*
      PolyGamma[3, a]*PolyGamma[5, a]^2 + 24443218800*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[5, a]^2 +
     12221609400*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[5, a]^2 +
     16295479200*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[5, a]^2 + 2036934900*PolyGamma[3, a]^2*PolyGamma[5, a]^2 +
     3259095840*PolyGamma[0, a]^3*PolyGamma[4, a]*PolyGamma[5, a]^2 +
     9777287520*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[5, a]^2 + 3259095840*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[5, a]^2 + 543182640*PolyGamma[0, a]^2*PolyGamma[5, a]^3 +
     543182640*PolyGamma[1, a]*PolyGamma[5, a]^3 + 77520*PolyGamma[0, a]^13*
      PolyGamma[6, a] + 6046560*PolyGamma[0, a]^11*PolyGamma[1, a]*
      PolyGamma[6, a] + 166280400*PolyGamma[0, a]^9*PolyGamma[1, a]^2*
      PolyGamma[6, a] + 1995364800*PolyGamma[0, a]^7*PolyGamma[1, a]^3*
      PolyGamma[6, a] + 10475665200*PolyGamma[0, a]^5*PolyGamma[1, a]^4*
      PolyGamma[6, a] + 20951330400*PolyGamma[0, a]^3*PolyGamma[1, a]^5*
      PolyGamma[6, a] + 10475665200*PolyGamma[0, a]*PolyGamma[1, a]^6*
      PolyGamma[6, a] + 22170720*PolyGamma[0, a]^10*PolyGamma[2, a]*
      PolyGamma[6, a] + 997682400*PolyGamma[0, a]^8*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[6, a] + 13967553600*PolyGamma[0, a]^6*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[6, a] +
     69837768000*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[6, a] + 104756652000*PolyGamma[0, a]^2*PolyGamma[1, a]^4*
      PolyGamma[2, a]*PolyGamma[6, a] + 20951330400*PolyGamma[1, a]^5*
      PolyGamma[2, a]*PolyGamma[6, a] + 1330243200*PolyGamma[0, a]^7*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 27935107200*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[6, a] +
     139675536000*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]^2*
      PolyGamma[6, a] + 139675536000*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[2, a]^2*PolyGamma[6, a] + 15519504000*PolyGamma[0, a]^4*
      PolyGamma[2, a]^3*PolyGamma[6, a] + 93117024000*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[6, a] +
     46558512000*PolyGamma[1, a]^2*PolyGamma[2, a]^3*PolyGamma[6, a] +
     15519504000*PolyGamma[0, a]*PolyGamma[2, a]^4*PolyGamma[6, a] +
     55426800*PolyGamma[0, a]^9*PolyGamma[3, a]*PolyGamma[6, a] +
     1995364800*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[6, a] + 20951330400*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[6, a] + 69837768000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[6, a] +
     52378326000*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[3, a]*
      PolyGamma[6, a] + 4655851200*PolyGamma[0, a]^6*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[6, a] + 69837768000*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     209513304000*PolyGamma[0, a]^2*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[6, a] + 69837768000*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[6, a] +
     46558512000*PolyGamma[0, a]^3*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[6, a] + 139675536000*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[6, a] +
     15519504000*PolyGamma[2, a]^3*PolyGamma[3, a]*PolyGamma[6, a] +
     3491888400*PolyGamma[0, a]^5*PolyGamma[3, a]^2*PolyGamma[6, a] +
     34918884000*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[3, a]^2*
      PolyGamma[6, a] + 52378326000*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[3, a]^2*PolyGamma[6, a] + 34918884000*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[6, a] +
     34918884000*PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[3, a]^2*
      PolyGamma[6, a] + 5819814000*PolyGamma[0, a]*PolyGamma[3, a]^3*
      PolyGamma[6, a] + 99768240*PolyGamma[0, a]^8*PolyGamma[4, a]*
      PolyGamma[6, a] + 2793510720*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 20951330400*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[4, a]*PolyGamma[6, a] +
     41902660800*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[4, a]*
      PolyGamma[6, a] + 10475665200*PolyGamma[1, a]^4*PolyGamma[4, a]*
      PolyGamma[6, a] + 5587021440*PolyGamma[0, a]^5*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 55870214400*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     83805321600*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 27935107200*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[4, a]*PolyGamma[6, a] +
     27935107200*PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[4, a]*
      PolyGamma[6, a] + 6983776800*PolyGamma[0, a]^4*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[6, a] + 41902660800*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     20951330400*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[6, a] + 27935107200*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[6, a] +
     3491888400*PolyGamma[3, a]^2*PolyGamma[4, a]*PolyGamma[6, a] +
     2793510720*PolyGamma[0, a]^3*PolyGamma[4, a]^2*PolyGamma[6, a] +
     8380532160*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]^2*
      PolyGamma[6, a] + 2793510720*PolyGamma[2, a]*PolyGamma[4, a]^2*
      PolyGamma[6, a] + 133024320*PolyGamma[0, a]^7*PolyGamma[5, a]*
      PolyGamma[6, a] + 2793510720*PolyGamma[0, a]^5*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 13967553600*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[5, a]*PolyGamma[6, a] +
     13967553600*PolyGamma[0, a]*PolyGamma[1, a]^3*PolyGamma[5, a]*
      PolyGamma[6, a] + 4655851200*PolyGamma[0, a]^4*PolyGamma[2, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 27935107200*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     13967553600*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[5, a]*
      PolyGamma[6, a] + 9311702400*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[5, a]*PolyGamma[6, a] + 4655851200*PolyGamma[0, a]^3*
      PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     13967553600*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 4655851200*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[6, a] +
     2793510720*PolyGamma[0, a]^2*PolyGamma[4, a]*PolyGamma[5, a]*
      PolyGamma[6, a] + 2793510720*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[5, a]*PolyGamma[6, a] + 465585120*PolyGamma[0, a]*
      PolyGamma[5, a]^2*PolyGamma[6, a] + 66512160*PolyGamma[0, a]^6*
      PolyGamma[6, a]^2 + 997682400*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[6, a]^2 + 2993047200*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[6, a]^2 + 997682400*PolyGamma[1, a]^3*PolyGamma[6, a]^2 +
     1330243200*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[6, a]^2 +
     3990729600*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[6, a]^2 + 665121600*PolyGamma[2, a]^2*PolyGamma[6, a]^2 +
     997682400*PolyGamma[0, a]^2*PolyGamma[3, a]*PolyGamma[6, a]^2 +
     997682400*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[6, a]^2 +
     399072960*PolyGamma[0, a]*PolyGamma[4, a]*PolyGamma[6, a]^2 +
     66512160*PolyGamma[5, a]*PolyGamma[6, a]^2 + 125970*PolyGamma[0, a]^12*
      PolyGamma[7, a] + 8314020*PolyGamma[0, a]^10*PolyGamma[1, a]*
      PolyGamma[7, a] + 187065450*PolyGamma[0, a]^8*PolyGamma[1, a]^2*
      PolyGamma[7, a] + 1745944200*PolyGamma[0, a]^6*PolyGamma[1, a]^3*
      PolyGamma[7, a] + 6547290750*PolyGamma[0, a]^4*PolyGamma[1, a]^4*
      PolyGamma[7, a] + 7856748900*PolyGamma[0, a]^2*PolyGamma[1, a]^5*
      PolyGamma[7, a] + 1309458150*PolyGamma[1, a]^6*PolyGamma[7, a] +
     27713400*PolyGamma[0, a]^9*PolyGamma[2, a]*PolyGamma[7, a] +
     997682400*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[7, a] + 10475665200*PolyGamma[0, a]^5*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[7, a] + 34918884000*PolyGamma[0, a]^3*
      PolyGamma[1, a]^3*PolyGamma[2, a]*PolyGamma[7, a] +
     26189163000*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[7, a] + 1163962800*PolyGamma[0, a]^6*PolyGamma[2, a]^2*
      PolyGamma[7, a] + 17459442000*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[7, a] + 52378326000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[7, a] +
     17459442000*PolyGamma[1, a]^3*PolyGamma[2, a]^2*PolyGamma[7, a] +
     7759752000*PolyGamma[0, a]^3*PolyGamma[2, a]^3*PolyGamma[7, a] +
     23279256000*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]^3*
      PolyGamma[7, a] + 1939938000*PolyGamma[2, a]^4*PolyGamma[7, a] +
     62355150*PolyGamma[0, a]^8*PolyGamma[3, a]*PolyGamma[7, a] +
     1745944200*PolyGamma[0, a]^6*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 13094581500*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[7, a] + 26189163000*PolyGamma[0, a]^2*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[7, a] +
     6547290750*PolyGamma[1, a]^4*PolyGamma[3, a]*PolyGamma[7, a] +
     3491888400*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[7, a] + 34918884000*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[7, a] +
     52378326000*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[7, a] + 17459442000*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[3, a]*PolyGamma[7, a] +
     17459442000*PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[3, a]*
      PolyGamma[7, a] + 2182430250*PolyGamma[0, a]^4*PolyGamma[3, a]^2*
      PolyGamma[7, a] + 13094581500*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[7, a] + 6547290750*PolyGamma[1, a]^2*
      PolyGamma[3, a]^2*PolyGamma[7, a] + 8729721000*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[7, a] +
     727476750*PolyGamma[3, a]^3*PolyGamma[7, a] + 99768240*PolyGamma[0, a]^7*
      PolyGamma[4, a]*PolyGamma[7, a] + 2095133040*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     10475665200*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[4, a]*
      PolyGamma[7, a] + 10475665200*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[4, a]*PolyGamma[7, a] + 3491888400*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     20951330400*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[7, a] + 10475665200*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     6983776800*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[4, a]*
      PolyGamma[7, a] + 3491888400*PolyGamma[0, a]^3*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[7, a] + 10475665200*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[7, a] +
     3491888400*PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[7, a] + 1047566520*PolyGamma[0, a]^2*PolyGamma[4, a]^2*
      PolyGamma[7, a] + 1047566520*PolyGamma[1, a]*PolyGamma[4, a]^2*
      PolyGamma[7, a] + 116396280*PolyGamma[0, a]^6*PolyGamma[5, a]*
      PolyGamma[7, a] + 1745944200*PolyGamma[0, a]^4*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[7, a] + 5237832600*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[5, a]*PolyGamma[7, a] +
     1745944200*PolyGamma[1, a]^3*PolyGamma[5, a]*PolyGamma[7, a] +
     2327925600*PolyGamma[0, a]^3*PolyGamma[2, a]*PolyGamma[5, a]*
      PolyGamma[7, a] + 6983776800*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     1163962800*PolyGamma[2, a]^2*PolyGamma[5, a]*PolyGamma[7, a] +
     1745944200*PolyGamma[0, a]^2*PolyGamma[3, a]*PolyGamma[5, a]*
      PolyGamma[7, a] + 1745944200*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[5, a]*PolyGamma[7, a] + 698377680*PolyGamma[0, a]*
      PolyGamma[4, a]*PolyGamma[5, a]*PolyGamma[7, a] +
     58198140*PolyGamma[5, a]^2*PolyGamma[7, a] + 99768240*PolyGamma[0, a]^5*
      PolyGamma[6, a]*PolyGamma[7, a] + 997682400*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[6, a]*PolyGamma[7, a] +
     1496523600*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[6, a]*
      PolyGamma[7, a] + 997682400*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[6, a]*PolyGamma[7, a] + 997682400*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[6, a]*PolyGamma[7, a] +
     498841200*PolyGamma[0, a]*PolyGamma[3, a]*PolyGamma[6, a]*
      PolyGamma[7, a] + 99768240*PolyGamma[4, a]*PolyGamma[6, a]*
      PolyGamma[7, a] + 31177575*PolyGamma[0, a]^4*PolyGamma[7, a]^2 +
     187065450*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[7, a]^2 +
     93532725*PolyGamma[1, a]^2*PolyGamma[7, a]^2 +
     124710300*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[7, a]^2 +
     31177575*PolyGamma[3, a]*PolyGamma[7, a]^2 + 167960*PolyGamma[0, a]^11*
      PolyGamma[8, a] + 9237800*PolyGamma[0, a]^9*PolyGamma[1, a]*
      PolyGamma[8, a] + 166280400*PolyGamma[0, a]^7*PolyGamma[1, a]^2*
      PolyGamma[8, a] + 1163962800*PolyGamma[0, a]^5*PolyGamma[1, a]^3*
      PolyGamma[8, a] + 2909907000*PolyGamma[0, a]^3*PolyGamma[1, a]^4*
      PolyGamma[8, a] + 1745944200*PolyGamma[0, a]*PolyGamma[1, a]^5*
      PolyGamma[8, a] + 27713400*PolyGamma[0, a]^8*PolyGamma[2, a]*
      PolyGamma[8, a] + 775975200*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[8, a] + 5819814000*PolyGamma[0, a]^4*
      PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[8, a] +
     11639628000*PolyGamma[0, a]^2*PolyGamma[1, a]^3*PolyGamma[2, a]*
      PolyGamma[8, a] + 2909907000*PolyGamma[1, a]^4*PolyGamma[2, a]*
      PolyGamma[8, a] + 775975200*PolyGamma[0, a]^5*PolyGamma[2, a]^2*
      PolyGamma[8, a] + 7759752000*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[8, a] + 11639628000*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[8, a] +
     2586584000*PolyGamma[0, a]^2*PolyGamma[2, a]^3*PolyGamma[8, a] +
     2586584000*PolyGamma[1, a]*PolyGamma[2, a]^3*PolyGamma[8, a] +
     55426800*PolyGamma[0, a]^7*PolyGamma[3, a]*PolyGamma[8, a] +
     1163962800*PolyGamma[0, a]^5*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 5819814000*PolyGamma[0, a]^3*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[8, a] + 5819814000*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[3, a]*PolyGamma[8, a] +
     1939938000*PolyGamma[0, a]^4*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 11639628000*PolyGamma[0, a]^2*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[8, a] +
     5819814000*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[8, a] + 3879876000*PolyGamma[0, a]*PolyGamma[2, a]^2*
      PolyGamma[3, a]*PolyGamma[8, a] + 969969000*PolyGamma[0, a]^3*
      PolyGamma[3, a]^2*PolyGamma[8, a] + 2909907000*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[3, a]^2*PolyGamma[8, a] +
     969969000*PolyGamma[2, a]*PolyGamma[3, a]^2*PolyGamma[8, a] +
     77597520*PolyGamma[0, a]^6*PolyGamma[4, a]*PolyGamma[8, a] +
     1163962800*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[8, a] + 3491888400*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[4, a]*PolyGamma[8, a] + 1163962800*PolyGamma[1, a]^3*
      PolyGamma[4, a]*PolyGamma[8, a] + 1551950400*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[8, a] +
     4655851200*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[8, a] + 775975200*PolyGamma[2, a]^2*
      PolyGamma[4, a]*PolyGamma[8, a] + 1163962800*PolyGamma[0, a]^2*
      PolyGamma[3, a]*PolyGamma[4, a]*PolyGamma[8, a] +
     1163962800*PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[8, a] + 232792560*PolyGamma[0, a]*PolyGamma[4, a]^2*
      PolyGamma[8, a] + 77597520*PolyGamma[0, a]^5*PolyGamma[5, a]*
      PolyGamma[8, a] + 775975200*PolyGamma[0, a]^3*PolyGamma[1, a]*
      PolyGamma[5, a]*PolyGamma[8, a] + 1163962800*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[5, a]*PolyGamma[8, a] +
     775975200*PolyGamma[0, a]^2*PolyGamma[2, a]*PolyGamma[5, a]*
      PolyGamma[8, a] + 775975200*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[5, a]*PolyGamma[8, a] + 387987600*PolyGamma[0, a]*
      PolyGamma[3, a]*PolyGamma[5, a]*PolyGamma[8, a] +
     77597520*PolyGamma[4, a]*PolyGamma[5, a]*PolyGamma[8, a] +
     55426800*PolyGamma[0, a]^4*PolyGamma[6, a]*PolyGamma[8, a] +
     332560800*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[6, a]*
      PolyGamma[8, a] + 166280400*PolyGamma[1, a]^2*PolyGamma[6, a]*
      PolyGamma[8, a] + 221707200*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[6, a]*PolyGamma[8, a] + 55426800*PolyGamma[3, a]*
      PolyGamma[6, a]*PolyGamma[8, a] + 27713400*PolyGamma[0, a]^3*
      PolyGamma[7, a]*PolyGamma[8, a] + 83140200*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[7, a]*PolyGamma[8, a] +
     27713400*PolyGamma[2, a]*PolyGamma[7, a]*PolyGamma[8, a] +
     4618900*PolyGamma[0, a]^2*PolyGamma[8, a]^2 + 4618900*PolyGamma[1, a]*
      PolyGamma[8, a]^2 + 184756*PolyGamma[0, a]^10*PolyGamma[9, a] +
     8314020*PolyGamma[0, a]^8*PolyGamma[1, a]*PolyGamma[9, a] +
     116396280*PolyGamma[0, a]^6*PolyGamma[1, a]^2*PolyGamma[9, a] +
     581981400*PolyGamma[0, a]^4*PolyGamma[1, a]^3*PolyGamma[9, a] +
     872972100*PolyGamma[0, a]^2*PolyGamma[1, a]^4*PolyGamma[9, a] +
     174594420*PolyGamma[1, a]^5*PolyGamma[9, a] + 22170720*PolyGamma[0, a]^7*
      PolyGamma[2, a]*PolyGamma[9, a] + 465585120*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[9, a] +
     2327925600*PolyGamma[0, a]^3*PolyGamma[1, a]^2*PolyGamma[2, a]*
      PolyGamma[9, a] + 2327925600*PolyGamma[0, a]*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[9, a] + 387987600*PolyGamma[0, a]^4*
      PolyGamma[2, a]^2*PolyGamma[9, a] + 2327925600*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[9, a] +
     1163962800*PolyGamma[1, a]^2*PolyGamma[2, a]^2*PolyGamma[9, a] +
     517316800*PolyGamma[0, a]*PolyGamma[2, a]^3*PolyGamma[9, a] +
     38798760*PolyGamma[0, a]^6*PolyGamma[3, a]*PolyGamma[9, a] +
     581981400*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[9, a] + 1745944200*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[3, a]*PolyGamma[9, a] + 581981400*PolyGamma[1, a]^3*
      PolyGamma[3, a]*PolyGamma[9, a] + 775975200*PolyGamma[0, a]^3*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[9, a] +
     2327925600*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[9, a] + 387987600*PolyGamma[2, a]^2*
      PolyGamma[3, a]*PolyGamma[9, a] + 290990700*PolyGamma[0, a]^2*
      PolyGamma[3, a]^2*PolyGamma[9, a] + 290990700*PolyGamma[1, a]*
      PolyGamma[3, a]^2*PolyGamma[9, a] + 46558512*PolyGamma[0, a]^5*
      PolyGamma[4, a]*PolyGamma[9, a] + 465585120*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[4, a]*PolyGamma[9, a] +
     698377680*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[4, a]*
      PolyGamma[9, a] + 465585120*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[9, a] + 465585120*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[4, a]*PolyGamma[9, a] +
     232792560*PolyGamma[0, a]*PolyGamma[3, a]*PolyGamma[4, a]*
      PolyGamma[9, a] + 23279256*PolyGamma[4, a]^2*PolyGamma[9, a] +
     38798760*PolyGamma[0, a]^4*PolyGamma[5, a]*PolyGamma[9, a] +
     232792560*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[5, a]*
      PolyGamma[9, a] + 116396280*PolyGamma[1, a]^2*PolyGamma[5, a]*
      PolyGamma[9, a] + 155195040*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[5, a]*PolyGamma[9, a] + 38798760*PolyGamma[3, a]*
      PolyGamma[5, a]*PolyGamma[9, a] + 22170720*PolyGamma[0, a]^3*
      PolyGamma[6, a]*PolyGamma[9, a] + 66512160*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[6, a]*PolyGamma[9, a] +
     22170720*PolyGamma[2, a]*PolyGamma[6, a]*PolyGamma[9, a] +
     8314020*PolyGamma[0, a]^2*PolyGamma[7, a]*PolyGamma[9, a] +
     8314020*PolyGamma[1, a]*PolyGamma[7, a]*PolyGamma[9, a] +
     1847560*PolyGamma[0, a]*PolyGamma[8, a]*PolyGamma[9, a] +
     92378*PolyGamma[9, a]^2 + 167960*PolyGamma[0, a]^9*PolyGamma[10, a] +
     6046560*PolyGamma[0, a]^7*PolyGamma[1, a]*PolyGamma[10, a] +
     63488880*PolyGamma[0, a]^5*PolyGamma[1, a]^2*PolyGamma[10, a] +
     211629600*PolyGamma[0, a]^3*PolyGamma[1, a]^3*PolyGamma[10, a] +
     158722200*PolyGamma[0, a]*PolyGamma[1, a]^4*PolyGamma[10, a] +
     14108640*PolyGamma[0, a]^6*PolyGamma[2, a]*PolyGamma[10, a] +
     211629600*PolyGamma[0, a]^4*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[10, a] + 634888800*PolyGamma[0, a]^2*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[10, a] + 211629600*PolyGamma[1, a]^3*
      PolyGamma[2, a]*PolyGamma[10, a] + 141086400*PolyGamma[0, a]^3*
      PolyGamma[2, a]^2*PolyGamma[10, a] + 423259200*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[2, a]^2*PolyGamma[10, a] +
     47028800*PolyGamma[2, a]^3*PolyGamma[10, a] + 21162960*PolyGamma[0, a]^5*
      PolyGamma[3, a]*PolyGamma[10, a] + 211629600*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[10, a] +
     317444400*PolyGamma[0, a]*PolyGamma[1, a]^2*PolyGamma[3, a]*
      PolyGamma[10, a] + 211629600*PolyGamma[0, a]^2*PolyGamma[2, a]*
      PolyGamma[3, a]*PolyGamma[10, a] + 211629600*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[3, a]*PolyGamma[10, a] +
     52907400*PolyGamma[0, a]*PolyGamma[3, a]^2*PolyGamma[10, a] +
     21162960*PolyGamma[0, a]^4*PolyGamma[4, a]*PolyGamma[10, a] +
     126977760*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[10, a] + 63488880*PolyGamma[1, a]^2*PolyGamma[4, a]*
      PolyGamma[10, a] + 84651840*PolyGamma[0, a]*PolyGamma[2, a]*
      PolyGamma[4, a]*PolyGamma[10, a] + 21162960*PolyGamma[3, a]*
      PolyGamma[4, a]*PolyGamma[10, a] + 14108640*PolyGamma[0, a]^3*
      PolyGamma[5, a]*PolyGamma[10, a] + 42325920*PolyGamma[0, a]*
      PolyGamma[1, a]*PolyGamma[5, a]*PolyGamma[10, a] +
     14108640*PolyGamma[2, a]*PolyGamma[5, a]*PolyGamma[10, a] +
     6046560*PolyGamma[0, a]^2*PolyGamma[6, a]*PolyGamma[10, a] +
     6046560*PolyGamma[1, a]*PolyGamma[6, a]*PolyGamma[10, a] +
     1511640*PolyGamma[0, a]*PolyGamma[7, a]*PolyGamma[10, a] +
     167960*PolyGamma[8, a]*PolyGamma[10, a] + 125970*PolyGamma[0, a]^8*
      PolyGamma[11, a] + 3527160*PolyGamma[0, a]^6*PolyGamma[1, a]*
      PolyGamma[11, a] + 26453700*PolyGamma[0, a]^4*PolyGamma[1, a]^2*
      PolyGamma[11, a] + 52907400*PolyGamma[0, a]^2*PolyGamma[1, a]^3*
      PolyGamma[11, a] + 13226850*PolyGamma[1, a]^4*PolyGamma[11, a] +
     7054320*PolyGamma[0, a]^5*PolyGamma[2, a]*PolyGamma[11, a] +
     70543200*PolyGamma[0, a]^3*PolyGamma[1, a]*PolyGamma[2, a]*
      PolyGamma[11, a] + 105814800*PolyGamma[0, a]*PolyGamma[1, a]^2*
      PolyGamma[2, a]*PolyGamma[11, a] + 35271600*PolyGamma[0, a]^2*
      PolyGamma[2, a]^2*PolyGamma[11, a] + 35271600*PolyGamma[1, a]*
      PolyGamma[2, a]^2*PolyGamma[11, a] + 8817900*PolyGamma[0, a]^4*
      PolyGamma[3, a]*PolyGamma[11, a] + 52907400*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[3, a]*PolyGamma[11, a] +
     26453700*PolyGamma[1, a]^2*PolyGamma[3, a]*PolyGamma[11, a] +
     35271600*PolyGamma[0, a]*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[11, a] + 4408950*PolyGamma[3, a]^2*PolyGamma[11, a] +
     7054320*PolyGamma[0, a]^3*PolyGamma[4, a]*PolyGamma[11, a] +
     21162960*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[11, a] + 7054320*PolyGamma[2, a]*PolyGamma[4, a]*
      PolyGamma[11, a] + 3527160*PolyGamma[0, a]^2*PolyGamma[5, a]*
      PolyGamma[11, a] + 3527160*PolyGamma[1, a]*PolyGamma[5, a]*
      PolyGamma[11, a] + 1007760*PolyGamma[0, a]*PolyGamma[6, a]*
      PolyGamma[11, a] + 125970*PolyGamma[7, a]*PolyGamma[11, a] +
     77520*PolyGamma[0, a]^7*PolyGamma[12, a] + 1627920*PolyGamma[0, a]^5*
      PolyGamma[1, a]*PolyGamma[12, a] + 8139600*PolyGamma[0, a]^3*
      PolyGamma[1, a]^2*PolyGamma[12, a] + 8139600*PolyGamma[0, a]*
      PolyGamma[1, a]^3*PolyGamma[12, a] + 2713200*PolyGamma[0, a]^4*
      PolyGamma[2, a]*PolyGamma[12, a] + 16279200*PolyGamma[0, a]^2*
      PolyGamma[1, a]*PolyGamma[2, a]*PolyGamma[12, a] +
     8139600*PolyGamma[1, a]^2*PolyGamma[2, a]*PolyGamma[12, a] +
     5426400*PolyGamma[0, a]*PolyGamma[2, a]^2*PolyGamma[12, a] +
     2713200*PolyGamma[0, a]^3*PolyGamma[3, a]*PolyGamma[12, a] +
     8139600*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[12, a] + 2713200*PolyGamma[2, a]*PolyGamma[3, a]*
      PolyGamma[12, a] + 1627920*PolyGamma[0, a]^2*PolyGamma[4, a]*
      PolyGamma[12, a] + 1627920*PolyGamma[1, a]*PolyGamma[4, a]*
      PolyGamma[12, a] + 542640*PolyGamma[0, a]*PolyGamma[5, a]*
      PolyGamma[12, a] + 77520*PolyGamma[6, a]*PolyGamma[12, a] +
     38760*PolyGamma[0, a]^6*PolyGamma[13, a] + 581400*PolyGamma[0, a]^4*
      PolyGamma[1, a]*PolyGamma[13, a] + 1744200*PolyGamma[0, a]^2*
      PolyGamma[1, a]^2*PolyGamma[13, a] + 581400*PolyGamma[1, a]^3*
      PolyGamma[13, a] + 775200*PolyGamma[0, a]^3*PolyGamma[2, a]*
      PolyGamma[13, a] + 2325600*PolyGamma[0, a]*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[13, a] + 387600*PolyGamma[2, a]^2*
      PolyGamma[13, a] + 581400*PolyGamma[0, a]^2*PolyGamma[3, a]*
      PolyGamma[13, a] + 581400*PolyGamma[1, a]*PolyGamma[3, a]*
      PolyGamma[13, a] + 232560*PolyGamma[0, a]*PolyGamma[4, a]*
      PolyGamma[13, a] + 38760*PolyGamma[5, a]*PolyGamma[13, a] +
     15504*PolyGamma[0, a]^5*PolyGamma[14, a] + 155040*PolyGamma[0, a]^3*
      PolyGamma[1, a]*PolyGamma[14, a] + 232560*PolyGamma[0, a]*
      PolyGamma[1, a]^2*PolyGamma[14, a] + 155040*PolyGamma[0, a]^2*
      PolyGamma[2, a]*PolyGamma[14, a] + 155040*PolyGamma[1, a]*
      PolyGamma[2, a]*PolyGamma[14, a] + 77520*PolyGamma[0, a]*
      PolyGamma[3, a]*PolyGamma[14, a] + 15504*PolyGamma[4, a]*
      PolyGamma[14, a] + 4845*PolyGamma[0, a]^4*PolyGamma[15, a] +
     29070*PolyGamma[0, a]^2*PolyGamma[1, a]*PolyGamma[15, a] +
     14535*PolyGamma[1, a]^2*PolyGamma[15, a] + 19380*PolyGamma[0, a]*
      PolyGamma[2, a]*PolyGamma[15, a] + 4845*PolyGamma[3, a]*
      PolyGamma[15, a] + 1140*PolyGamma[0, a]^3*PolyGamma[16, a] +
     3420*PolyGamma[0, a]*PolyGamma[1, a]*PolyGamma[16, a] +
     1140*PolyGamma[2, a]*PolyGamma[16, a] + 190*PolyGamma[0, a]^2*
      PolyGamma[17, a] + 190*PolyGamma[1, a]*PolyGamma[17, a] +
     20*PolyGamma[0, a]*PolyGamma[18, a] + PolyGamma[19, a]

(******************************************************************************)



MySimplify[expr_] := Module[{temp, parts},
  temp = Together[expr] /. 
    Power[xxx_, yyy_] :> 
     If[(*And[MemberQ[Variables[yyy],ep],Head[Expand[xxx]]===Plus]*)
      And[IntegerQ[yyy], yyy > 0] =!= True, p[xxx, yyy], 
      Power[xxx, yyy]];
  temp = {temp};
  parts = Cases[temp, p[__], {0, Infinity}];
  While[Length[parts] > 0,
   temp = temp /. parts[[1]] -> exp1;
   
   temp = (min = -Exponent[##, 1/exp1];
       max = Exponent[##, exp1];
       (*Print[min];
       Print[max];*)
       
       Table[Coefficient[##, exp1, iii]*(exp1)^iii, {iii, min, 
         max}]) & /@ temp;
   temp = Flatten[temp, 1];
   temp = temp /. exp1 -> (parts[[1]] /. p -> pp);
   parts = Cases[temp, p[__], {0, Infinity}];
   ];
  (*temp = Together[temp];*)
temp=Together/@temp;
(*If[Length[temp]>1,Print[expr]];*)
  temp
  ]
MyFactor[xxx_] := Module[{temp,bad},
  temp=Together[xxx];
  If[Head[temp===Plus],Return[SDEvaluateDirect2[x,{temp},{1},0]]];
  temp = Select[
    Select[Cases[temp, pp[_, _]], MemberQ[Variables[##[[1]]], x[_]] &],
     Or[MemberQ[Variables[##[[2]]], ep],MemberQ[Variables[##[[2]]], delta[_]]] &];
  temp = Transpose[
     Prepend[Apply[List, temp, {1}], {Together[xxx/Times @@ temp], 
       1}]] /. pp -> Power;
  (*Print[temp];*)
  
  temp = 
    Reap[Apply[Sow, 
       Transpose[
        temp], {1}], _, {Together[Times @@ (#2)], #1} &][[2]];
  bad=Select[temp,And[MemberQ[Variables[##[[2]]],ep],Or[Head[Together[##[[1]]]]===Plus,Depth[##[[1]]]>3]]&];
  If[Length[bad]>1,Print[temp]];
  If[Length[bad]==1,
    temp=DeleteCases[temp,bad[[1]]];
    temp=Join[{temp[[1]],bad[[1]]},Drop[temp,1]];
  ];
  temp=Transpose[temp];
  (*temp*)
  Global`ParInt@@temp
(*  SDEvaluateDirect2 @@ Append[Prepend[temp, x], 0]*)
  ]



QHullRun[pts_List, dim_Integer]:=Module[{temp},
    temp=QHull[pts,dim,Executable->QHullPath,
	InFile->DataPath<>"q"<>ToString[$KernelID]<>"i",
	OutFile->DataPath<>"q"<>ToString[$KernelID]<>"o",
	Mode->"Fv 2>/dev/null",Verbose->False];
    DeleteFile[DataPath<>"q"<>ToString[$KernelID]<>"i"];
    DeleteFile[DataPath<>"q"<>ToString[$KernelID]<>"o"];
    temp
];

(*faces of a ploytope containing the origin*)
ZeroFaces[list_List]:=Module[{n,pos,temp},
    If[Length[list]==0,Print["Zero list"];Abort[]];
    n=Length[list[[1]]];
    pos=Position[list,Table[0,{n}]];
    If[pos=={},Print["List does not contain zero"];Abort[]];
    pos=pos[[1]][[1]];
    temp=QHullRun[list,n];
    If[temp=={},Print["Something went wrong with QHull"];Print[list];Abort[]];
    temp=Select[temp,MemberQ[##,pos]&];
    If[temp=={},Return[{}]];
    temp=Map[list[[##]]&,temp,{2}];
    Return[temp];
]

(* normal vector to a facet containing zero*)
NormVector[list_List,direction_List]:=Module[{n,pos,temp,det,vec,rank,i,j,temp2},
    If[Length[list]==0,Print["Empty facet"];Abort[]];
    n=Length[list[[1]]];
    pos=Position[list,Table[0,{n}]];
    If[pos=={},Print["Facet does not contain zero"];Abort[]];
    temp=DeleteCases[list,Table[0,{n}]];

(*    rank=0;i=1;temp2=Table[Table[0,{n}],{n}];
    While[rank<n-1,
      If[MatrixRank[ReplacePart[temp2,temp[[i]],rank+1]]>MatrixRank[temp2],
	temp2[[rank+1]]=temp[[i]];
	rank++;
      ];
      i++;
    ];
    temp=temp2;
    temp[[n]]=Table[1,{n}];
*)

      For[i=1,i<=Length[temp],i++,
	  If[temp[[i]]==Table[0,{Length[temp[[i]]]}],Continue[]];
	  pos=First[Complement[Range[Length[temp[[i]]]],Flatten[Position[temp[[i]],0]]]];
	  For[j=i+1,j<=Length[temp],j++,
	      If[temp[[j]][[pos]]!=0,temp[[j]]=(temp[[i]][[pos]])*temp[[j]]-(((temp[[j]][[pos]]))*temp[[i]])];
	  ];
      ];
      temp=DeleteCases[temp,Table[0,{Length[temp[[1]]]}]];
      AppendTo[temp,Table[1,{n}]];

    
    det=Det[temp];
    vec=Table[0,{n}];
    vec[[n]]=det;
    vec=Inverse[temp].vec;
    det=GCD@@vec;
    vec=(##/det)&/@vec;
    If[vec.direction<0,vec=-vec];
    Return[vec];
]

(*dual cone to the original polytope*)
DualCone[list_List]:=Module[{n,pos,temp,c},
    temp=ZeroFaces[list];
    If[temp=={},Return[{}]];
    n=Length[list[[1]]];
    If[Length[temp]<n,Return[{}]]; (*zero is not a facet in fact*)
    (*If[Length[temp]<n,Print["The number of facets is too small"];Print[list];Abort[];];*)
    temp=NormVector[##,DeleteCases[DeleteCases[temp,##][[1]],Table[0,{n}]][[1]]]&/@temp;
    temp={Plus@@##,##}&/@temp;
    c=LCM@@((##[[1]])&/@temp);
    temp=((c/##[[1]])*(##[[2]]))&/@temp;
    Return[temp];
]

(*qhull of a polytope of a smaller dimension*)
QHullWrapper[list_List,dim_Integer]:=Module[{n,temp,rank,i,ort,found,minor,positions,pos},
    temp=(##-list[[1]])&/@list;
    temp=Drop[temp,1];
    n=Length[temp[[1]]];
    rank=dim;
    If[rank<n,
      temp=Transpose[temp];
      For[i=1,i<=n,i++,
	  If[temp[[i]]==Table[0,{Length[temp[[i]]]}],Continue[]];
	  pos=First[Complement[Range[Length[temp[[i]]]],Flatten[Position[temp[[i]],0]]]];
	  For[j=i+1,j<=n,j++,
	      If[temp[[j]][[pos]]!=0,temp[[j]]=temp[[j]]-(((temp[[j]][[pos]])/(temp[[i]][[pos]]))*temp[[i]])];
	  ];
      ];
      temp=DeleteCases[temp,Table[0,{Length[temp[[1]]]}]];
      newtemp=Transpose[temp];
      newtemp=Prepend[newtemp,Table[0,{rank}]];


      newtemp=(LCM@@(Denominator/@Flatten[newtemp]))*newtemp;


      Return[QHullRun[newtemp,rank]];
    ,
      Return[QHullRun[list,n]];
    ]
]

(*recursive simplexification of a cone*)
Simplexify[list_List,dim_Integer]:=Module[{temp},
    If[Length[list]<=dim,Print["Simplefify error"];Abort[]];
    If[Length[list]==dim+1,Return[{list}]];
    temp=QHullWrapper[list,dim];
    temp=Select[temp,Not[MemberQ[##,1]]&];
    temp=Map[list[[##]]&,temp,{2}];
    If[STRATEGY===STRATEGY_KU2,
      temp=(SimplexifyWrapper[##,dim-1])&/@temp;
    ,
      temp=(Simplexify[##,dim-1])&/@temp;
    ];
    temp=Flatten[temp,1];
    temp=Prepend[##,list[[1]]]&/@temp;
    Return[temp];
]

SimplexifyWrapper[list_List,dim_Integer]:=Module[{temp,min,i,tempres,res},
    min=Infinity; 
    i=1;
    temp=list;
    While[And[i<=Length[temp],min>2],
	tempres=Simplexify[temp,dim];
	If[Length[tempres]<min,
	  min=Length[tempres];
	  res=tempres;
	];
	i++;
	temp=RotateRight[temp];
    ];
    Return[res];
]

(*simplex cones corresponding to the original polytope*)
SimplexCones[list_List]:=Module[{n,pos,temp,facets,i,min,res,tempres},
    temp=DualCone[list];
    If[temp=={},Return[{}]];
    n=Length[temp[[1]]];
    If[Length[temp]<n,Print["Not enough edges in the dual cone"];Abort[]];
    If[MatrixRank[temp]<n,Return[{}]]; (*zero was not the vertex*)
    If[STRATEGY===STRATEGY_KU0,
      Return[Simplexify[temp,n-1]];
    ,
      Return[SimplexifyWrapper[temp,n-1]];
    ];
(*
    min=Infinity;
    i=1;
    While[And[i<=Length[temp],min>2],
	tempres=Simplexify[temp,n-1];
	If[Length[tempres]<min,
	  min=Length[tempres];
	  res=tempres;
	];
	i++;
	temp=RotateRight[temp];
    ];
    Return[res];*)
]
    
    

LocateBadEndsBefore[expr_] := Module[{vars, ends, rule, rules, temp},
  vars = Union[Cases[expr, x[_], {0, Infinity}]];
  ends = Tuples[{0, 1}, Length[vars]];
  ends = DeleteCases[ends, Table[0, {Length[vars]}]];
  temp = Reap[
     (rule = Rule @@@ Transpose[{vars, ##}];
        temp = expr /. rule;
        If[temp === 0,
         temp = Flatten[Position[##, 1]];
         temp = 
          ReplacePart[##[[1]], ##[[2]] -> 1/2] & /@ 
           Transpose[{Table[##, {Length[temp]}], temp}];
         temp = Transpose[{Table[vars, {Length[temp]}], temp}];
         temp = Transpose /@ temp;
         rules = Apply[Rule, temp, {2}];
         temp = (expr /. ##) & /@ rules;
         temp = Not[TrueQ[## == 0]] & /@ temp;
         temp = And @@ temp;
         If[temp,
          temp = Take[vars, Flatten[Position[##, 1]]];
          Sow[Map[(##[[1]]) &, temp, {1}]];
          ];
         ];
        ) & /@ ends
     , _][[2]];
  If[Length[temp] > 0, temp = temp[[1]]];
  temp
  ]







IntegralDim:=Global`IntegralDim;
PExpand[xx__]:=Global`PExpand[xx];
AlphaRepExpand[xx__]:=Global`AlphaRepExpand[xx];
QOpen[xx__]:=Global`QOpen[xx];
QRead[xx__]:=Global`QRead[xx];
QRemoveDatabase[xx__]:=Global`QRemoveDatabase[xx];
QRepair[xx__]:=Global`QRepair[xx];
QClose[xx__]:=Global`QClose[xx];
QList[xx__]:=Global`QList[xx];
QSize[xx__]:=Global`QSize[xx];
QPut[xx__]:=Global`QPut[xx];
QGet[xx__]:=Global`QGet[xx];
QSafeGet[xx__]:=Global`QSafeGet[xx];
QCheck[xx__]:=Global`QCheck[xx];
QRemove[xx__]:=Global`QRemove[xx];
QSetCompressionOn[]:=Global`QSetCompressionOn[];
QSetAutoBucketOn[]:=Global`QSetAutoBucketOn[];
QSetBucketSize[xx__]:=Global`QSetBucketSize[xx];
QSetNoLock[]:=Global`QSetNoLock[];
CIntegrate[xx__]:=Global`CIntegrate[xx];
SetPoints[xx__]:=Global`SetPoints[xx];
SetCut[xx__]:=Global`SetCut[xx];
CAddString[xx__]:=Global`CAddString[xx];
CClearString[xx__]:=Global`CClearString[xx];



End[];


SDEvaluateDirect[x__]:=FIESTA`SDEvaluateDirect[x]
SDExpandDirect[x__]:=FIESTA`SDExpandDirect[x]
SDEvaluate[x__]:=FIESTA`SDEvaluate[x]
SDEvaluateG[x__]:=FIESTA`SDEvaluateG[x]
SDExpand[x__]:=FIESTA`SDExpand[x]
SDExpandG[x__]:=FIESTA`SDExpandG[x]
SDAnalyze[x__]:=FIESTA`SDAnalyze[x]
SDExpandAsy[x__]:=FIESTA`SDExpandAsy[x]
SDIntegrate[]:=FIESTA`SDIntegrate[]
GenerateAnswer[]:=FIESTA`GenerateAnswer[]
IntegrationCommand[]:=FIESTA`IntegrationCommand[]
UF[x__]:=FIESTA`UF[x]


SDEvaluateG::usage="SDEvaluate[{graph,external},{U,F,loops},indices,order] evaluates the integral";
SDEvaluate::usage="SDEvaluate[{U,F,loops},indices,order] evaluates the integral";
SDEvaluateDirect::usage="SDEvaluate[var,degrees,functions,order,deltas(optional)] evaluates the integral";
SDExpandG::usage="SDExpandG[{graph,external},{U,F,loops},indices,order,expand_var,expand_degree] expands the integral";
SDExpand::usage="SDExpand[{U,F,loops},indices,order,expand_var,expand_degree] expands the integral";
SDExpandAsy::usage="SDExpandAsy[{U,F,loops},indices,order,expand_var,expand_degree] expands the integral with the regions approach";
SDExpandDirect::usage="SDExpandDirect[var,degrees,functions,order,expand_var,expand_degree,deltas(optional)] expands the integral";
SDIntegrate::usage="SDIntegrate[] - integrate using prepared database";
SDAnalyze::usage="SDAnalyze[{U,F,h},degrees,order,dmin,dmax] searches for possible ep-poles";

GenerateAnswer::usage="GenerateAnswer[] - generate answer with the use of results from the database";
UF::usage="UF[LoopMomenta,Propagators,subst] generates the functions U and F";
