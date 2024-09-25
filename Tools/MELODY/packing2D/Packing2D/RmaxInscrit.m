function [X,Y,R]=RmaxInscrit(Xcontourfin,Ycontourfin,num,Xx,Yy);
%Trouve le rayon maximal d'un cercle inscrit dans un contour de points
%(Xc,Yc) en partant du point num, et dans la direction tangente au contour

if Xcontourfin(num+1,1)>Xcontourfin(num-1,1)
    sens=1;
else
    sens=-1;
end

angletot=0;
for i=1:size(Xcontourfin,1)-1
    x1=Xcontourfin(i,1)-Xx;
    x2=Xcontourfin(i+1,1)-Xx;
    y1=Ycontourfin(i,1)-Yy;
    y2=Ycontourfin(i+1,1)-Yy;
    angletot=angletot+acos((x1*x2+y1*y2)/(sqrt(x1^2+y1^2)*sqrt(x2^2+y2^2)))*sign(x1*y2-x2*y1);
end
sens=sens*sign(angletot);
alpha=3.14159/2+atan((Ycontourfin(num+1,1)-Ycontourfin(num-1,1))/(Xcontourfin(num+1,1)-Xcontourfin(num-1,1)));
cosalpha=cos(alpha);
sinalpha=sin(alpha);

vectR=zeros(size(Xcontourfin,1),3);
for i=1:size(Xcontourfin,1)
    if i==num
        continue
    end
    DX=Xcontourfin(num,1)-Xcontourfin(i,1);
    DY=Ycontourfin(num,1)-Ycontourfin(i,1);
    vectR(i,3)=(-DX^2-DY^2)/(2*DX*cosalpha+2*DY*sinalpha);
    vectR(i,1)=Xcontourfin(num,1)+vectR(i,3)*cosalpha;
    vectR(i,2)=Ycontourfin(num,1)+vectR(i,3)*sinalpha;
end
if sens==1
    R=1000000;
    for j=1:size(vectR,1)
        if vectR(j,3)>0 & vectR(j,3)<R
            X=vectR(j,1);
            Y=vectR(j,2);
            R=vectR(j,3);
        end
    end
elseif sens==-1
    R=-1000000;
    for j=1:size(vectR,1)
        if vectR(j,3)<0 & vectR(j,3)>R
            X=vectR(j,1);
            Y=vectR(j,2);
            R=vectR(j,3);
        end
    end
end
R=abs(R);
%plot(Xx,Yy,'.r')
%plotcircle(X,Y,R);