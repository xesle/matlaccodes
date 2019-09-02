function [] = histcv_cmd2()

close all;clc;

inputDir = cd;

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');
templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);   
imga2 = imread('/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/2a.png');   


outputR =   imga;
outputR2 =   imga2;
outputDouble = im2double(outputR);
templateDouble = double(templateR);

sigmaCMDh =  1.45;
precisioncmdh = 1;
thcmdh = 0.1;

sigmaCMDl =  1.89;
precisioncmdl = 4;
thcmdl = 0.0574;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCMDh);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
cmdValueh = zeros(size(lambda1));
div = zeros(size(lambda1));
suma =  zeros(size(lambda1));
sumaq = lambda1 + lambda2;
divq = lambda1 ./ lambda2;
cmdValueh = -(divq .* sumaq);        
cmdValueh(sumaq >= 0) = 0;

cmdValueRoundh =  roundn(cmdValueh,precisioncmdh);
result = zeros(size(cmdValueRoundh));
result(abs(thcmdh - cmdValueRoundh) <= eps(cmdValueRoundh)) = 1;

cmdh = bwfill(result,'holes',8);
[La,numa] = bwlabel(cmdh,8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
[gxx, gxy, gyy] = imHessian(outputDouble,sigmaCMDl);
[lambda11, lambda22] = imEigenValues(gxx, gxy, gyy, maskR);
cmdValuel = zeros(size(lambda11));

sumaq2 = lambda11 + lambda22;
divq2 = lambda11 ./ lambda22;
cmdValuel = -(divq2 .* sumaq2);        

cmdValuel(sumaq >= 0) = 0;

cmdValueRoundl =  roundn(cmdValuel,precisioncmdl);
   
cmdl = zeros(size(cmdValueRoundl));
cmdl(abs(thcmdl - cmdValueRoundl) <= eps(cmdValueRoundl)) = 1;

[m n] = size(cmdh);
resultHisteresis1 = zeros(m,n);

for a = 1:m
    for b = 1:n
        if cmdl(a,b) == 0 || resultHisteresis1(a,b) == 1
            continue;
        else
            for i=1:numa
                  aux2 = zeros(m,n); 
                  aux2(La == i) = 1;
                  aux2 = bwfill(aux2,'holes',8);
                if cmdl(a,b) == aux2(a,b)
                    resultHisteresis1 = resultHisteresis1 + aux2;
                end
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sigmaCVl = 0.77;
% precisioncvl = 4;
% tcvl = 0.2452;
% 
% sigmaCVH = 1.94;
% precisioncvh = 2;
% tcvh = 0.04;

sigmaCVl = 1.9;
precisioncvl = 4;
tcvl = 0.0364;

sigmaCVh = 3.8;
precisioncvh = 2;
tcvh = 0.01;

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCVl);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

generalRate = hypot(lambda1, lambda2);

generalRater =  roundn(generalRate,precisioncvl);

result = zeros(size(generalRater));
result(abs(tcvl - generalRater) <= eps(generalRater)) = 1;

[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCVh);
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

commonResult = sum(resultHisteresis & templateR);
unionResult = sum(resultHisteresis | templateR);
cm=sum(resultHisteresis == 1); 
co=sum(templateR == 1); 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);

templateDouble2 = zeros(size(templateDouble));
templateDouble2(templateDouble > 0) = 1;

adder = resultHisteresis + templateDouble2;
TP = length(find(adder == 2));
TN = length(find(adder == 0));
subtr = resultHisteresis - templateDouble2;
FN = length(find(subtr == -1));
FP = length(find(subtr == 1));
precision = TP / (TP + FP); 
recall  = TP / (TP + FN);

disp('precision');
disp(precision);
disp('recall');
disp(recall);

end



