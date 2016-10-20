clear all;close all;
img = double(imread('synthetic.png'));
img = rgb2gray(img);

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
sigma = 3.0;
scales = 50;
s = k.^(1:scales)*sigma;

responseLoG = zeros(size(img,1),size(img,2),length(s));
imG = zeros(size(img,1),size(img,2),length(s));

%% Filter over a set of scales
% 50 scales - response LoG  is m x n x 50 dim matrix
for si = 1:length(s);
    sL = s(si);
    hs= max(25,min(floor(sL*3),128));
    HL = fspecial('log',[hs hs],sL);
    imgFiltL = conv2(imgS,HL,'same');
   
    %Compute the LoG
    responseLoG(:,:,si)  = sparse(abs((sL^2)*imgFiltL));
    
%     %local maxima and minima for level
%     if ((si > 1) && (si < length(s) -1))
%         %Dimensionality of these maxima and minima will not match across
%         %level
%         v = reshape(responseLoG(:,:,si),1,[]);
%         [fMax,fmaxLocs] = findpeaks(v); %maxima
%         [fMin,fminLocs] = findpeaks(-v); %minima
%     end
    
    
    %figure; imagesc(responseLoG(:,:,si)); axis image; colormap gray;
    %title(['Response LoG ',num2str(sL),' sigma value ']);    
end

chk = 0
if chk==1
    maxima_x = [];
    maxima_y = [];
    maxima_scale = [];
    for level=2:(scales-1)
        %3x3 search grid -- restrict check to levels 2-(scales -1)
        %check indices x = 2:size(response,1) -1 
        %and y = 2:size(response,2) -1
        curScale = responseLoG(:,:,level);
        curScale = reshape(curScale,1,[]);
        [fMax,fmaxLocs] = findpeaks(v); %maxima
        [fMin,fminLocs] = findpeaks(-v); %minima
        
        %translate fmax and min Locs to x and y coordinates and operate on
        %them or just do all the operations here across a vector
        for x=2:size(curScale,2)-1
           for y=2:size(curScale,1)-1
               cpix = responseLoG(x,y,level);
               %neighbours to pixel across scale and location
               neighbours = zeros(3,3,3);
               neighbours(:,:,2) = responseLoG(x-1:x+1,y-1:y+1,level);
               neighbours(:,:,1) = responseLoG(x-1:x+1,y-1:y+1,level+1);
               neighbours(:,:,3) = responseLoG(x-1:x+1,y-1:y+1,level-1);
               %3x3x3 logical 
               gt = cpix > neighbours;
               %pixel is a maxima across scale and location
               if (sum(gt(:))==26)
                   maxima_x = [maxima_x:x];
                   maxima_y = [maxima_y:y];
                   maxima_scale = [maxima_scale:level];
               end
           end
        end
    end
end















% 
% %% Find maxima in each scale space
% fg = figure;imagesc(img);axis image;hold on;colormap gray;
% drawnow;
% 
% % This will find the maxima in each scale space at given point x,y
% % Ultimately we want all maxima/minima points above a given LoG sigma
% % threshold size (e.g. only relevant maxima/minima
% 
% [x,y] = ginput(1);
% x= round(x);
% y = round(y);
%     
% LoG = figure;plot(s,squeeze(responseLoG(y,x,:)));
% title('LoG');grid on;hold on;
% figure(LoG);
% 
% %Get the maxima/minima over scale
% f = squeeze(responseLoG(y,x,:));
% [fMax,fmaxLocs] = findpeaks(f);%maxima
% [fMin,fminLocs] = findpeaks(-f);%minima
% 
% for i = 1:numel(fmaxLocs)
%     sc = s(fmaxLocs(i));
%     figure(LoG);
%     line([sc sc],[min(f) max(f)],'color',[1 0 0]);
%     %Draw a circle
%     figure(fg);
%     xc = sc*sin(0:0.1:2*pi)+x;
%     yc = sc*cos(0:0.1:2*pi)+y;
%     plot(xc,yc,'r');
% 
%     %% Is it also a spatial maxima/minima?
%     [nx,ny,nz] = meshgrid(x-1:x+1,y-1:y+1,fmaxLocs(i));
%     inds = sub2ind(size(responseLoG),ny,nx,nz);
%     df = responseLoG(inds(5))-responseLoG(inds);
%     df(5)=[];%don't compare to itself
%     if(min(df)>=0)
%         plot(xc,yc,'r-o');
%     end
% end
% 
% pause;
% close all;
% drawnow;
% 
% %% Pseduo code
% % convolve image with a number of different scaling Laplacians with
% % different sigmas
% % for each level find the maximum at location and across scales (the two
% % neighbouring sigma scale levels)
% 
% %minimum across scale -- = local minima
% 
% 
% %For each conv'd image at a given scale, find local maximum past a given
% %threshold, then check if the maxima is a maxmima across scales as well as
% %in location. if it is then add it to a vector 
% 
% %if it is a maximum across scales - then that scale is associate with that
% %given feature point at that given location.
% 
% %for a given location if the response is not high enough then ignore that
% %point
% 
% 
% %findpeaks will give us local peaks of a vector -- the image after we get
% %LoG for each scale
% %then we want to compare that peak to the neighbours across scale
% %if the level we are on is a maximum in both respects, save the feature in
% %a list

