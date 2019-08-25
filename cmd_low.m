function [] = cmd_low()

close all;clc;
inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';
[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

sigmaCMD = 0.1:0.01:2;

precisioncmd = 4;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);

[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
        
                       
outputR =  imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);


% totalTH = [];
% totalSG = [];
% sumValues = [];    
    
for y = 1:numel(sigmaCMD)

disp(sigmaCMD(y));    
[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCMD(y));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

sumaq = lambda1 + lambda2;
divq = lambda1 ./ lambda2;
cmdValue = -(divq .* sumaq);        

cmdValue(sumaq >= 0) = 0;

cmdValueRound =  roundn(cmdValue,precisioncmd);
positiveUnique = unique(cmdValueRound); 

for x = 1:numel(positiveUnique)
    
    result = zeros(size(cmdValueRound));
    result(abs(positiveUnique(x) - cmdValueRound) <= eps(cmdValueRound)) = 1;

    commonResult = sum(result & templateR);
    unionResult = sum(result | templateR);
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

%detections = connecction(L, num, result);
 
if FP == 0  
    
detections = connecction(L, num, result);
 
if detections > 5

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

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & resultExtend) = 246;
outputRPB(outputRPB & resultExtend) = 22;
outputRPC(outputRPC & resultExtend) = 22;


im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('detect_%1.7f_1_name_%s_cmd_%1.7f_sg_%1.7f_FP_%1.7f_.png',detections,filename,positiveUnique(x),sigmaCMD(y),FP);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  

end
end
end
end

close all;


end
