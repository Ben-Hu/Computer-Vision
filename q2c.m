%Question 2 c)
clear all;close all;
img = double(imread('cameraman.tif'));

%Create a seperable filter
hx =[1 2 1];
hy = [1 2 1]';
H = hy*hx;
hx = hx/sum(hx(:));
hy = hy/sum(hy(:));
H = H/sum(H(:));%normalize the filter

imgSmooth = conv2(img,H,'same');

%anisotropic gaussian convolutions 
builtinAniso = imgaussfilt(img, [15,2]);
bisize = computeFilterSizeFromSigma([15,2]);
reference = images.internal.createGaussianKernel([15,2],[61,9]);
builtin2 = conv2(img, reference, 'same');

figure;imagesc(builtinAniso);axis image;colormap gray;
figure;imagesc(builtin2);axis image;colormap gray;

f = genAnisoGauss(15,2);
myAniso = conv2(img, genAnisoGauss(15,2), 'same');
figure;imagesc(myAniso);axis image;colormap gray;

%imggaussfilt uses filter size
function filterSize = computeFilterSizeFromSigma(sigma)
filterSize = 2*ceil(2*sigma) + 1;
end


%generate an anisotropic gaussian kernel for given sigma_x and sigma_y of
function [myAnisoGauss] = genAnisoGauss(sig_x, sig_y)
x = 2*ceil(2*sig_x) + 1
y = 2*ceil(2*sig_y) + 1
xOffset = (x-1)/2;
yOffset = (y-1)/2;

%xCoord = matrix w/ x value wrt the origin (0) e.g. [-1,0,1;-1,0,1;1,0,1]
%yCoord = matrix w/ y values wrt the origin, upsidedown [-1,-1,-1;0,0,0;1,1,1]
[xCoord,yCoord] = meshgrid(-yOffset:yOffset,-xOffset:xOffset);

%pre-allocate myAnisoGauss
myAnisoGauss = zeros(x,y);

for xIter = 1:x
    for yIter = 1:y
        a = 1/(2*pi*sig_x*sig_y);
        b = (xCoord(xIter,yIter).*xCoord(xIter,yIter))/(sig_y*sig_y) + ...
            (yCoord(xIter,yIter).*yCoord(xIter,yIter))/(sig_x*sig_x);
        res = a * exp(-b/2); 
        myAnisoGauss(xIter,yIter) = res;      
    end
end
myAnisoGauss = myAnisoGauss/sum(myAnisoGauss(:));

end
