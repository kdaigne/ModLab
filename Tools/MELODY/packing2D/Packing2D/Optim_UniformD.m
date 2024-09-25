function Error=Optim_UniformD(Dmin)
global Ntot Atot r
Dmax=r*Dmin;
d=[Dmin:(Dmax-Dmin)/10000:Dmax];
n=ones(1,10001)*Ntot/10000;
ErrorN=abs((sum(n)-Ntot)/Ntot);
ErrorA=abs((sum(pi/4*n.*d.^2)-Atot)/Atot);
Error=ErrorN+ErrorA;