
im = rgb2gray(imread('../data/collected/22.jpeg'));
%im = imcrop(im);
lap = -fspecial('log',[1,width],sigma);
filter = repmat(lap,[1,1]);
fim1 = imfilter(im,filter,'replicate');
fim2 = imfilter(im,filter','replicate');
fim = (fim1+fim2)*.5;
[H,W] = size(im);
sigma = 1;
width = 100;
visited = false(size(im));
predict = zeros(size(im));

for wy = 48:-12:36
    wx = 3*wy;
    xstride = wx/3;
    ystride = wy/3;
    r = 0;
    tic
    for y = 1:ystride:H-wy
        for x = 1:xstride:W-wx

            c = imcrop(fim,[x,y,wx,wy]);

            %c = im2bw(c);
    %         imshow(im);
    %         hold on
    %         rectangle('Position', [x,y,wx,wy],...
    %         'EdgeColor','r', 'LineWidth', 1)
    %         hold off
    %         pause(0.001);
            %c = imadjust(c);
            bw = im2bw(c,graythresh(c));
            [labeledImage,numlabels] = bwlabel(bw);
            measurements = regionprops(labeledImage,...
                'BoundingBox');
            for i = 1 : numlabels
                region = ismember(labeledImage, i);
                region = region > 0;
                whites = sum(region(:));
                if whites < 0.005 * wx*wy || whites > 0.1 * wx*wy
                    continue
                end

                %region = imcrop(region, bounds);
    %             size(region)
    %             size(visited(y:y+wy,x:x+wx))
                if sum(sum(visited(y:y+wy,x:x+wx) & region)) == sum(region(:))
                    continue;
                end

                bounds = measurements(i).BoundingBox;
                features = geometric_features(imcrop(bw, bounds));
                p = geo3(features);
                if p>0.5
                    predict(y:y+wy,x:x+wx) = predict(y:y+wy,x:x+wx) | region;

                end
%                 imshow(imcrop(region, bounds));
%                 title('region');
%                 pause(0.01)
%                 r = r + 1;
                % mark as visited
                visited(y:y+wy,x:x+wx) = visited(y:y+wy,x:x+wx) | region;
            end


        end
    end
    
    % for each predicted blob
    
    [labeledImage,numlabels] = bwlabel(predict);
    measurements = regionprops(labeledImage,...
        'BoundingBox');
    predicted = predict;
    for i = 1 : numlabels

        region = ismember(labeledImage, i);
        region = region > 0;
        bounds = measurements(i).BoundingBox;
        features = geometric_features(imcrop(region, bounds));
        p = geo3(features);
        if p<0.5
            predict = predict & (~region);
        end
        if bounds(3) < bounds(4)
            bounds(1) = bounds(1) - bounds(4) + floor(bounds(3)/2);
            bounds(3) = bounds(4)*2;
        else
            bounds(1) = bounds(1) - bounds(3);
    %         bounds(2) = bounds(2) - bounds(4);
            bounds(3) = bounds(3) * 3;
    %         bounds(4) = bounds(4) ;
        end
        cc = imcrop(predict,bounds);
%             imshow(predict)
%             hold on
%             rectangle('Position', bounds,...
%             'EdgeColor','r', 'LineWidth', 1)
%             hold off
%             pause(0.1)
        if sum(cc(:)) / (bounds(3)*bounds(4)) < 0.2
            predict = predict & (~region);
        end
            
        
    end    
    [labeledImage,numlabels] = bwlabel(predict);
    measurements = regionprops(labeledImage,...
        'BoundingBox');
    for i = 1 : numlabels

        region = ismember(labeledImage, i);
        region = region > 0;
        bounds = measurements(i).BoundingBox;
        if bounds(3) < bounds(4)
            bounds(1) = bounds(1) - bounds(4) + floor(bounds(3)/2);
            bounds(3) = bounds(4)*2;
        else
            bounds(1) = bounds(1) - bounds(3);
    %         bounds(2) = bounds(2) - bounds(4);
            bounds(3) = bounds(3) * 3;
    %         bounds(4) = bounds(4) ;
        end
        cc = imcrop(predict,bounds);
%             imshow(predict)
%             hold on
%             rectangle('Position', bounds,...
%             'EdgeColor','r', 'LineWidth', 1)
%             hold off
%             pause(0.1)
        if sum(cc(:)) / (bounds(3)*bounds(4)) < 0.2
            predict = predict & (~region);
        end
            
        
    end
    figure;
    pair = imshow(predict);
    toc
end
av = fspecial('average',[5,48]);
f = imfilter(im2double(predict),av);
bw = im2bw(f,graythresh(f));
predict = bw;
[labeledImage,numlabels] = bwlabel(predict);
measurements = regionprops(labeledImage,...
        'BoundingBox');
figure;
imshow(im)
for i = 1 : numlabels

    region = ismember(labeledImage, i);
    region = region > 0;
    bounds = measurements(i).BoundingBox;

    if bounds(3) / bounds(4) < 4
        predict = predict & (~region);
    else
        hold on
        rectangle('Position', bounds,...
        'EdgeColor','r', 'LineWidth', 1)

    end


end    
hold off