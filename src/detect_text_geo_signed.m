function predict = detect_text_geo_signed(I,model,sign)




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
for wy = 60:-12:12
    wx = 3*wy;
    xstride = wx/3;
    ystride = wy/3;
    r = 0;
    tic
    for y = 1:ystride:H-wy
        for x = 1:xstride:W-wx
    
            c = imcrop(fim,[x,y,wx,wy]);
            if std2(c) < stdthresh
                continue
            end
%             imshow(c);
%             title(num2str(std2(c)));
%             pause;

            %c = im2bw(c);
%             subplot(1,2,1)
%             imshow(im);
%             hold on
%             rectangle('Position', [x,y,wx,wy],...
%             'EdgeColor','r', 'LineWidth', 1)
%             hold off
%             pause(0.001);
            
%             bw = im2bw(c,graythresh(c));
            bw = imcrop(hbw,[x,y,wx,wy]);
%             subplot(1,2,2)
%             imshow(bw);
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
%                 imshow(region);
%                 title(num2str(numlabels))
%                 pause(0.01);
%                 region = imcrop(region, bounds);
%                 size(region)
%                 size(visited(y:y+wy,x:x+wx))
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
%                     imshow(region);
%                     pause
                    continue
                end
                features = geometric_features(imcrop(bw, bounds));
                p = model(features);
                if p>0.5
                    predict(y:y+wy,x:x+wx) = predict(y:y+wy,x:x+wx) | region;
%                 else
%                     imshow(imcrop(bw, bounds));
%                     pause
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
    for i = 1 : numlabels

        region = ismember(labeledImage, i);
        region = region > 0;
        bounds = measurements(i).BoundingBox;
        features = geometric_features(imcrop(region, bounds));
        p = model(features);
        if p<0.5
%             imshow(region)
%             title('p < 0.5');
%             pause
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
%             pause(0.01)
        if sum(cc(:)) / (bounds(3)*bounds(4)) < 0.15 % no enough white pixels, could be a thin noisy blob
            
%             imshow(cc)
%             title('sum(cc(:)) / (bounds(3)*bounds(4)) < 0.15');
%             pause
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
        if sum(cc(:)) / (bounds(3)*bounds(4)) < 0.15
            predict = predict & (~region);
        end
            
        
    end
    toc
end
av = fspecial('average',[1,36]);
f = imfilter(im2double(predict),av);
imshow(f)
pause
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
