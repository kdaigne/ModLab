function [Xinsc,Yinsc,Rinsc]=RayonInscrit(X,Y)
Lis=zeros(size(X,1)-2,3);
for i=2:size(X,1)-1
    [x,y,r]=RmaxInscrit(X,Y,i,0,0);
    Lis(i,1)=x;
    Lis(i,2)=y;
    Lis(i,3)=r;
end
Lis=flipud(sortrows(Lis,3));
Xinsc=Lis(1,1);
Yinsc=Lis(1,2);
Rinsc=Lis(1,3);