clear all;close all;
noiseTemplate = (double(imread('templateNoise.png'))/255);
waldoNoise = (double(imread('waldoNoise.png'))/255);

noiseTemplate = rgb2gray(noiseTemplate);
waldoNoise = rgb2gray(waldoNoise);


tempConv1 = imgaussfilt(noiseTemplate,1);
tempConv2 = imgaussfilt(noiseTemplate,2);
tempConv3 = imgaussfilt(noiseTemplate,3);
waldoConv1 = imgaussfilt(waldoNoise,1);
waldoConv2 = imgaussfilt(waldoNoise,2);
waldoConv3 = imgaussfilt(waldoNoise,3);

mag_of_grad(waldoConv1);
mag_of_grad(waldoConv2);
mag_of_grad(waldoConv3);
mag_of_grad(tempConv1);
mag_of_grad(tempConv2);
mag_of_grad(tempConv3);

function [magOut] = mag_of_grad(img)
%img = rgb2gray(img);
%img= imgaussfilt(img,1);

img_siz = size(img);

m1 = [-1, 0, 1];
m2 = [-1;0;1];

res1 = conv2(img,m1,'same');
res2 = conv2(img,m2,'same');

res1 = reshape(res1,[],1);
res2 = reshape(res2,[],1);
siz = size(res1)

for iter=1:siz(1)
    mag(iter)=sqrt((res1(iter) * res1(iter)) + (res2(iter) * res2(iter)));
end

mag = reshape(mag, [img_siz(1),img_siz(2)]);
figure; imagesc(mag);axis image;colormap gray;
end
