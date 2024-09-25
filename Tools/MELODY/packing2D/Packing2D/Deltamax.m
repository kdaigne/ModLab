function Delta=Deltamax(poly,Xc,Yc,POLY)
n=size(poly,1)-1;
N=size(POLY,1)-1;
ai=zeros(n,1);
bi=zeros(n,1);
Aj=zeros(N,1);
Bj=zeros(N,1);
for i=1:n
    ai(i,1)=(poly(i,2)-Yc)/(poly(i,1)-Xc);
    bi(i,1)=Yc-ai(i,1)*Xc;
end
for j=1:N-1
    Aj(j,1)=(POLY(j+1,2)-POLY(j,2))/(POLY(j+1,1)-POLY(j,1));
    Bj(j,1)=POLY(j,2)-Aj(j,1)*POLY(j,1);
end
Aj(N,1)=(POLY(1,2)-POLY(N,2))/(POLY(1,1)-POLY(N,1));
Bj(N,1)=POLY(N,2)-Aj(N,1)*POLY(N,1);
Delta=10^9;
for i=1:n
    for j=1:N
        Xij=(bi(i,1)-Bj(j,1))/(Aj(j,1)-ai(i,1));
        dijli=(Xij-Xc)/(poly(i,1)-Xc);
        if dijli>0 & dijli<Delta
            Delta=dijli;
        end
    end
end