function [] = histcv()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

sigmaCVl = 0.92;
precisioncvl = 4;
tcvl = 0.1297;

sigmaCVH = 2.97;
precisioncvh = 2;
tcvh = 0.01;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);                      

outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);


[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCVl);

[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
generalRate = hypot(lambda1, lambda2);
generalRater =  roundn(generalRate,precisioncvl);

resultl = zeros(size(generalRater));
resultl(abs(tcvl - generalRater) <= eps(generalRater)) = 1;



[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCVH);
[lambda12, lambda22] = imEigenValues(gxxr2, gxyr2, gyyr2, maskR);
generalRate2 = hypot(lambda12, lambda22);
generalRated =  roundn(generalRate2,precisioncvh);
resulth = zeros(size(generalRated));
resulth(abs(tcvh - generalRated) <= eps(generalRated)) = 1;

resultH = bwfill(resulth,'holes',8);

[L,num] = bwlabel(resultH,8);

low = resultl;

[m n] = size(resultl);
resultHisteresis = zeros(m,n);

for a = 1:m
    for b = 1:n
        if low(a,b) == 0 || resultHisteresis(a,b) == 1
            continue;
        else
            for i=1:num
                  aux = zeros(m,n); 
                  aux(L == i) = 1;
                  aux = bwfill(aux,'holes',8);
                if low(a,b) == aux(a,b)
                    resultHisteresis = resultHisteresis + aux;
                end
            end
        end
    end
end



outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;
    
contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;


outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

im = cat(3, outputRPA, outputRPB, outputRPC);

ground = zeros(size(templateDouble));
ground(templateDouble > 0) = 1;

adder = resultHisteresis + ground;
TP = length(find(adder == 2));
TN = length(find(adder == 0));
subtr = resultHisteresis - ground;
FN = length(find(subtr == -1));
FP = length(find(subtr == 1));
precision = TP / (TP + FP); 
recall  = TP / (TP + FN);

disp('precision');
disp(precision);
disp('recall');
disp(recall);


commonResult = sum(resultHisteresis & ground);
unionResult = sum(resultHisteresis | ground);
cm=sum(resultHisteresis == 1); % the number of voxels in m
co=sum(ground == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);

disp('Jacc');
disp(Jaccard);
disp('Dic');
disp(Dice);

nameImage = sprintf('%s',filename);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(resultHisteresis, outputDir);  



close all;