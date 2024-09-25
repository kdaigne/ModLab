function TextFilePFC(ODECS,Proprietes,Walls,file)
%walls : active side on the left from point 1 to point 2 :
% better loop in the trigonometric direction

Densites=DiscMass(ODECS,Proprietes,2650,2);
Timestep=0;
NumClump=size(Walls,1);
NumWall=0;
NumCercle=size(ODECS,1)+size(Walls,1);

fid = fopen(file,'w');
for i=1:size(Walls,1)
    NumWall=NumWall+1;
    fprintf(fid,'%8s','wall id=');
    fprintf(fid,'%10.0f',NumWall);
    fprintf(fid,'%8s',' nodes (');
    fprintf(fid,'%10.10f',Walls(i,1)/1000);
    fprintf(fid,'%3s',' , ');
    fprintf(fid,'%10.10f',Walls(i,2)/1000);
    fprintf(fid,'%3s',') (');
    fprintf(fid,'%10.10f',Walls(i,3)/1000);
    fprintf(fid,'%3s',' , ');
    fprintf(fid,'%10.10f\n',Walls(i,4)/1000);
end

for i=1:size(ODECS,1)
    NumClump=NumClump+1;
    Cercles=ODECS{i,1};
    NumIni=NumCercle+1;
    for j=1:size(Cercles,1)
        NumCercle=NumCercle+1;
        fprintf(fid,'%8s','ball id=');
        fprintf(fid,'%10.0f',NumCercle);
        fprintf(fid,'%3s',' x ');
        fprintf(fid,'%10.10f',Cercles(j,1)/1000);
        fprintf(fid,'%3s',' y ');
        fprintf(fid,'%10.10f',Cercles(j,2)/1000);
        fprintf(fid,'%5s',' rad ');
        fprintf(fid,'%10.10f\n',Cercles(j,3)/1000);
        fprintf(fid,'%17s','property density ');
        fprintf(fid,'%10.10f',Densites{i,1}(j,1));
        fprintf(fid,'%10s',' range id=');
        fprintf(fid,'%10.0f\n',NumCercle);
        if Timestep~=0
            mass=Densites{i,1}(j,1)*3.14159*(ODECS{i,1}(j,3)/1000)^2;
            k=mass/(2*Timestep^2);
            fprintf(fid,'%12s','property kn ');
            fprintf(fid,'%10.10f',k);
            fprintf(fid,'%4s',' ks ');
            fprintf(fid,'%10.10f',k);
            fprintf(fid,'%10s',' range id=');
            fprintf(fid,'%10.0f\n',NumCercle);
        end
    end
    NumFin=NumCercle;
    fprintf(fid,'%9s','clump id=');
    fprintf(fid,'%10.0f',NumClump);
    fprintf(fid,'%10s',' permanent');
    fprintf(fid,'%10s',' range id ');
    fprintf(fid,'%10.0f',NumIni);
    fprintf(fid,'%1s',' ');
    fprintf(fid,'%10.0f\n',NumFin);
end
fclose(fid);
