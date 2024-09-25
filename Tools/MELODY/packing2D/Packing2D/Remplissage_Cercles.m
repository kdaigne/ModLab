function [Cercles]=Remplissage_Cercles(Xcontour,Ycontour,dmin,rmin,pmax)
ncont=size(Xcontour,1);
Ntirages=20;
Tirages=cell(Ntirages,1);
Nombres=zeros(Ntirages,1);
for k=1:Ntirages
    Cercles=zeros(1,3);
    PointsOK=ones(ncont,1);
    Ncercle=0;
    while sum(PointsOK)/ncont>pmax
        point=randint(1,1,[2,ncont-1]);
        if PointsOK(point,1)==1
            PointsOK(point,1)=0;
            [X,Y,R]=RmaxInscrit(Xcontour,Ycontour,point,0,0);
            if R>rmin
                Ncercle=Ncercle+1;
                Cercles(Ncercle,1)=X;
                Cercles(Ncercle,2)=Y;
                Cercles(Ncercle,3)=R;
                for i=1:ncont
                    if PointsOK(i,1)==0
                        continue
                    elseif sqrt((Xcontour(i,1)-X)^2+(Ycontour(i,1)-Y)^2)<R+dmin
                        PointsOK(i,1)=0;
                    end
                end
            end
        end
    end
    Tirages{k,1}=Cercles;
    Nombres(k,1)=size(Cercles,1);
    Nombres(k,2)=k;
end
Nombres=sortrows(Nombres,1);

SurfaceCible=polyarea(Xcontour,Ycontour);
k=0;
Sortie=0;
while Sortie==0
    k=k+1;
    Cercles=Tirages{Nombres(k,2),1};
    ncercles=Nombres(k,1);
    Limsx=[min(Cercles(:,1)-Cercles(:,3)),max(Cercles(:,1)+Cercles(:,3))];
    Limsy=[min(Cercles(:,2)-Cercles(:,3)),max(Cercles(:,2)+Cercles(:,3))];
    n=0;
    N=1000;
    H=Halton1(N,2);
    Lisx=Limsx(1)+(Limsx(2)-Limsx(1))*H(:,1);
    Lisy=Limsy(1)+(Limsy(2)-Limsy(1))*H(:,2);
    for i=1:N
        x=Lisx(i,1);
        y=Lisy(i,1);
        for j=1:ncercles
            if sqrt((Cercles(j,1)-x)^2+(Cercles(j,2)-y)^2)<Cercles(j,3)
                n=n+1;
                break
            end
        end
    end
    V=(Limsx(2)-Limsx(1))*(Limsy(2)-Limsy(1));
    SurfaceCercles=n/N*V;
    if (SurfaceCible-SurfaceCercles)/SurfaceCible<0.02 | k==Ntirages
        Sortie=1;
    end
end