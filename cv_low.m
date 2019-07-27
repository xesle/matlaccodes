function [] = cv_low()

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

%sigmaCV2 = 0.1:0.01:5;
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
    
%for y = 1:numel(sigmaCV2)



[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCV2);
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

result = zeros(size(generalRater));
result(abs(positiveUnique(x) - generalRater) <= eps(generalRater)) = 1;
% result = bwfill(result2,'holes',8);

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
 
if detections > 5 && FP == 0

outputRPA = 255 - outputR;
outputRPB = 255 - outputR;
outputRPC = 255 - outputR;

[l,m] = size(result);
resultExtend = result;
for a=1:l
    for b=1:m
        if result(a,b) == 1
            if a+3 < l
                aux = a+1;
                resultExtend(a:a+3,b) = 1;
            end
            if a-3 > 0
                aux = a-1;
                resultExtend(a-3:a,b) = 1;
            end    
            if b-3 > 0
                aux = b-1;
                resultExtend(a,b-3:b) = 1;
            end
            if b + 3 < m
                aux = b+1;
                resultExtend(a,b:b+3) = 1;
            end    
        end    
    end    
end    

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & resultExtend) = 246;
outputRPB(outputRPB & resultExtend) = 22;
outputRPC(outputRPC & resultExtend) = 22;


im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('Dete_%1.7f_1_name_%s_cv_%1.7f_sg_%1.7f_FP_%1.7f_.png',detections,filename,positiveUnique(x),sigmaCV2,FP);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  

end

end

%end

close all;


end
