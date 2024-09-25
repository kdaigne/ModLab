function TraceIMC(X,Y,Xn,Yn,COVCible,AngleMoy,Rapport_Ani,SurfacesN,AnglesN,ElongationsN,Historique,CellulesN,VerticesN,Domain)
Npoints=size(X,1);
Stot=polyarea(Domain(:,1),Domain(:,2));
Ntranches=30;
Largeur=3;
Distance=1/sqrt(Npoints);
MoyCible=Stot/Npoints;
StdCible=COVCible*MoyCible;
[MuN,SigN]=Gauss_to_Log(MoyCible,StdCible);
Width=(2*Largeur*SigN)/Ntranches;
Edges=transpose(MuN-Largeur*SigN:Width:MuN+Largeur*SigN);
Centres=transpose(MuN-Largeur*SigN+Width/2:Width:MuN+Largeur*SigN-Width/2);
Cumul=normcdf(Edges,MuN,SigN);
HistoLogCible=zeros(size(Centres,1),1);
for i=1:size(Centres,1)
    HistoLogCible(i,1)=Cumul(i+1,1)-Cumul(i,1);
end
HistoAngleCible=zeros(18,1);
for i=1:18
    %if (i-0.5)*10-90>Anglemin & (i-0.5)*10-90<Anglemax
    %    HistoAngleCible(i,1)=1;
    %end
    %HistoAngleCible(i,1)=Cumul(i+1,1)-Cumul(i,1);
    angle=((i-0.5)*10-90)/180*3.14159;
    HistoAngleCible(i,1)=(1+Rapport_Ani)/(1-Rapport_Ani)+cos((angle-AngleMoy/180*3.14159)*2);
end
HistoAngleCible=HistoAngleCible/sum(HistoAngleCible);
[Vertices,Cellules]=voronoin(cat(2,X,Y));
[Surfaces,Angles,Elongations,Voisins]=PropVoronoi2D(X,Y,Vertices,Cellules);

Liste=zeros(size(Surfaces,1),1);
Num=0;
for i=1:size(Surfaces,1)
    if isnan(Surfaces(i,1))==1
        continue
    else
        Num=Num+1;
        Liste(Num,1)=i;
    end
end
Liste=Liste(1:Num,1);
Ncellules=size(Liste,1);
HistoLogIni=transpose(hist(log(Surfaces(Liste,:)),Centres))/Ncellules;
HistoAngleIni=transpose(hist(Angles(Liste,:),[-85:10:85]))/Ncellules;
HistoElongIni=transpose(hist(Elongations(Liste,:),[0.025:0.05:0.975]))/Ncellules;

Liste=zeros(size(SurfacesN,1),1);
Num=0;
for i=1:size(SurfacesN,1)
    if isnan(SurfacesN(i,1))==1
        continue
    else
        Num=Num+1;
        Liste(Num,1)=i;
    end
end
Liste=Liste(1:Num,1);
Ncellules=size(Liste,1);
HistoLogExp=transpose(hist(log(SurfacesN(Liste,:)),Centres))/Ncellules;
HistoAngleExp=transpose(hist(AnglesN(Liste,:),[-85:10:85]))/Ncellules;
HistoElongExp=transpose(hist(ElongationsN(Liste,:),[0.025:0.05:0.975]))/Ncellules;

%figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68]);
%set(figure1,'WindowStyle','docked')
%voronoi(X,Y);axis equal;%axis([min(Xdomain) max(Xdomain) min(Ydomain) max(Ydomain)])

figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68]);
set(figure1,'WindowStyle','docked')
for i=1:size(SurfacesN,1)
    x=cat(1,VerticesN(transpose(CellulesN{i,1}),1),VerticesN(CellulesN{i,1}(1,1),1));
    y=cat(1,VerticesN(transpose(CellulesN{i,1}),2),VerticesN(CellulesN{i,1}(1,1),2));
    plot(x,y,'-b');hold on
end
plot(Xn,Yn,'.b');axis equal;%axis([min(Xdomain) max(Xdomain) min(Ydomain) max(Ydomain)])
title('Constrained Voronoi Tessellation')

figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68]);
set(figure1,'WindowStyle','docked')
for i=1:size(Liste,1)
    x=cat(1,VerticesN(transpose(CellulesN{Liste(i,1),1}),1),VerticesN(CellulesN{Liste(i,1),1}(1,1),1));
    y=cat(1,VerticesN(transpose(CellulesN{Liste(i,1),1}),2),VerticesN(CellulesN{Liste(i,1),1}(1,1),2));
    patch(x,y,sqrt(SurfacesN(Liste(i,1),1)),'linestyle','none');hold on
    plot(x,y,'-k')
end
axis equal
title('Voronoi Cells Surfaces')

figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68]);
set(figure1,'WindowStyle','docked')
bar(Centres,cat(2,HistoLogIni,HistoLogExp));hold on;%plot(Centres,HistoLogCible,'-r','linewidth',3);
title('Voronoi Cells Surfaces')

figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68]);
set(figure1,'WindowStyle','docked')
for i=1:size(Liste,1)
    x=cat(1,VerticesN(transpose(CellulesN{Liste(i,1),1}),1),VerticesN(CellulesN{Liste(i,1),1}(1,1),1));
    y=cat(1,VerticesN(transpose(CellulesN{Liste(i,1),1}),2),VerticesN(CellulesN{Liste(i,1),1}(1,1),2));
    patch(x,y,AnglesN(Liste(i,1),1),'linestyle','none');hold on
    plot(x,y,'-b')
end
axis equal
title('Voronoi Cells Orientations')

figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68]);
set(figure1,'WindowStyle','docked')
bar([-85:10:85],cat(2,HistoAngleIni,HistoAngleExp));hold on;plot([-85:10:85],HistoAngleCible,'-r','linewidth',3);
title('Voronoi Cells Orientations')

figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68]);
set(figure1,'WindowStyle','docked')
plot(Historique(:,1),Historique(:,2),'-b');hold on
plot(Historique(:,1),Historique(:,3),'-r')
plot(Historique(:,1),Historique(:,4),'-g')
title('Convergence of Constrained Voronoi Tessellation')