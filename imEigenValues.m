function [lambda1, lambda2] = imEigenValues(gxx, gxy, gyy, mask)

lambda1 = zeros(size(gxx));
lambda2 =  zeros(size(gxx));
n = numel(gxx);

for i = 1:n
    if mask(i) == 1
        ev = eig([gxx(i) gxy(i) ; gxy(i) gyy(i)]);
        if ev(1)< ev(2)
            lambda2(i) = ev(2);
            lambda1(i) = ev(1);
        else
            lambda2(i) = ev(1);
            lambda1(i) = ev(2);
        end
    end   
end
    
end
