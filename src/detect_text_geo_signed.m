function predict = detect_text_geo_signed(I,model,sign)

%%
% 
% Miss when the letters are too far from each others
% Miss when letters are too close to each others (or not?)
% Miss when letters are too big or too small
% Miss when the letters are not filled .. NO, just not guaranteed
% Miss non horizontal text
%%

sigma = 1;
width = 100;
stdthresh = 10;
smallmin = 5;
smallmax = 10;
im = rgb2gray(I);
%im = imcrop(im);
lap = sign * fspecial('log',[1,width],sigma);
filter = repmat(lap,[1,1]);
fim1 = imfilter(im,filter,'replicate');
fim2 = imfilter(im,filter','replicate');
fim = (fim1+fim2)*.5;
[H,W] = size(im);
visited = false(size(im));
predict = zeros(size(im));
hbw = im2bw(fim,graythresh(fim));
% subplot(1,6,1);
% imshow(im);
% title('Gray')
% subplot(1,6,2);
% imshow(fim);
% title('Lines')
for wy = 60:-12:12
    wx = 3*wy;
    xstride = wx/3;
    ystride = wy/3;
    
    for y = 1:ystride:H-wy
        for x = 1:xstride:W-wx
    
            c = imcrop(fim,[x,y,wx,wy]);
            if std2(c) < stdthresh
                continue
            end
            bw = imcrop(hbw,[x,y,wx,wy]);
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
                if sum(sum(visited(y:y+wy,x:x+wx) & region)) == sum(region(:))
                    continue;
                end

                bounds = measurements(i).BoundingBox;
                gc = imcrop(c,bounds);
                if std2(gc) < stdthresh % too smooth
                    continue;
                end 
                if min(bounds(3:4)) < smallmin ||...
                        max(bounds(3:4)) < smallmax ||...
                        bounds(3)*bounds(4) < smallmin*smallmin % too small
                    continue
                end
                features = geometric_features(imcrop(bw, bounds));
                p = model(features);
                if p>0.5
                    predict(y:y+wy,x:x+wx) = predict(y:y+wy,x:x+wx) | region;
                end
                visited(y:y+wy,x:x+wx) = visited(y:y+wy,x:x+wx) | region;
            end


        end
    end
    
%     subplot(1,6,3);
%     imshow(predict);
%     title('Prediction')
    
    % for each predicted blob
    [labeledImage,numlabels] = bwlabel(predict);
    measurements = regionprops(labeledImage,...
        'BoundingBox');
    for i = 1 : numlabels

        region = ismember(labeledImage, i);
        region = region > 0;
        bounds = measurements(i).BoundingBox;
        features = geometric_features(imcrop(region, bounds));
        p = model(features);
        if p<0.5 % could fail after merging binary shapes
            predict = predict & (~region);
        end
        if min(bounds(3:4)) < smallmin || max(bounds(3:4)) < smallmax  % too small
            imshow(region)
            title('min(bounds(3:4)) < smallx');
            pause
            predict = predict & (~region);
        end
        if bounds(3) < bounds(4)
            bounds(1) = bounds(1) - bounds(4) + floor(bounds(3)/2);
            bounds(3) = bounds(4)*2;
        else
            bounds(1) = bounds(1) - bounds(3);
            bounds(3) = bounds(3) * 3;
        end
        cc = imcrop(predict,bounds);
        if sum(cc(:)) / (bounds(3)*bounds(4)) < 0.15 % no enough white pixels, could be a thin noisy blob

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
            bounds(3) = bounds(3) * 3;
        end
        cc = imcrop(predict,bounds);

        if sum(cc(:)) / (bounds(3)*bounds(4)) < 0.15
            predict = predict & (~region);
        end
            
        
    end
    
    
    
end
% subplot(1,6,4);
% imshow(predict);
% title('Cleaning')
av = fspecial('average',[1,36]);
f = imfilter(im2double(predict),av);
    
% subplot(1,6,5);
% imshow(f);
% title('Merged')
    
bw = im2bw(f,graythresh(f));
predict = bw;
[labeledImage,numlabels] = bwlabel(predict);
measurements = regionprops(labeledImage,...
        'BoundingBox','Orientation');
for i = 1 : numlabels

    region = ismember(labeledImage, i);
    region = region > 0;
    bounds = measurements(i).BoundingBox;
    gc = imcrop(fim,bounds);
    if min(bounds(3:4)) < smallmin ||max(bounds(3:4)) < smallmax  % too small
        predict = predict & (~region);
    end
    if std2(gc) < stdthresh % too smooth
        continue;
    end
    orientation = measurements(i).Orientation;
%     imshow(predict);
%     hold on
%     rectangle('Position', bounds,...
%     'EdgeColor','r', 'LineWidth', 1)
%     hold off
%     pause(0.01)
    if bounds(3) / bounds(4) < 2 || abs(orientation) > 10
        predict = predict & (~region);
    end
    
end
    
% subplot(1,6,6);
% imshow(im2double(predict) .* im2double(im));
% title('Result')
