%% Assignment 3 Q3
%% Use vlfeat SIFT implementation to find features and matches
clear all; close all;
imgA = single(imread('book.jpg'))/255;
imgB= single(imread('findBook.jpg'))/255;
imgA = rgb2gray(imgA);
imgB = rgb2gray(imgB);

%Visualize sift features
figure; imagesc(imgA); axis image; colormap gray;
title('book');
[keypointsA,descA] = vl_sift(imgA);
perm = randperm(size(keypointsA,2)) ;
sel = perm(1:50) ;
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
sel = perm(1:50) ;
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

%keypoints are formated [x;y;s;th]
%xA = keypointsA(1,vl_matches(1,i))
%yA = keypointsA(2,vl_matches(1,i))
%xB = keypointsB(1,vl_matches(2,i))
%yB = keypointsB(2,vl_matches(2,i))

%vl_scores  = squared euclidean distance between matches
[vl_matches, vl_scores] = vl_ubcmatch(descA, descB);


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
    x1A = keypointsA(1,match1(1));
    y1A = keypointsA(2,match1(1));
    x1B = keypointsB(1,match1(2));
    y1B = keypointsB(2,match1(2));
      
    x2A = keypointsA(1,match2(1));
    y2A = keypointsA(2,match2(1));
    x2B = keypointsB(1,match2(2));
    y2B = keypointsB(2,match2(2));
     
    x3A = keypointsA(1,match3(1));
    y3A = keypointsA(2,match3(1));
    x3B = keypointsB(1,match3(2));
    y3B = keypointsB(2,match3(2));
    
    % Compute the affine transform for these 3 matches
    xA = [x1A,x2A,x3A];
    yA = [y1A,y2A,y3A];
    xyA = [xA,yA];
    
    xB = [x1B,x2B,x3B];
    yB = [y1B,y2B,y3B];
    xyB = [xB,yB];
    
    % For 3 matches, a = P^-1 P'

    P1 = [x1A,y1A,0,0,1,0;0,0,x1A,y1A,0,1];
    P2 = [x2A,y2A,0,0,1,0;0,0,x2A,y3A,0,1];
    P3 = [x3A,y3A,0,0,1,0;0,0,x3A,y3A,0,1];
    
    P = [P1;P2;P3];
    
    Pr = [x1B;y1B;x2B;y2B;x3B;y3B];
 
    aff = inv(P) * Pr;
    
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
        A_pnt = keypointsA(1:2,A_ind);
        B_pnt = keypointsB(1:2,B_ind);
        X_pnt = round(am * [A_pnt;1]);
        X = [reshape(B_pnt,size(B_pnt,2),[]);reshape(X_pnt,size(X_pnt,2),[])];
        dist = pdist(X, 'euclidean');
        
        if dist < min_dist
            min_dist = dist;
        end
        if dist > max_dist & max_dist ~= inf
            max_dist = dist;
        end
        
        if dist <= T
            num_inliers = num_inliers + 1;
        end
    end
    
    %Check if this model is currently the best and keep it if it is
    if num_inliers > max_inliers 
        best_am = am;
        max_inliers = num_inliers;
        best_matches = random_indices;
    end
    
end
 
%Visualize the best fit we found
XA = zeros(size(imgB,1),size(imgB,2));
for i=1:size(imgA,1)
    for j=1:size(imgA,2)
        res = best_am * [i;j;1];
        new_x = max(1,round(res(1)));
        new_y = max(1,round(res(2)));
        XA(new_x,new_y) = imgA(i,j);
    end
end
figure; imagesc(XA);axis image; colormap gray;hold on
title('RANSAC');

%% Actual best approximiation of the affine transformation for this image set
ao = 0.646834359842923;
bo = -0.243278378238744;
co = 0.265036402581497;
do = 0.723401738903347;
eo = 514.697256161717;
fo = 666.495657542318;
 
am_opt = [ao,bo,eo;co,do,fo];

%Visualize the actual best approximation via moore-penrose
XAo = zeros(size(imgB,1),size(imgB,2));
for i=1:size(imgA,1)
    for j=1:size(imgA,2)
        res = am_opt * [i;j;1];
        new_x = max(1,round(res(1)));
        new_y = max(1,round(res(2)));
        XAo(new_x,new_y) = imgA(i,j);
    end
end

figure; imagesc(XAo);axis image; colormap gray;hold on
title('Moore-Penrose Least Squares');


    


