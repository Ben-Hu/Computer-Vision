
%% Assignment 3 Q3A
%% Use vlfeat SIFT implementation to find features and matches
clear all; close all;
imgA = rgb2gray(single(imread('mugShot.jpg'))/255);
cut1= rgb2gray(single(imread('shredded/cut01.png'))/255); %968x216
cut2 = rgb2gray(single(imread('shredded/cut02.png'))/255); %968x215
cut3 = rgb2gray(single(imread('shredded/cut03.png'))/255); %968x216
cut4 = rgb2gray(single(imread('shredded/cut04.png'))/255); %968x216
cut5 = rgb2gray(single(imread('shredded/cut05.png'))/255); %968x217
cut6 = rgb2gray(single(imread('shredded/cut06.png'))/255); %968x216
%Trim 1 or 2 pixels off shredded images to standardize matrix size
%So they can be 'stacked' as a 968x215x6 matrix
imgBt = cut1(:,1:215);
imgBt = cat(3, imgBt, cut2);
imgBt = cat(3, imgBt, cut3(:,1:215));
imgBt = cat(3, imgBt, cut4(:,1:215));
imgBt = cat(3, imgBt, cut5(:,1:215));
imgBt = cat(3, imgBt, cut6(:,1:215));

% Best fits
max_inliers = 0;
best_am = [];
best_matches = [];
best_img = [];

S_cuts = 500;
for i=1:S_cuts
    %Assemble random permutations of cuts
    %Greedy/Dynamic approach would be faster but this will work
    %Highest number of inliers overall across all models and permutations
    %should be the closest match to the mugshot template
    random_cuts = randperm(6,6); 
    imgB = [imgBt(:,:,random_cuts(1)),imgBt(:,:,random_cuts(2)),...
        imgBt(:,:,random_cuts(3)),imgBt(:,:,random_cuts(4)),...
        imgBt(:,:,random_cuts(5)),imgBt(:,:,random_cuts(6))];

    %some base level smoothing
    imgA = conv2(imgA,fspecial('Gaussian',[25 25],0.5),'same');
    imgB = conv2(imgB,fspecial('Gaussian',[25 25],0.5),'same');

    %Find sift features
    [keypointsA,descA] = vl_sift(imgA);
    [keypointsB,descB] = vl_sift(imgB);

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
    pkS = 0.2^3; 
    S = round(log(1-PS)/log(1-pkS));

    % Inlier threshold (euclidean distance between tranformed point and actual
    % match x,y
    T = 1.5;

    num_matches = size(vl_matches,2);

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

            % Thresholding based on the euclidean distance calculation
            if dist <= T
                num_inliers = num_inliers + 1;
            end
        end

        %Check if this model is currently the best and keep it if it is
        if num_inliers > max_inliers 
            best_am = am;
            max_inliers = num_inliers;
            best_matches = random_indices;
            best_img = imgB;
        end

    end
end


%% Visualize the best fit we found, transform imgB -> imgA
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
title('imgA-mugshot');
figure; imagesc(imgB);axis image; colormap gray;hold on
title('imgB-last attempted permutation');
figure; imagesc(XA);axis image; colormap gray;hold on
title('RANSAC Transform');
figure; imagesc(best_img);axis image; colormap gray;hold on
title('Best Img Permutation');


