function varargout = imHessian(I, sigma, varargin)


% if ndims(img) == 2 
    % Compute kernel coordinates
%     nx = round(sigma * 3);
     

% Make kernel coordinates
[X,Y] = ndgrid(-round(3*sigma):round(3*sigma));

% Build the gaussian 2nd derivatives filters
DGaussxx = 1/(2*pi*sigma^4) * (X.^2/sigma^2 - 1) .* exp(-(X.^2 + Y.^2)/(2*sigma^2));
DGaussxy = 1/(2*pi*sigma^6) * (X .* Y)           .* exp(-(X.^2 + Y.^2)/(2*sigma^2));
DGaussyy = DGaussxx';

Dxx = imfilter(I,DGaussxx,'conv');
Dxy = imfilter(I,DGaussxy,'conv');
Dyy = imfilter(I,DGaussyy,'conv');
    
    
    varargout = {Dxx,Dxy, Dyy};
    
% elseif ndims(img) == 3
%     % Use smoothing, and succession of finite differences
%     if sigma ~= 0
%         img = imgaussfilt(img, sigma);
%     end
%     
%     Dx = gradient3d(img, 'x');
%     Dy = gradient3d(img, 'y');
%     Dz = gradient3d(img, 'z');
%     Dxx = gradient3d(Dx, 'x');
%     Dyy = gradient3d(Dy, 'y');
%     Dzz = gradient3d(Dz, 'z');
%     Dxy = gradient3d(Dx, 'y');
%     Dxz = gradient3d(Dx, 'z');
%     Dyz = gradient3d(Dy, 'z');
%     
%     varargout = {Dxx, Dyy, Dzz, Dxy, Dxz, Dyz};
% 
% else
%     error('Requires a 2D or 3D image');
% end
% 
% function grad = gradient3d(img, dir)
% 
% grad = img;
% switch dir
%     case {1, 'y'}
%         grad(1,:,:) = img(2,:,:) - img(1,:,:);
%         grad(2:end-1,:,:) = img(3:end,:,:) - img(1:end-2,:,:);
%         grad(end,:,:) = img(end,:,:) - img(end-1,:,:);
%     case {2, 'x'}
%         grad(:,1,:) = img(:,2,:) - img(:,1,:);
%         grad(:,2:end-1,:) = img(:,3:end,:) - img(:,1:end-2,:);
%         grad(:,end,:) = img(:,end,:) - img(:,end-1,:);
%     case {3, 'z'}
%         grad(:,:,1) = img(:,:,2) - img(:,:,1);
%         grad(:,:,2:end-1) = img(:,:,3:end) - img(:,:,1:end-2);
%         grad(:,:,end) = img(:,:,end) - img(:,:,end-1);
end