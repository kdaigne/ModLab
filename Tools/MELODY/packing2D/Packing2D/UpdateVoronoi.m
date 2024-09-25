function [Xn,Yn,VoisinsN,VerticesN,CellulesN,SurfacesN,AnglesN,ElongationsN]=UpdateVoronoi(X,Y,Domain,Point,Distance,Angle,Voisins,Vertices,Cellules,Surfaces,Angles,Elongations)
global x y

Npoints=size(X,1);
Stot=polyarea(Domain(:,1),Domain(:,2));
Couches=0;
Erreur=1;
while Erreur==1
    Couches=Couches+1;
    OK=ones(Npoints,1);
    OK(Point,1)=0;
    Liste=Point;
    for compt=1:Couches
        for i=1:size(Liste,1)
            for j=1:size(Voisins{Liste(i,1),1},2)
                if OK(Voisins{Liste(i,1),1}(1,j))==1
                    OK(Voisins{Liste(i,1),1}(1,j))=0;
                    Liste=cat(1,Liste,Voisins{Liste(i,1),1}(1,j));
                end
            end
        end
    end
    ListePeri=[];
    for i=1:size(Liste,1)
        for j=1:size(Voisins{Liste(i,1),1},2)
            if OK(Voisins{Liste(i,1),1}(1,j))==1
                OK(Voisins{Liste(i,1),1}(1,j))=0;
                ListePeri=cat(1,ListePeri,Voisins{Liste(i,1),1}(1,j));
            end
        end
    end

    VertListe=[];
    for i=1:size(Liste,1)
        VertListe=cat(1,VertListe,transpose(Cellules{Liste(i,1),1}));
    end
    VertListe=SqueezeList(VertListe);
    VertListe(:,2:3)=Vertices(VertListe,:);

    dx=Distance*cos(Angle);
    dy=Distance*sin(Angle);
    Xn=X;
    Yn=Y;
    Xn(Point,1)=Xn(Point,1)+dx;
    Yn(Point,1)=Yn(Point,1)+dy;

    [xxx,yyy,VerticesN,C]=VoronoiDomain2D(Xn(cat(1,Liste,ListePeri),1),Yn(cat(1,Liste,ListePeri),1),Domain);

    Erreur=0;
    for i=1:size(C{1,1},2)
        NumV=C{1,1}(1,i);
        for j=size(Liste,1)+1:size(C,1)
            for k=1:size(C{j,1},2)
                if NumV==C{j,1}(1,k)
                    Erreur=1;
                    break
                end
            end
            if Erreur==1
                break
            end
        end
        if Erreur==1
            break
        end
    end
end

CellulesN=cell(size(Liste,1),1);
for i=1:size(Liste,1)
    CellulesN{i,1}=C{i,1};
end
VertListeN=[];
for i=1:size(Liste,1)
    VertListeN=cat(1,VertListeN,transpose(CellulesN{i,1}));
end
VertListeN=SqueezeList(VertListeN);
VertListeN(:,2:3)=VerticesN(VertListeN,:);
for i=1:size(VertListe,1)
    for j=1:size(VertListeN,1)
        if abs(VertListe(i,2)-VertListeN(j,2))<sqrt(Stot/Npoints)/10000 & abs(VertListe(i,3)-VertListeN(j,3))<sqrt(Stot/Npoints)/10000
            VertListe(i,4)=j;
            VertListeN(j,4)=VertListe(i,1);
        end
    end
end
if VertListeN(1,2)==Inf
    VertListeN(1,4)=1;
end
if VertListe(1,2)==Inf
    VertListe(1,4)=1;
end

VerticesN=Vertices;
num=1;
Vides=[];

for j=1:size(VertListe,1)
    if VertListe(j,4)==0
        Vides=cat(1,Vides,[VertListe(j,1)]);
        VerticesN(VertListe(j,1),:)=[0,0];
    end
end

num=0;
for j=1:size(VertListeN,1)
    if VertListeN(j,4)==0
        num=num+1;
        if num>size(Vides,1)
            Case=size(VerticesN,1)+1;
        else
            Case=Vides(num,1);
        end
        VerticesN(Case,:)=VertListeN(j,2:3);
        VertListeN(j,4)=Case;
    end
end

C=CellulesN;
CellulesN=Cellules;
for i=1:size(C,1)
    for j=1:size(C{i,1},2)
        for k=1:size(VertListeN,1)
            if C{i,1}(1,j)==VertListeN(k,1)
                C{i,1}(1,j)=VertListeN(k,4);
                break
            end
        end
    end
end

for j=1:size(Liste,1)
    i=Liste(j,1);
    CellulesN{i,1}=C{j,1};
end

l=cat(1,Liste,ListePeri);
Triangulation=delaunay(Xn(l,1),Yn(l,1));
V=Voisinage(Xn(l,1),Yn(l,1),Triangulation);
VN=cell(size(Liste,1),1);
for i=1:size(Liste,1)
    for j=1:size(V{i,1},2);
        VN{i,1}(1,j)=l(V{i,1}(1,j),1);
    end
end
SurfacesN=Surfaces;
AnglesN=Angles;
ElongationsN=Elongations;
VoisinsN=Voisins;
options=optimset('TolX',0.1,'TolFun',0.1);
for i=1:size(Liste,1)
    VoisinsN{Liste(i,1),1}=VN{i,1};
    x=VerticesN(CellulesN{Liste(i,1),1},1);
    y=VerticesN(CellulesN{Liste(i,1),1},2);
    SurfacesN(Liste(i,1),1)=polyarea(x,y);
    [angle,S]=fminbnd(@Width,-3.14159,3.14159);
    yn=sin(angle)*x+cos(angle)*y;
    L=max(yn)-min(yn);
    if S>L
        l=S;
        S=L;
        L=l;
    end
    angle=angle/3.14159*180;
    if angle>90
        AnglesN(Liste(i,1),1)=angle-180;
    elseif angle<-90
        AnglesN(Liste(i,1),1)=angle+180;
    else
        AnglesN(Liste(i,1),1)=angle;
    end
    ElongationsN(Liste(i,1),1)=S/L;
end
