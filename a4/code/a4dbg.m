%% Assignment 4 DBG
clear all; close all;
globals;
addpath(genpath(pwd))
%img = single(imread('x.png'))/255;

%./data
%training data and test images in data
%load detectors from data/detectors/*.mat

%./code
%devkit
%helpers
%dpm

%getData.m - browse provided data, loading and plotting functionality

%only need to process images in ./data/test
%process the first three images written in the data/test/test.txt
%getData: data = getData([], ?test?, ?list?); ids = data.ids(1:3);

%% Get dataset to process
data = getData([], 'test', 'list'); 
% cast cell to str 
ids = string(data.ids(1:3));

%% Camera Calibration Objs
% structs *.: f, baseline, K, P_left, P_right
for i=1:size(ids,1)
    eval(sprintf('calib%d = getData(ids(%d), ''test'', ''calib'');',i, i));
end

%% Disparity maps 
% Located @ ../data/test/results/{id}_left_disparity.png
for i=1:size(ids,1)
    eval(sprintf('dispMap%d = getData(ids(%d), ''test'', ''disp'');',i,i));
    eval(sprintf('dispMap%d = dispMap%d.disparity;',i,i));
end

%% Calculate Depth f.e. Pix in DispMaps
% Given camera calibrations & dispMaps, calculate depth of each pixel in
depth1 = zeros(size(dispMap1,1), size(dispMap1,2));
depth2 = zeros(size(dispMap2,1), size(dispMap2,2));
depth3 = zeros(size(dispMap3,1), size(dispMap3,2));

%f is in pixels, T in meters, and disparity in pixels. Putting Z in meters.
%closer = larger disparity value = white
for i=1:size(dispMap1,1)
    for j=1:size(dispMap1,2)
        %depth Z = f * T / disparity 
        %f = focal length (pixels) calib{i}.f
        %T = distance between stereo (meters) calib{i}.baseline
        %disparity = [xr - xl] (pixels)
        f = calib1.f;
        T = calib1.baseline;
        Z =  (f * T) / dispMap1(i,j); 
        depth1(i,j) = Z;
    end
end

for i=1:size(dispMap2,1)
    for j=1:size(dispMap2,2)
        %depth Z = f * T / disparity 
        %f = focal length (pixels) calib{i}.f
        %T = distance between stereo (meters) calib{i}.baseline
        %disparity = [xr - xl] (pixels)
        f = calib2.f;
        T = calib2.baseline;
        Z =  (f * T) / dispMap2(i,j); 
        depth2(i,j) = Z;
    end
end

for i=1:size(dispMap3,1)
    for j=1:size(dispMap3,2)
        %depth Z = f * T / disparity 
        %f = focal length (pixels) calib{i}.f
        %T = distance between stereo (meters) calib{i}.baseline
        %disparity = [xr - xl] (pixels)
        f = calib3.f;
        T = calib3.baseline;
        Z =  (f * T) / dispMap3(i,j); 
        depth3(i,j) = Z;
    end
end

%% Visualize the result, depth should be the inverse of disparity
% C = [0 255]; 
% figure; imagesc(dispMap1); axis image; 
% figure; imagesc(depth1,C); axis image; 
% figure; imagesc(dispMap2); axis image; 
% figure; imagesc(depth2,C); axis image;
% figure; imagesc(dispMap3); axis image; 
% figure; imagesc(depth3,C); axis image; 

















