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


%% Compute the homographies between adjacent image components 
% compute via eigendecomposition
% do not use maketform
% visualize: transform keypoints from one image onto the next, diff color.

homographies = zeros(3,3,size(img,3)-1);

for i=1:size(img,3)-1
   
    %Workaround for dynamic variables in matlab
    eval(sprintf('vl_matches = vl_matches%d;', i));
    eval(sprintf('vl_scores = vl_scores%d;', i));
    eval(sprintf('keypointsA = keypoints%d;',i));
    eval(sprintf('keypointsB = keypoints%d;',i+1));
       
    % RANSAC 

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
    S = 1;
    
    
    for i=1:S
        % Pick 4 random matches
        random_indices = randperm(num_matches,4); 
        % hardcoded for 4
        match1 = vl_matches(:,random_indices(1));
        match2 = vl_matches(:,random_indices(2));
        match3 = vl_matches(:,random_indices(3));
        match4 = vl_matches(:,random_indices(4));
        
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
        
        x4A = keypointsA(2,match4(1));
        y4A = keypointsA(1,match4(1));
        x4B = keypointsB(2,match4(2));
        y4B = keypointsB(1,match4(2));

        % Compute the projective transform for these 4 matches
        % Compute the homography via eigen decomposition
        
        % A format 
        % [xn,yn,1,0,0,0,-x'n*xn,-x'n*yn,-x'n;
        % [0,0,0,xn,yn,1,-y'n*xn,-y'n*yn,-y'n];
        A1 = [x1A,y1A,1,0,0,0,-x1B*x1A,-x1B*y1A,-x1B;...
              0,0,0,x1A,y1A,1,-y1B*x1A,-y1B*y1A,-y1B];
        A2 = [x2A,y2A,1,0,0,0,-x2B*x2A,-x2B*y2A,-x2B;...
              0,0,0,x2A,y2A,1,-y2B*x2A,-y2B*y2A,-y2B];
        A3 = [x3A,y3A,1,0,0,0,-x3B*x3A,-x3B*y3A,-x3B;...
              0,0,0,x3A,y3A,1,-y3B*x3A,-y3B*y3A,-y3B];
        A4 = [x4A,y4A,1,0,0,0,-x4B*x4A,-x4B*y4A,-x4B;...
              0,0,0,x4A,y4A,1,-y4B*x4A,-y4B*y4A,-y4B];
        A = [A1;A2;A3;A4];

        %h^ = eigenvector w/ smallest eigenvalue of A^T * A
        At = A' * A;
        [V,D] = eig(At);
       

        hm = eye(3,3);

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

            %for homographies, need to normalize the result of X_pnt
            %dividing x,y by a -- X_pnt(3)
            X_pnt = round(hm * [A_x;A_y;1]);
            X_pnt(1) = X_pnt(1)/X_pnt(3);
            X_pnt(2) = X_pnt(2)/X_pnt(3);
            X_pnt = [X_pnt(1);X_pnt(2)];
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
            best_hm = hm;
            max_inliers = num_inliers;
            best_matches = random_indices;
        end

    end
    
    % Keep the best homography for this image pair, i/i+1
    homographies(:,:,i) = best_hm;

end




% %% Visualize the best fit we found, transform imgB -> imgA
% XA = zeros(size(imgB,1),size(imgB,2));
% for i=1:size(imgA,1)
%     for j=1:size(imgA,2)
%         res = best_am * [i;j;1];
%         new_x = max(1,round(res(1)));
%         new_y = max(1,round(res(2)));
%         XA(new_x,new_y) = imgA(i,j);
%     end
% end
% figure; imagesc(imgA);axis image; colormap gray;hold on
% title('mgA');
% figure; imagesc(imgB);axis image; colormap gray;hold on
% title('imgB');
% figure; imagesc(XA);axis image; colormap gray;hold on
% title('RANSAC Transform');
% 
% %Plot the trasnformation as parallelogram over the image
% bl_corner = round(best_am*[0;0;1]);
% br_corner = round(best_am*[0;387;1]);
% tl_corner = round(best_am*[395;0;1]);
% tr_corner = round(best_am*[395;387;1]);
% 
% figure; imagesc(imgB);axis image; colormap gray;hold on
% line([bl_corner(2),tl_corner(2)],[bl_corner(1),tl_corner(1)]);
% line([bl_corner(2),br_corner(2)],[bl_corner(1),br_corner(1)]);
% line([tr_corner(2),br_corner(2)],[tr_corner(1),br_corner(1)]);
% line([tr_corner(2),tl_corner(2)],[tr_corner(1),tl_corner(1)]);
% title('Transform Overlay');
% 
% %Reference transform from Moore-Penrose lease squares from by A2 code.
% t_am = [0.0597929162403003,1.04042462070958,511.473935250196;,-1.04304742306299,-0.132837054877354,1484.35163183366]
% XAt = zeros(size(imgB,1),size(imgB,2));
% for i=1:size(imgA,1)
%     for j=1:size(imgA,2)
%         res = t_am * [i;j;1];
%         new_x = max(1,round(res(1)));
%         new_y = max(1,round(res(2)));
%         XAt(new_x,new_y) = imgA(i,j);
%     end
% end
% figure; imagesc(XAt);axis image; colormap gray;hold on
% title('RANSACt');


