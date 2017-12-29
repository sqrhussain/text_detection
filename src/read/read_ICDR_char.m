function [X,y] = read_ICDR_char(path)
descriptor = strcat(path,'char.xml');
xml = xmlread(descriptor);

tags = xml.getElementsByTagName('image');
X = {};
y = [];
lst = 1;
for i = 0 : tags.getLength-1
    tag = tags.item(i);
    file = tag.getAttribute('file');
    label = tag.getAttribute('tag');
    impath = strcat(path,char(file));
    im = imread(impath);
    if ~isalpha_num(char(label(1)))
        continue
    end
    X{lst} = im;
    lst = lst + 1;
    y = [y,label];
end

