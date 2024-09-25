function plotcircle(X,Y,R,rempli,couleur);
a=transpose(0:5:360)/180*3.1415927;
Xc=X+R*cos(a);
Yc=Y+R*sin(a);
if rempli==0
    plot(Xc,Yc,'-r')
else
    %for i=1:72
    %    patch([X,Xc(i,1),Xc(i+1,1)],[Y,Yc(i,1),Yc(i+1,1)],[0,0,0],'r','linestyle','none')
    %    hold on
    %end
    patch(Xc,Yc,couleur,'linestyle','none')
end
