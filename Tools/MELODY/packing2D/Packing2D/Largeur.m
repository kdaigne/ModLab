function width=Largeur(angle)
global Cercles_Largeur
Cercles=Cercles_Largeur;
Rots=zeros(size(Cercles,1),2);
%Rots(:,1)=cos(angle)*Cercles(:,1)-sin(angle)*Cercles(:,2);
Rots(:,2)=sin(-angle)*Cercles(:,1)+cos(-angle)*Cercles(:,2);
width=max(Rots(:,2)+Cercles(:,3))-min(Rots(:,2)-Cercles(:,3));