clear all;close all;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

% sigmaCVl = 1.93;
% precisioncvl = 4;
% tcvl = 0.0324;



precisioncmd = 1;

maxJac = [];
posSig = [];
posCV = [];   



templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);


[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
                              
outputR =  imga;
I = im2double(outputR);
templateDouble = double(templateR);    
  

count = 0;
for i=0.5:0.5:6.5

count = count + 1;    
k = 3;
G1=fspecial('gauss',[round(k*i), round(k*i)], i); 
Ig = imfilter(I,G1,'conv');

img3y = imcrop(Ig,[804.5 94.5 41 44]);


[gxxr, gxyr, gyyr] = imHessian(img3y,i);
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

resultF = bwfill(result,'holes',8);

narea = sum(resultF(:) == 1);

if narea > 10

% 

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);
outputRPA = img3y;
outputRPB = img3y;
outputRPC = img3y;

outputRPA(outputRPA & resultF) = 246;
outputRPB(outputRPB & resultF) = 22;
outputRPC(outputRPC & resultF) = 22;

area = sum(resultF(:) == 1);

im = cat(3, outputRPA, outputRPB, outputRPC);
nameImage = sprintf('%d_%1.7f_%1.7f_a.png',count,positiveUnique(x),area);
% nameImage = sprintf('%d.png',count);

outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);

end 
    
end    
end

