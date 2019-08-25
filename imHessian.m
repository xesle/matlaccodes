function varargout = imHessian(I, sigma, varargin)


% if ndims(img) == 2 
    % Compute kernel coordinates     
% [x,y]=ndgrid(floor(-3*sigma):ceil(3*sigma),floor(-3*sigma):ceil(3*sigma)); 
% 
% DGaussxx = 1/(2*pi*sigma^4) * (x.^2/sigma^2 - 1) .* exp(-(x.^2 + y.^2)/(2*sigma^2));  
% DGaussxy = 1/(2*pi*sigma^6) * (x .* y) .* exp(-(x.^2 + y.^2)/(2*sigma^2)); 
% DGaussyy = 1/(2*pi*sigma^4) * (y.^2/sigma^2 - 1) .* exp(-(x.^2 + y.^2)/(2*sigma^2)); 
 
% Dxx = conv2(I,DGaussxx,'same');
% Dyy = conv2(I,DGaussyy,'same');
% Dxy = conv2(I,DGaussxy,'same');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DGaussxx = ndgauss([11 11],2*sqrt(2)*[1 1],'der',[2 0]);
% DGaussyy = ndgauss([11 11],2*sqrt(2)*[1 1],'der',[0 2]);
% DGaussxy = ndgauss([11 11],2*sqrt(2)*[1 1],'der',[1 1]);
% 
% 
% Dxx = conv2(I,DGaussxx,'same');
% Dyy = conv2(I,DGaussyy,'same');
% Dxy = conv2(I,DGaussxy,'same');

% 

k = 3;
G1=fspecial('gauss',[3, 3], sigma);
%G1=fspecial('gauss',[round(k*sigma), round(k*sigma)], sigma);
[Gx,Gy] = gradient(G1);   
[Gxx,Gxy] = gradient(Gx);
[Gyx,Gyy] = gradient(Gy);
    
    
Dxx = imfilter(I,Gxx,'conv');
Dxy = imfilter(I,Gxy,'conv');
Dyy = imfilter(I,Gyy,'conv');

varargout = {Dxx,Dxy, Dyy};
    

end