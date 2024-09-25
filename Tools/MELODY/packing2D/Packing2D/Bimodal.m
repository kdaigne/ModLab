function [X,N]=Bimodal(Mu1,Sig1,N1,Mu2,Sig2,N2,Nbins)
xmin=min([Mu1-3*Sig1,Mu2-3*Sig2]);
xmax=max([Mu1+3*Sig1,Mu2+3*Sig2]);
dx=(xmax-xmin)/Nbins;
X=xmin:dx:xmax;
N=N1*exp(-((X-Mu1)/Sig1).^2)+N2*exp(-((X-Mu2)/Sig2).^2);