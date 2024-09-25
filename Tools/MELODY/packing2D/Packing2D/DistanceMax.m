function [Dist]=DistanceMax(C)
global Xconv Yconv
x=C(1);
y=C(2);
if inpolygon(x,y,Xconv,Yconv)==1
    dist=zeros(size(Xconv,1),1);
    for i=1:size(dist,1)
        dist(i,1)=sqrt((Xconv(i,1)-x)^2+(Yconv(i,1)-y)^2);
    end
    Dist=max(dist);
else
    Dist=10^5*sqrt(x^2+y^2);
end
