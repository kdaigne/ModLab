function [X,N]=Fractal(xmin,xmax,Fdim,Nbins)
dx=(xmax-xmin)/Nbins;
X=xmin:dx:xmax;
CumulN=X.^(-Fdim);
CumulN=1-CumulN/max(CumulN);
N=zeros(1,size(CumulN,2));
for i=1:size(CumulN,2)-1
    N(i)=CumulN(i+1)-CumulN(i);
end