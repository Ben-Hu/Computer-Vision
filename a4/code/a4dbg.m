%% Assignment 4 DBG
clear all; close all;
addpath('../data');
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

%These are the images that actually need to be processed
data = getData([], 'test', 'list'); 
ids = data.ids(1:3);


