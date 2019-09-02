function [] = histcv_multi()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

sigmaCVl = 0.51;
precisioncvl = 4;
tcvl = 0.5278;

sigmaCVh = 0.53;
precisioncvh = 1;
tcvh = 0.6;

sigmaCVh3 = 0.7;
precisioncvh3 = 1;
tcvh3 = 0.3;

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
%result = bwfill(result2,'holes',8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCVh);
[lambda12, lambda22] = imEigenValues(gxxr2, gxyr2, gyyr2, maskR);
generalRate2 = hypot(lambda12, lambda22);
generalRated =  roundn(generalRate2,precisioncvh);
resultH = zeros(size(generalRated));
resultH(abs(tcvh - generalRated) <= eps(generalRated)) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[gxxr3, gxyr3, gyyr3] = imHessian(outputDouble,sigmaCVh3);
[lambda13, lambda3] = imEigenValues(gxxr3, gxyr3, gyyr3, maskR);
generalRate3 = hypot(lambda13, lambda3);
generalRated =  roundn(generalRate3,precisioncvh3);
resultH3 = zeros(size(generalRated));
resultH3(abs(tcvh3 - generalRated) <= eps(generalRated)) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


resultHight = resultH3 | resultH;

[L,num] = bwlabel(resultHight,8);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%plotconfusion(templateR,resultHisteresis);

outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;
    

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;


commonResult = sum(resultHisteresis & templateR);
unionResult = sum(resultHisteresis | templateR);
cm=sum(resultHisteresis == 1); % the number of voxels in m
co=sum(templateR == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);


adder = resultHisteresis + templateDouble;
TP = length(find(adder == 2));
TN = length(find(adder == 0));
subtr = resultHisteresis - templateDouble;
FN = length(find(subtr == -1));
FP = length(find(subtr == 1));
precision = TP / (TP + FP); 
recall  = TP / (TP + FN);

disp('precision');
disp(precision);
disp('recall');
disp(recall);




im = cat(3, outputRPA, outputRPB, outputRPC);


% commonResult = sum(resultHisteresis & templateR);
% unionResult = sum(resultHisteresis | templateR);
% cm=sum(resultHisteresis == 1); % the number of voxels in m
% co=sum(templateR == 1); % the number of voxels in o 
% Jaccard=commonResult/unionResult;
% Dice=(2*commonResult)/(cm+co);

% 
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


nameImage = sprintf('%s',filename);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(resultHisteresis, outputDir);  


%end

%end

close all;