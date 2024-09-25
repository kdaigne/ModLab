function [Mu,Sig]=Gauss_to_Log(Mu,Sig)
Sigi=Sig;
Mui=Mu;
Sig=sqrt(log(1+Sigi^2/Mui^2));
Mu=log(Mui)-1/2*Sig^2;
