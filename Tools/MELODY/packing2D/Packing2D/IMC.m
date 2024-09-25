function [X,Y,Surfaces,Elongations,Angles,Historique,Cellules,Vertices]=IMC(X,Y,Domain,DistributionType,DistributionParameters,AngleMoy,Rapport_Ani,Niter,ErreurCible,Nom)
global x y
global Ntot Atot COV1 COV2 r Prop1 Nbins Fdim

[X,Y,Vertices,Cellules]=VoronoiDomain2D(X,Y,Domain);
[Surfaces,Angles,Elongations,Voisins]=PropVoronoi2D(X,Y,Vertices,Cellules);
Npoints=size(X,1);
Ncellules=Npoints;

Stot=polyarea(Domain(:,1),Domain(:,2));
Npoints=size(X,1);
Ntranches=max([10,min([floor(Npoints/20),50])]);
Largeur=3;
if strcmp(DistributionType,'GaussianA')
    % PARAMETRES : [COEFFICIENT DE VARIATION DE LA SURFACE]
    MoyCible=Stot/Npoints;
    StdCible=DistributionParameters*MoyCible;
    Width=(2*Largeur*StdCible)/Ntranches;
    Edges=transpose(MoyCible-Largeur*StdCible:Width:MoyCible+Largeur*StdCible);
    Centres=transpose(MoyCible-Largeur*StdCible+Width/2:Width:MoyCible+Largeur*StdCible-Width/2);
    Edges=Edges(find(Edges>0));
    Centres=Centres(size(Centres,1)-size(Edges,1)+2:end,1);
    Cumul=normcdf(Edges,MoyCible,StdCible)*Ncellules;
    HistoCible=zeros(size(Centres,1),1);
    for i=1:size(Centres,1)
        HistoCible(i,1)=Cumul(i+1,1)-Cumul(i,1);
    end
    HistoCible=HistoCible/sum(HistoCible)*Ncellules;
elseif strcmp(DistributionType,'LognormalA')
    % PARAMETRES : [COEFFICIENT DE VARIATION DE LA SURFACE]
    MoyCible=Stot/Npoints;
    StdCible=DistributionParameters*MoyCible;
    [MuN,SigN]=Gauss_to_Log(MoyCible,StdCible);
    Width=(2*Largeur*SigN)/Ntranches;
    Edges=transpose(MuN-Largeur*SigN:Width:MuN+Largeur*SigN);
    Centres=transpose(MuN-Largeur*SigN+Width/2:Width:MuN+Largeur*SigN-Width/2);
    Cumul=normcdf(Edges,MuN,SigN)*Ncellules;
    HistoCible=zeros(size(Centres,1),1);
    for i=1:size(Centres,1)
        HistoCible(i,1)=Cumul(i+1,1)-Cumul(i,1);
    end
    Centres=exp(Centres);
elseif strcmp(DistributionType,'UniformA')
    % PARAMETRES : [RATIO ENTRE PLUS GRANDE ET PLUS PETITE SURFACE]
    MoyCible=Stot/Npoints;
    Amin=2*MoyCible/(1+DistributionParameters);
    Amax=Amin*DistributionParameters;
    SpanCible=(Amax-Amin)/2;
    Width=(2*Largeur*SpanCible)/Ntranches;
    Edges=transpose(MoyCible-Largeur*SpanCible:Width:MoyCible+Largeur*SpanCible);
    Centres=transpose(MoyCible-Largeur*SpanCible+Width/2:Width:MoyCible+Largeur*SpanCible-Width/2);
    Edges=Edges(find(Edges>0));
    Centres=Centres(size(Centres,1)-size(Edges,1)+2:end,1);
    HistoCible=zeros(size(Centres,1),1);
    HistoCible(find(Centres>MoyCible-SpanCible & Centres<MoyCible+SpanCible))=1;
    HistoCible=HistoCible/sum(HistoCible)*Ncellules;
elseif strcmp(DistributionType,'UniformD')
    % PARAMETRES : [RATIO ENTRE PLUS GRAND ET PLUS PETIT DIAMETRE EQUIVALENT]
    Ntot=Ncellules;
    Atot=Stot;
    r=DistributionParameters;
    Dmin=fminsearch(@Optim_UniformD,sqrt(Atot/Ntot));
    Dmax=r*Dmin;
    Width=(1.2*Dmax-0.8*Dmin)/Ntranches;
    Edges=transpose(0.8*Dmin:Width:1.2*Dmax);
    Centres=transpose(0.8*Dmin+Width/2:Width:1.2*Dmax-Width/2);
    Edges=Edges(find(Edges>0));
    Centres=Centres(size(Centres,1)-size(Edges,1)+2:end,1);
    HistoCible=zeros(size(Centres,1),1);
    HistoCible(find(Centres>Dmin & Centres<Dmax))=1;
    HistoCible=HistoCible/sum(HistoCible)*Ncellules;
    Edges=pi/4*Edges.^2;
    Centres=pi/4*Centres.^2;
elseif strcmp(DistributionType,'BimodalA')
    % PARAMETRES : [COV_SURFACES1, COV_SURFACES2, MOYENNE_SURFACES2/MOYENNE_SURFACES1, PROPORTION SURFACES1 EN PIC D'EFFECTIF]
    Ntot=Ncellules;
    Atot=Stot;
    COV1=DistributionParameters(1);
    COV2=DistributionParameters(2);
    r=DistributionParameters(3);
    Prop1=DistributionParameters(4);
    Nbins=Ntranches;
    Moy=Stot/Npoints;
    Param=fminsearch(@Optim_BimodalA,[Atot/Ntot,Ntot/Nbins]);
    Mu1=Param(1);
    Sig1=Mu1*COV1;
    N1=Param(2);
    Mu2=Mu1*r;
    Sig2=Mu2*COV2;
    N2=N1/Prop1;
    [a,n]=Bimodal(Mu1,Sig1,N1,Mu2,Sig2,N2,Nbins);
    %Edges=a';
    %HistoCible=((n(2:end)+n(1:end-1))/2)';
    %Centres=(Edges(2:end)+Edges(1:end-1))/2;
    HistoCible=n';
    Centres=d';
    %
    HistoCible=HistoCible(find(Centres>0));
    Centres=Centres(find(Centres>0));
    HistoCible=HistoCible/sum(HistoCible)*Ncellules;
elseif strcmp(DistributionType,'BimodalD')
    % PARAMETRES : [COV_DIAMETRES1, COV_DIAMETRES2, MOYENNE_DIAMETRES2/MOYENNE_DIAMETRES1, PROPORTION DIAMETRES1 EN PIC D'EFFECTIF]
    Ntot=Ncellules;
    Atot=Stot;
    COV1=DistributionParameters(1);
    COV2=DistributionParameters(2);
    r=DistributionParameters(3);
    Prop1=DistributionParameters(4);
    Nbins=Ntranches;
    Moy=Stot/Npoints;
    Param=fminsearch(@Optim_BimodalD,[sqrt(Atot/Ntot),Ntot/Nbins]);
    Mu1=Param(1);
    Sig1=Mu1*COV1;
    N1=Param(2);
    Mu2=Mu1*r;
    Sig2=Mu2*COV2;
    N2=N1/Prop1;
    [d,n]=Bimodal(Mu1,Sig1,N1,Mu2,Sig2,N2,Nbins);
    %Edges=pi/4*sign(d').*(d').^2;
    %HistoCible=((n(2:end)+n(1:end-1))/2)';
    %Centres=(Edges(2:end)+Edges(1:end-1))/2;
    HistoCible=n';
    Centres=pi/4*sign(d').*(d').^2;
    %
    HistoCible=HistoCible(find(Centres>0));
    Centres=Centres(find(Centres>0));
    HistoCible=HistoCible/sum(HistoCible)*Ncellules;
elseif strcmp(DistributionType,'BimodalLogD')
    % PARAMETRES : [COV_DIAMETRES1, COV_DIAMETRES2, MOYENNE_DIAMETRES2/MOYENNE_DIAMETRES1, PROPORTION DIAMETRES1 EN PIC D'EFFECTIF]
    Ntot=Ncellules;
    Atot=Stot;
    COV1=DistributionParameters(1);
    COV2=DistributionParameters(2);
    r=DistributionParameters(3);
    Prop1=DistributionParameters(4);
    Nbins=Ntranches;
    Moy=Stot/Npoints;
    Param=fminsearch(@Optim_BimodalLogD,[sqrt(Atot/Ntot),Ntot/Nbins]);
    Mu1=Param(1);
    Sig1=Mu1*COV1;
    [MuN1,SigN1]=Gauss_to_Log(Mu1,Sig1);
    N1=Param(2);
    Mu2=Mu1*r;
    Sig2=Mu2*COV2;
    [MuN2,SigN2]=Gauss_to_Log(Mu2,Sig2);
    N2=N1/Prop1;
    [logd,n]=Bimodal(MuN1,SigN1,N1,MuN2,SigN2,N2,Nbins);
    d=exp(logd);
    %Edges=pi/4*sign(d').*(d').^2;
    %HistoCible=((n(2:end)+n(1:end-1))/2)';
    %Centres=(Edges(2:end)+Edges(1:end-1))/2;
    HistoCible=n';
    Centres=pi/4*sign(d').*(d').^2;
    %
    HistoCible=HistoCible(find(Centres>0));
    Centres=Centres(find(Centres>0));
    HistoCible=HistoCible/sum(HistoCible)*Ncellules;
elseif strcmp(DistributionType,'FractalD')
    % PARAMETRES : [FRACTAL-DIMENSION]
    Moy=Stot/Npoints;
    Ntot=Ncellules;
    Atot=Stot;
    Fdim=DistributionParameters;
    Nbins=Ntranches;
    Param=fminsearch(@Optim_FractalD,[0.5*sqrt(Moy),2*sqrt(Moy)]);
    Dmin=Param(1);
    Dmax=Param(2);
    [d,n]=Fractal(Dmin,Dmax,Fdim,Nbins);
    HistoCible=n';
    Centres=pi/4*sign(d').*(d').^2;
    HistoCible=HistoCible/sum(HistoCible)*Ncellules;
    Dcentres=Centres(2)-Centres(1);
    Centres=[Centres(1)-Dcentres;Centres];
    Centres=[Centres(1)-Dcentres;Centres];
    Centres=[Centres(1)-Dcentres;Centres];
    Centres=[Centres(1)-Dcentres;Centres];
    HistoCible=[0;0;0;0;HistoCible];
end
w=Centres(2:end)-Centres(1:end-1);w(end+1)=w(end);
    
HistoAngleCible=zeros(18,1);
for i=1:18
    angle=((i-0.5)*10-90)/180*3.14159;
    HistoAngleCible(i,1)=(1+Rapport_Ani)/(1-Rapport_Ani)+cos((angle-AngleMoy/180*3.14159)*2);
end
HistoAngleCible=HistoAngleCible/sum(HistoAngleCible)*Ncellules;

HistoExp=transpose(hist(Surfaces,Centres));
Erreur1=sqrt(sum(w.*(HistoCible/Ncellules-HistoExp/Ncellules).^2)/sum(w))/(sum(w.*HistoCible/Ncellules)/sum(w)); %Erreur sur les surfaces
%Erreur1=sum(w.*abs(HistoCible/Ncellules-HistoExp/Ncellules))/sum(w.*HistoCible/Ncellules); %Erreur sur les surfaces
%Erreur1=mean(abs((HistoCible-HistoExp)./(HistoCible+1)));
HistoAngleExp=transpose(hist(Angles,[-85:10:85]));
HistoAngleIni=HistoAngleExp;
Erreur2=sqrt(mean((HistoAngleCible/Ncellules-HistoAngleExp/Ncellules).^2)); %Erreur sur les angles
Erreur=max([Erreur1,Erreur2])

figure
%FIG=bar(Centres,HistoExp,'b',);
FIG=plot(Centres,HistoExp,'-b');
hold on
plot(Centres,HistoCible,'.r','markersize',10)

Historique=[1,Erreur1,Erreur2,Erreur];
Compteur=2;
while Erreur>ErreurCible & Compteur<Niter
    NumPoint=randint(1,1,[1,Npoints]);
    xmi=min(Vertices(transpose(Cellules{NumPoint,1}),1));
    ymi=min(Vertices(transpose(Cellules{NumPoint,1}),2));
    xma=max(Vertices(transpose(Cellules{NumPoint,1}),1));
    yma=max(Vertices(transpose(Cellules{NumPoint,1}),2));
    nvois=size(Voisins{NumPoint,1},2);
    for i=1:nvois
        if min(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),1))<xmi
            xmi=min(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),1));
        end
        if min(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),2))<ymi
            ymi=min(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),2));
        end
        if max(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),1))>xma
            xma=max(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),1));
        end
        if max(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),2))>yma
            yma=max(Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),2));
        end
    end
    Xco=Vertices(transpose(Cellules{NumPoint,1}),1);
    Xco=cat(1,Xco,Xco(1,1));
    Yco=Vertices(transpose(Cellules{NumPoint,1}),2);
    Yco=cat(1,Yco,Yco(1,1));
    OK=0;
    while OK==0
        xtir=xmi+rand*(xma-xmi);
        ytir=ymi+rand*(yma-ymi);
        if inpolygon(xtir,ytir,Xco,Yco)==1
            OK=1;
            break
        end
        for i=1:nvois
            Xvois=Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),1);
            Xvois=cat(1,Xvois,Xvois(1,1));
            Yvois=Vertices(transpose(Cellules{Voisins{NumPoint,1}(1,i),1}),2);
            Yvois=cat(1,Yvois,Yvois(1,1));
            if inpolygon(xtir,ytir,Xvois,Yvois)==1
                OK=1;
                break
            end
        end
    end
    Angle=AnglePolaire(xtir-X(NumPoint,1),ytir-Y(NumPoint,1));
    Distance=sqrt((xtir-X(NumPoint,1))^2+(ytir-Y(NumPoint,1))^2);
    [Xn,Yn,VoisinsN,VerticesN,CellulesN,SurfacesN,AnglesN,ElongationsN]=UpdateVoronoi(X,Y,Domain,NumPoint,Distance,Angle,Voisins,Vertices,Cellules,Surfaces,Angles,Elongations);
        
    HistoExp=transpose(hist(SurfacesN,Centres));
    ErreurN1=sqrt(sum(w.*(HistoCible/Ncellules-HistoExp/Ncellules).^2)/sum(w))/(sum(w.*HistoCible/Ncellules)/sum(w)); %Erreur sur les surfaces
    %ErreurN1=sum(w.*abs(HistoCible/Ncellules-HistoExp/Ncellules))/sum(w.*HistoCible/Ncellules); %Erreur sur les surfaces
    %ErreurN1=mean(abs((HistoCible-HistoExp)./(HistoCible+1)));
    HistoAngleExp=transpose(hist(AnglesN,[-85:10:85]));
    ErreurN2=sqrt(mean((HistoAngleCible/Ncellules-HistoAngleExp/Ncellules).^2)); %Erreur sur les angles
    ErreurN=max([ErreurN1,ErreurN2]);
    
    if ErreurN<Erreur
        set(FIG,'YData',HistoExp);
        drawnow
        Compteur
        X=Xn;
        Y=Yn;
        Erreur=ErreurN
        Voisins=VoisinsN;
        Vertices=VerticesN;
        Cellules=CellulesN;
        Surfaces=SurfacesN;
        Angles=AnglesN;
        Elongations=ElongationsN;
        Historique(size(Historique,1)+1,1)=Compteur;
        Historique(size(Historique,1),2)=ErreurN1;
        Historique(size(Historique,1),3)=ErreurN2;
        Historique(size(Historique,1),4)=ErreurN;
        %save(Nom,'Historique')
        %save([Nom ' ' int2str(Compteur) '.mat'])
        %save(Nom)
    end
    Compteur=Compteur+1;
end

[X,Y,Vertices,Cellules]=VoronoiDomain2D(X,Y,Domain);
[Surfaces,Angles,Elongations,Voisins]=PropVoronoi2D(X,Y,Vertices,Cellules);
