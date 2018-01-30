
function printed_character_recognition(impath)

init_env

im = imread(impath);
detect_text_geo(im,geo8);

end