$ii=1;
while (-e "intfile$ii.cc"){
print "compiling 1l0h0, epsord 1\n";
$makecheck=system("make -s -j 48 -f make${ii}file");
if ($makecheck!=0) {
 system("make -s -f make${ii}file clean");
 system("make -s -j 48 -f make${ii}file");
}
$ii++;}
