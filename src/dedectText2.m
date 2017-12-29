% Function for dedecting text regions in an image. Take image as an input
% and returns an image with bounding boxes indicating the regions of text.
% Image is turned into a binary image in following manner:
% Smooth -> Gradient -> Normalize -> Binarize
% Properties of binary regions are used to remove features that are not
% likely to be text.

function dedectText2(origImage)

% Turn RGB image to grayscale 
%origImage = '../data/collected/2.jpeg';
colorImage = imread(origImage);
I = rgb2gray(colorImage);
% Smooth with Gaussian
% Take the gradient of the image
f1 = [-1 -1 -1; 2 2 2; -1 -1 -1];
f2 = f1';
fim1 = (imfilter(I,f1));
fim2 = (imfilter(I,f2));
g = (fim1 + fim2) * 0.5;


% Normalize and Binarize
mask = im2bw(g,graythresh(g));


subplot(2,2,1);
imshow(I);
title('grayscale');
subplot(2,2,2);
imshow(g);
title('DoG');
subplot(2,2,3);
imshow(mask);
title('Mask before filtering');
% Remove small features
mask = bwareaopen(mask,50);


% Measure image properties
[height, width] = size(mask);
imageArea = height*width;
boundingBoxes= regionprops(mask,'BoundingBox');
regions = struct2cell(regionprops(mask,'PixelIdxList'));
orientations = cell2mat(struct2cell(regionprops(mask,'Orientation')));

k=1;
for i=1:length(orientations)
    box = boundingBoxes(i).BoundingBox;
    width = box(3);
    height = box(4);
    regionArea = height*width;
    orientation = abs(orientations(i));
    if regionArea > imageArea/4 % Remove large features
       mask(regions{i})=0;
    elseif height > 3*width     % Remove vertical features
       mask(regions{i})=0;
    end
    k=k+1;
end

% Fill holes in imgae
mask = imfill(mask,'holes'); 

% Use median filter to remove vertical lines between regions
mask = medfilt2(mask,[1 7]); 

% Measure image properties again
regionAreas= cell2mat(struct2cell(regionprops(mask,'Area')));
medianArea = median(regionAreas);
regions = struct2cell(regionprops(mask,'PixelIdxList'));
orientations = cell2mat(struct2cell(regionprops(mask,'Orientation')));

k=1;
for i=1:length(regionAreas)
    width = box(3);
    height = box(4);
    orientation = abs(orientations(i));
    if height > 3*width     % Remove vertical features
       mask(regions{i})=0;
    elseif orientation > 10
        mask(regions{i})=0; % Remove features with orientation > 10° respect to x-axis
    end
    k=k+1;
end

% Remove small features
%mask = bwareaopen(mask,round(medianArea/2));
mask = bwmorph(mask,'open',Inf);
% Bounding boxes for text regions
mask = bwmorph(mask, 'close', Inf);
boundingBoxes = regionprops(mask,'BoundingBox');


% Show original image with bounding boxes indicating regions of text

subplot(2,2,4);
imshow(mask);
title('Mask after filtering');

figure;
imshow(colorImage);
title('Result');

hold on
for i=1:length(boundingBoxes)
    boundingBox = boundingBoxes(i).BoundingBox;
    rectangle('Position', boundingBox,...
	'EdgeColor','r', 'LineWidth', 1)
%     
%     c = imcrop(g,boundingBox);
%     close all;
%     subplot(2,1,1);
%     bw = im2bw(c, graythresh(c));
%     bw = imfill(bw,'holes');
%     cc = bwconncomp(bw);
%     label = labelmatrix(cc);
%     sh = label2rgb(label);
%     imshow(sh);
% %     s = sum(c);
% %     plot(s);
%     subplot(2,1,2);
%     imshow(c);
%     pause;
end
