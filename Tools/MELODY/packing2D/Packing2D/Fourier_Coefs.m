function [An,Bn]=Fourier_Coefs(Teta,X,Y,Xc,Yc);
R=zeros(size(Teta,1),1);
for i=1:size(R,1)
    R(i,1)=sqrt((Xc-X(i,1))^2+(Yc-Y(i,1))^2);
end
figure;plot(Teta,R);hold on
figure;polar(Teta,R);hold on
%F=fft(R);
%An=real(F);
%Bn=imag(F);
N=size(R,1);
An=zeros(N,1);
Bn=zeros(N,1);
for i=0:N-1
    for j=1:N
        An(i+1,1)=An(i+1,1)+R(j,1)*cos(i*Teta(j,1))*(2*3.14159/N);
        Bn(i+1,1)=Bn(i+1,1)+R(j,1)*sin(i*Teta(j,1))*(2*3.14159/N);
    end
end
An=N*An/(2*3.14159);
Bn=N*Bn/(2*3.14159);