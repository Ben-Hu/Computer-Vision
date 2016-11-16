%% Assignment 4 Q2d
% compute the center of mass for each bounding box from q2c
% the center of mass is the x,y,z center
% how to get depth of the object? - use depth information within each
% detection's bounding box.

%code from q2c
%Visualize the three images with the 
%best detections of car, person, and bicycle
%car = red
%person = blue
%bicycle = cyan
% - text function - add label to each bounding box as well
clear all; close all;
globals;
addpath(genpath(pwd))

%% Get dataset to process
data = getData([], 'test', 'list'); 
% cast cell to str 
ids = string(data.ids(1:3));

%% Left camera imgs and detections
for i=1:size(ids,1)
    eval(sprintf('imdata = getData(ids(%d), ''test'', ''left'');', i));
    eval(sprintf('img%dLeft = imdata.im;', i));
    eval(sprintf('img%dLeftCarRes = getData(ids(%d), [], ''result_car_left'');',i,i));
    eval(sprintf('img%dLeftCarRes = img%dLeftCarRes.ds;',i,i));
    eval(sprintf('img%dLeftPersonRes = getData(ids(%d), [], ''result_person_left'');',i,i));
    eval(sprintf('img%dLeftPersonRes = img%dLeftPersonRes.ds;',i,i));
    eval(sprintf('img%dLeftBicycleRes = getData(ids(%d), [], ''result_bicycle_left'');',i,i));
    eval(sprintf('img%dLeftBicycleRes = img%dLeftBicycleRes.ds;',i,i));
end

%% Right camera imgs and detections
for i=1:size(ids,1)
    eval(sprintf('imdata = getData(ids(%d), ''test'', ''right'');', i));
    eval(sprintf('img%dRight = imdata.im;', i)); 
    eval(sprintf('img%dRightCarRes = getData(ids(%d), [], ''result_car_right'');',i,i));
    eval(sprintf('img%dRightCarRes = img%dRightCarRes.ds;',i,i));
    eval(sprintf('img%dRightPersonRes = getData(ids(%d), [], ''result_person_right'');',i,i));
    eval(sprintf('img%dRightPersonRes = img%dRightPersonRes.ds;',i,i));
    eval(sprintf('img%dRightBicycleRes = getData(ids(%d), [], ''result_bicycle_right'');',i,i));
    eval(sprintf('img%dRightBicycleRes = img%dRightBicycleRes.ds;',i,i));
end

% figure; imagesc(img1Left);axis image;
% figure; imagesc(img2Left);axis image;
% figure; imagesc(img3Left);axis image;
% 
% figure; imagesc(img1Right);axis image;
% figure; imagesc(img2Right);axis image;
% figure; imagesc(img3Right);axis image;

%% Depth calculations from part A
depthMap1 = load('./depthMap1.mat');
depthMap1 = depthMap1.depth1;
depthMap2 = load('./depthMap2.mat');
depthMap2 = depthMap2.depth2;
depthMap3 = load('./depthMap3.mat');
depthMap3 = depthMap3.depth3;

%% Plot the boxes on the images
% IMG1LEFT
[cm1cL,cm1pL,cm1bL] = plotBoxes(img1Left, img1LeftCarRes, img1LeftPersonRes, img1LeftBicycleRes,10,10,10,depthMap1);

% IMG2LEFT
[cm2cL,cm2pL,cm2bL] = plotBoxes(img2Left, img2LeftCarRes, img2LeftPersonRes, img2LeftBicycleRes,10,10,10,depthMap2);

% IMG3LEFT
[cm3cL,cm3pL,cm3bL] = plotBoxes(img3Left, img3LeftCarRes, img3LeftPersonRes, img3LeftBicycleRes,10,10,10,depthMap3);


% IMG1RIGHT
[cm1cR,cm1pR,cm1bR] = plotBoxes(img1Right, img1RightCarRes, img1RightPersonRes, img1RightBicycleRes,10,10,10,depthMap1);

% IMG2RIGHT
[cm2cR,cm2pR,cm2bR] = plotBoxes(img2Right, img2RightCarRes, img2RightPersonRes, img2RightBicycleRes,10,10,10,depthMap2);

% IMG3RIGHT
[cm3cR,cm3pR,cm3bR] = plotBoxes(img3Right, img3RightCarRes, img3RightPersonRes, img3RightBicycleRes,10,10,10,depthMap3);

%% Plot all the bounding boxes for cars, persons, and bicycles on the img
function [cmC,cmP,cmB]=plotBoxes(img,carRes,personRes,bicycleRes,topC,topP,topB,depthMap)
    %top* params are for limiting the plots to the top 'top*' detections
    %should have thresholded more in part b since ther are many false
    %detections
    fontsize = 10;
    cmC = zeros(min(topC,size(carRes,1)),3);
    cmP = zeros(min(topC,size(personRes,1)),3);
    cmB = zeros(min(topC,size(bicycleRes,1)),3);
    figure;imagesc(img);axis image;hold on;
    for i=1:min(topC,size(carRes,1))
        bounds = carRes(i,1:4);
        xl = bounds(1);
        yt = bounds(2);
        xr = bounds(3);
        yb = bounds(4);
        xp = [xl,xr,xr,xl,xl];
        yp = [yb,yb,yt,yt,yb];
        %need to estimate the 'width/length' of object (depending on it's
        %orientation, depth from earlier parts, Z + some estimate of the
        %object's actual size -- don't think we can get this from stereo
        %images?
        
        %get depth at the center of the bounding box, need to add some
        %offset to this depth
        xc = round((xr + xl)/2);
        yc = round((yb + yt)/2);
        dt = round(depthMap(yc,xc));
        cmC(i,:) = [xc,yc,depthMap(yc,xc)];
        plot(xp,yp,'r','LineWidth',2);
        text(xl,yt+fontsize/2, sprintf('Car%d',i) ,'Color','r','FontSize',fontsize,'FontWeight','bold');
        text(xc,yc, sprintf('c:%d d:%d',i,dt),'Color','m','FontSize',fontsize,'FontWeight','bold');
    end
    for i=1:min(topP,size(personRes,1))
        bounds = personRes(i,1:4);
        xl = bounds(1);
        yt = bounds(2);
        xr = bounds(3);
        yb = bounds(4);
        xp = [xl,xr,xr,xl,xl];
        yp = [yb,yb,yt,yt,yb];
        xc = round((xr + xl)/2);
        yc = round((yb + yt)/2);
        dt = round(depthMap(yc,xc));
        cmP(i,:) = [xc,yc,depthMap(yc,xc)];
        plot(xp,yp,'b','LineWidth',2); 
        text(xl,yt+fontsize/2,sprintf('Person_%d',i),'Color','b','FontSize',fontsize,'FontWeight','bold');
        text(xc,yc,sprintf('p:%d d:%d',i,dt),'Color','g','FontSize',fontsize,'FontWeight','bold');
    end
    for i=1:min(topB,size(bicycleRes,1))
        bounds = bicycleRes(i,1:4);
        xl = bounds(1);
        yt = bounds(2);
        xr = bounds(3);
        yb = bounds(4);
        xp = [xl,xr,xr,xl,xl];
        yp = [yb,yb,yt,yt,yb];
        xc = round((xr + xl)/2);
        yc = round((yb + yt)/2);
        dt = round(depthMap(yc,xc));
        cmB(i,:) = [xc,yc,depthMap(yc,xc)];
        plot(xp,yp,'c','LineWidth',2); 
        text(xl,yt+fontsize/2,sprintf('Bike_%d',i),'Color','c','FontSize',fontsize,'FontWeight','bold');
        text(xc,yc, sprintf('b:%d d:%d',i,dt),'Color','y','FontSize',fontsize,'FontWeight','bold');
    end
    hold off;
end

% 
% C = [0 255];
% figure; imagesc(depthMap1,C); axis image; title('depth 1');
% hp = impixelinfo;