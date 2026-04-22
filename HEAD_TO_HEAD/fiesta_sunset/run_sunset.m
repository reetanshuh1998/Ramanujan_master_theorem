(* FIESTA 5.0 script for 2-loop massive sunset *)
FIESTAPath = FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "third_party", "fiesta-5.0", "FIESTA5"}];
SetDirectory[FIESTAPath];
<<FIESTA5.m;

(* Configuration *)
UsingC = True;
UsingQLink = True;
NumberOfLinks = 1;

(* Kinematics *)
m1sq = 1.0; m2sq = 2.0; m3sq = 3.0; psq = 100.0;

(* Polynomial Mode (More robust for FIESTA 4.1) *)
(* Sunset: U = x1x2 + x2x3 + x3x1, F = p2 x1x2x3 - (m1x1 + m2x2 + m3x3)U *)
vU = x[1]*x[2] + x[2]*x[3] + x[3]*x[1];
vF = psq*x[1]*x[2]*x[3] - (m1sq*x[1] + m2sq*x[2] + m3sq*x[3])*vU;

(* Evaluation *)
Print["Starting FIESTA Evaluation (Polynomial Mode)..."];
startTime = AbsoluteTime[];
res = SDEvaluate[{vU, vF, 1}, {1, 1, 1}, 0]; (* epsord=0 to match pySecDec finite part *)
endTime = AbsoluteTime[];

Print["Result: ", res];
Print["Time: ", endTime - startTime];

Export[FileNameJoin[{DirectoryName[$InputFileName], "result.txt"}], {res, endTime - startTime}];
Quit[];
