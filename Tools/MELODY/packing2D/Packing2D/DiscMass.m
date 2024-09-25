function Densites=DiscMass(ODECS,Proprietes,densite,Case)
%Case 1 : all discs in a cluster with the same mass
%Case 2 : all discs in a cluster with the same density

Npart=size(Proprietes,1);
Densites=cell(Npart,1);
for i=1:Npart
    Ndisc=size(ODECS{i,1},1);
    Surface=Proprietes(i,6);
    Mass=Surface*densite;
    if Case==1
        for j=1:Ndisc
            Rayon=ODECS{i,1}(j,3);
            Densites{i,1}(j,1)=(Mass/Ndisc)/(3.14159*Rayon^2);
        end
    elseif Case==2
        SurfTot=0;
        for j=1:Ndisc
            SurfTot=SurfTot+3.14159*ODECS{i,1}(j,3)^2;
        end
        for j=1:Ndisc
            Densites{i,1}(j,1)=Mass/SurfTot;
        end
    end
end