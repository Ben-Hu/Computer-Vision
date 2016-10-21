%% Question 2 a
% Using vlfeat SIFT implementation
% Find and plot the keypoints and descriptors
clear all; close all;
book = single(imread('book.jpg'))/255;
findBook= single(imread('findBook.jpg'))/255;
book = rgb2gray(book);
findBook = rgb2gray(findBook);

%keypoints [x,y,s,th]
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

%vlfeat matching
[matches, scores] = vl_ubcmatch(descA, descB) ;

% find euclidean distance between every match pair
% sort the matches and compare the closest match to the second
% reliability ratio - threshold values too low -- ambiguous

%first descriptor e.g. descA(:,1);
%for every descriptor of A,find euclidean distance to every descriptor of B

distances = zeros(size(descA,2),size(descB,2));

for i=1:size(descA,2)
    for j=1:size(descB,2)
        distances(i,j) = sqrt(sum( (descA(:,i) - descB(:,j)).^2 ));
    end
end

%for each descriptor find the match with minimum euclidean distance
%1,1 = closest dist between descA(:,1) and all descB(:,x) feature vecs
%2,1 = closest between descA(:,2), etc.
closest = zeros(size(descA,2),1);
sec_close = zeros(size(descA,2),1);
closest_ind = zeros(size(descA,2),1);
sec_close_ind = zeros(size(descA,2),1);
%closest inds correspond to index of descB that has min euclidean dist
%the descriptor that has closest euclidean distance to the first 
%descriptor in descA is descB(closest_ind(1)), 
%the desc. that has closest euc. dist. to the second desc. in descA,
%descB(closet_ind(2)), etc.

for i=1:size(descA,2)
    cur_desc_dists = distances(i,:);
    [closest(i),closest_ind(i)] = min(cur_desc_dists);
    [sec_close(i),sec_close_ind(i)] = min(cur_desc_dists(cur_desc_dists>min(cur_desc_dists)));
end

%indices line up with the indices of the descriptor output of vl_sift
%since we computed everything sequentially and didn't sort

%match if reliability ratio between the closest and second closest is less
%less than a threshold

rel_threshold = 0.8;
reliability_ratios = closest ./ sec_close;
closest_descriptors = find(reliability_ratios < rel_threshold);
%descB(:,closest_ind(closest_descriptor(i))) matches with
%descA(:,closest_discriptor(i));

matches = zeros(length(closest_descriptors), 2);
for i=1:length(closest_descriptors)
    matches(i,1) = closest_descriptors(i);
    matches(i,2) = closest_ind(closest_descriptors(i));
end

%matches(i,1) = index to descA/keypointsA 
%matches(i,2) = index to descB/keypointsB

findBook = single(imread('findBook.jpg'))/255;
findBook = rgb2gray(findBook);

highlights = zeros(size(findBook,1),size(findBook,2));
for i=1:size(matches,1)
    x = round(keypointsB(1,matches(i,2)));
    y = round(keypointsB(2,matches(i,2)));
    highlights(x,y) = 1;
end

figure; imagesc(highlights); axis image; colormap gray;
title('book keypoints');



