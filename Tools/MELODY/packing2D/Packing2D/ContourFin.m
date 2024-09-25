function [Teta,R,X,Y,Perimetre]=ContourFin(Cercles,Xc,Yc,N);
Teta=transpose(0:2*3.14159/N:2*3.14159);
R=zeros(size(Teta,1),1);
ncercles=size(Cercles,1);
for i=1:N+1
    teta=Teta(i,1)+0.0001;
    x0=Xc+cos(teta);
    y0=Yc+sin(teta);
    a=tan(teta);
    b=Yc-a*Xc;
    dmax=0;
    for j=1:ncercles
        xc=Cercles(j,1);
        yc=Cercles(j,2);
        r=Cercles(j,3);
        A=-1-a^2;
        B=2*xc-2*a*(b-yc);
        C=r^2-xc^2-(b-yc)^2;
        Del=B^2-4*A*C;
        if Del>=0
            x1=(-B+sqrt(Del))/(2*A);
            x2=(-B-sqrt(Del))/(2*A);
            y1=a*x1+b;
            y2=a*x2+b;
            d1=(x1-Xc)/(x0-Xc);
            d2=(x2-Xc)/(x0-Xc);
            if d1>d2 & d1>0
                d=sqrt((x1-Xc)^2+(y1-Yc)^2);
                if d>dmax
                    dmax=d;
                end
            elseif d2>d1 & d2>0
                d=sqrt((x2-Xc)^2+(y2-Yc)^2);
                if d>dmax
                    dmax=d;
                end
            end
        end
    end
    if dmax==0
        dmax=R(i-1,1);
    end
    X(i,1)=Xc+dmax*cos(teta);
    Y(i,1)=Yc+dmax*sin(teta);
    R(i,1)=dmax;
end
Teta=Teta(1:N,1);
R=R(1:N,1);

Perimetre=0;
for i=1:size(X,1)-1
    Perimetre=Perimetre+sqrt((X(i+1,1)-X(i,1))^2+(Y(i+1,1)-Y(i,1))^2);
end