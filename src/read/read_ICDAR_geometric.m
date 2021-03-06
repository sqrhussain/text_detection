function [X,t] = read_ICDAR_geometric(path)
descriptor = strcat(path,'char.xml');
xml = xmlread(descriptor);
N = 6185;
tags = xml.getElementsByTagName('image');
% X = zeros(9,N);
% t = ones(1,N);
X = [];
t = [];
pbar = waitbar(0,'Reading ICDAR positives...');
for i = 0 : tags.getLength-1
    tag = tags.item(i);
    file = tag.getAttribute('file');
    label = tag.getAttribute('tag');
    impath = strcat(path,char(file));
    if exist(impath, 'file') == 0
        continue
    end
%     disp('read')
    im = imread(impath);
    if ~isalpha_num(char(label(1)))
        continue
    end
    g = rgb2gray(im);
    bw = im2bw(g,graythresh(g));
    brdrs = sum(bw(1,:)) + sum(bw(end,:)) + sum(bw(:,1)) + sum(bw(:,end));
    if brdrs > size(bw,1) + size(bw,2)
        bw = 1-bw;
    end
    
    [region,bounds] = region_of_interest(bw);
%     imshow(region);
%     pause(0.001);
    
%     X(:,i+1) = geometric_features(region);
    X = [X,geometric_features(region)];
    t = [t,1];
   waitbar(i/N);
end