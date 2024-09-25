function Error=Optim_BimodalLogD(Param)
global Ntot Atot COV1 COV2 r Prop1 Nbins

Mu1=Param(1);
Sig1=Mu1*COV1;
[MuN1,SigN1]=Gauss_to_Log(Mu1,Sig1);
N1=Param(2);
Mu2=Mu1*r;
Sig2=Mu2*COV2;
[MuN2,SigN2]=Gauss_to_Log(Mu2,Sig2);
N2=N1/Prop1;

[logd,n]=Bimodal(MuN1,SigN1,N1,MuN2,SigN2,N2,Nbins);

ErrorN=abs((sum(n)-Ntot)/Ntot);
ErrorA=abs((sum(pi/4*n.*(exp(logd)).^2)-Atot)/Atot);

Error=ErrorN+ErrorA;