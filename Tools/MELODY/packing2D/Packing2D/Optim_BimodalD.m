function Error=Optim_BimodalD(Param)
global Ntot Atot COV1 COV2 r Prop1 Nbins

Mu1=Param(1);
Sig1=Mu1*COV1;
N1=Param(2);
Mu2=Mu1*r;
Sig2=Mu2*COV2;
N2=N1/Prop1;

[d,n]=Bimodal(Mu1,Sig1,N1,Mu2,Sig2,N2,Nbins);

ErrorN=abs((sum(n)-Ntot)/Ntot);
ErrorA=abs((sum(pi/4*n.*d.^2)-Atot)/Atot);

Error=ErrorN+ErrorA;