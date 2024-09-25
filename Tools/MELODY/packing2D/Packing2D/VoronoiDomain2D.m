function [X,Y,Vertices,Cellules]=VoronoiDomain2D(X,Y,Domain);
%type 1 : domaine polygonal connexe
%type 2 : rhéomètre de Couette
Npoints=size(X,1);
Xv=Domain(:,1);
Yv=Domain(:,2);
Stot=polyarea(Xv,Yv);
DistLim=3*sqrt(Stot/Npoints);
Ndroites=size(Xv,1)-1;
Droites=zeros(Ndroites,2);
Infinie=zeros(Ndroites,1);
for j=1:Ndroites
    if Xv(j+1,1)==Xv(j,1)
        Infinie(j,1)=1;
        Droites(j,1)=0;
        Droites(j,2)=Xv(j,1);
    else
        Droites(j,1)=(Yv(j+1,1)-Yv(j,1))/(Xv(j+1,1)-Xv(j,1));
        Droites(j,2)=Yv(j,1)-Droites(j,1)*Xv(j,1);
    end
end
liste=zeros(size(X,1),1);
Npoints=0;
for i=1:size(X,1)
    if inpolygon(X(i,1),Y(i,1),Xv,Yv)==1
        Npoints=Npoints+1;
        liste(Npoints,1)=i;
    end
end
liste=liste(1:Npoints,1);
X=X(liste,1);
Y=Y(liste,1);
[Vertices,Cellules]=voronoin(cat(2,X,Y));
liste=[];
for i=1:Npoints
    x=Vertices(transpose(Cellules{i,1}),1);
    y=Vertices(transpose(Cellules{i,1}),2);
    if min(Cellules{i,1})==1
        liste=cat(1,liste,[i]);
    else
        for j=1:size(x,1)
            if inpolygon(x(j,1),y(j,1),Xv,Yv)==0
                liste=cat(1,liste,[i]);
                break
            end
        end
    end
end
Nprob=size(liste,1);
Xadd=[];
Yadd=[];
for i=1:Nprob
    x=X(liste(i,1),1);
    y=Y(liste(i,1),1);
    for j=1:Ndroites
        if Infinie(j,1)==1
            b=Droites(j,2);
            dist=abs(x-b);
            if dist<DistLim
                Xadd=cat(1,Xadd,[x+2*(b-x)]);
                Yadd=cat(1,Yadd,[y]);
            end
        elseif Droites(j,1)==0
            b=Droites(j,2);
            dist=abs(y-b);
            if dist<DistLim
                Xadd=cat(1,Xadd,[x]);
                Yadd=cat(1,Yadd,[y+2*(b-y)]);
            end
        else
            a=Droites(j,1);
            b=Droites(j,2);
            dist=abs(a*x-y+b)/sqrt(1+a^2);
            if dist<DistLim
                xc=(y+x/a-b)/(a+1/a);
                yc=a*xc+b;
                Xadd=cat(1,Xadd,[x+2*(xc-x)]);
                Yadd=cat(1,Yadd,[y+2*(yc-y)]);
            end
        end
    end
end
[Vertices,Cellules]=voronoin(cat(2,cat(1,X,Xadd),cat(1,Y,Yadd)));
Cellules=Cellules(1:Npoints,1);