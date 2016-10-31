clear all; close all;
shoe = double(imread('shoe.jpg'))/255;
shoe = rgb2gray(shoe);
figure;imagesc(shoe);axis image;hold on;colormap gray;
[x,y] = ginput(4);
xy = [x,y];

%% Reference Canadian 5 dollar bill image
ref_bill = double(imread('5dollar.jpg'))/255;
ref_bill = rgb2gray(ref_bill);
figure;imagesc(ref_bill);axis image;hold on;colormap gray;
[xr,yr] = ginput(4);
xyr = [xr,yr];

%% Find the transform based on manually inputted points, from this estimate shoe size
tform = maketform('projective',xy,xyr);

% Warp the image based on the transform
imw = imtransform(shoe, tform, 'bicubic','fill', 0);
figure;imagesc(imw);axis image;hold on;colormap gray;

%Now take manual inputs for the length of the shoe
[xs,ys] = ginput(2);

%And manual inputs for the length of the bill
[xb,yb] = ginput(2);

%Based on the fact that a Canadian 5 dollar bill is 152.4mm in length, the
%ratio between lengths in the transformed image should be a decent
%approximation of the length of the shoe. 
xys = [xs,ys];
xyb = [xb,yb];

shoe_len = pdist(xys, 'euclidean');
bill_len = pdist(xyb, 'euclidean');

%estimated length of the shoe in mm
real_shoe_len = (shoe_len/bill_len) * 152.4;

%We find based on the manual inputs the estimated shoe length to be
%274.075mm, based on http://www.tennis-warehouse.com/LC/shoesizing.html
%US shoe size 10.5 has a shoe length of 275mm, take this to be the
%estimated result


