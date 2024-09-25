function [PDFAnglesExp,PDFSurfacesExp,PDFElongsExp,PDFRoundExp,PDFCircExp,PDFRegulExp,SolidFraction,VoidRatio,D10,D50,Cu]=Statistics(Proprietes,ODECS,Domain)
Ncellules=size(Proprietes,1);

ClassesAngles=[-85:10:85];
PDFAnglesExp=transpose(hist(Proprietes(:,2),ClassesAngles))/Ncellules/10;
PDFAnglesExp=cat(2,transpose(ClassesAngles),PDFAnglesExp);

Dsurf=(max(Proprietes(:,6))-min(Proprietes(:,6)))/20;
ClassesSurfaces=[min(Proprietes(:,6)):Dsurf:max(Proprietes(:,6))];
PDFSurfacesExp=transpose(hist(Proprietes(:,6),ClassesSurfaces))/Ncellules/Dsurf;
PDFSurfacesExp=cat(2,transpose(ClassesSurfaces),PDFSurfacesExp);

ClassesElongs=[0.51:0.02:0.99];
PDFElongsExp=transpose(hist(Proprietes(:,5),ClassesElongs))/Ncellules/0.02;
PDFElongsExp=cat(2,transpose(ClassesElongs),PDFElongsExp);

Roundness=Proprietes(:,21);
ClassesRound=[0.225:0.05:0.975];
PDFRoundExp=transpose(hist(Roundness,ClassesRound))/Ncellules/0.05;
PDFRoundExp=cat(2,transpose(ClassesRound),PDFRoundExp);

Circularity=Proprietes(:,22);
ClassesCirc=[0.66:0.02:0.99];
PDFCircExp=transpose(hist(Circularity,ClassesCirc))/Ncellules/0.02;
PDFCircExp=cat(2,transpose(ClassesCirc),PDFCircExp);

Regularity=Proprietes(:,23);
ClassesRegul=[1.1:0.2:4.9];
PDFRegulExp=transpose(hist(Regularity,ClassesRegul))/Ncellules/0.2;
PDFRegulExp=cat(2,transpose(ClassesRegul),PDFRegulExp);

Stot=polyarea(Domain(:,1),Domain(:,2));
SolidFraction=sum(Proprietes(:,6))/Stot;
VoidRatio=(1-SolidFraction)/SolidFraction;

Npoints=Ncellules;
Sample=cat(2,Proprietes(:,6),Proprietes(:,4));
Sample=sortrows(Sample,2);
Mtot=sum(Sample(:,1)); %en2D!!!
Passant=zeros(floor(Npoints),1);
Passant(1,1)=Sample(1,1);
for i=2:Npoints
    Passant(i,1)=Passant(i-1,1)+Sample(i,1);
end
Passant=Passant/Mtot;
for i=1:Npoints
    if Passant(i,1)>0.1
        %D10=2*sqrt(Sample(i,1)/3.14159);
        D10=Sample(i,2);
        break
    end
end
for i=1:Npoints
    if Passant(i,1)>0.5
        %D50=2*sqrt(Sample(i,1)/3.14159)
        D50=Sample(i,2);
        break
    end
end
for i=1:Npoints
    if Passant(i,1)>0.6
        %D60=2*sqrt(Sample(i,1)/3.14159);
        D60=Sample(i,2);
        break
    end
end
Cu=D60/D10;

Sample_Solid_Fraction=SolidFraction
Sample_D50=D50
Sample_Cu=Cu