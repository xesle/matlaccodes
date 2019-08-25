function [] = quist_size()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet'; 
[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
            
disp('Area');
disp(sum(templateR(:)==1));

[L,num] = bwlabel(templateR,8);

aux = zeros(size(templateR));

areaSuma = 0;

for i = 1:num

aux = zeros(size(templateR));    
aux(L == i) = 1;
SA = regionprops(aux,'Area');
disp('..');
disp(i);
disp(SA(1).Area);

disp('----------');

% figure;
% imshow(aux);
% 
% pause(10);

end

end

