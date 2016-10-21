clear all;%close all;
%% Question 1 c)
img = double(imread('synthetic.png'));
img = double(imread('building.jpg'))/255;
img = rgb2gray(img);

imgS = conv2(img,fspecial('Gaussian',[25 25],0.5),'same');%Base smoothing
clear responseLoG

% Parameters used to make a set of scales(sigmas) for the LoGs
k = 1.1;
sigma = 1.5;
scales = 50;
s = k.^(1:scales)*sigma;

responseLoG = zeros(size(img,1),size(img,2),length(s));

%% Filter over a set of scales
% 50 scales - response LoG  is m x n x 50 dim matrix
for si = 1:length(s);
    sL = s(si);
    %original tutorial code support was too limited
    %185 size filter with the chosen k,sigma,scales, and thresholds
    %is the minimum we need to get all the relevant details for this image
    hs = min(2*ceil(2*sL) + 1, 185);
    HL = fspecial('log',[hs hs],sL);
    imgFiltL = conv2(imgS,HL,'same');
   
    %Compute the LoG
    responseLoG(:,:,si)  = sparse(abs((sL^2)*imgFiltL));
    
    %figure; imagesc(responseLoG(:,:,si)); axis image; colormap gray;
    %title(['Response LoG ',num2str(sL),' sigma value ']);    
end

%Parameters adjusted, going below scales-11 on the high end loses out on
%the left eye and having too high of a low threshold loses the corners of 
%the mouth
scale_low_thresh = 5;
scale_high_thresh = scales-11; %39
scales_checked = scale_high_thresh - scale_low_thresh;

relMaxes = zeros(size(img,1),size(img,2),scales_checked);
relMins = zeros(size(img,1),size(img,2),scales_checked);

for level=scale_low_thresh:scale_high_thresh
    % m x n x 3 stack of LoG responses  
    scaleLayers = responseLoG(:,:,level-1:level+1);
    
    % for each max/min wrt location the middle layer (current 'level'),
    % check if it is a max/min across scale (in layer level-1 and level+1)
    % specifically check 26 connected neighbours of each pixel in the 
    % 3d scaleLayers matrix 9 above, 9 below, and 8 on the same level
    
    % tried imregionalmax but that function returns local trues in 
    % locations where neighbours have equal value. Using imdilate instead 
    % with a strictly greater than operator comparison against scaleLayers 
    % will filter out the 'non-strict maxima'
    
    % imdilate replaces the value of each pixel with the maximum of it's 
    % connected neighbours with value 1 in the given 3d cube mask.
    % The > comparison with the original scaleLayers matrix returns a 
    % m x n x 3 logical matrix where the 0s are non-maxima and 1s are
    % strict maxima. 
    
    % Each layer of the output logical matrix, dilated, corresponds to
    % maxima across scale for the given layer compared to the adjacent
    % layers e.g. dilated(:,:,3) has maxima compared to dilated(:,:,2)
    % which is not useful for our purposes, we only care about maxima in
    % the middle layer (2) since that is the scale levle we are currently 
    % checking
    
    mask = cat(3, cat(3, ones(3,3), [1,1,1;1,0,1;,1,1,1]), ones(3,3));
    dilated = imdilate(scaleLayers, mask);
    curMaxes = scaleLayers > dilated;
    relMaxes(:,:,level) = curMaxes(:,:,2);
    
    % imerode will operate similarily to imdilate except for smallest neighbour
    % values instead of greatest
    dilated_min = imerode(-scaleLayers, mask);
    curMins = -scaleLayers < dilated_min;
    relMins(:,:,level) = curMins(:,:,2);
    
end

% Combine all the maxima found across all scales into a 2d matrix to show
% in grayscale
sumMax = sum(relMaxes,3);
sumMin = sum(relMins,3);

interestPoints = sumMax; + sumMin;
figure; imagesc(interestPoints); title('interest points'); colormap gray;

%overlay the points over the original image
overlay = cat(3, interestPoints, zeros(size(img,1),size(img,2)));
overlay = cat(3, overlay, img);

%overlay = cat(3, interestPoints + img, img);
%overlay = cat(3, overlay, img);

%overlay = img + interestPoints;
figure; imagesc(overlay); title('overlay'); axis image; colormap gray;

