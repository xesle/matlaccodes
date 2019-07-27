function [] = histcv_cmd()

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
resultHisteresis1 = zeros(m,n);

for a = 1:m
    for b = 1:n
        if low(a,b) == 0 || resultHisteresis1(a,b) == 1
            continue;
        else
            for i=1:num
                  aux = zeros(m,n); 
                  aux(L == i) = 1;
                  aux = bwfill(aux,'holes',8);
                if low(a,b) == aux(a,b)
                    resultHisteresis1 = resultHisteresis1 + aux;
                end
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigmaCV1 = 0.3;
precisioncv1 = 4;
tcv1 = 0.6582;

sigmaCV2 = 1.01;
precisioncv2 = 1;
tcv2 = 0.1;

sigmaSI = 0.49;
precisionsi = 4;
tsi = -0.9257;

outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCV1);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

generalRate = hypot(lambda1, lambda2);

generalRater =  roundn(generalRate,precisioncv1);

result = zeros(size(generalRater));
result(abs(tcv1 - generalRater) <= eps(generalRater)) = 1;

[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCV2);
[lambda12, lambda22] = imEigenValues(gxxr2, gxyr2, gyyr2, maskR);
generalRate2 = hypot(lambda12, lambda22);

generalRated =  roundn(generalRate2,precisioncv2);

resultH = zeros(size(generalRated));
resultH(abs(tcv2 - generalRated) <= eps(generalRated)) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[gxxr3, gxyr3, gyyr3] = imHessian(outputDouble,sigmaSI);
[lambda3, lambda33] = imEigenValues(gxxr3, gxyr3, gyyr3, maskR);

generalRates =  2/pi .* atan((lambda33 + lambda3) ./ (lambda33 - lambda3));
generalRatess =  roundn(generalRates,precisionsi);

resultSI = zeros(size(generalRatess));
resultSI(abs(tsi - generalRatess) <= eps(generalRatess)) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[L,num] = bwlabel(resultH,8);

low = resultSI | result;

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

resultHisteresis = resultHisteresis2 | resultHisteresis1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%plotconfusion(templateR,resultHisteresis);

outputRPA =  outputR;
outputRPB = outputR;
outputRPC = outputR;
    

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% im = cat(3, outputRPA, outputRPB, outputRPC);
% 
% nameImage = sprintf('_%s_.png',filename);
% outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
% imwrite(im, outputDir);  

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













%end

% end


end



