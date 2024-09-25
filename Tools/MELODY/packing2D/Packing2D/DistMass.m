function [Inertie1,Xc1,Yc1,Inertie2,Xc2,Yc2]=DistMass(Cercles,Surface)
%Cas 1 : densité constante sur tous les cercles
%Cas 2 : masse constante sur tous les cercles

Mi1=Cercles(:,3).^2;
Mi1=Mi1/sum(Mi1)*Surface;
Mi2=ones(size(Cercles,1))*Surface/size(Cercles,1);

Inertie1=0;
Xc1=0;
Yc1=0;
Inertie2=0;
Xc2=0;
Yc2=0;
for i=1:size(Cercles,1)
    Xc1=Xc1+Mi1(i,1)*Cercles(i,1);
    Yc1=Yc1+Mi1(i,1)*Cercles(i,2);
    Xc2=Xc2+Mi2(i,1)*Cercles(i,1);
    Yc2=Yc2+Mi2(i,1)*Cercles(i,2);
end
Xc1=Xc1/Surface;
Yc1=Yc1/Surface;
Xc2=Xc2/Surface;
Yc2=Yc2/Surface;
    
for i=1:size(Cercles,1)
    di1=sqrt((Cercles(i,1)-Xc1)^2+(Cercles(i,2)-Yc1)^2);
    di2=sqrt((Cercles(i,1)-Xc2)^2+(Cercles(i,2)-Yc2)^2);
    ri=Cercles(i,3);
    Inertie1=Inertie1+Mi1(i)*(ri^2/2+di1^2);
    Inertie2=Inertie2+Mi2(i)*(ri^2/2+di2^2);
end