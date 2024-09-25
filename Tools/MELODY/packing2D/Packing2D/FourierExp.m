function Ratio=FourierExp(D)
global D2 D3 Decay1 D8 Decay2 Rmax Ndesc Dtail NVAR Surface FracCible Cn

D0=D(1,1);
D1=10^-10;
Dn=cat(1,D(2:size(D,1),1),Dtail);
Cnlocal=Cn*D0;

An=Cnlocal.*cos(Dn);
Bn=Cnlocal.*sin(Dn);
Teta=transpose(0:2*3.14159/Ndesc:2*3.14159);
[x,y,R]=Fourier_Recons(Teta,An,Bn,0,0);
%
%R=R/mean(R)*mean(Rmax);
Ratio=norm(R-Rmax);
if max(R)/min(R)>4
    Ratio=Ratio+100*max(R)/min(R);
end
%D(1,1)=D(1,1)/max(R./Rmax);
return
%
Penal=0;
for i=1:Ndesc
    if R(i,1)>Rmax(i,1)
        Penal=Penal+10+1000*(R(i,1)-Rmax(i,1))/Rmax(i,1);
    end
end
if max(R)/min(R)>5
    Penal=Penal+100*max(R)/min(R);
end
Ratio=abs(FracCible-(polyarea(x,y)/Surface))+Penal;