



negpath = '../data/training/neg/';
files = dir(negpath);
files = files(3:end);
files = files(1:2:end);
neginv = zeros(length(files),6);
neginv2 = zeros(length(files),6);

pbar = waitbar(0,'Reading negatives...');
filter = fspecial('Gaussian');

for i = 1 : length(files)
    file = files(i);
    im = imread(strcat(negpath,file.name));
    g = rgb2gray(im);
    g = imfilter(g,filter);
    bw = im2bw(g, graythresh(g));
    inv = invariant_moments(bw);
    neginv(i,:) = inv;
    bw = 1-bw;
    inv = invariant_moments(bw);
    neginv2(i,:) = inv;
%     subplot(2,1,1);
%     set(gca,'YLim',[0 1])
%     semilogy(abs(inv));
%     subplot(2,1,2);
%     imshow(bw)
%     pause
   waitbar(i/length(files));
end

close(pbar);
pbar = waitbar(0,'Reading positives...');

pospath = '../data/training/pos/';
files = dir(pospath);
files = files(3:end);

posinv = zeros(length(files),6);
posinv2 = zeros(length(files),6);
for i = 1 : length(files)
    file = files(i);
    im = imread(strcat(pospath,file.name));
    g = rgb2gray(im);
    g = imfilter(g,filter);
    bw = im2bw(g, graythresh(g));
    inv = invariant_moments(bw);
    posinv(i,:) = inv;
    bw = 1-bw;
    inv = invariant_moments(bw);
    posinv2(i,:) = inv;
%        subplot(2,1,1);
%     set(gca,'YLim',[0 1])
%     semilogy(abs(inv));
%     subplot(2,1,2);
%     imshow(bw)
%     pause

   waitbar(i/length(files));
end
neginv = [neginv;neginv2];
posinv = [posinv;posinv2];

neginv = neginv(max(abs(neginv')) <= 1,:);
posinv = posinv(max(abs(posinv')) <= 1,:);
neginv = neginv(1:size(posinv,1),:);
X = [neginv;posinv]';

for i = 1:6
    X(i,:) = (X(i,:)-mean(X(i,:)))...
    ./ (std(X(i,:)));
end
t = zeros(1,size(X,2));
t(size(neginv,1)+1:end) = 1;
