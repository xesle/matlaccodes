function [] = segmentateOCTCV()

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

sigmaCV2 = 0.3;
precisioncv2 = 4;

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
    

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCV2);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
generalRater = hypot(lambda1, lambda2);

generalRateRCVH =  roundn(generalRater,precisioncv2);

t = zeros(size(generalRateRCVH));
              
t(generalRateRCVH < (0.3)) = 0;
t(generalRateRCVH > (0.5)) = 0;

positiveUnique = unique(generalRateRCVH);      

disp('---------ANTES ----------')
disp(numel(unique(t)))
disp('-------------------')

disp('---------AHORA ----------')
disp(numel(positiveUnique))
disp('-------------------')


for x = 1:numel(positiveUnique)

result = zeros(size(generalRateRCVH));
result(abs(positiveUnique(x) - generalRateRCVH) <= eps(generalRateRCVH)) = 1;

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

detections = connecction(L, num, result);


disp('********')
disp(detections)
disp('*********')
 
if detections > 7 && FP == 0

outputRPA = 255 - outputR;
outputRPB = 255 - outputR;
outputRPC = 255 - outputR;

outputRPA(outputRPA & result) = 246;
outputRPB(outputRPB & result) = 22;
outputRPC(outputRPC & result) = 22;
contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('1_name_%s_cv_%1.7f_recall_%1.7f_det_%1.7f_FP_%1.7f_.png',filename,positiveUnique(x),recall,detections,FP);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  


end

end

close all;
end
