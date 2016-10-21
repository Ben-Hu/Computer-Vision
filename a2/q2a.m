%% Question 2 a
% Using vlfeat SIFT implementation
% Find and plot the keypoints and descriptors
clear all; close all;
book = single(imread('book.jpg'))/255;
findBook= single(imread('findBook.jpg'))/255;
book = rgb2gray(book);
findBook = rgb2gray(findBook);

figure; imagesc(book); axis image; colormap gray;
title('book');
[framesA,descA] = vl_sift(book);
perm = randperm(size(framesA,2)) ;
sel = perm(1:50) ;
h1 = vl_plotframe(framesA(:,sel)) ;
h2 = vl_plotframe(framesA(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
h3 = vl_plotsiftdescriptor(descA(:,sel),framesA(:,sel)) ;
set(h3,'color','g') ;

figure; imagesc(findBook); axis image; colormap gray;
title('findBook');
[framesB,descB] = vl_sift(findBook);
perm = randperm(size(framesB,2)) ;
sel = perm(1:50) ;
h1 = vl_plotframe(framesB(:,sel)) ;
h2 = vl_plotframe(framesB(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
h3 = vl_plotsiftdescriptor(descB(:,sel),framesB(:,sel)) ;
set(h3,'color','g') ;

[fa, da] = vl_sift(book) ;
[fb, db] = vl_sift(findBook) ;
[matches, scores] = vl_ubcmatch(desc1, descB) ;



