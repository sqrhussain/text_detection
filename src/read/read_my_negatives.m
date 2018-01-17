function [X,t] = read_my_negatives()



negpath = '../data/training/neg/';
files = dir(negpath);
files = files(3:end);
N = length(files);
X = zeros(8,N);
t = zeros(1,N);


pbar = waitbar(0,'Reading my negatives...');
for i = 1 : length(files)
    file = files(i);
    im = imread(strcat(negpath,file.name));
    g = rgb2gray(im);
    bw = im2bw(g, graythresh(g));
    
    [region,bounds] = region_of_interest(bw);
    
    X(:,i) = geometric_features(region);
        
    waitbar(i/N);
end