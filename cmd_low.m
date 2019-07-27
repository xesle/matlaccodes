function [] = cmd_low()

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

sigmaCMD =  0.5:0.01:1;
%sigmaCMD = 0.1;

precisioncmd = 1;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);

[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
        
[rows columns nc] = size(imga);

if nc == 3
    imga = rgb2gray(imga);
end;
                       
outputR =  imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);


% totalTH = [];
% totalSG = [];
% sumValues = [];    
    
for y = 1:numel(sigmaCMD)

    

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCMD(y));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);


cmdValue = zeros(size(lambda1));
div = zeros(size(lambda1));
suma =  zeros(size(lambda1));

n = numel(lambda1);

for i = 1:n
        suma(i) = lambda1(i) + lambda2(i);
        aux = lambda1(i) ./ lambda2(i);
        if isnan(aux)
            div(i) = 0;
        else    
            div(i) = aux;
        end    
        cmdValue(i) = -(div(i) * suma(i));  
end

cmdValue(suma >= 0) = 0;

cmdValueRound =  roundn(cmdValue,precisioncmd);
positiveUnique = unique(cmdValueRound); 

% imshow(cmdValueRound);
% 
% pause(5);     

disp('*******************')
disp(numel(positiveUnique))
disp(positiveUnique);


for x = 1:numel(positiveUnique)

result2 = zeros(size(cmdValueRound));
result2(abs(positiveUnique(x) - cmdValueRound) <= eps(cmdValueRound)) = 1;
result = bwfill(result2,'holes',8);

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

% detections = connecction(L, num, result);
 
% if Jaccard == 0.4

outputRPA = 255 - outputR;
outputRPB = 255 - outputR;
outputRPC = 255 - outputR;

% [l,m] = size(result);
% resultExtend = result;
% for a=1:l
%     for b=1:m
%         if result(a,b) == 1
%             if a+3 < l
%                 aux = a+1;
%                 resultExtend(a:a+3,b) = 1;
%             end
%             if a-3 > 0
%                 aux = a-1;
%                 resultExtend(a-3:a,b) = 1;
%             end    
%             if b-3 > 0
%                 aux = b-1;
%                 resultExtend(a,b-3:b) = 1;
%             end
%             if b + 3 < m
%                 aux = b+1;
%                 resultExtend(a,b:b+3) = 1;
%             end    
%         end    
%     end    
% end    

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & result) = 246;
outputRPB(outputRPB & result) = 22;
outputRPC(outputRPC & result) = 22;


im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('TP_%1.7f_1_name_%s_cmd_%1.7f_sg_%1.7f_FP_%1.7f_.png',TP,filename,positiveUnique(x),sigmaCMD(y),FP);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  

%end

% end

end

close all;


end
