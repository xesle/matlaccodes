function [] = cmd_hight()

close all;clc;
inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';
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

sigmaCMD =  0.01:0.01:1.5;
%sigmaCMD = 0.1;

precisioncmdl = 2;
precisioncmdh = 1;
cmd = 0.1;
sigmah = 1.32;
%% 0.53

precisioncmdh2 = 1;
cmd2 = 0.1;
sigmah2 = 1.32;



templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);



[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
outputR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);

outputDouble = im2double(outputR);
templateDouble = double(templateR);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmah);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
cmdValueB = zeros(size(lambda1));
div = zeros(size(lambda1));
suma =  zeros(size(lambda1));
sumaq = lambda1 + lambda2;
divq = lambda1 ./ lambda2;
cmdValueB = -(divq .* sumaq);        
cmdValueB(sumaq >= 0) = 0;

cmdValueRoundB =  roundn(cmdValueB,precisioncmdh);
result = zeros(size(cmdValueRoundB));
result(abs(cmd - cmdValueRoundB) <= eps(cmdValueRoundB)) = 1;

resulth = bwfill(result,'holes',8);







[La,numa] = bwlabel(resulth,8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
for y = 1:numel(sigmaCMD)

disp('---');
disp(sigmaCMD(y));
    
[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCMD(y));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

sumaq2 = lambda1 + lambda2;
divq2 = lambda1 ./ lambda2;
cmdValue = -(divq2 .* sumaq2);        

cmdValue(sumaq >= 0) = 0;

cmdValueRound2 =  roundn(cmdValue,precisioncmdl);
positiveUnique = unique(cmdValueRound2); 

for x = 1:numel(positiveUnique)
    
    result = zeros(size(cmdValueRound2));
    result(abs(positiveUnique(x) - cmdValueRound2) <= eps(cmdValueRound2)) = 1;

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

if FP == 0 
    
detections = connecction(L, num, result);
 
if detections > 6  
    
%detections = connecction(L, num, result);
%  
%if detections > 5

outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;
% % 
low = result;

disp(sum(low(:)));
[m n] = size(resulth);
resultHisteresis = zeros(m,n);

for a = 1:m
    for b = 1:n
        if low(a,b) == 0 || resultHisteresis(a,b) == 1
            continue;
        else
            for i=1:numa
                  aux = zeros(m,n); 
                  aux(La == i) = 1;
                  aux = bwfill(aux,'holes',8);
                if low(a,b) == aux(a,b)
                    resultHisteresis = resultHisteresis + aux;
                end
            end
        end
    end
end


contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

%resulth = bwfill(result,'holes',8);


outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;


im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('de_%1.7f_1_name_%s_cmd_%1.7f_sg_%1.7f_FP_%1.7f_.png',detections,filename,positiveUnique(x),sigmaCMD(y),FP);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  

end
end
end
end

close all;
end
