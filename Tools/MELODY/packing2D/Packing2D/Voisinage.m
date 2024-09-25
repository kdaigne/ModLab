function Voisins=Voisinage(X,Y,Triangulation)
Npoints=size(X,1);
Voisins=cell(Npoints,1);
Triangulation=transpose(sort(transpose(Triangulation)));
Triangulation=sortrows(Triangulation,[1,2,3]);
for i=1:size(Triangulation,1)
    Voisins{Triangulation(i,1),1}(1,size(Voisins{Triangulation(i,1),1},2)+1)=Triangulation(i,2);
    Voisins{Triangulation(i,1),1}(1,size(Voisins{Triangulation(i,1),1},2)+1)=Triangulation(i,3);
    Voisins{Triangulation(i,2),1}(1,size(Voisins{Triangulation(i,2),1},2)+1)=Triangulation(i,1);
    Voisins{Triangulation(i,2),1}(1,size(Voisins{Triangulation(i,2),1},2)+1)=Triangulation(i,3);
    Voisins{Triangulation(i,3),1}(1,size(Voisins{Triangulation(i,3),1},2)+1)=Triangulation(i,1);
    Voisins{Triangulation(i,3),1}(1,size(Voisins{Triangulation(i,3),1},2)+1)=Triangulation(i,2);
end
for i=1:Npoints
    %Voisins{i,1}=transpose(sort(transpose(Voisins{i,1})));
    %lis=1:2:size(Voisins{i,1},2);
    %Voisins{i,1}=Voisins{i,1}(1,lis);
    Voisins{i,1}=transpose(SqueezeList(transpose(Voisins{i,1})));
end