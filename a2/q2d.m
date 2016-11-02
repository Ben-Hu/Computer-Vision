
%% Question 2 d)
a = affine_matrix(1); b = affine_matrix(2); c = affine_matrix(3);
d = affine_matrix(4); e = affine_matrix(5); f = affine_matrix(6);

aff = [a,b,e;c,d,f];
%append row of ones to a_keys (x,y,1)
a_keys = cat(1,a_keys,ones(1,length(a_keys)));

transformed_book = zeros(size(findBook,1),size(findBook,2));
for i=1:size(book,1)
    for j=1:size(book,2)
        res = aff * [i;j;1];
        new_x = round(res(1));
        new_y = round(res(2));
        transformed_book(new_x,new_y) = book(i,j);
    end
end
figure; imagesc(transformed_book);axis image; colormap gray;hold on

%Plot the parallelogram over the findBook image
bl_corner = round(aff*[0;0;1]);
br_corner = round(aff*[0;320;1]);
tl_corner = round(aff*[499;0;1]);
tr_corner = round(aff*[499;320;1]);

figure; imagesc(findBook);axis image; colormap gray;hold on
line([bl_corner(2),tl_corner(2)],[bl_corner(1),tl_corner(1)]);
line([bl_corner(2),br_corner(2)],[bl_corner(1),br_corner(1)]);
line([tr_corner(2),br_corner(2)],[tr_corner(1),br_corner(1)]);
line([tr_corner(2),tl_corner(2)],[tr_corner(1),tl_corner(1)]);
title('plot parallelogram');
