function c = label2char(label)

label = label - 1;
if label <= 10
    c = char(label + '0');
elseif label <= 10 + 26
    c = char(label - 10 - 1 + 'A');
else
    c = char(label - 26 - 10 - 1 + 'a');
end