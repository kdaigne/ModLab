function [ODECS,Disposition,Proprietes,Index,Compteur,Rapports]=Generation(Cellules,Surfaces,Vertices,D2,D3,Decay1,D8,Decay2,ElongMin,ElongMax,RapportCible);
global Cercles Points
Drapport=0.02;

NODEC=size(Cellules,1);
V=Vertices;
C=Cellules;
ODECS=cell(NODEC,1);
Disposition=zeros(NODEC,3);
Proprietes=zeros(NODEC,18);
Index=zeros(NODEC,1);
Compteur=zeros(NODEC,1);
Liste=transpose(1:NODEC);

for i=1:NODEC
    i
    Sortie=0;
    while Sortie==0
        %D2=0.3*rand;
        [Ce,Xconv,Yconv]=GenerateCircles(D2,D3,Decay1,D8,Decay2);
        [Angle,L,S,Excentricite,Surface,Xc,Yc,Inertie,Req]=ProprietesODEC(Ce);
        if ElongMin<S/L & S/L<ElongMax
            Sortie=1;
        end
    end
    poly=cat(2,Xconv,Yconv);
    %K=C{i,1};
    %Points=V(transpose(K),:);
    %POLY=cat(1,Points,Points(1,:));
    %[Angle,Xc,Yc,Delta]=Expansion(poly,POLY);
    
    Sortie=0;
    liste=Liste;
    liste(:,2)=transpose(1:size(liste,1));
    Max=10^10;
    compt=0;
    while Sortie==0
        compt=compt+1
        if size(liste,1)==0
            K=C{jmax,1};
            Points=V(transpose(K),:);
            POLY=cat(1,Points,Points(1,:));
            [Angle,Xc,Yc,Delta]=Expansion(poly,POLY);
            Index(i,1)=jmax;
            Liste=cat(1,Liste(1:numax-1,1),Liste(numax+1:size(Liste,1),1));
            Rapport=sqrt(Delta^2*Surface/Surfaces(jmax,1));
            Rapports(i,1)=Rapport;
            Sortie=1;
        else
            k=randint(1,1,[1,size(liste,1)]);
            num=liste(k,2);
            j=liste(k,1);
            liste=cat(1,liste(1:k-1,:),liste(k+1:size(liste,1),:));
            K=C{j,1};
            Points=V(transpose(K),:);
            POLY=cat(1,Points,Points(1,:));
            [Angle,Xc,Yc,Delta]=Expansion(poly,POLY);
            Rapport=sqrt(Delta^2*Surface/Surfaces(j,1));
            if Rapport>RapportCible-Drapport & Rapport<RapportCible+Drapport
                Sortie=1;
                Index(i,1)=j;
                Rapports(i,1)=Rapport;
                Liste=cat(1,Liste(1:num-1,1),Liste(num+1:size(Liste,1),1));
            elseif abs(Rapport-RapportCible)<Max
                Max=abs(Rapport-RapportCible);
                jmax=j;
                numax=num;
            end
        end
    end
    Compteur(i,1)=compt;
        
        
        
    
    Cercles=zeros(size(Ce,1),3);
    Cercles(:,1)=cos(Angle/180*3.14159)*Ce(:,1)-sin(Angle/180*3.14159)*Ce(:,2);
    Cercles(:,2)=sin(Angle/180*3.14159)*Ce(:,1)+cos(Angle/180*3.14159)*Ce(:,2);
    Cercles(:,3)=Ce(:,3);
    
    ODECS{i,1}=Cercles;
    Disposition(i,1)=Xc;
    Disposition(i,2)=Yc;
    Disposition(i,3)=Delta;
    
    %[Angle,L,S,Excentricite,Surface,Xc,Yc,Inertie,Req]=ProprietesODEC(Cercles);
    [TetaContourfin,RContourfin,XContourfin,YContourfin,Perimetre]=ContourFin(Cercles,0,0,500);
    [Xconv,Yconv,PerimetreConv]=ContourConvexe(XContourfin,YContourfin);
    [Xinsc,Yinsc,Rinsc]=RayonInscrit(XContourfin,YContourfin);
    [Xcirc,Ycirc,Rcirc]=RayonCirconscrit(Xconv,Yconv);
    [Inertie1,Xc1,Yc1,Inertie2,Xc2,Yc2]=DistMass(Cercles,Surface);
    
    Proprietes(i,1)=Angle;
    Proprietes(i,2)=L;
    Proprietes(i,3)=S;
    Proprietes(i,4)=Excentricite;
    Proprietes(i,5)=Surface;
    Proprietes(i,6)=Xc;
    Proprietes(i,7)=Yc;
    Proprietes(i,8)=Inertie;
    Proprietes(i,9)=Req;
    Proprietes(i,10)=PerimetreConv;
    Proprietes(i,11)=Rinsc;
    Proprietes(i,12)=Rcirc;
    Proprietes(i,13)=Xc1;
    Proprietes(i,14)=Yc1;
    Proprietes(i,15)=Inertie1;
    Proprietes(i,16)=Xc2;
    Proprietes(i,17)=Yc2;
    Proprietes(i,18)=Inertie2;
end