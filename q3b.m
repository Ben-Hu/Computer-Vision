function out = findWaldo(im, filter)
% returns the output of normalized cross-correlation between image im and
% filter 
% by Sanja Fidler, UofT
% Modified to perform normalized cross-correlation between the magnitude
% of the gradients of image im and filter filter

% convert image (and filter) to grayscale
im_input = im;
im = rgb2gray(im);
im = double(im);
filter = rgb2gray(filter);
filter = double(filter);
filter = filter/sqrt(sum(sum(filter.^2)));

%smooth image, magnitude of gradient of image as new_im
im_siz = size(im);
im= imgaussfilt(im,1);
m1 = [-1, 0, 1];
m2 = [-1;0;1];
res1 = conv2(im,m1,'same');
res2 = conv2(im,m2,'same');
%figure; imagesc(res1);axis image; colormap gray;
%figure; imagesc(res2);axis image; colormap gray;
res1 = reshape(res1,[],1);
res2 = reshape(res2,[],1);
siz = size(res1);
new_im = zeros(im_siz(1),im_siz(2));
for iter=1:siz(1)
    new_im(iter)=sqrt((res1(iter) * res1(iter)) + (res2(iter) * res2(iter)));
end
new_im = reshape(new_im, [im_siz(1),im_siz(2)]);

%smooth filter and compute magnitude of gradients of filter (template)
filter_siz = size(filter);
filter = imgaussfilt(filter,1);
m1 = [-1, 0, 1];
m2 = [-1;0;1];
res1 = conv2(filter,m1,'same');
res2 = conv2(filter,m2,'same');
res1 = reshape(res1,[],1);
res2 = reshape(res2,[],1);
siz = size(res1);
new_filter = zeros(filter_siz(1),filter_siz(2));
for iter=1:siz(1)
    new_filter(iter)=sqrt((res1(iter) * res1(iter)) + (res2(iter) * res2(iter)));
end
new_filter = reshape(new_filter, [filter_siz(1),filter_siz(2)]);

% normalized cross-correlation
out = normxcorr2(new_filter, new_im);

% plot the cross-correlation results
figure('position', [100,100,size(out,2),size(out,1)]);
subplot('position',[0,0,1,1]);
imagesc(out)
axis off;
axis equal;

% find the peak in response
[y,x] = find(out == max(out(:)));
y = y(1) - size(filter, 1) + 1;
x = x(1) - size(filter, 2) + 1;

% plot the detection's bounding box
figure('position', [300,100,size(new_im,2),size(new_im,1)]);
subplot('position',[0,0,1,1]);
imshow(im_input)
axis off;
axis equal;
rectangle('position', [x,y,size(new_filter,2),size(new_filter,1)], 'edgecolor', [0.1,0.2,1], 'linewidth', 3.5);

end
