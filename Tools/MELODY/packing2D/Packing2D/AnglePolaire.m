function Angle=AnglePolaire(X,Y)
if X>0 & Y>=0
    Angle=atan(Y/X);
elseif X>0 & Y<0
    Angle=atan(Y/X)+2*3.1415927;
elseif X<0
    Angle=atan(Y/X)+3.1415927;
elseif X==0 & Y>0
    Angle=3.1415927/2;
elseif X==0 & Y<0
    Angle=3*3.1415927/2;
end