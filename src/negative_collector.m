
path = '../data/collected/';

negpath = '../data/training/pos/';
pospath = '../data/training/pos/';
files = dir(path);
files = files(3:end);



negs = dir(negpath);
poss = dir(pospath);

negc = 6587;



for i = 1 : length(files)
    file = files(i);
    im = imread(strcat(path,file.name));
    [w,h,~] = size(im);
    imshow(im)
    choice = input('Investigate? 0/1 >> ');
    if choice == 0
        continue
    end
    choice = 1;
    IM = im;
    while choice == 1
        im = IM;
        im = imcrop(im);
        ws = input('Window size? >> ');
        [w,h,~] = size(im);
        for y = 1:ws/2:w-ws/2
            for x = 1:ws/2:h-ws/2
                c = imcrop(im,[x,y,ws,ws]);
%                 imshow(im);
%                 hold on
%                 rectangle('Position', [x,y,ws,ws],...
%                 'EdgeColor','r', 'LineWidth', 1)
% 
%                 hold off
%                 title(strcat(int2str(x),',',int2str(y)))
                
                imwrite(c,strcat(negpath,int2str(negc),'.png'));
                negc = negc +1;
            end
        end
        choice = input('Continue with the same pic? 0/1 >>');
    end
end
