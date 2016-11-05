%% Assignment 3 Q4
clear all; close all;
%Right most image = 00, Left most image = 07, 07->00 L->R
img = single(imread('hotel/hotel-00.png'))/255;
img = cat(3,img,single(imread('hotel/hotel-01.png'))/255);
img = cat(3,img,single(imread('hotel/hotel-02.png'))/255);
img = cat(3,img,single(imread('hotel/hotel-03.png'))/255);
img = cat(3,img,single(imread('hotel/hotel-04.png'))/255);
img = cat(3,img,single(imread('hotel/hotel-05.png'))/255);
img = cat(3,img,single(imread('hotel/hotel-06.png'))/255);
img = cat(3,img,single(imread('hotel/hotel-07.png'))/255);
for q=1:size(img,3)
    img(:,:,q) = conv2(img(:,:,q),fspecial('Gaussian',[25 25],0.5),'same');
end

%some base level smoothing
% imgA = conv2(imgA,fspecial('Gaussian',[25 25],0.5),'same');
% imgB = conv2(imgB,fspecial('Gaussian',[25 25],0.5),'same');

%% Find SIFT feature descriptors & keypoints in each component image
[keypoints1,desc1] = vl_sift(img(:,:,1));
[keypoints2,desc2] = vl_sift(img(:,:,2));
[keypoints3,desc3] = vl_sift(img(:,:,3));
[keypoints4,desc4] = vl_sift(img(:,:,4));
[keypoints5,desc5] = vl_sift(img(:,:,5));
[keypoints6,desc6] = vl_sift(img(:,:,6));
[keypoints7,desc7] = vl_sift(img(:,:,7));
[keypoints8,desc8] = vl_sift(img(:,:,8));

%% Feature correspondence 
%vl_matches (1,i) = index descriptor A descA(:,vl_matches(1,i)) 
%vl_matches (1,i) = index keypoints A keypointsA(:,vl_matches(1,i))

%vl_matches (2,i) = index descriptor B descB(:,vl_matches(2,i))
%vl_matches (2,i) = index keypoints B keypointsB(:,vl_matches(2,i))

%vl_scores  = squared euclidean distance between matches

%Find feature correspondence between adjacent component images 
[vl_matches1, vl_scores1] = vl_ubcmatch(desc1, desc2, 2.5);
[vl_matches2, vl_scores2] = vl_ubcmatch(desc2, desc3, 2.5);
[vl_matches3, vl_scores3] = vl_ubcmatch(desc3, desc4, 2.5);
[vl_matches4, vl_scores4] = vl_ubcmatch(desc4, desc5, 2.5);
[vl_matches5, vl_scores5] = vl_ubcmatch(desc5, desc6, 2.5);
[vl_matches6, vl_scores6] = vl_ubcmatch(desc6, desc7, 2.5);
[vl_matches7, vl_scores7] = vl_ubcmatch(desc7, desc8, 2.5);
%scores = squared euclidean distance - top k = min k scores

%%Sort the matches according to score
for j=1:size(img,3)-1
    eval(sprintf('c_matches = vl_matches%d;', j));
    eval(sprintf('c_scores = vl_scores%d;', j));    
    sorted = [c_scores',c_matches'];
    sorted = sortrows(sorted);
    sorted_scores = sorted(:,1)';
    sorted_matches = sorted(:,2:3)';
    eval(sprintf('vl_scores%d = sorted_scores;', j));
    eval(sprintf('vl_matches%d = sorted_matches;', j));
end

%% Compute the homographies between adjacent image components 
% compute via eigendecomposition
% do not use maketform
% visualize: transform keypoints from one image onto the next, diff color.

homographies = zeros(3,3,size(img,3)-1);

for k=1:size(img,3)-1  
    %Workaround for dynamic variables in matlab
    eval(sprintf('vl_matchesk = vl_matches%d;', k));
    eval(sprintf('vl_scoresk = vl_scores%d;', k));
    eval(sprintf('keypointsAk = keypoints%d;',k));
    eval(sprintf('keypointsBk = keypoints%d;',k+1));

    % ***USE TOP k ordered by squared euclidean disnace
    % Inconsistent and poor results with RANSAC even with higher S
    % iteration values many different threshold values/other parameters,
    % getting really consistent and decent results with 
    % top k estimation

    top_k = 8;
    A = [];
    for i=1:top_k
        matchi = vl_matchesk(:,i);    
        xiA = keypointsAk(2,matchi(1));
        yiA = keypointsAk(1,matchi(1));
        xiB = keypointsBk(2,matchi(2));
        yiB = keypointsBk(1,matchi(2));
        Ai = [xiA,yiA,1,0,0,0,-xiB*xiA,-xiB*yiA,-xiB;...
            0,0,0,xiA,yiA,1,-yiB*xiA,-yiB*yiA,-yiB];
        A = cat(1,A,Ai);
    end

    %h^ = eigenvector w/ smallest eigenvalue of A^T * A
    At = A' * A;
    [eigvec,eigval] = eig(At);
    eigval = sum(eigval,1);
    [min_eigval,min_eigval_ind]= min(eigval);
    
    %eigenvector corresponding to the minimum eigenvalue 1x9
    min_eigvec = eigvec(:,min_eigval_ind);

    best_hm = reshape(min_eigvec,3,3)';
    %best_matches = [1,2,3,4];
    
    % Keep the best homography for this image pair, i/i+1
    homographies(:,:,k) = best_hm;
end

%% Plot transformed imgA points onto imgB, should do for 1-7 plotting over 2-8
%p = 1; 
img = ones(768,1024,8);
for p=1:size(img,3)-1
    eval(sprintf('vl_matchesp = vl_matches%d;', p));
    eval(sprintf('vl_scoresp = vl_scores%d;', p));
    eval(sprintf('keypointsAp = keypoints%d;',p));
    eval(sprintf('keypointsBp = keypoints%d;',p+1));

    xyA = zeros(2,top_k);
    xyB = zeros(2,top_k);
    matches = zeros(2,top_k);
    pnts = zeros(3,top_k);
    for q=1:top_k 
        matches(:,q) = vl_matchesp(:,q);
        xyA(:,q) = [keypointsAp(2,matches(1,q)),keypointsAp(1,matches(1,q))];
        xyB(:,q) = [keypointsBp(2,matches(2,q)),keypointsBp(1,matches(2,q))];
        pnts(:,q) = homographies(:,:,p) * [xyA(:,q);1];
        pnts(1,q) = max(1,pnts(1,q)/pnts(3,q));
        pnts(2,q) = max(1,pnts(2,q)/pnts(3,q));
    end

    figure; imagesc(img(:,:,p));axis image; colormap gray;hold on
    for q=1:top_k
        plot(xyA(2,q),xyA(1,q),'r.','MarkerSize',20);
    end
    hold off;
    title('imgA(top k points)');

    figure; imagesc(img(:,:,p+1));axis image; colormap gray;hold on
    for q=1:top_k
        %%You won't be able to see the computed points in red since the
        %%points in green will be pretty much on top of them
        plot(pnts(2,q),pnts(1,q),'r.','MarkerSize',20);
        plot(xyB(2,q),xyB(1,q),'g.','MarkerSize',20);
    end
    hold off;
    title('imgB(xformed points)');
end

%% Transform the images and display
for p=1:size(img,3)-1
    imgA = img(:,:,p)';
    tform = projective2d(homographies(:,:,p)');
    XFt = imwarp(imgA,tform)';
    eval(sprintf('XF%d = XFt;', p));
    %figure; imagesc(XA);axis image; colormap gray;hold on
    %title('Transformed imgA');
end

for p=1:size(img,3)-1
   eval(sprintf('figure; imagesc(XF%d); axis image; colormap gray; hold on', p)); 
   eval(sprintf('title(string(%d));', p)); 
end

%% Form the panorama
%img = 768x1024x8
%panoimg = 768x8192 if perfectly horizontal
%make sure there's enough space
%accumulate transforms to / from center
%center is XF4/img(:,:,4)
panoimg = zeros(1000,5000);
XF8 = imadjust(img(:,:,8));
yoffset = 200;
xoffset = 0;
panoimg(1+yoffset:size(XF8,1)+yoffset,1+xoffset:size(XF8,2)+xoffset) = XF8; %xoffset=size(XF8,2);

%x7 should also be x8(1), x8(2)
%where XF7 begins therefore should be 
%x8(1) - x7(1), x8(2)+yoffset - x7(2)

%We want 7 to be overlayed such that these points line up
%yoffset = abs(x8(1)+yoffset - x7(1));

top_pnt7 = keypoints7(:,vl_matches7(1,1));
top_pnt8 = keypoints8(:,vl_matches7(2,1));
x7 = top_pnt7;
x8 = top_pnt8;
xoffset = abs(x8(1)+xoffset - x7(1));
yoffset = abs(x8(2)+yoffset - x7(2));
panoimg(1+yoffset:size(XF7,1)+yoffset,1+xoffset:size(XF7,2)+xoffset) = XF7; %xoffset=xoffset+size(XF7,2);

top_pnt6 = keypoints6(:,vl_matches6(1,1));
top_pnt7 = keypoints7(:,vl_matches6(2,1));
x6 = top_pnt6;
x7 = top_pnt7;
xoffset = abs(x7(1)+xoffset - x6(1));
yoffset = abs(x7(2)+yoffset - x6(2))
tform = projective2d(homographies(:,:,7)');
XF6 = imwarp(XF6',tform)';
panoimg(1+yoffset:size(XF6,1)+yoffset,1+xoffset:size(XF6,2)+xoffset) = XF6; %xoffset=xoffset+size(XF6,2);

top_pnt5 = keypoints5(:,vl_matches5(1,1));
top_pnt6 = keypoints6(:,vl_matches5(2,1));
x5 = top_pnt5;
x6 = top_pnt6;
xoffset = abs(x6(1)+xoffset - x5(1));
yoffset = abs(x6(2)+yoffset - x5(2));
tform = projective2d(homographies(:,:,6)');
XF5 = imwarp(XF5',tform)';
panoimg(1+yoffset:size(XF5,1)+yoffset,1+xoffset:size(XF5,2)+xoffset) = XF5; %xoffset=xoffset+size(XF5,2);

top_pnt4 = keypoints4(:,vl_matches4(1,1));
top_pnt5 = keypoints5(:,vl_matches4(2,1));
x4 = top_pnt4;
x5 = top_pnt5;
xoffset = abs(x5(1)+xoffset - x4(1));
yoffset = abs(x5(2)+yoffset - x4(2));
tform = projective2d(homographies(:,:,5)');
XF4 = imwarp(XF4',tform)';
panoimg(1+yoffset:size(XF4,1)+yoffset,1+xoffset:size(XF4,2)+xoffset) = XF4; %xoffset=xoffset+size(XF4,2);

top_pnt3 = keypoints3(:,vl_matches3(1,1));
top_pnt4 = keypoints4(:,vl_matches3(2,1));
x3 = top_pnt3;
x4 = top_pnt4;
xoffset = abs(x4(1)+xoffset - x3(1));
yoffset = abs(x4(2)+yoffset - x3(2));
tform = projective2d(homographies(:,:,4)');
XF3 = imwarp(XF3',tform)';
panoimg(1+yoffset:size(XF3,1)+yoffset,1+xoffset:size(XF3,2)+xoffset) = XF3; %xoffset=xoffset+size(XF3,2);
figure;imagesc(panoimg);axis image;colormap gray;

top_pnt2 = keypoints2(:,vl_matches2(1,1));
top_pnt3 = keypoints3(:,vl_matches2(2,1));
x2 = top_pnt2;
x3 = top_pnt3;
xoffset = abs(x3(1)+xoffset - x2(1));
yoffset = abs(x3(2)+yoffset - x2(2));
tform = projective2d(homographies(:,:,3)');
XF2 = imwarp(XF2',tform)';
panoimg(1+yoffset:size(XF2,1)+yoffset,1+xoffset:size(XF2,2)+xoffset) = XF2; %xoffset=xoffset+size(XF2,2);


top_pnt1 = keypoints1(:,vl_matches1(1,1));
top_pnt2 = keypoints2(:,vl_matches1(2,1));
x1 = top_pnt1;
x2 = top_pnt2;
xoffset = abs(x2(1)+xoffset - x1(1));
yoffset = abs(x2(2)+yoffset - x1(2));
tform = projective2d(homographies(:,:,2)');
XF1 = imwarp(XF1',tform)';
panoimg(1+yoffset:size(XF1,1)+yoffset,1+xoffset:size(XF1,2)+xoffset) = XF1; %xoffset=xoffset+size(XF1,2);
figure;imagesc(panoimg);axis image;colormap gray;


