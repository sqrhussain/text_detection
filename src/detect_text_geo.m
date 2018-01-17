function predict = detect_text_geo(I,model)


p1 = detect_text_geo_signed(I,model,-1);

p2 = detect_text_geo_signed(I,model,+1);

predict = p1 | p2;

imshow(I)
[labeledImage,numlabels] = bwlabel(p1);
measurements = regionprops(labeledImage,...
        'BoundingBox');
hold on
for i = 1 : length(measurements)
bounds = measurements(i).BoundingBox;
    rectangle('Position', bounds,...
    'EdgeColor','r', 'LineWidth', 1)
end 
[labeledImage,numlabels] = bwlabel(p2);
measurements = regionprops(labeledImage,...
        'BoundingBox');
hold on
for i = 1 : length(measurements)
bounds = measurements(i).BoundingBox;
    rectangle('Position', bounds,...
    'EdgeColor','g', 'LineWidth', 1)
end 


title('Total prediction');