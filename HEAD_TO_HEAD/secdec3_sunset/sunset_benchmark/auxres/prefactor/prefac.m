AppendTo[$Messages,"stderr"];
defaultprefactor=-(Gamma[-1+2*eps]/prefactor);
outfilepath="/home/reet/Downloads/Ramanujan/HEAD_TO_HEAD/secdec3_sunset/sunset_benchmark/auxres/prefactor/";
epsord=0;
loops=2;
Dim=4-2*eps;
Nn=3;
prefacord=-1;
gmin=-1;
prefacordmax=-gmin+epsord;
multiplier=defaultprefactor;
smulti=Series[multiplier,{eps,0,prefacordmax}];
mysc[msexpr_,msord_]:=If[MatchQ[Head[msexpr],SeriesData],
SeriesCoefficient[msexpr,msord],
If[MatchQ[msord,0],msexpr,0]];
multi[i_]:=N[mysc[smulti,i]];
Do[
 outfile=StringJoin[outfilepath,ToString[doi]];
OpenWrite[outfile];
Write[outfile, multi[doi]];
Close[outfile];
,
{doi,prefacord,prefacordmax}
]
Exit[Length[DeleteCases[Map[MessageList, Range[$Line - 1]],{}|HoldPattern[MessageList[_]]]]];
