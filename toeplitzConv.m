I = [1,2,3;4,5,6;7,8,9]

hx =[1 2 1];
hy = [1 2 1]';
H = hy*hx;
hx = hx/sum(hx(:));
hy = hy/sum(hy(:));
H = H/sum(H(:));%normalize the filter

IC = conv2(I,H,'same');

H2 = reshape(H,[numel(H),1])
ICtoeplitz = convmtx(I,length(H2))

IC2 = ICtoeplitz * H2;

figure;imagesc(IC);axis image;colormap gray;
figure;imagesc(IC2);axis image;colormap gray;

