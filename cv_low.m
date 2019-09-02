function [] = cv_low()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet/';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');


precisioncv2 = 4;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);

[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
                              
outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);    
  
sigmaCV2 = 0.44:0.01:2;


%     0.4400

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
disp(sigmaCV2(y));
disp(numel(positiveUnique))

disp(numel(sigmaCV2)); 
parfor x = 1:numel(positiveUnique)

result = zeros(size(generalRater));
result(abs(positiveUnique(x) - generalRater) <= eps(generalRater)) = 1;

% commonResult = sum(result & templateR);
% unionResult = sum(result | templateR);
% cm=sum(result == 1); % the number of voxels in m
% co=sum(templateR == 1); % the number of voxels in o 
% Jaccard=commonResult/unionResult;
% Dice=(2*commonResult)/(cm+co);

adder = result + templateDouble;
TP = length(find(adder == 2));
TN = length(find(adder == 0));
subtr = result - templateDouble;
FN = length(find(subtr == -1));
FP = length(find(subtr == 1));
precision = TP / (TP + FP); 
recall  = TP / (TP + FN);


if FP == 0 
    
    
detections = connecction(L, num, result);

if detections > 6
 
outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;

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


outputRPA(outputRPA & resultExtend) = 246;
outputRPB(outputRPB & resultExtend) = 22;
outputRPC(outputRPC & resultExtend) = 22;

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;



im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('Detect_%1.7f_name_%s_cv_%1.7f_sg_%1.7f_FP_%1.7f_.png',detections, filename,positiveUnique(x),sigmaCV2(y),FP);
outputDir = ['/home/xenon/git_workspace/results/20/'  nameImage];
imwrite(im, outputDir);  

%end

end

end

end

close all;


end

end