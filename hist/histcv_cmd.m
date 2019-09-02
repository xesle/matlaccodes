function [] = histcv_cmd()

close all;clc;

inputDir = cd;

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');
templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);   

resultCMD = imread('/home/xenon/git_workspace/results/6.png');
resultHisteresis1 = zeros(size(resultCMD));


resultHisteresis1(resultCMD > 0) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigmaCVl = 1.34;
precisioncvl = 4;
tcvl = 0.0658;

sigmaCVH = 1.02;
precisioncvh = 1;
tcvh = 0.1;



outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCVl);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

generalRate = hypot(lambda1, lambda2);

generalRater =  roundn(generalRate,precisioncvl);

result = zeros(size(generalRater));
result(abs(tcvl - generalRater) <= eps(generalRater)) = 1;

[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCVH);
[lambda12, lambda22] = imEigenValues(gxxr2, gxyr2, gyyr2, maskR);
generalRate2 = hypot(lambda12, lambda22);

generalRated =  roundn(generalRate2,precisioncvh);

resultH = zeros(size(generalRated));
resultH(abs(tcvh - generalRated) <= eps(generalRated)) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[L,num] = bwlabel(resultH,8);

low = result;

disp('mmm')
disp(sum(low(:)));


[m n] = size(result);
resultHisteresis2 = zeros(m,n);

for a = 1:m
    for b = 1:n
        if low(a,b) == 0 || resultHisteresis2(a,b) == 1
            continue;
        else
            for i=1:num
                  aux = zeros(m,n); 
                  aux(L == i) = 1;
                  aux = bwfill(aux,'holes',8);
                if low(a,b) == aux(a,b)
                    resultHisteresis2 = resultHisteresis2 + aux;
                end
            end
        end
    end
end

resultHisteresis = resultHisteresis2 | resultHisteresis1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
outputRPA =  outputR;
outputRPB = outputR;
outputRPC = outputR;

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('final%s',filename);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(resultHisteresis, outputDir);  

ground = zeros(size(templateDouble));
ground(templateDouble > 0) = 1;

commonResult = sum(resultHisteresis & ground);
unionResult = sum(resultHisteresis | ground);
cm=sum(resultHisteresis == 1); 
co=sum(ground == 1); 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);

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



end



