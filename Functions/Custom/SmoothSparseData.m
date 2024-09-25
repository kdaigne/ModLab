function [Ysmooth,Ystd]=SmoothSparseData(X,Y,Xsmooth,Width)
% By Guilhem Mollon
% This function provides a smooth moving average of a cloud of points
% (X,Y). Xsmooth is the list of points for which this moving average is
% asked, and Width is a span (over X) used for the smoothing.
% The function returns Ysmooth (the moving average at the points Xsmooth)
% and Ystd (the corresponding standard deviation at the same points).
Ysmooth=zeros(length(Xsmooth),1);
Ystd=zeros(length(Xsmooth),1);
for i=1:size(Ysmooth,1)
    l=find(X>Xsmooth(i)-Width/2 & X<Xsmooth(i)+Width/2);
    Ysmooth(i)=sum(Y(l).*(exp(-((X(l)-Xsmooth(i))/(Width/4)).^2)-exp(-4)))/sum(exp(-((X(l)-Xsmooth(i))/(Width/4)).^2)-exp(-4));
    Ystd(i)=sqrt(sum((Y(l).^2-Ysmooth(i)^2).*(exp(-((X(l)-Xsmooth(i))/(Width/4)).^2)-exp(-4)))/sum(exp(-((X(l)-Xsmooth(i))/(Width/4)).^2)-exp(-4)));
end
end