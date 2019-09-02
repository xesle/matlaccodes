function [] = histcmd()

close all;clc;
inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';
[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

sigmaCMDh =  1.45;
precisioncmdh = 1;
thcmdh = 0.1;

sigmaCMDl =  1.89;
precisioncmdl = 4;
thcmdl = 0.0574;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
[L,num] = bwlabel(templateR);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
outputR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);

outputRm = imread('/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/2a.png');

outputDouble = im2double(outputR);
templateDouble = double(templateR);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

resulth = bwfill(result,'holes',8);
[La,numa] = bwlabel(resulth,8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
[gxx, gxy, gyy] = imHessian(outputDouble,sigmaCMDl);
[lambda11, lambda22] = imEigenValues(gxx, gxy, gyy, maskR);
cmdValuel = zeros(size(lambda11));

sumaq2 = lambda11 + lambda22;
divq2 = lambda11 ./ lambda22;
cmdValuel = -(divq2 .* sumaq2);        

cmdValuel(sumaq >= 0) = 0;

cmdValueRoundl =  roundn(cmdValuel,precisioncmdl);
   
resultl = zeros(size(cmdValueRoundl));
resultl(abs(thcmdl - cmdValueRoundl) <= eps(cmdValueRoundl)) = 1;

low = resultl;

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

commonResult = sum(resultHisteresis & templateR);
unionResult = sum(resultHisteresis | templateR);
cm=sum(resultHisteresis == 1); % the number of voxels in m
co=sum(templateR == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);

% adder = resulth + templateDouble;
% TP = length(find(adder == 2));
% TN = length(find(adder == 0));
% subtr = resulth - templateDouble;
% FN = length(find(subtr == -1));
% FP = length(find(subtr == 1));
% precision = TP / (TP + FP); 
% recall  = TP / (TP + FN);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [l,m] = size(low);
% resultExtend = low;
% for a=1:l
%     for b=1:m
%         if low(a,b) == 1
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;


disp('Area');
disp(sum(templateR(:)==1));
disp('Area final ');
disp(sum(resultHisteresis(:)==1));

disp('Jaccard');
disp(Jaccard);

disp('Dice');
disp(Dice);


im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('%s',filename);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(resultHisteresis, outputDir);  


% tamano=get(0,'ScreenSize');
% figDir = ['/home/xenon/git_workspace/results/'];
% figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
% 
% imshowpair(templateR, resultHisteresis);
% title(['Jaccard Index = ' num2str(Jaccard) '       ' 'Dice Index = ' num2str(Dice)]); 
% 
% h=openfig(figDir,'new','invisible');
% saveas(h,outputDir,'png');
% close(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% tamano=get(0,'ScreenSize');
% figDir = ['/home/xenon/git_workspace/results/figDir/'];
% figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
% cdata = [(TP+FP) TP FP; (FN+TN) FN TN];
% xvalues = {'Total','+','-'};
% yvalues = {'+','-'};
% h = heatmap(xvalues,yvalues,cdata);
% h.CellLabelFormat = '%6.3f';
% errorRate = round(((FP + FN) / (FP + FN + TP + TN)) * 100,2);
% % h.Title = (['Matrix Confusion  ------- Error Rate = ' num2str(errorRate) '%']);
% % h.Title = (['Confusion matrix']);
% h.XLabel = 'ACTUAL';
% h.YLabel = 'PREDICTED'; 
% savefig(figDir);
%  h=openfig(figDir,'new','invisible');
% saveas(h,outputDir,'png');
% close(h);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
end
