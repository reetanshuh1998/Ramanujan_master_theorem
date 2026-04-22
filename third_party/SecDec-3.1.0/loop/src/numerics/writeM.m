writeM[result_,outfile_,time_]:=
  Block[{fst},
	fst=OpenWrite[outfile];
	WriteString[fst,"Real part:\nresult = "];
	WriteString[fst,NumberForm[Re[result], 12, NumberFormat -> (Row[{#1, "e", #3}] &)]];
	WriteString[fst,"\nerror = n.a."];
	WriteString[fst,"\nerrorprob = 0\n"];
	WriteString[fst,"\ntime = n.a.\n\n"];
	WriteString[fst,"Imaginary part:\nresult = "];
	WriteString[fst,NumberForm[Im[result], 12, NumberFormat -> (Row[{#1, "e", #3}] &)]];
	WriteString[fst,"\nerror = n.a."];
	WriteString[fst,"\nerrorprob = 0\n"];
	WriteString[fst,"\ntime = n.a.\n\n"];
	WriteString[fst,"Time (s) = "];
	Write[fst,N[SetAccuracy[time,4]]];
	WriteString[fst,"\nMaxErrorprob = 0\n"];
	Close[fst];
	];

writeMreal[result_,outfile_,time_]:=
  Block[{fst},
	fst=OpenWrite[outfile];
	WriteString[fst,"Real part:\nresult = "];
	WriteString[fst,NumberForm[Re[result], 12, NumberFormat -> (Row[{#1, "e", #3}] &)]];
	WriteString[fst,"\nerror = n.a."];
	WriteString[fst,"\nerrorprob = 0\n"];
	WriteString[fst,"\ntime = n.a.\n\n"];
	WriteString[fst,"Time (s) = "];
	Write[fst,N[SetAccuracy[time,4]]];
	WriteString[fst,"\nMaxErrorprob = 0\n"];
	Close[fst];
	];
