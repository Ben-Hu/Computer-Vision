%Q1
clear all;close all;
img = double(imread('cameraman.tif'));
courtImg = rgb2gray(double(imread('tennisCourt.jpg'))/255);
courtEdge1= edge(courtImg,'canny');
courtEdge2= edge(courtImg,'canny', [0.1,0.40]);
courtEdge3= edge(courtImg,'canny', [0.1,0.45]); 
courtEdge4= edge(courtImg,'canny', [0.1,0.50]); %this
courtEdge5= edge(courtImg,'canny', [0.1,0.55]); %or this

figure; imagesc(courtImg);axis image; colormap gray;
figure; imagesc(courtEdge1);axis image; colormap gray;
figure; imagesc(courtEdge2);axis image; colormap gray;
figure; imagesc(courtEdge3);axis image; colormap gray;
figure; imagesc(courtEdge4);axis image; colormap gray;
figure; imagesc(courtEdge5);axis image; colormap gray;
