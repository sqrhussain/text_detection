
function [X,t] = read_all_geo

[X1,t1] = read_ICDAR_geometric('../data/char/');
[X2,t2] = read_my_negatives;
X = [X1,X2];
t = [t1,t2];


