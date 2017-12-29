function out = labels2outvec(y,numlabels)
out = zeros(length(y),numlabels);
    for i = 1 : length (y)
        out(i,y(i)) = 1;
    end
out = out';
end