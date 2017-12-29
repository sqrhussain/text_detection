function x = c_im2vec(im)
im = rgb2gray(im);
im = imresize(im,[10 10]);
x = im(:);
end