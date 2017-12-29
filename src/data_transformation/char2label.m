function label = c_char2label(c)
x(c<= 48 + 9) = c(c<= '9') - 48;
c(c<= '9') = 127;
x(c <= 'Z') = c(c <= 'Z') -65 + 10 + 1;
c(c <= 'Z') = 127;
x(c <= 'z') = c(c <= 'z') -'a' + 26+ 10 + 1;

label = x' + 1;
end
