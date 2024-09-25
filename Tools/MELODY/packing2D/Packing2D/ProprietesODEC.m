function [Angle,L,S,Excentricite,Surface,Xc,Yc,Inertie,Req]=ProprietesODEC(Cercles)
ncercles=size(Cercles,1);
%Rots=zeros(36,ncercles,2);
%for i=1:36
%    angle=-5*(i-1)/180*3.1415927;
%    Rots(i,:,1)=cos(angle)*Cercles(:,1)-sin(angle)*Cercles(:,2);
%    Rots(i,:,2)=sin(angle)*Cercles(:,1)+cos(angle)*Cercles(:,2);
%end
%Dims=zeros(36,3);
%for i=1:36
%    Dims(i,1)=max(squeeze(Rots(i,:,1))+transpose(Cercles(:,3)))-min(squeeze(Rots(i,:,1))-transpose(Cercles(:,3)));
%    Dims(i,2)=max(squeeze(Rots(i,:,2))+transpose(Cercles(:,3)))-min(squeeze(Rots(i,:,2))-transpose(Cercles(:,3)));
%    Dims(i,3)=i;
%end
%Dims=sortrows(Dims,1);
%L=Dims(1,2);
%S=Dims(1,1);
%Angle=5*(Dims(1,3)-1);
%Excentricite=S/L;
%Centres=squeeze(Rots(Dims(1,3),:,:));

global Cercles_Largeur
Cercles_Largeur=Cercles;
%[angle,S]=fminbnd(@Largeur,-3.14159,3.14159);
ang=transpose(-3.14159/2:3.14159/16:3.14159/2);
for i=1:17
    ang(i,2)=Largeur(ang(i,1));
end
ang=sortrows(ang,2);
[angle,S]=fminsearch(@Largeur,ang(1,1));

if angle>3.14159/2
    angle=angle-3.14159;
elseif angle<-3.14159/2
    angle=angle+3.14159;
end
Centres=zeros(ncercles,2);
Centres(:,1)=cos(-angle)*Cercles(:,1)-sin(-angle)*Cercles(:,2);
Centres(:,2)=sin(-angle)*Cercles(:,1)+cos(-angle)*Cercles(:,2);
Angle=angle/3.14159*180;
L=max(Centres(:,1)+Cercles(:,3))-min(Centres(:,1)-Cercles(:,3));
Excentricite=S/L;

Limsx=[min(Centres(:,1)-Cercles(:,3)),max(Centres(:,1)+Cercles(:,3))];
Limsy=[min(Centres(:,2)-Cercles(:,3)),max(Centres(:,2)+Cercles(:,3))];

n=0;
nx=0;
ny=0;

%N=100000;
%for i=1:N
%    x=Limsx(1)+(Limsx(2)-Limsx(1))*rand;
%    y=Limsy(1)+(Limsy(2)-Limsy(1))*rand;
%    for j=1:ncercles
%        if sqrt((Centres(j,1)-x)^2+(Centres(j,2)-y)^2)<Cercles(j,3)
%            n=n+1;
%            nx=nx+x;
%            ny=ny+y;
%            break
%        end
%    end
%end

N=10000;
H=Halton1(N,2);
Lisx=Limsx(1)+(Limsx(2)-Limsx(1))*H(:,1);
Lisy=Limsy(1)+(Limsy(2)-Limsy(1))*H(:,2);
for i=1:N
    x=Lisx(i,1);
    y=Lisy(i,1);
    for j=1:ncercles
        if sqrt((Centres(j,1)-x)^2+(Centres(j,2)-y)^2)<Cercles(j,3)
            n=n+1;
            nx=nx+x;
            ny=ny+y;
            break
        end
    end
end

V=(Limsx(2)-Limsx(1))*(Limsy(2)-Limsy(1));
Surface=n/N*V;
nx=nx/N*V;
ny=ny/N*V;
Xcr=nx/Surface;
Ycr=ny/Surface;

n2=0;
for i=1:N
    x=Limsx(1)+(Limsx(2)-Limsx(1))*rand;
    y=Limsy(1)+(Limsy(2)-Limsy(1))*rand;
    for j=1:ncercles
        if sqrt((Centres(j,1)-x)^2+(Centres(j,2)-y)^2)<Cercles(j,3)
            n2=n2+(x-Xcr)^2+(y-Ycr)^2;
            break
        end
    end
end
Inertie=n2/N*V;
Xc=cos(Angle/180*3.14159)*Xcr-sin(Angle/180*3.14159)*Ycr;
Yc=sin(Angle/180*3.14159)*Xcr+cos(Angle/180*3.14159)*Ycr;
Req=sqrt(Surface/3.1415927);