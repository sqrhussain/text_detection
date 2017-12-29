function y = scaled_log(im)

for width = 20:20:100
    lap = -fspecial('log',[1,width],1);
    filter = repmat(lap,[10,1]);
    fim1 = imfilter(im,filter,'replicate');
    imshow(fim1);
    %fim2 = imfilter(im,-filter,'replicate');
    %subplot(2,1,1)
    %plot(lap)
    %subplot(2,1,2)
    %fim = fim/max(max(fim));
    %imshowpair(fim1,fim2,'montage')
    pause
end

y = 0;