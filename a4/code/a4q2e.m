%% Assignment 4 Q2e
% segment the objects in the bounding boxes
% we have the depth of the object (assuming center of mass is the Z we
% found) - for every pixel that has depth <= 3m difference in each box,
% assume that is part of the object

% Save the cm#objL/R variables in image groups
% 1L(c,p,b) 2L(c,p,b) 3L(c,p,b) 
% 1R(c,p,b) 2R(c,p,b) 3R(c,p,b)

% Easy to implement, for each each object in each group perform this
% segmentation 

clear all; %close all;
globals;
addpath(genpath(pwd))

%% Get dataset to process
data = getData([], 'test', 'list'); 
% cast cell to str 
ids = string(data.ids(1:3));

%% Left camera imgs
for i=1:size(ids,1)
    eval(sprintf('imdata = getData(ids(%d), ''test'', ''left'');', i));
    eval(sprintf('img%dLeft = imdata.im;', i));
end

%% Right camera imgs
for i=1:size(ids,1)
    eval(sprintf('imdata = getData(ids(%d), ''test'', ''right'');', i));
    eval(sprintf('img%dRight = imdata.im;', i)); 
end

%% Depth Calculations from Q2a
depthMap1 = load('./depthMap1.mat');
depthMap1 = depthMap1.depth1;
depthMap2 = load('./depthMap2.mat');
depthMap2 = depthMap2.depth2;
depthMap3 = load('./depthMap3.mat');
depthMap3 = depthMap3.depth3;

%% Results from Q2d
% L/R structs
% .cmCar
% .cmPerson 
% .cmBike
% .img
% .carRes
% .bikeRes
% .personRes
L1 = load('L1.mat');
L2 = load('L2.mat');
L3 = load('L3.mat');

R1 = load('R1.mat');
R2 = load('R2.mat');
R3 = load('R3.mat');

%all images same dims
init = zeros(size(img1Left,1),size(img1Left,2));
centerMass = L1.cmCar; %center mass information for cars in img1 left
boxes = L1.carRes;
img = L1.img;

%find one object, wrap this in a loop over centerMass to get all objects of
%a type
for i=1:size(depthMap1,1)
    for j=1:size(depthMap1,2)
        %segment the first object
        %need to constrain this to the area of the bounding box
        %centerMass(i,3) = depth of center of mass for i'th best match
        %for all pixels in the depth map, mask those within 3m of the plane
        %given by the depth of the object
        
        %bounds to segment given by boxes(i,1:4)
        obj = 3;
        xl = boxes(obj,1);
        yt = boxes(obj,2);
        xr = boxes(obj,3);
        yb = boxes(obj,4);
        if (i > yt && i < yb) && (j > xl && j < xr) 
            if abs(depthMap1(i,j) - centerMass(obj,3)) <= 3
                %init(centerMass(1,2),centerMass(1,1)) = 50;
                init(i,j) = 1;
            end
        end
    end
end

figure; imagesc(img); axis image; 

%% Need to check if the depth information is correct

figure; imagesc(init); axis image; colormap gray

C = [0 255];
figure; imagesc(depthMap1,C); axis image; title('depth 1');
hp = impixelinfo;



