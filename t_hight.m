function [] = t_hight()

close all;clc;

inputDir = cd;

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

if (iscell(filename))
    maxE = numel(filename);
else
    maxE = 1;
end 

for i = 1:maxE
    if (iscell(filename))
        imagePath{i} = [folderPath ,filename{i}];
    else
        imagePath = [folderPath ,filename];
    end
end 

precisioncv2 = 1;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);

[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
        
[rows columns nc] = size(imga);

if nc == 3
    imga = rgb2gray(imga);
end;
                      
outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);

% totalTH = [];
% totalSG = [];
% sumValues = [];    
  
sigmaCV2 = 0.1:0.01:1.5;

for y = 1:numel(sigmaCV2)



[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCV2(y));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
generalRate = hypot(lambda1, lambda2);

generalRater =  roundn(generalRate,precisioncv2);
% t = generalRateRCVH;
% t(generalRateRCVH > 6.4) = 0;
% t(generalRateRCVH < 3) = 0;
positiveUnique = unique(generalRater);      

disp('*******************')
disp(numel(positiveUnique))


for x = 1:numel(positiveUnique)

result2 = zeros(size(generalRater));
result2(abs(positiveUnique(x) - generalRater) <= eps(generalRater)) = 1;
result = bwfill(result2,'holes',8);

commonResult = sum(result & templateR);
unionResult = sum(result | templateR);
%       plotconfusion(templateR,result);
cm=sum(result == 1); % the number of voxels in m
co=sum(templateR == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);

adder = result + templateDouble;
TP = length(find(adder == 2));
TN = length(find(adder == 0));
subtr = result - templateDouble;
FN = length(find(subtr == -1));
FP = length(find(subtr == 1));
precision = TP / (TP + FP); 
recall  = TP / (TP + FN);

if Jaccard > 0.8
 
outputRPA = 255 - outputR;
outputRPB = 255 - outputR;
outputRPC = 255 - outputR;

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & result) = 246;
outputRPB(outputRPB & result) = 22;
outputRPC(outputRPC & result) = 22;


im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('ja_%1.7f_name_%s_cv_%1.7f_sg_%1.7f_FP_%1.7f_.png',Jaccard, filename,positiveUnique(x),sigmaCV2(y),FP);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  

end

end

end

close all;


end
