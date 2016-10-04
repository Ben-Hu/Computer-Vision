%%Compute magnitude of the gradients of the image
clear all; close all;
img = double(imread('emoji.png'))/255;
img = rgb2gray(img);
% sub-sample I for now for ease of computation
%img = img(100:150,100:150);
%img = img(1:4,1:4);
% smooth img
img = imgaussfilt(img, 1);
img_siz = size(img);
m1 = [-1, 0, 1];
m2 = [-1;0;1];
% grad wrt x
res1 = conv2(img,m1,'same');
% gradient wrt y
res2 = conv2(img,m2,'same');
% turn into vectors
res1 = reshape(res1,[],1);
res2 = reshape(res2,[],1);
siz = size(res1);
% pre-allocated gradient of magnitudes vector
gradMag = zeros(siz(1),1);
% compute magnitude of gradients
for iter=1:siz(1)
    gradMag(iter)=sqrt((res1(iter) * res1(iter)) + (res2(iter) * res2(iter)));
end
% reshape magnitude of gradients to original image dimensions
gradMag = reshape(gradMag, [img_siz(1),img_siz(2)]);
%figure; imagesc(gradMag);axis image;colormap gray;

% create a graph with source S and sink T
% for each node n1 and n2, edge weight(n1, n2) = the pixel value of n2. 
% nodes will be indexed according to matrix position e.g. node 1 = (1,1)
% e.g. weight(S,node(1)) = gradMag(1,1)
% connect each node in the graph to it's neighbour directly below and 
% diagonally below (if exists) in the matrix (do not connect horizontal 
% neighbours

%create edge_table and node_table to make the graph

% NodeTable
node_table = table;
x_vals = 1:img_siz(1);
x_vals = reshape(repmat(x_vals,img_siz(2),1),[],1);
node_table.x = x_vals;

y_vals = reshape(1:1:img_siz(2),[],1);
y_vals = reshape(repmat(y_vals,1, img_siz(1)),[],1);
node_table.y = y_vals;

node_indexes = reshape(1:1:img_siz(1)*img_siz(2),[],1);
node_table.pixelIndex = node_indexes;

% EdgeTable
edge_table = table; 
% DOWN EDGES
% skip last rows
n1= 1:1:(img_siz(1)*img_siz(2))-img_siz(1);
% skip first row
n2 = img_siz(1)+1:1:img_siz(1)*img_siz(2);
n1 = reshape(n1,[],1);
n2 = reshape(n2,[],1);
%edge_table.EndNodes = reshape([n1;n2],[],2); % something is going wrong here, reshape first before concating
edge_table.EndNodes = [n1,n2];
%pixel values of all except first row
edge_table.Weight = reshape(gradMag(2:end,:),[],1);

g3 = digraph(edge_table,node_table);
% DIAGONAL EDGES
% Skip SW edge iff node(n) n mod img_siz(2) == 1 (left edge of image)
% Skip SE edge iff node(n) n mod img_Siz(2) == 0 (right edge of image)
% Else SW edge = n + im_siz(2) - 1
% and SE edge = n + im_siz(2) + 1
% Fill edge weights with 1 for now

for node=1:length(node_indexes)
    if mod(node,img_siz(2)) ~= 1
        %not a node in the first column 
        %find the SW edge value (gradient magnitude of pixel at 
        %nodeIndex + img_siz(2) - 1
        row = node_table.pixelIndex==node+img_siz(2)-1;
        pixInd = node_table.pixelIndex(row);
        %Matrix indices of the pixel being processed
        x = node_table.x(row);
        y = node_table.y(row);
        g3 = addedge(g3,node,pixInd,gradMag(x,y));
    end
    if mod(node,img_siz(2)) ~= 0
        %not a node in the last column
        %find the SE edge value (gradient magnitude of pixel at
        %nodeIndex + img_size(2) + 1
        row = node_table.pixelIndex==node+img_siz(2)+1;
        pixInd = node_table.pixelIndex(row);
        %Matrix indicies of the pixel being processed
        x = node_table.x(row);
        y = node_table.y(row);
        g3 = addedge(g3,node,pixInd,gradMag(x,y));
    end
end

% add SOURCE and SINK nodes 
source_sink = table;
source_sink.x = zeros(2,1);
source_sink.y = zeros(2,1);
source_sink.pixelIndex = [-1;-2];
g3 = addnode(g3,source_sink);
% nodeid of source will be img_siz(1) * img_siz(2) + 1
% nodeid of sink will be img_siz(1) * img_siz(2) + 2
source  = img_siz(1) * img_siz(2) + 1;
sink = img_siz(1) * img_siz(2) + 2;
% Connect the source and sink to the graph
for first_row_node=1:img_siz(2)
    % Connect to every node in the first row to the source
    
    % weights equal the first row of the magnitude of the gradients
    row_f = node_table.pixelIndex==first_row_node;
    %pixInd should be equal to the iterator
    pixind_f = node_table.pixelIndex(row_f);
    x_f = node_table.x(row_f);
    y_f = node_table.y(row_f);
    g3 = addedge(g3,source, pixind_f, gradMag(x_f,y_f));
    
    % Connect every node in the last row with the sink
    % Weights for edges equal to 0 ( do not affect gradient energy calculation)
    last_row_node = first_row_node + ((img_siz(1)-1) * img_siz(2));
    row_l = node_table.pixelIndex==last_row_node;
    pixind_l = node_table.pixelIndex(row_l);
    g3 = addedge(g3,pixind_l,sink,0);
end

%figure;
%plot(g3);

%find least cost path from source to sink 
%equal to the lowest gradient energy from top to bottom of image
%this is for 'vertical' seams
%flip the image to do 'horizontal' seams

s_path = shortestpath(g3,source,sink);
%do not try to remove source/sink
s_path = s_path(2:end-1);

%change image into a vector and delete the nodes in the shortest path from
%the vector, then reshape into the original image dimension, would
%probably have been better to treat the image as a vector from the start.

%reshape transpose of img and turn it into a vector so the indices
%of the vector line up with the pixelIndices of the nodes
%for value v in s_path, remove index v from this image vector

new_img = reshape(img.',1,[]);
num_to_remove = length(s_path);
for i=1:num_to_remove
    %remove pixel s_path(i) from new_img
    %offset the index in s_path as the indexes of new_img change as we
    %remove pixels
    offset = i-1;
    pixel = s_path(i);
    new_img(pixel-offset) = [];
end

figure; imagesc(new_img);axis image;colormap gray;





