Get["examples/include.m"];
Get["extra/asy2.1.1.m"];
result = SDExpandAsy[
 UF[{k, p}, {-p^2, -p^2, -k^2 + m^2, -(k + p)^2 + m^2, -(p + q)^2 + 
     M^2}, {q^2 -> 1, M^2 -> 1, m^2 -> tt^2}], {1, 1, 1, 1, 1}, 0, tt,
       0];
InputForm[result]