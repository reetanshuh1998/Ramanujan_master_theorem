(* ============================================================ *)
(* FIESTA 5 Extended Benchmark                                 *)
(* Topologies: triangle3L, elliptic2L, box2L_invprop           *)
(* ============================================================ *)

FIESTAPath = FileNameJoin[{DirectoryName[$InputFileName], "..", "third_party", "fiesta-5.0", "FIESTA5"}];
SetDirectory[FIESTAPath];
<<FIESTA5.m;

SetOptions[FIESTA, "ComplexMode" -> True];

results = <||>;

(* 1. triangle3L *)
Print["Processing triangle3L..."];
uf1 = UF[{k1, k2, k3},
    {-k1^2, -(k1+p1)^2, -(k1-k2)^2, -(k2+p1)^2, -(k1-k3)^2, -(k3+p1)^2, -(k2-k3)^2},
    {SP[p1,p1]->0, s->-1}
];
results["triangle3L"] = AbsoluteTiming[SDEvaluate[uf1, {1,1,1,1,1,1,1}, 0]];

(* 2. elliptic2L Euclidean *)
Print["Processing elliptic2L (Euclidean)..."];
uf2e = UF[{k1, k2},
    {-k1^2+msq, -k2^2+msq, -(k1-k2)^2+msq, -(k1+p)^2, -(k2+p)^2},
    {SP[p,p]->-1, msq->1}
];
results["elliptic2L_euclidean"] = AbsoluteTiming[SDEvaluate[uf2e, {1,1,1,1,1}, 0]];

(* 3. elliptic2L Physical *)
Print["Processing elliptic2L (Physical)..."];
uf2p = UF[{k1, k2},
    {-k1^2+msq, -k2^2+msq, -(k1-k2)^2+msq, -(k1+p)^2, -(k2+p)^2},
    {SP[p,p]->10, msq->1}
];
results["elliptic2L_physical"] = AbsoluteTiming[SDEvaluate[uf2p, {1,1,1,1,1}, 0]];

(* 4. box2L_invprop *)
Print["Processing box2L_invprop..."];
uf3 = UF[{k1, k2},
    {-k1^2, -(k1+p1)^2, -(k1+p1+p2)^2, -(k1+p1+p2+p3)^2, -k2^2, -(k2-p1-p2)^2, -(k1-k2)^2},
    {SP[p1,p1]->0, SP[p2,p2]->0, SP[p3,p3]->0, SP[p1,p2]->-3/2, SP[p2,p3]->-2/2}
];
results["box2L_invprop"] = AbsoluteTiming[SDEvaluate[uf3, {1,1,1,1,1,1,1}, 0]];

Print["Writing results..."];
Export[FileNameJoin[{DirectoryName[$InputFileName], "extended_fiesta5_results.txt"}], results];
Quit[];
