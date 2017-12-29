

function [ region ,bounds ] = region_of_interest( binaryImage )

% binaryImage = im2bw(grayImage,graythresh(grayImage));

labeledImage = bwlabel(binaryImage);

measurements = regionprops(labeledImage, 'BoundingBox', 'Area');

[~, sortingIndexes] = sort( [measurements.Area], 'descend');

handIndexes = sortingIndexes(1:min(2,size(sortingIndexes,2)));

region = ismember(labeledImage, handIndexes(1));
region = region > 0;
bounds = measurements(handIndexes(1)).BoundingBox;
region = imcrop(region, bounds);

end