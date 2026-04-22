dummys={};
dummyorder={};
commonparamstring=;
filepath=;
path=;
dummynames=ToString/@dummys;
dummyorder=Transpose[{dummynames,dummyorder}];

Get[path<>"src/subexp/ExpOpt.m"];

varletter="w";
MyBlock[listvar_,listabbr_]:={listvar,listabbr};

writeasfortran[name_String]:=Module[{},
	inputname=filepath<>name<>".m";
	Get[inputname];	
	dnames=Complement[dummynames,{name}];
	doublestring="      double precision "<>#<>"\n"&/@dnames;
	doublestring=StringJoin@@doublestring;
	epsOrd=Select[dummyorder,#[[1]]==name &][[1,2]]; 
	ndi=Length[intvars];
	reps=Table[intvars[[i]]->Symbol["x"<>ToString[i]],{i,ndi}];
	functiontooptimize=Symbol[name]/.reps;
	xstr=StringJoin@@Table[If[i>1,",",""]<>"x"<>ToString[i],{i,ndi}];
	fortranstring1="      double precision function ";
	fortranstring0="("<>xstr<>")\n      implicit double precision (a-h,o-z)\n"<>
	doublestring<>"      "<>
	commonparamstring<>
	"\n      double precision "<>xstr<>"\n";
	fortranstring2[1] = fortranstring0;
	fortranstring3="\n      return\n      end";
(*	Print[fortranstring1<>name<>fortranstring2<>"stuff\n"<>fortranstring3];*)
	Do[
	  funcname = If[eo>0,name<>"Deps"<>ToString[eo],name];
	  outfile=filepath<>funcname<>".f";
	  try=OptimizeExpression[SeriesCoefficient[functiontooptimize,{eps,0,eo}], OptimizationSymbol -> w];
	  tt =try/.{OptimizedExpression->Hold};
	  he1=tt/.{Block->MyBlock,CompoundExpression->List,Set->Rule};
	  expr=ReleaseHold[he1];
	  writeopt[expr,varletter,funcname,outfile,1];
	  myclear[name];
	  ,
	  {eo,0,epsOrd}
	]
];
myclear[varname_]:=Clear[varname];

writeasfortran/@dummynames;
