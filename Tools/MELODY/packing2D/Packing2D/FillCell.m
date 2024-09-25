function [Cercles,Xconv,Yconv,Contour,An,Bn,Xcr,Ycr]=FillCell(D2,D3,Decay1,D8,Decay2,Xcell,Ycell,NVAR,FracCible,dmin,rmin,pmax,flag_RA);
global Rmax Ndesc Dtail Surface COVSpectre TypeSpectre FileSpectre Cn TypeCOV
options=optimset('TolX',1e-3,'TolFun',1e-3,'MaxFunEvals',10^10,'MaxIter',10^10);
Ndesc=128;
limite=8;

%% Determination of the centre of mass %%
N=1000;
H=Halton1(N,2);
Lisx=min(Xcell)+(max(Xcell)-min(Xcell))*H(:,1);
Lisy=min(Ycell)+(max(Ycell)-min(Ycell))*H(:,2);
A=inpolygon(Lisx,Lisy,Xcell,Ycell);
n=0;nx=0;ny=0;
for i=1:N
    if A(i,1)==1
        n=n+1;
        nx=nx+Lisx(i,1);
        ny=ny+Lisy(i,1);
    end
end
V=(max(Xcell)-min(Xcell))*(max(Ycell)-min(Ycell));
Surface=n/N*V;
nx=nx/N*V;
ny=ny/N*V;
Xcr=nx/Surface;
Ycr=ny/Surface;

%% Determination of the maximum radius for each angle value %%
Teta=transpose(0:2*3.14159/Ndesc:2*3.14159);
Tetac=zeros(size(Xcell,1),1);
Droites=zeros(size(Xcell,1)-1,2);
for i=1:size(Tetac,1)-1
    Tetac(i,1)=AnglePolaire(Xcell(i,1)-Xcr,Ycell(i,1)-Ycr);
    if (Xcell(i+1,1)-Xcell(i,1))~=0
        Droites(i,1)=(Ycell(i+1,1)-Ycell(i,1))/(Xcell(i+1,1)-Xcell(i,1));
    else
        Droites(i,1)=10^10;
    end
    Droites(i,2)=Ycell(i,1)-Droites(i,1)*Xcell(i,1);
end
Tetac(i+1,1)=AnglePolaire(Xcell(i+1,1)-Xcr,Ycell(i+1,1)-Ycr);
Rmax=zeros(Ndesc+1,1);
for i=1:size(Rmax,1)
    if Teta(i,1)>max(Tetac) | Teta(i,1)<min(Tetac)
        for j=1:size(Droites,1)
            if Tetac(j,1)==max(Tetac)
                a1=Droites(j,1);
                b1=Droites(j,2);
                break
            end
        end
    else
        for j=1:size(Droites,1)
            if (Tetac(j,1)<=Teta(i,1) & Teta(i,1)<=Tetac(j+1,1))
                a1=Droites(j,1);
                b1=Droites(j,2);
                break
            end
        end
    end
    a2=tan(Teta(i,1));
    b2=Ycr-a2*Xcr;
    Xi=(b1-b2)/(a2-a1);
    Yi=a1*Xi+b1;
    Rmax(i,1)=sqrt((Xcr-Xi)^2+(Ycr-Yi)^2);
end
    
%% Cell Filling %%
%Dtail=rand(Ndesc-(NVAR+1),1)*2*3.14159-3.14159;
Dtail=rand(Ndesc-(NVAR+1),1)*3.14159;
N=size(Rmax,1);
An=zeros(N,1);
Bn=zeros(N,1);
for i=0:N-1
    for j=1:N
        An(i+1,1)=An(i+1,1)+Rmax(j,1)*cos(i*Teta(j,1))*(2*3.14159/N);
        Bn(i+1,1)=Bn(i+1,1)+Rmax(j,1)*sin(i*Teta(j,1))*(2*3.14159/N);
    end
end
An=N*An/(2*3.14159);
Bn=N*Bn/(2*3.14159);
Dini=cat(1,mean(Rmax),zeros(NVAR,1));
for i=1:NVAR+1
    Dini(i+1,1)=AnglePolaire(An(i,1),Bn(i,1))-pi;
end
[MuN,SigN]=Gauss_to_Log(1,COVSpectre);
if TypeSpectre==0
    [Cn]=Spectre(Ndesc,1,10^-10,D2,D3,Decay1,D8,Decay2);
else
    load(FileSpectre)
end
if TypeCOV==0
    FactCOV=exp(MuN+SigN*randn(size(Cn,1)-2,1));
elseif TypeCOV==1
    FactCOV=exp(MuN+SigN*randn)*ones(size(Cn,1)-2,1);
end
Cn(3:size(Cn,1),1)=Cn(3:size(Cn,1),1).*FactCOV;
%
[Dfin,Ratio]=fminsearch(@FourierExp,[Dini],options);
%


%
%Dtemp=Dini(1);
%Dtail=rand(Ndesc,1)*2*3.14159-3.14159;
%for i=2:NVAR
%    Dtemp=[Dtemp;Dtail(1)];
%    Dtail=Dtail(2:size(Dtail,1),:);
%    [Dtemp,Ratio]=fminsearch(@FourierExp,[Dtemp],options);
%end
%Dfin=Dtemp;
%





%% ODECS Algorithm %%
D0=Dfin(1,1);
D1=0.0001;
Dn=Dfin(2:size(Dfin,1),1);
Dn=cat(1,Dfin(2:size(Dfin,1),1),Dtail);
%if flag_RA==1
%    Rot=2*pi*rand;
%    Dn(2:end)=Dn(2:end)+Rot;
%end

if TypeSpectre==0
    [Cn]=Spectre(Ndesc,1,10^-10,D2,D3,Decay1,D8,Decay2);
else
    load(FileSpectre)
end
Cn(3:size(Cn,1),1)=Cn(3:size(Cn,1),1).*FactCOV;
Cn=Cn*D0;
An=Cn.*cos(Dn);
Bn=Cn.*sin(Dn);
Teta=transpose(0:2*3.14159/Ndesc:2*3.14159);
[x,y,R]=Fourier_Recons(Teta,An,Bn,Xcr,Ycr);
%
if flag_RA==1
    irot=1+ceil(126*rand);
    R=[R(irot:end);R(1:irot-1)];
    ratio1=max(R./Rmax);
    ratio2=sqrt((polyarea(x,y)/Surface)/FracCible);
    R=R/max([ratio1,ratio2]);
    x=R.*cos(Teta)+Xcr;
    y=R.*sin(Teta)+Ycr;
else
    ratio1=max(R./Rmax);
    ratio2=sqrt((polyarea(x,y)/Surface)/FracCible);
    Cn=Cn/max([ratio1,ratio2]);
    An=Cn.*cos(Dn);
    Bn=Cn.*sin(Dn);
    [x,y,R]=Fourier_Recons(Teta,An,Bn,Xcr,Ycr);
end

%
dmin=dmin*D0;
rmin=rmin*D0;
[Cercles]=Remplissage_Cercles(x-Xcr,y-Ycr,dmin,rmin,pmax);
Cercles(:,1)=Cercles(:,1)+Xcr;
Cercles(:,2)=Cercles(:,2)+Ycr;
%
K=convhull(x,y);
Xconv=x(K,1);
Yconv=y(K,1);
%
Solid_Fraction=polyarea(x,y)/Surface
%figure;plot(Rmax,'-r');hold on;plot(R,'-b')
%Cercles=[];Xconv=[];Yconv=[];

Contour=[x,y,R,Teta];