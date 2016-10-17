clear all;close all;
%% Question 1 a)
img = double(imread('cameraman.tif'));
%img = double(imread('synthetic.png'));
%img = rgb2gray(img);

%Function for Harris corner metric using harmonic mean
%Cornerness metric output
%use builtins for convolution,gradients but compute M
%adjust a to get a good result 

% baseline smoothing of the original image 
img = imgaussfilt(img,2.0);
img_siz = size(img);

% gradient wrt to x and y
[gx, gy] = gradient(img);

% Compute M and R
% M is a 2 × 2 second moment matrix computed from image gradients
% need to compute M in each image location
% In a particular location I need to compute M as a weighted average of gradients in a window

% M = w(x,y) for all x y [Ix^2, Ix * Iy;  Ix * Iy, Iy^2];

% w(x,y) window function
% window function either a box filter or gaussian, using a gaussian here

Ix = gx .* gx;
Iy = gy .* gy;
Ixy = gx .* gy;

% Use same window function as MATLAB implementation
%w = fspecial('gaussian',[5 1],1.5);
w = fspecial('gaussian',[5 1],2.0);
window = w * w';

% Convolve Ix^2, Iy^2, and IxIy with window function to get values for
% window around each i,j in image
Ix = conv2(Ix, window, 'same');
Iy = conv2(Iy, window, 'same');
Ixy = conv2(Ixy, window, 'same');

M_ij = zeros(2);
R = zeros(img_siz(1), img_siz(2));

for i=1:img_siz(1)
    for j=1:img_siz(2)
        M_ij = [Ix(i,j), Ixy(i,j); Ixy(i,j), Iy(i,j)];
        %Not using Brown Harmonic Mean, using Harris and Stevens R value
        sens_val = 0.04;
        R(i,j) = det(M_ij) - sens_val * trace(M_ij) .^ 2;
        % Harmonic Mean
        R(i,j) = det(M_ij)/trace(M_ij);
    end
end

figure; imagesc(R); axis image; colormap gray;

% Compare with builtin cornerness metric calculations
%cornernessB = cornermetric(mean(img,3)); 

%figure; imagesc(cornernessB); axis image; colormap gray;

cornerness = R;
% Playing around with ordfilt 2 to do non-maxima suppression
% Using a square element, should use a circular at end


%% Q1b
%Maximum filter -- what we want -- filter out non-corners
cornernessMax = ordfilt2(cornerness,9,ones(3,3));
% Different sized element - going above three seems to not be necessary
% you end up just making the points larger
% The larger the element used, the more coarse the maxima suppression
% output becomes, e.g. maximum are much larger 'blocks'
cornernessMax1 = ordfilt2(cornerness,49,ones(7,7));

figure; imagesc(cornernessMax); axis image; colormap gray;
figure; imagesc(cornernessMax1); axis image; colormap gray;

% use a disk filter and find position of maximum element based on numel
% Larger radius for disk elements has a similar effect to square elements
% the circular points become larger where the maxima are

element = fspecial('disk',3)>0; %> 0 makes elems logicals

B = ordfilt2(cornerness, numel(find(element)), element);
figure; imagesc(B); axis image; colormap gray;



%% Q1c

% Lowe’s approach creates a Gaussian pyramid with s blurring levels per
% octave, computes difference between consecutive levels, and finds local
% extrema in space and scales

sigma = 2;
%Filter image over range of scales defined based on the sigma of the LoG
log = fspecial('log', [25,25], sigma);
%figure; imagesc(h); axis image; colormap gray;


imgS = img;%conv2(img,fspecial('Gaussian',[25 25],0.5),'same');%Base smoothing
cnt = 1;
clear responseDoG responseLoG
k = 1.1;
sigma = 2.0;
s = k.^(1:50)*sigma;
responseDoG = zeros(size(img,1),size(img,2),length(s));
responseLoG = zeros(size(img,1),size(img,2),length(s));
imG = zeros(size(img,1),size(img,2),length(s));

%% Filter over a set of scales
% 50 scales - response LoG  is m x n x 50 dim matrix
for si = 1:length(s);
    sL = s(si);
    hs= max(25,min(floor(sL*3),128));
    HL = fspecial('log',[hs hs],sL);
    H = fspecial('Gaussian',[hs hs],sL);
    if(si<length(s))
        Hs = fspecial('Gaussian',[hs hs],s(si+1));
    else
        Hs = fspecial('Gaussian',[hs hs],sigma*k^(si+1));
    end
    imgFiltL = conv2(imgS,HL,'same');
    imgFilt = conv2(imgS,H,'same');
    imG(:,:,si) = imgFilt;
    imgFilt2 = conv2(imgS,Hs,'same');
    %Compute the DoG
    responseDoG(:,:,si)  = (imgFilt2-imgFilt);
    %Compute the LoG
    responseLoG(:,:,si)  = (sL^2)*imgFiltL;
    %figure; imagesc(responseLoG(:,:,si)); axis image; colormap gray;
    %title('Response LoG');
end
        fg = figure;imagesc(img);axis image;hold on;colormap gray;
        drawnow;
        %[x,y] = ginput(1);
        %x= round(x);
        %y = round(y);


%% Find maxima in each scale space
for x=10:img_siz(1)-10
    for y=10:img_siz(2)-10

           %asdf
        LoG = figure;plot(s,squeeze(responseLoG(y,x,:)));
        title('LoG');grid on;hold on;
        figure(LoG);

        %Get the maxima/minima over scale
        f = squeeze(responseLoG(y,x,:));
        [fMax,fmaxLocs] = findpeaks(f);%maxima
        [fMin,fminLocs] = findpeaks(-f);%minima

        for i = 1:numel(fmaxLocs)
            sc = s(fmaxLocs(i));
            figure(LoG);
            line([sc sc],[min(f) max(f)],'color',[1 0 0]);
            %Draw a circle
            figure(fg);
            xc = sc*sin(0:0.1:2*pi)+x;
            yc = sc*cos(0:0.1:2*pi)+y;
            plot(xc,yc,'r');

            %% Is it also a spatial maxima/minima?
            [nx,ny,nz] = meshgrid(x-1:x+1,y-1:y+1,fmaxLocs(i));
            inds = sub2ind(size(responseLoG),ny,nx,nz);
            df = responseLoG(inds(5))-responseLoG(inds);
            df(5)=[];%don't compare to itself
            if(min(df)>=0)
                plot(xc,yc,'r-o');
            end
        end
 %asdf
    end
end

        pause;
        close all;
        drawnow;
