%% Assignment 3 Q3A
%% Use vlfeat SIFT implementation to find features and matches
clear all; close all;
imgA = single(imread('book.jpg'))/255;
imgB= single(imread('findBook.jpg'))/255;
imgA = single(imread('c1.png'))/255;
imgB= single(imread('c2.png'))/255;
imgA = rgb2gray(imgA);
imgB = rgb2gray(imgB);

%some base level smoothing
imgA = conv2(imgA,fspecial('Gaussian',[25 25],0.5),'same');
imgB = conv2(imgB,fspecial('Gaussian',[25 25],0.5),'same');

%Visualize sift features as is in the vlfeat vl_sift tutorial
figure; imagesc(imgA); axis image; colormap gray;
title('book');
[keypointsA,descA] = vl_sift(imgA);
perm = randperm(size(keypointsA,2)) ;
sel = perm(1:20) ;
h1 = vl_plotframe(keypointsA(:,sel)) ;
h2 = vl_plotframe(keypointsA(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
h3 = vl_plotsiftdescriptor(descA(:,sel),keypointsA(:,sel)) ;
set(h3,'color','g') ;

figure; imagesc(imgB); axis image; colormap gray;
title('findBook');
[keypointsB,descB] = vl_sift(imgB);
perm = randperm(size(keypointsB,2)) ;
sel = perm(1:20) ;
h1 = vl_plotframe(keypointsB(:,sel)) ;
h2 = vl_plotframe(keypointsB(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
h3 = vl_plotsiftdescriptor(descB(:,sel),keypointsB(:,sel)) ;
set(h3,'color','g') ;

%Feature correspondence 
%vl_matches (1,i) = index descriptor A descA(:,vl_matches(1,i)) 
%vl_matches (1,i) = index keypoints A keypointsA(:,vl_matches(1,i))

%vl_matches (2,i) = index descriptor B descB(:,vl_matches(2,i))
%vl_matches (2,i) = index keypoints B keypointsB(:,vl_matches(2,i))

%vl_scores  = squared euclidean distance between matches
[vl_matches, vl_scores] = vl_ubcmatch(descA, descB, 2.5);

%% RANSAC 

% Number of Iterations
PS = 0.99;
pkS = 0.2^4;
S = round(log(1-PS)/log(1-pkS));

% Inlier threshold (euclidean distance between tranformed point and actual
% match x,y
T = 1.5;

num_matches = size(vl_matches,2);

% debuggina and best fits
max_inliers = 0;
best_am = [];
best_matches = [];
min_dist = 9999;
max_dist = 0;

for i=1:S
    % Pick 4 random matches
    random_indices = randperm(num_matches,3); 
    % hardcoded for 4
    match1 = vl_matches(:,random_indices(1));
    match2 = vl_matches(:,random_indices(2));
    match3 = vl_matches(:,random_indices(3));
    
    %debugging, clean up later
    x1A = keypointsA(2,match1(1));
    y1A = keypointsA(1,match1(1));
    x1B = keypointsB(2,match1(2));
    y1B = keypointsB(1,match1(2));
      
    x2A = keypointsA(2,match2(1));
    y2A = keypointsA(1,match2(1));
    x2B = keypointsB(2,match2(2));
    y2B = keypointsB(1,match2(2));
     
    x3A = keypointsA(2,match3(1));
    y3A = keypointsA(1,match3(1));
    x3B = keypointsB(2,match3(2));
    y3B = keypointsB(1,match3(2));
    
    % Compute the affine transform for these 3 matches
    % For 3 matches, a = P^-1 P'

    P1 = [x1A,y1A,0,0,1,0;0,0,x1A,y1A,0,1];
    P2 = [x2A,y2A,0,0,1,0;0,0,x2A,y3A,0,1];
    P3 = [x3A,y3A,0,0,1,0;0,0,x3A,y3A,0,1];   
    P = [P1;P2;P3];
    
    Pr = [x1B;y1B;x2B;y2B;x3B;y3B];
     
    aff = inv(P) * Pr;
    %aff = inv(P' * P) * P' * Pr;
    
    a = aff(1); b = aff(2); c = aff(3);
    d = aff(4); e = aff(5); f = aff(6);

    am = [a,b,e;c,d,f];
    
    %Find number of inliers with this calculated transformation
    %Keep track of best transform and matches so far
    
    num_inliers = 0;
    
    %Determine the number of inliers for this affine transform
    for j=1:size(vl_matches,2)
        A_ind = vl_matches(1,j);
        B_ind = vl_matches(2,j);
        %Use computed transform on A_pnt for result X_pnt
        %use euclidean distance between result X_pnt and B_pnt 
        %to determine if it is an inlier based on threshold T
        A_x = keypointsA(2,A_ind);
        A_y = keypointsA(1,A_ind);
        B_x = keypointsB(2,B_ind);
        B_y = keypointsB(1,B_ind);
        
        X_pnt = round(am * [A_x;A_y;1]);
        X = [B_x,B_y;reshape(X_pnt,1,[])];
        dist = pdist(X, 'euclidean');
        
        % For purposes of tuning T
        if dist < min_dist
            min_dist = dist;
        end
        if dist > max_dist & max_dist ~= inf
            max_dist = dist;
        end
        
        % Thresholding based on the euclidean distance calculation
        if dist <= T
            num_inliers = num_inliers + 1;
        end
    end
    
    %Check if this model is currently the best and keep it if it is
    if num_inliers >= max_inliers 
        best_am = am;
        max_inliers = num_inliers;
        best_matches = random_indices;
    end
    
end
 
%Visualize the best fit we found, transform imgB -> imgA
XA = zeros(size(imgB,1),size(imgB,2));
for i=1:size(imgA,1)
    for j=1:size(imgA,2)
        res = best_am * [i;j;1];
        new_x = max(1,round(res(1)));
        new_y = max(1,round(res(2)));
        XA(new_x,new_y) = imgA(i,j);
    end
end
figure; imagesc(imgA);axis image; colormap gray;hold on
title('mgA');
figure; imagesc(imgB);axis image; colormap gray;hold on
title('imgB');
figure; imagesc(XA);axis image; colormap gray;hold on
title('RANSAC Transform');

%Plot the trasnformation as parallelogram over the image
bl_corner = round(best_am*[0;0;1]);
br_corner = round(best_am*[0;387;1]);
tl_corner = round(best_am*[395;0;1]);
tr_corner = round(best_am*[395;387;1]);

figure; imagesc(imgB);axis image; colormap gray;hold on
line([bl_corner(2),tl_corner(2)],[bl_corner(1),tl_corner(1)]);
line([bl_corner(2),br_corner(2)],[bl_corner(1),br_corner(1)]);
line([tr_corner(2),br_corner(2)],[tr_corner(1),br_corner(1)]);
line([tr_corner(2),tl_corner(2)],[tr_corner(1),tl_corner(1)]);
title('Transform Overlay');

%Reference transform from Moore-Penrose lease squares from by A2 code.
t_am = [0.0597929162403003,1.04042462070958,511.473935250196;,-1.04304742306299,-0.132837054877354,1484.35163183366]
XAt = zeros(size(imgB,1),size(imgB,2));
for i=1:size(imgA,1)
    for j=1:size(imgA,2)
        res = t_am * [i;j;1];
        new_x = max(1,round(res(1)));
        new_y = max(1,round(res(2)));
        XAt(new_x,new_y) = imgA(i,j);
    end
end
figure; imagesc(XAt);axis image; colormap gray;hold on
title('RANSACt');



