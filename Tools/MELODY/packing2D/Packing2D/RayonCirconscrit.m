function [Xcirc,Ycirc,Rcirc]=RayonCirconscrit(X,Y)
global Xconv Yconv
Xconv=X;
Yconv=Y;
options=optimset('TolFun',0.0001,'TolX',0.0001);
[Ccirc,Rcirc]=fminsearch(@DistanceMax,[0,0],options);
Xcirc=Ccirc(1);
Ycirc=Ccirc(2);