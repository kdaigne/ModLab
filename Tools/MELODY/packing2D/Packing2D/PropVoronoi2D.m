function [Surfaces,Angles,Elongations,Voisins]=PropVoronoi2D(X,Y,Vertices,Cellules)
global x y
Npoints=size(X,1);
Surfaces=zeros(Npoints,1);
Angles=zeros(Npoints,1);
Elongations=zeros(Npoints,1);

for i=1:Npoints
    x=Vertices(Cellules{i,1},1);
    y=Vertices(Cellules{i,1},2);
    %if min(x)>0 & max(x)<1 & min(y)>0 & max(y)<1
        Surfaces(i,1)=polyarea(x,y);
        [angle,S]=fminbnd(@Width,-3.14159,3.14159);
        yn=cos(-angle)*x-sin(-angle)*y;
        L=max(yn)-min(yn);
        if S>L
            l=S;
            S=L;
            L=l;
        end
        angle=angle/3.14159*180;
        if angle>90
            Angles(i,1)=angle-180;
        elseif angle<-90
            Angles(i,1)=angle+180;
        else
            Angles(i,1)=angle;
        end
        Elongations(i,1)=S/L;
    %else
    %    Surfaces(i,1)=NaN;
    %    Angles(i,1)=NaN;
    %    Elongations(i,1)=NaN;
    %end
end
Triangulation=delaunay(X,Y);
Voisins=Voisinage(X,Y,Triangulation);