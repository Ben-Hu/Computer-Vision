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
%pmatches = zeros(7,4);

for k=1:size(img,3)-1  
    %Workaround for dynamic variables in matlab
    eval(sprintf('vl_matchesk = vl_matches%d;', k));
    eval(sprintf('vl_scoresk = vl_scores%d;', k));
    eval(sprintf('keypointsAk = keypoints%d;',k));
    eval(sprintf('keypointsBk = keypoints%d;',k+1));

    % ***USE TOP k ordered by squared euclidean disnace
    % Inconsistent results with RANSAC, poor runtime performance with
    % higher iterations

    top_k = 16;
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
    %pmatches(k,:) = best_matches;
end


imgA = img(:,:,2)';
tform = projective2d(homographies(:,:,2)');
XA = imwarp(imgA,tform)';
figure; imagesc(XA);axis image; colormap gray;hold on
title('RANSAC Transform');


%% Plot transformed imgA points onto imgB, should do for 1-7 plotting over 2-8
p = 1;
eval(sprintf('vl_matchesp = vl_matches%d;', p));
eval(sprintf('vl_scoresp = vl_scores%d;', p));
eval(sprintf('keypointsAp = keypoints%d;',p));
eval(sprintf('keypointsBp = keypoints%d;',p+1));

xy = zeros(2,top_k);
matches = zeros(2,top_k);
pnts = zeros(3,top_k);
for q=1:top_k 
    matches(:,q) = vl_matchesp(:,q);
    xy(:,q) = [keypointsAp(2,matches(2,q)),keypointsAp(1,matches(1,q))];
    pnts(:,q) = homographies(:,:,p) * [xy(:,q);1];
    pnts(1,q) = max(1,pnts(1,q)/pnts(3,q));
    pnts(2,q) = max(1,pnts(2,q)/pnts(3,q));
end

figure; imagesc(img(:,:,1));axis image; colormap gray;hold on
for q=1:top_k
    plot(xy(2,q),xy(1,q),'r.','MarkerSize',20);
end
hold off;
title('imgA(top k points)');

figure; imagesc(img(:,:,2));axis image; colormap gray;hold on
for q=1:top_k
    plot(pnts(2,q),pnts(1,q),'r.','MarkerSize',20);
end
hold off;
title('imgB(xformed points)');

% figure; imagesc(img(:,:,2)); axis image; colormap gray;
% title('imgA');
% [keypointsA,descA] = vl_sift(img(:,:,2));
% perm = randperm(size(keypointsA,2)) ;
% sel = perm(1:100) ;
% h1 = vl_plotframe(keypointsA(:,sel)) ;
% h2 = vl_plotframe(keypointsA(:,sel)) ;
% set(h1,'color','k','linewidth',3) ;
% set(h2,'color','y','linewidth',2) ;
% h3 = vl_plotsiftdescriptor(descA(:,sel),keypointsA(:,sel)) ;
% set(h3,'color','g') ;



