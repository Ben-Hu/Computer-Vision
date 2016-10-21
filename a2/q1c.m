clear all;close all;
img = double(imread('synthetic.png'));
img = rgb2gray(img);

% img = zeros(256,256);
% img(100:125,100:125)=1;

%% Q1c
% Lowe’s approach creates a Gaussian pyramid with s blurring levels per
% octave, computes difference between consecutive levels, and finds local
% extrema in space and scales

sigma = 2;
%Filter image over range of scales defined based on the sigma of the LoG
log = fspecial('log', [25,25], sigma);
%figure; imagesc(h); axis image; colormap gray;

%imgS = img;
imgS = conv2(img,fspecial('Gaussian',[25 25],0.5),'same');%Base smoothing
cnt = 1;
clear responseLoG
%k = scaling factor of LoGs
%k = 1.1;
k = 1.1;
%sigma = 2.0;
sigma = 2.0;
scales = 50;
s = k.^(1:scales)*sigma;

responseLoG = zeros(size(img,1),size(img,2),length(s));

%% Filter over a set of scales
% 50 scales - response LoG  is m x n x 50 dim matrix
for si = 1:length(s);
    sL = s(si);
    %Limited support for larger gaussians in original tutorial code
    %hs= max(25,min(floor(sL*3),128));
    hs = 2*ceil(2*sL) + 1;
    HL = fspecial('log',[hs hs],sL);
    imgFiltL = conv2(imgS,HL,'same');
   
    %Compute the LoG
    responseLoG(:,:,si)  = sparse(abs((sL^2)*imgFiltL));
    
    %figure; imagesc(responseLoG(:,:,si)); axis image; colormap gray;
    %title(['Response LoG ',num2str(sL),' sigma value ']);    
end

scale_low_thresh = 10;
scale_high_thresh = scales-20; %49
scales_checked = scale_high_thresh - scale_low_thresh;
relMaxes = zeros(size(img,1),size(img,2),scales_checked);
relMins = zeros(size(img,1),size(img,2),scales_checked);
nonzeros = 0;
nonzeros_min = 0;

for level=scale_low_thresh:scale_high_thresh
    %3x3 search grid -- restrict check to levels 2-(scales -1)
    localCube = responseLoG(:,:,level-1:level+1);
    %for each max/min check if it is a max/min across scale
    %check 26 connected neighbours of each pixel in 3d matrix
    %output is a mxnx3 logical
    allMaxes = imregionalmax(localCube,26);
    allMins = imregionalmax(-localCube,26);
    %maxes on relevant 'slice'
    curMaxes = allMaxes(:,:,2);
    curMins = allMins(:,:,2);
    %if sum(curMaxes(:)) ~= 0
    %    relMaxes = cat(3,relMaxes,curMaxes);
    %end
    if sum(curMaxes(:)) ~= 0
        nonzeros = nonzeros + 1;
        relMaxes(:,:,level) = curMaxes;
    end
    if sum(curMins(:)) ~= 0
        nonzeros_min = nonzeros_min + 1;
        relMins(:,:,level) = curMins;
    end
    
end

%Mins are messed up
sumMax = sum(relMaxes,3);
sumMin = sum(relMins,3);

interestPoints = sumMax + sumMin;
figure; imagesc(interestPoints); title('interest points'); colormap gray;

overlay = cat(3, img, interestPoints);
overlay = cat(3, overlay, interestPoints);
figure; imagesc(overlay); title('overlay');

