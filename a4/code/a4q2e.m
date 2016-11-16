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

%% Results from Q2d
% L/R structs
% .cmCar
% .cmPerson 
% .cmBike
% .img
% .carRes
% .bikeRes
% .personRes
% .depthMap
L1 = load('L1.mat');
L2 = load('L2.mat');
L3 = load('L3.mat');

R1 = load('R1.mat');
R2 = load('R2.mat');
R3 = load('R3.mat');

%% Some depth based segmentation examples, cherrypicked to avoid mis-detections

%car segmentation for IMG1
L1c1 = segByDepth(L1,'Car',1,3);
L1c2 = segByDepth(L1,'Car',2,3);
L1c3 = segByDepth(L1,'Car',3,3);

%car segmentation for IM2
L2c2 = segByDepth(L2,'Car',2,3);
L2c3 = segByDepth(L2,'Car',3,3);
L2c4 = segByDepth(L2,'Car',4,3);
L2c6 = segByDepth(L2,'Car',6,3);

%car segmentation for IM3
L3c1 = segByDepth(L3,'Car',1,3);
L3c2 = segByDepth(L3,'Car',2,3);
L3c3 = segByDepth(L3,'Car',3,3);

%use a smaller depth threshold for people & bikes
L1p2 = segByDepth(L1,'Person',2,1);

L2p1 = segByDepth(L1,'Person',2,1);
L2b1 = segByDepth(L2,'Bike',1,1);


show = 0;
if show == 1
%IMG 1 segmentations
figure; imagesc(L1c1); axis image; colormap gray;
figure; imagesc(L1c2); axis image; colormap gray;
figure; imagesc(L1c3); axis image; colormap gray;
figure; imagesc(L1p2); axis image; colormap gray;

%IMG 2 segmentations
figure; imagesc(L2c2); axis image; colormap gray;
figure; imagesc(L2c3); axis image; colormap gray;
figure; imagesc(L2c4); axis image; colormap gray;
figure; imagesc(L2c6); axis image; colormap gray;
figure; imagesc(L2p1); axis image; colormap gray;
figure; imagesc(L2b1); axis image; colormap gray;

%IMG 3 segmentations
figure; imagesc(L3c1); axis image; colormap gray;
figure; imagesc(L3c2); axis image; colormap gray;
figure; imagesc(L3c3); axis image; colormap gray;
end

%% Segmentation of Object by Depth
function [segmented]=segByDepth(inStruct,objType,objNum,dThresh)
% inputs 
% inStruct: L{1-3}/R{1-3} struct from Q2d
% objType: e.g. 'Car', 'Person', 'Bike'
% objNum: which detection to segment (1 is top detection, 2 2nd best, etc.)
% depthMap: depth calculation from depthMap*.mats
% dThresh: distance threshold to use

img = inStruct.img;
depthMap = inStruct.depthMap;
eval(sprintf('centerMass = inStruct.cm%s;', objType));
eval(sprintf('boxes = inStruct.res%s;', objType));

segmented = zeros(size(img,1),size(img,2));
for i=1:size(depthMap,1)
    for j=1:size(depthMap,2)
        %segment the first object
        %need to constrain this to the area of the bounding box
        %centerMass(i,3) = depth of center of mass for i'th best match
        %for all pixels in the depth map, mask those within 3m of the plane
        %given by the depth of the object
        
        %bounds to segment given by boxes(i,1:4)
        %only segment within the bounds of the bounding box for the given
        %object
        xl = boxes(objNum,1);
        yt = boxes(objNum,2);
        xr = boxes(objNum,3);
        yb = boxes(objNum,4);
        if (i > yt && i < yb) && (j > xl && j < xr) 
            if abs(depthMap(i,j) - centerMass(objNum,3)) <= dThresh
                segmented(i,j) = 1;
            end
        end
        
    end
end

%% For debugging depth values
% C = [0 255];
% figure; imagesc(depthMap1,C); axis image; title('depth 1');
% hp = impixelinfo;

% figure; imagesc(img); axis image; 
% figure; imagesc(segmented); axis image; colormap gray

end





