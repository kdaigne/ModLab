function Halton=Halton1(n,m)
p=primes(10);
if m>1
    Sortie=0;
    while Sortie==0
        lis=randint(1,m,[1,size(p,2)]);
        lis=transpose(sort(transpose(lis)));
        Sortie=1;
        for i=2:m
            if lis(i)==lis(i-1)
                Sortie=0;
                break
            end
        end
    end
    bases=p(lis);
else
    bases=p(randint(1,1,[1,size(p,2)]));
end
    
Halton=zeros(n,m);
for k=1:m
    b=bases(k);
    H=zeros(n,1);
    nbits=1+ceil(log(n)/log(b));
    vb=b.^(-(1:nbits));
    wv=zeros(1,nbits);
    for i=1:n
        j=1;
        ok=0;
        while ok==0
            wv(j)=wv(j)+1;
            if wv(j)<b
                ok=1;
            else
                wv(j)=0;
                j=j+1;
            end
        end
        H(i)=dot(wv,vb);
    end
    Halton(:,k)=H;
end
