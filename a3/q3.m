%% Assignment 3 Q3
%% Use vlfeat SIFT implementation to find features and matches
clear all; close all;
book = single(imread('book.jpg'))/255;
findBook= single(imread('findBook.jpg'))/255;
book = rgb2gray(book);
findBook = rgb2gray(findBook);

%Visualize sift features
figure; imagesc(book); axis image; colormap gray;
title('book');
[keypointsA,descA] = vl_sift(book);
perm = randperm(size(keypointsA,2)) ;
sel = perm(1:50) ;
h1 = vl_plotframe(keypointsA(:,sel)) ;
h2 = vl_plotframe(keypointsA(:,sel)) ;
set(h1,'color','k','linewidth',3) ;
set(h2,'color','y','linewidth',2) ;
h3 = vl_plotsiftdescriptor(descA(:,sel),keypointsA(:,sel)) ;
set(h3,'color','g') ;

figure; imagesc(findBook); axis image; colormap gray;
title('findBook');
[keypointsB,descB] = vl_sift(findBook);
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
P = 0.99;
pk = 0.2;
S = round(log(1-P)/log(1-pk));

% Inlier threshold (euclidean distance between tranformed point and actual
% match x,y
T = 500;

num_matches = size(vl_matches,2);

 for i=1:S
    % Pick 4 random matches
    random_indices = randperm(num_matches,4); 
    % hardcoded for 4
    match1 = vl_matches(:,random_indices(1));
    match2 = vl_matches(:,random_indices(2));
    match3 = vl_matches(:,random_indices(3));
    match4 = vl_matches(:,random_indices(4));
    
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
    
    x4A = keypointsA(1,match4(1));
    y4A = keypointsA(2,match4(1));
    x4B = keypointsB(1,match4(2));
    y4B = keypointsB(2,match4(2));
    
    % Compute the transform for these 4 matches
    xs = [x1A,x2,A,x3A,x4A];
    
    
    
 end
    
    


