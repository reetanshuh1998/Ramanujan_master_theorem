Get["examples/include.m"];
Get["extra/asy2.1.1.m"];
RegVar = la;
result = SDExpandAsy[{x[1] + x[2] + x[3] + x[4], x[1] x[3] + t x[2] x[4], 
  1}, {1 + la, 1, 1 - la, 1}, 1, t, 0];
InputForm[result]