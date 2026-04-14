Get["examples/include.m"];
STRATEGY=STRATEGY_SS;
result = SDEvaluateG[{{{1, 3}, {2, 3}, {1, 2}, {3, 4}, {1, 4}, {2, 4}}, {}}, 
 UF[{k1, k2, 
    k3}, {-(k1 + k3)^2 + mm, -(k2 - k3)^2 + mm, -k3^2 + 
        mm, -(k1 + k2)^2 + mm, -k1^2 + mm, -k2^2 + mm}, {mm -> 1}], {1, 1,
           1, 1, 1, 1}, 0];
InputForm[result]