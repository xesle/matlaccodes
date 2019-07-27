function [] = histcmd()

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

sigmaCMDh =  0.94;
precisioncmdh = 1;
thcmdh = 0.2

sigmaCMDl =  0.3;
precisioncmdl = 4;
thcmdl = 1.2162

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
    
    

[gxxh, gxyh, gyyh] = imHessian(outputDouble,sigmaCMDh);
[lambda1h, lambda2h] = imEigenValues(gxxh, gxyh, gyyh, maskR);
cmdValueh = zeros(size(lambda1h));
divh = zeros(size(lambda1h));
sumah =  zeros(size(lambda1h));
nh = numel(lambda1h);

[gxxl, gxyl, gyyl] = imHessian(outputDouble,sigmaCMDl);
[lambda1l, lambda2l] = imEigenValues(gxxl, gxyl, gyyl, maskR);
cmdValuel = zeros(size(lambda1l));
divl = zeros(size(lambda1l));
sumal =  zeros(size(lambda1l));
nl = numel(lambda1l);

for i = 1:nh
        sumah(i) = lambda1h(i) + lambda2h(i);
        auxh = lambda1h(i) ./ lambda2h(i);
        if isnan(auxh)
            divh(i) = 0;
        else    
            divh(i) = auxh;
        end    
        cmdValueh(i) = -(divh(i) * sumah(i));  
end

cmdValueh(sumah >= 0) = 0;
cmdValueRoundh =  roundn(cmdValueh,precisioncmdh);
result2 = zeros(size(cmdValueRoundh));
result2(abs(thcmdh - cmdValueRoundh) <= eps(cmdValueRoundh)) = 1;
resulth = bwfill(result2,'holes',8);

for i = 1:nl
        sumal(i) = lambda1l(i) + lambda2l(i);
        auxl = lambda1l(i) ./ lambda2l(i);
        if isnan(auxl)
            divl(i) = 0;
        else    
            divl(i) = auxl;
        end    
        cmdValuel(i) = -(divl(i) * sumal(i));  
end

cmdValuel(sumal >= 0) = 0;
cmdValueRoundl =  roundn(cmdValuel,precisioncmdl);
resultl = zeros(size(cmdValueRoundl));
resultl(abs(thcmdl - cmdValueRoundl) <= eps(cmdValueRoundl)) = 1;






% commonResult = sum(result & templateR);
% unionResult = sum(result | templateR);
% %       plotconfusion(templateR,result);
% cm=sum(result == 1); % the number of voxels in m
% co=sum(templateR == 1); % the number of voxels in o 
% Jaccard=commonResult/unionResult;
% Dice=(2*commonResult)/(cm+co);
% 
% adder = result + templateDouble;
% TP = length(find(adder == 2));
% TN = length(find(adder == 0));
% subtr = result - templateDouble;
% FN = length(find(subtr == -1));
% FP = length(find(subtr == 1));
% precision = TP / (TP + FP); 
% recall  = TP / (TP + FN);

% detections = connecction(L, num, result);
 
% if Jaccard == 0.4

outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;

[L,num] = bwlabel(resulth,8);

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

    

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;

commonResult = sum(resultHisteresis & templateR);
unionResult = sum(resultHisteresis | templateR);
%       plotconfusion(templateR,result);
cm=sum(resultHisteresis == 1); % the number of voxels in m
co=sum(templateR == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);


tamano=get(0,'ScreenSize');
figDir = ['/home/xenon/git_workspace/results/'];
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);

imshowpair(templateR, resultHisteresis);
title(['Jaccard Index = ' num2str(Jaccard) '       ' 'Dice Index = ' num2str(Dice)]); 

h=openfig(figDir,'new','invisible');
saveas(h,outputDir,'png');
close(h);


% im = cat(3, outputRPA, outputRPB, outputRPC);
% 
% nameImage = sprintf('_%s_.png',filename);
% outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
% imwrite(im, outputDir);  

%end

% end


end



