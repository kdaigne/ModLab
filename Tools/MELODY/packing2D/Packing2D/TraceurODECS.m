function []=TraceurODECS(ODECS,Disposition,Cellules,Vertices,Couleurs,Axes,Plein);
figure1 = figure('PaperPosition',[0.6345 6.345 20.3 15.23],'PaperSize',[20.98 29.68],'color',[1,1,1]);
colordef black
set(figure1,'WindowStyle','docked')

xmin=Axes(1,1);
xmax=Axes(1,2);
ymin=Axes(1,3);
ymax=Axes(1,4);

for i=1:size(ODECS,1)
    if size(ODECS{i,1},1)>0
        Xc=Disposition(i,1);
        Yc=Disposition(i,2);
        Delta=Disposition(i,3);
        Cercles=zeros(size(ODECS{i,1},1),3);
        Cercles(:,1)=Xc+ODECS{i,1}(:,1)*Delta;
        Cercles(:,2)=Yc+ODECS{i,1}(:,2)*Delta;
        Cercles(:,3)=ODECS{i,1}(:,3)*Delta;
        Couleur=Couleurs(i,:);
        for j=1:size(Cercles,1)
            if Cercles(j,1)>xmin-(xmax-xmin)/10 & Cercles(j,1)<xmax+(xmax-xmin)/10 & Cercles(j,2)>ymin-(ymax-ymin)/10 & Cercles(j,2)<ymax+(ymax-ymin)/10
                plotcircle(Cercles(j,1),Cercles(j,2),Cercles(j,3),Plein,Couleur);hold on
            end
        end
    end
end
axis equal;axis(Axes)
title('Final Packing')