function [Xconv,Yconv,PerimetreConv]=ContourConvexe(X,Y)
K=convhull(X,Y);
Xconv=X(K,1);
Yconv=Y(K,1);
PerimetreConv=0;
for i=1:size(Xconv,1)-1
    PerimetreConv=PerimetreConv+sqrt((Xconv(i+1,1)-Xconv(i,1))^2+(Yconv(i+1,1)-Yconv(i,1))^2);
end