Get["examples/include.m"];
OnlyPrepare = True;
result = SDExpand[{x[1] + x[2] + x[3] + x[4], x[1] x[3] + t x[2] x[4], 1}, {1, 
  1, 1, 1}, 1, t, 0];