clear
rand('state',sum(100*clock))
global D2 D3 Decay1 D8 Decay2 Rmax Ndesc Dtail NVAR FracCible Surface TypeSpectre FileSpectre COVSpectre Cn TypeCOV

Nom='a.mat';

Npoints=100; %Number of generated points in the rectangular domain
COVCible=0.2; %Target COV of the grains surfaces
AngleMoy=0; %Angle of main orientation
Rapport_Ani=0.9999; %Ratio of anisotropy
TypeDistribution=2; %1:Uniform Distribution ; 2:Halton Series
TypeDomain=1; %1:polygon ; 2:Rheometer
%Domain=[0;0;10;25];
Domain=[1,0;10,16;10,40;-10,40;-10,16;-1,0;1,0]; %(must be closed)
Niter=100; %Number of iterations for IMC
ErreurCible=0.002; %Target error for IMC

FracCible=0.5; %Target solid fraction
NVAR=6; %Number of optimization variables for the filling algorithm
COVSpectre=0; %COV of the Fourier descriptors
TypeCOV=1; %0:Modes vary individually ; 1:Spectrum varies altogether
TypeSpectre=1; %0:Automatic spectrum ; 1:Existing spectrum
FileSpectre='Spectrum_Toyoura.mat'; %Name of a Spectrum file
D2=10^-10;
D3=10^-10;
Decay1=-2;
D8=10^-10;
Decay2=-2;



if TypeDistribution==1
    Sample=rand(Npoints,2);
elseif TypeDistribution==2
    Sample=Halton1(Npoints,2);
end
if TypeDomain==1
    xmin=min(Domain(:,1));
    xmax=max(Domain(:,1));
    ymin=min(Domain(:,2));
    ymax=max(Domain(:,2));
    Xini=xmin+Sample(:,1)*(xmax-xmin);
    Yini=ymin+Sample(:,2)*(ymax-ymin);
    X=[];
    Y=[];
    for i=1:size(Xini,1)
        if inpolygon(Xini(i,1),Yini(i,1),Domain(:,1),Domain(:,2))==1
            X=cat(1,X,[Xini(i,1)]);
            Y=cat(1,Y,[Yini(i,1)]);
        end
    end
    Npoints=size(X,1);   
elseif TypeDomain==2
    xmin=Domain(1,1)-Domain(4,1);
    xmax=Domain(1,1)+Domain(4,1);
    ymin=Domain(2,1)-Domain(4,1);
    ymax=Domain(2,1)+Domain(4,1);
    Xini=xmin+Sample(:,1)*(xmax-xmin);
    Yini=ymin+Sample(:,2)*(ymax-ymin);
    X=[];
    Y=[];
    for i=1:size(Xini,1)
        if sqrt((Xini(i,1)-Domain(1,1))^2+(Yini(i,1)-Domain(2,1))^2)>Domain(3,1) & sqrt((Xini(i,1)-Domain(1,1))^2+(Yini(i,1)-Domain(2,1))^2)<Domain(4,1)
            X=cat(1,X,[Xini(i,1)]);
            Y=cat(1,Y,[Yini(i,1)]);
        end
    end
    Npoints=size(X,1); 
end

[Xn,Yn,Surfaces,Elongations,Angles,Historique,Cellules,Vertices]=IMC(X,Y,TypeDomain,Domain,COVCible,AngleMoy,Rapport_Ani,Niter,ErreurCible,Nom);
save(Nom)
Couleurs=rand(size(Cellules,1),3);
Disposition=zeros(Npoints,3);
Disposition(:,3)=ones(Npoints,1);
ODECS=cell(Npoints,1);
Proprietes=zeros(Npoints,23);
for i=1:Npoints
    i
    Cell=Vertices(transpose(Cellules{i,1}),:);
    x=Cell(:,1);y=Cell(:,2);
    K=convhull(Cell(:,1),Cell(:,2));Xcell=x(K,1);Ycell=y(K,1);
    [Cercles,Xconv,Yconv]=FillCell(D2,D3,Decay1,D8,Decay2,Xcell,Ycell,NVAR,FracCible);
    ODECS{i,1}=Cercles;
    
    [Angle,L,S,Excentricite,Surface,Xc,Yc,Inertie,Req]=ProprietesODEC(Cercles);
    [TetaContourfin,RContourfin,XContourfin,YContourfin,Perimetre]=ContourFin(Cercles,Xc,Yc,500);
    [Xconv,Yconv,PerimetreConv]=ContourConvexe(XContourfin-Xc,YContourfin-Yc);
    [Xinsc,Yinsc,Rinsc]=RayonInscrit(XContourfin-Xc,YContourfin-Yc);
    [Xcirc,Ycirc,Rcirc]=RayonCirconscrit(Xconv,Yconv);
    [Inertie1,Xc1,Yc1,Inertie2,Xc2,Yc2]=DistMass(Cercles,Surface);
    
    Proprietes(i,1)=size(Cercles,1);
    Proprietes(i,2)=Angle;
    Proprietes(i,3)=L;
    Proprietes(i,4)=S;
    Proprietes(i,5)=Excentricite; %Elongation
    Proprietes(i,6)=Surface;
    Proprietes(i,7)=Perimetre;
    Proprietes(i,8)=Xc;
    Proprietes(i,9)=Yc;
    Proprietes(i,10)=Inertie;
    Proprietes(i,11)=Req;
    Proprietes(i,12)=PerimetreConv;
    Proprietes(i,13)=Rinsc;
    Proprietes(i,14)=Rcirc;
    Proprietes(i,15)=Xc1;
    Proprietes(i,16)=Yc1;
    Proprietes(i,17)=Inertie1;
    Proprietes(i,18)=Xc2;
    Proprietes(i,19)=Yc2;
    Proprietes(i,20)=Inertie2;
    Proprietes(i,21)=mean(Cercles(1,3))/Rinsc; %Roundness
    Proprietes(i,22)=(Rinsc/Rcirc)^0.5; %Circularity
    Proprietes(i,23)=-log10((Perimetre-PerimetreConv)./Perimetre); %Regularity
end
[PDFAnglesExp,PDFSurfacesExp,PDFElongsExp,PDFRoundExp,PDFCircExp,PDFRegulExp,SolidFraction,VoidRatio,D10,D50,Cu]=Statistics(Proprietes,ODECS,TypeDomain,Domain);
save(Nom)


TraceIMC(X,Y,Xn,Yn,COVCible,AngleMoy,Rapport_Ani,Surfaces,Angles,Elongations,Historique,Cellules,Vertices,TypeDomain,Domain);
TraceurODECS(ODECS,Disposition,Cellules,Vertices,Couleurs,[xmin xmax ymin ymax],1);
%TraceurODECS(ODECS,Disposition,Cellules,Vertices,Couleurs,[0.45,0.55,0.45,0.55],1);
%TraceurODECS(ODECS,Disposition,Cellules,Vertices,Couleurs,[0.45,0.55,0.45,0.55],0);
%TraceurODECS_Coul(ODECS,Disposition,Cellules,Vertices,Surfaces,[0,1,0,1],1);