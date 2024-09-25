function Error=Optim_FractalD(Param)
global Ntot Atot Fdim Nbins

Dmin=Param(1);
Dmax=Param(2);

[d,n]=Fractal(Dmin,Dmax,Fdim,Nbins);
n=n/sum(n)*Ntot;

ErrorN=abs((sum(n)-Ntot)/Ntot);
ErrorA=abs((sum(pi/4*n.*d.^2)-Atot)/Atot);
%ErrorC=sum(1-n(find(n<1)));
ErrorC=abs(n(end-1)-max([Ntot/1000,1]));
%n(end)
Error=ErrorN+ErrorA+ErrorC;