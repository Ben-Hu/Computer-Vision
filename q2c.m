clear all;close all;
%fix this, should not have x and y sepcified, generated x and y as 2-3 * sigma (sufficient support)
x = 11;
y = 11;
sig_x = 1;
sig_y = 1;

reference = fspecial('gaussian', [11 11], 1);

xOffset = (x-1)/2;
yOffset = (y-1)/2;

%xCoord = matrix w/ x value wrt the origin (0) e.g. [-1,0,1;-1,0,1;1,0,1]
%yCoord = matrix w/ y values wrt the origin, upsidedown [-1,-1,-1;0,0,0;1,1,1]
[xCoord,yCoord] = meshgrid(-xOffset:xOffset,-yOffset:yOffset);

for xIter = 1:x
    for yIter = 1:y
        a = 1/(2*pi*sig_x*sig_y);
        b = (xCoord(xIter,yIter)*xCoord(xIter,yIter))/(sig_x*sig_x) + ...
            (yCoord(xIter,yIter)*yCoord(xIter,yIter))/(sig_y*sig_y);
        res = a * exp(-b/2); 
        myAnisoGauss(xIter,yIter) = res;      
    end
end
