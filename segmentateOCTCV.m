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

sigmaCV2 = 0.1:0.1:1;
precisioncv2 = 0.0001;

templateR =  imread(['C:\Users\xose\Documents\MATLAB_OLD\TFG\NewDataSet\CroppedTemplates\' filename]);
maskR = imread(['C:\Users\xose\Documents\MATLAB_OLD\TFG\NewDataSet\maskCropped\' filename]);
imga = imread(['C:\Users\xose\Documents\MATLAB_OLD\TFG\NewDataSet\Cropped\' filename]);
        
[rows columns nc] = size(imga);

if nc == 3
    imga = rgb2gray(imga);
end;
                      
outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);

totalTH = [];
totalSG = [];
sumValues = [];

for y = 1:numel(sigmaCV2)


[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCV2(y));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
generalRater = hypot(lambda1, lambda2);
generalRateRCVH = quant(generalRater,precisioncv2);
positiveUnique = unique(generalRateRCVH);      
    

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
FP = length(find(subtr == -1));
FN = length(find(subtr == 1));
precision = TP / (TP + FP);
recall  = TP / (TP + FN);
 
if ~isnan(Jaccard) && Jaccard < 1
    sumValues = [sumValues Jaccard];
    totalTH = [totalTH positiveUnique(x)];
    totalSG = [totalSG sigmaCV2(y)];

end

end

end

disp(numel(sumValues));

if numel(sumValues) > 0

[ma, ia] = max(sumValues);
[gxxr, gxyr, gyyr] = imHessian(outputDouble,totalSG(ia));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
generalRate = hypot(lambda1, lambda2);
generalRate = quant(generalRate,precisioncv2);

result = zeros(size(generalRate));
result(abs(totalTH(ia) - generalRate) <= eps(generalRate)) = 1;

outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;

outputRPA(outputRPA & result) = 246;
outputRPB(outputRPB & result) = 22;
outputRPC(outputRPC & result) = 22;
contour = imread(['C:\Users\xose\Documents\MATLAB_OLD\TFG\NewDataSet\Contour\' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('1_name_%s_sg_%1.7f_cv_%1.7f_Jaccard_%1.7f_.png',filename,totalSG(ia),totalTH(ia),sumValues(ia));
outputDir = ['results\images\CVhight\'  nameImage];
imwrite(im, outputDir);         

else
    disp('no');
end

close all;
end
