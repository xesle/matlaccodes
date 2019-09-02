function [] = cv_hight()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

% sigmaCVl = 1.93;
% precisioncvl = 4;
% tcvl = 0.0324;
precisioncv2 = 2;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);

[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
                              
outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);    
  
sigmaCV2 = 0.1:0.01:4;

for y = 1:numel(sigmaCV2)

disp(sigmaCV2(y));    
[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCV2(y));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

generalRate = hypot(lambda1, lambda2);

generalRater =  roundn(generalRate,precisioncv2);
positiveUnique = unique(generalRater);      

for x = 1:numel(positiveUnique)

result = zeros(size(generalRater));
result(abs(positiveUnique(x) - generalRater) <= eps(generalRater)) = 1;

resultF = bwfill(result,'holes',8);

commonResult = sum(result & templateR);
unionResult = sum(result | templateR);
cm=sum(result == 1); 
co=sum(templateR == 1); 
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


if recall < 1 && Jaccard > 0.7
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
 
outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;

outputRPA(outputRPA & resultF) = 246;
outputRPB(outputRPB & resultF) = 22;
outputRPC(outputRPC & resultF) = 22;

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;



im = cat(3, outputRPA, outputRPB, outputRPC);


nameImage = sprintf('Asg_%1.7f_name_%s_cv_%1.7f_jac_%1.7f_recall_%1.7f_.png',sigmaCV2(y), filename,positiveUnique(x),Jaccard,recall);
outputDir = ['/home/xenon/git_workspace/results/20/'  nameImage];
imwrite(im, outputDir);


close all;

end

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ma, ind] = max(maxJac);
% disp(ma); 
% 
% [gxxr, gxyr, gyyr] = imHessian(outputDouble,posSig(ind));
% [lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
% indexCV = hypot(lambda1, lambda2);
% 
% generalRateA =  roundn(indexCV,precisioncv2);
% 
% 
% resultf = zeros(size(generalRateA));
% resultf(abs(posCV(ind) - generalRateA) <= eps(generalRateA)) = 1;
% 
% resultf = bwfill(resultf,'holes',8);
% 
% outputRPA = 255 - outputR;
% outputRPB = 255 - outputR;
% outputRPC = 255 - outputR;
% 
% contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);
% 
% outputRPA(outputRPA & contour) = 59;
% outputRPB(outputRPB & contour) = 246;
% outputRPC(outputRPC & contour) = 22;
% 
% outputRPA(outputRPA & resultf) = 246;
% outputRPB(outputRPB & resultf) = 22;
% outputRPC(outputRPC & resultf) = 22;
% 
% 
% im = cat(3, outputRPA, outputRPB, outputRPC);
% 
% nameImage = sprintf('best_sg_%1.7f_name_%s_cv_%1.7f_Prec_%1.7f_.png',posSig(ind), filename,posCV(ind),ma);
% outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
% imwrite(im, outputDir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




close all;


end
