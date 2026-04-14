(*
#****m* SecDec/general/src/deco/decomposition.m
# NAME
#  decomposition.m
# USAGE
#  called from subdir/graph/graph.m, via decompose.pl
# PURPOSE
#  to perform the sector decomposition.
# RESULT
# [integral]P*l*h*.out, [integral]OUT.info written to subdir/integral
# SEE ALSO
#  SDroutines.m
#****
*)
(* does the actual sector decomposition *)

Get[path<>"src/deco/SDroutines.m"];

decotime=AbsoluteTiming[
decomposedsectors=paralleldecompose[newtodeco];
decomposedsectors=decomposedsectors/.{AA__,A}->{AA};
decomposedsectors=decomposedsectors//.{AA___,null,BB___}->{AA,BB};
makeoutput
];
Print["\n"];
Print["Time taken to do the decomposition: ",AccountingForm[decotime[[1]]]," secs"];
