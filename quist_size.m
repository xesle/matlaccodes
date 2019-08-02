function [] = histcv_cmd()

close all;clc;

% inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';
% 
% [filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

templateR =  imread('/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/2.png');
                    
[L,num] = bwlabel(templateR,8);

aux = zeros(size(templateR));

aux(L == 15) = 1;

S = regionprops(aux,'Centroid');
SA = regionprops(aux,'Area');
SO = regionprops(aux,'Orientation');
SF = regionprops(aux,'FilledArea');

disp('..');
disp(num);
disp(SA);
figure;
imshow(aux);


end



