clear all; %close all;
%% Question 1 a)
img = double(imread('synthetic.png'));
img = double(imread('building.jpg'))/255;
img = rgb2gray(img);
figure; imagesc(img);axis image;colormap gray;

%Function for Harris corner metric using harmonic mean
%Cornerness metric output
%use builtins for convolution,gradients but compute M
%adjust a to get a good result 

% baseline smoothing of the original image 
img = imgaussfilt(img,2.0);
img_siz = size(img);

% gradient wrt to x and y
[gx, gy] = gradient(img);

% Compute M and R
% M is a 2 × 2 second moment matrix computed from image gradients
% need to compute M in each image location
% In a particular location I need to compute M as a weighted average of gradients in a window

% M = w(x,y) for all x y [Ix^2, Ix * Iy;  Ix * Iy, Iy^2];

% w(x,y) window function
% window function either a box filter or gaussian, using a gaussian here

Ix = gx .* gx;
Iy = gy .* gy;
Ixy = gx .* gy;

% Use same window function as MATLAB implementation
%w = fspecial('gaussian',[5 1],1.5);
w = fspecial('gaussian',[5 1],2.0);
window = w * w';

% Convolve Ix^2, Iy^2, and IxIy with window function to get values for
% window around each i,j in image
Ix = conv2(Ix, window, 'same');
Iy = conv2(Iy, window, 'same');
Ixy = conv2(Ixy, window, 'same');

M_ij = zeros(2);
R = zeros(img_siz(1), img_siz(2));

for i=1:img_siz(1)
    for j=1:img_siz(2)
        M_ij = [Ix(i,j), Ixy(i,j); Ixy(i,j), Iy(i,j)];
        %Not using Brown Harmonic Mean, using Harris and Stevens R value
        sens_val = 0.04;
        R(i,j) = det(M_ij) - sens_val * trace(M_ij) .^ 2;
        % Harmonic Mean
        R(i,j) = det(M_ij)/trace(M_ij);
    end
end

figure; imagesc(R); axis image; colormap gray;

% Compare with builtin cornerness metric calculations
%cornernessB = cornermetric(mean(img,3)); 

%figure; imagesc(cornernessB); axis image; colormap gray;
R(isnan(R))=0;
cornerness = R;
% Playing around with ordfilt 2 to do non-maxima suppression
% Using a square element, should use a circular at end


%% Q1b
% use a disk filter and find position of maximum element based on numel
% Larger radius for disk = larger area to filter
% e.g. Only 1 max within the area of the disk, the smaller the radius
% the more points we keep, the larger, the more points we discard

element = fspecial('disk',3)>0; %> 0 makes elems logicals
%supp = ordfilt2(cornerness, numel(find(element)), element);
supp = imdilate(cornerness, element);
%figure; imagesc(supp); axis image; colormap gray;
threshold = 0.0002;
corners = (cornerness==supp)&(supp>threshold); 

fig = cat(3, corners, zeros(size(img,1), size(img,2)));
fig = cat(3, fig, img);

figure; imagesc(fig); axis image; colormap gray;

