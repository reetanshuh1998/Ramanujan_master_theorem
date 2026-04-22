Get["examples/include.m"];
result=SDEvaluate[{x[1] + x[2] + x[3] + x[4], x[1] x[3] + x[2] x[4], 1}, {0, 1, 1, 1}, 1];
InputForm[result]