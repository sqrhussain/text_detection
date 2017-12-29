function X = cellarray2inputvec(data)
X = [];
for i = 1 : length(data)
    X = [X ; (c_im2vec(data{i}))'];
end
X = X';
X = im2double(X);
end