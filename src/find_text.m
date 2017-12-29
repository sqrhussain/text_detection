function conf = find_text(im,net)

im = rgb2gray(im);
[h,w] = size(im);
conf = zeros(size(im));
%progbar = waitbar(0,'Processing...');
tic
for ws = 30:10:30 % loop over window size
    conf = zeros(size(im));
    for x = -ws/2+1:2:w-ws/2
        for y = -ws/2+1:2:h-ws/2
            c = imcrop(im,[x,y,ws,ws]);
            bw = im2bw(c, graythresh(c));
           % if sum(bw(:)) <0.1* ws*ws || sum(bw(:)) > 0.90*ws*ws
                %disp(sum(bw(:)))
                
            %else
                
                inv = invariant_moments(bw);
                est = net(inv);
                conf(y+ws/2,x+ws/2) = est;
            %end
            %imshowpair(c,bw,'montage');
            subplot(1,3,1);
            imshow(im);
            hold on
            rectangle('Position', [x,y,ws,ws],...
            'EdgeColor','r', 'LineWidth', 1)

            hold off
            title(num2str(est,'%.3f'))
            %title(sum(bw(:)))
            subplot(1,3,2);
            imshow(conf);
            subplot(1,3,3);
            imshow(bw);
            
            pause(0.001)
            %xx(x+ws/2,y+ws/2) = im(x+ws/2,y+ws/2);
            %disp(strcat(int2str(x),',',int2str(y)))
            %waitbar((x*h+y) / (w*h));

        end
        
        %imshow(conf);
    end
    figure
    imshow(conf);
    title(strcat('Window Size = ',int2str(ws)))
end
toc


end