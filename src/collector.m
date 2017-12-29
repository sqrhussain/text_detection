
path = '../data/collected/';

negpath = '../data/training/neg/';
pospath = '../data/training/pos/';
files = dir(path);
files = files(3:end);



negs = dir(negpath);
poss = dir(pospath);
%ss = find(negs(end).name == '.');
negc = 500;
%ss = find(poss(end).name == '.');
posc = 500;



for i = 1 : length(files)
    file = files(i);
    im = imread(strcat(path,file.name));
    [w,h,~] = size(im);
    imshow(im)
    choice = input('Investigate? 0/1 >> ');
    if choice == 0
        continue
    end
    choice = input('Crop? 0/1 >> ');
    if choice == 1
        im = imcrop(im);
    end
    ws = input('Window size?');
    [w,h,~] = size(im);
    %for ws = 55:10:55 % loop over window size
        for y = 1:ws/2:w-ws/2
            for x = 1:ws/2:h-ws/2
                c = imcrop(im,[x,y,ws,ws]);
                imshow(im);
                hold on
                rectangle('Position', [x,y,ws,ws],...
                'EdgeColor','r', 'LineWidth', 1)

                hold off
                title(strcat(int2str(x),',',int2str(y)))
                choice = input('Text? 0/1 >> ');
                if choice == 0
                    imwrite(c,strcat(negpath,int2str(negc),'.png'));
                    negc = negc +1;
                elseif choice == 1
                    imwrite(c,strcat(pospath,int2str(posc),'.png'));
                    posc = posc + 1;
                end
                    
                
            end
        end
    %end
end
