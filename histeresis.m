function [] = histeresis()

close all;clc;


%% 
if(~ispref('cropUtility','inputDir'))
    addpref('cropUtility','inputDir','');
end
if(~ispref('cropUtility','outputDir'))
    addpref('cropUtility','outputDir','');
end
inputDir = getpref('cropUtility','inputDir');
if (strcmp(inputDir,''))
    inputDir = cd;
end
outputDir = getpref('cropUtility','outputDir');
if (strcmp(outputDir,''))
    outputDir = cd;
end
%% 

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');


if (isequal(filename,0) && isequal(folderPath,0) && isequal(filterindex,0))
    return;
else
    inputDir = folderPath;
    setpref('cropUtility','inputDir',inputDir);
end


if (iscell(filename))
    maxE = numel(filename);
else
    maxE = 1;
end 

% extOutImg = 'png';

%flags for display layers on image
%rpe   isos     oplonl   inlopl    iplinl    nflgcl  ilm

P = [];
S = [];
D = [];
J = [];
        
imagePath = [folderPath ,filename];
   

%if ii == 1
 
thcv1 = 0.3;  
sigmaCV1 = 0.3;
precisioncv1 = 1;
 
thcv2 = 0.1;
sigmaCV2 = 0.41;
precisioncv2 = 0.1;
 

thsi = -0.9923;  
sigmaSI = 1.8;
precisioncSI = 0.0001;

    
% elseif ii == 2
%    
% thcv1 = 0.0915;  
% sigmaCV1 = 0.42;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.42;
% precisioncv2 = 0.1;
%  
% thsi = -0.9466;  
% sigmaSI = 1.4;
% precisioncSI = 0.0001;
%     
%     
% elseif ii == 3
%     
% thcv1 = 0.2346;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.41;
% precisioncv2 = 0.1;
%  
% thsi = -0.9845;  
% sigmaSI = 0.8;
% precisioncSI = 0.0001;
%   
% elseif ii == 4
% 
% thcv1 = 0.1011;  
% sigmaCV1 = 0.41;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.41;
% precisioncv2 = 0.1;
%  
% thsi = -0.9100;  
% sigmaSI = 2;
% precisioncSI = 0.0001;
%     
%     
% elseif ii == 5    
%     
% thcv1 = 0.7281;  
% sigmaCV1 = 0.2;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.44;
% precisioncv2 = 0.1;
%  
% thsi = -0.9383;  
% sigmaSI = 2;
% precisioncSI = 0.0001;
%  
%     
% elseif ii == 6
%     
% thcv1 = 0.0972;  
% sigmaCV1 = 0.41;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.41;
% precisioncv2 = 0.1;
%  
% thsi = -0.9602;  
% sigmaSI = 1.4;
% precisioncSI = 0.0001;
%  
%     
% elseif ii == 7
%     
% thcv1 = 0.4137;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.43;
% precisioncv2 = 0.1;
%  
% thsi = -0.9774;  
% sigmaSI = 0.7;
% precisioncSI = 0.0001;
%     
% elseif ii == 8
%     
% thcv1 = 0.5516;  
% sigmaCV1 = 0.2;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.4;
% precisioncv2 = 0.1;
%  
% thsi = -0.9662;  
% sigmaSI = 2.8;
% precisioncSI = 0.0001;
%        
% elseif ii == 9
%     
% thcv1 = 0.437;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.41;
% precisioncv2 = 0.1;
%  
% thsi = -0.9125;  
% sigmaSI = 3.6;
% precisioncSI = 0.0001;
%     
%     
% elseif ii == 10
%     
% thcv1 = 0.1064;  
% sigmaCV1 = 0.43;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.44;
% precisioncv2 = 0.1;
%  
% thsi = -0.9693;  
% sigmaSI = 0.6;
% precisioncSI = 0.0001; 
%     
% elseif ii == 11
%     
% thcv1 = 0.1192;  
% sigmaCV1 = 0.42;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.42;
% precisioncv2 = 0.1;
%  
% thsi = -0.9719;  
% sigmaSI = 1.8;
% precisioncSI = 0.0001;
%    
%     
% elseif ii == 12
%     
% thcv1 = 0.1254;  
% sigmaCV1 = 0.42;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.42;
% precisioncv2 = 0.1;
%  
% thsi = -0.9429;  
% sigmaSI = 3.2;
% precisioncSI = 0.0001;
%        
% elseif ii == 13
%     
% thcv1 = 0.3546;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.4;
% precisioncv2 = 0.1;
%  
% thsi = -0.9678;  
% sigmaSI = 3.4;
% precisioncSI = 0.0001;
%        
% elseif ii == 14
%  
% 
% thcv1 = 0.3940;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.4;
% precisioncv2 = 0.1;
%  
% thsi = -0.9816;  
% sigmaSI = 3.8;
% precisioncSI = 0.0001;
%        
% elseif ii == 15
%     
% thcv1 = 0.1384;  
% sigmaCV1 = 0.4;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.42;
% precisioncv2 = 0.1;
%  
% thsi = -0.9714;  
% sigmaSI = 2.3;
% precisioncSI = 0.0001;
%      
% elseif ii == 16
%     
% thcv1 = 0.8613;  
% sigmaCV1 = 0.2;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.42;
% precisioncv2 = 0.1;
%  
% thsi = -0.9987;  
% sigmaSI = 0.6;
% precisioncSI = 0.0001;
%       
% elseif ii == 17
%     
% thcv1 = 0.9266;  
% sigmaCV1 = 0.2;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.43;
% precisioncv2 = 0.1;
%  
% thsi = -0.9513;  
% sigmaSI = 4.1;
% precisioncSI = 0.0001;
%        
% elseif ii == 18
%     
% thcv1 = 0.3832;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.41;
% precisioncv2 = 0.1;
%  
% thsi = -0.9170;  
% sigmaSI = 1;
% precisioncSI = 0.0001;
%      
% elseif ii == 19
%      
% thcv1 = 0.4098;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.0001;
%  
% thcv2 = 0.1;
% sigmaCV2 = 0.42;
% precisioncv2 = 0.1;
%  
% thsi = -0.9610;  
% sigmaSI = 1.8;
% precisioncSI = 0.0001;
%         
% else
%     
% thcv1 = 0.3795;  
% sigmaCV1 = 0.3;
% precisioncv1 = 0.0001;
% 
% thcv2 = 0.1;
% sigmaCV2 = 0.42;
% precisioncv2 = 0.1;
% 
% thsi = -0.9369;  
% sigmaSI = 1.9;
% precisioncSI = 0.0001;   
% end;    
    

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
        
[rows columns nc] = size(imga);

if nc == 3
    imga = rgb2gray(imga);
end;


outputR = imga;
outputRSI = 255 - imga;

outputDouble = im2double(outputR);
outputDoubleSI = im2double(outputRSI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOW CV
[gxx, gxy, gyy] = imHessian(outputDouble,sigmaCV1);
[lambda1, lambda2] = imEigenValues(gxx, gxy, gyy, maskR);
generalRater = hypot(lambda1, lambda2);
%generalRateRCV1 = quant(generalRater, precisioncv1);

generalRateRCV1 =  roundn(generalRater,precisioncv1);
lowCV = zeros(size(generalRateRCV1));
lowCV(abs(thcv1 - generalRateRCV1) <= eps(generalRateRCV1)) = 1;


% [gxx, gxy, gyy] = imHessian(outputDouble,sigmaCV2);
% [lambda1, lambda2] = imEigenValues(gxx, gxy, gyy, maskR);
% generalRater = hypot(lambda1, lambda2);
% generalRateRCV2 = quant(generalRater, precisioncv2);
% hight = zeros(size(generalRateRCV2));
% hight(abs(thcv2 - generalRateRCV2) <= eps(generalRateRCV2)) = 1;
% 
% [gxxr, gxyr, gyyr] = imHessian(outputDoubleSI,sigmaSI);
% [lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
% generalRateRc =  2/pi .* atan((lambda2 + lambda1) ./ (lambda2 - lambda1));
% generalRateRSI = quant(generalRateRc,precisioncSI);
% lowSI = zeros(size(generalRateRSI));
% lowSI(abs(thsi - generalRateRSI) <= eps(generalRateRSI)) = 1;

low = lowCV;

% hight = bwfill(hight,'holes',8);% hight = imerode(hight2, se);
% [L,num] = bwlabel(hight,8);
% 
% [m n] = size(low);
% resultHisteresis = zeros(m,n);
% 
% for a = 1:m
%     for b = 1:n
%         if low(a,b) == 0 || resultHisteresis(a,b) == 1
%             continue;
%         else    
%             for i=1:num 
%                   aux = zeros(m,n);
%                   aux(L == i) = 1;
%                    aux = bwfill(aux,'holes',8);
%                 if low(a,b) == aux(a,b)
%                     resultHisteresis = resultHisteresis + aux;
%                     break;
%                 end
%             end
%         end
%     end
% end  


outputRPA = 255 - outputR;
outputRPB = 255 - outputR;
outputRPC = 255 - outputR;

% outputRPA(outputRPA & resultHisteresis) = 246;
% outputRPB(outputRPB & resultHisteresis) = 22;
% outputRPC(outputRPC & resultHisteresis) = 22;

outputRPA(outputRPA & low) = 246;
outputRPB(outputRPB & low) = 22;
outputRPC(outputRPC & low) = 22;


contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);


outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

im = cat(3, outputRPA, outputRPB, outputRPC);
dt = datestr(now,'HH_MM_SS');
nameImage = sprintf('%1.7f_%1.7f_%s_%s',thcv2,sigmaCV2,dt, filename);
outputDir = ['/home/xenon/git_workspace/matlaccodes/results/'  nameImage];
imwrite(im, outputDir);

%%
% commonResult = sum(resultHisteresis & templateR);
% unionResult = sum(resultHisteresis | templateR);
% cm=sum(resultHisteresis == 1); 
% co=sum(templateR == 1); 
% Jaccard=commonResult/unionResult;
% Dice=(2*commonResult)/(cm+co);
% adder = resultHisteresis + templateDouble;
% TP = length(find(adder == 2));
% TN = length(find(adder == 0));
% subtr = resultHisteresis - templateDouble;
% FP = length(find(subtr == -1));
% FN = length(find(subtr == 1));



% tamano=get(0,'ScreenSize');
% figDir = ['results\images\HISTCVSI2\'];
% figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
% subplot(3,1,1);
% imshow(im);
% subplot(3,1,2);
% cdata = [(TP+FP) TP FP; (FN+TN) FN TN];
% xvalues = {'Total','+','-'};
% yvalues = {'+','-'};
% h = heatmap(xvalues,yvalues,cdata);
% h.CellLabelFormat = '%6.3f';
% errorRate = round(((FP + FN) / (FP + FN + TP + TN)) * 100,2);
% h.Title = (['Matrix Confusion  ------- Error Rate = ' num2str(errorRate) '%']);
% h.XLabel = 'ACTUAL';
% h.YLabel = 'PREDICTED';
% subplot(3,1,3);
% imshowpair(templateR, resultHisteresis);
% title(['Jaccard Index = ' num2str(Jaccard) '       ' 'Dice Index = ' num2str(Dice)]); 
% savefig(figDir);
%  h=openfig(figDir,'new','invisible');
% saveas(h,outputDir,'png');
% close(h);


%J = [J Jaccard];
%%

% PRECISION = TP / (TP + FP);
% SENSIBILIDAD = TP / (TP + FN);
% 
% P = [P PRECISION];
% S = [S SENSIBILIDAD];
% d = sqrt((1-PRECISION)^2+(1-SENSIBILIDAD)^2);
% D = [D (1-d)];
%end

% P = P;
% S = S;
% D = D;
%N = 1:20;
% 
% 
% tamano=get(0,'ScreenSize');
% figDir = ['results\images\\HISTCVSI\'];
% figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
% hold on;
% grid on;
% plot(P,S,'*');
% title(['SIMILARITY']); 
% xlabel('Precision');
% ylabel('Sensitivity');
% xlim([0.68 1]);
% ylim([0.86 1]);
% for j=1:numel(P)
% xx =[P(j) 1];
% yy =[S(j) 1];
% plot(xx,yy);
% end
% Z = 1:1:numel(P);
% strValues  = strtrim(cellstr(num2str([Z(:) D(:)],'%d:%6.3f'))); 
% text(P,S,strValues,'VerticalAlignment','bottom','Color','red','FontSize',8);
% savefig(figDir);
% h=openfig(figDir,'new','invisible');
% saveas(h,outputDir,'png');
% close all;

% tamano=get(0,'ScreenSize');
% figDir = ['results\images\HISTCVSI2\'];
% figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
% hold on;
% grid on;
% plot(N,J,'*');
% title(['Global Jaccard']); 
% xlabel('Image');
% ylabel('Jaccard');
% xlim([0 1]);
% ylim([0 1]);
% for j=1:numel(P)
% xx =[P(j) 1];
% yy =[S(j) 1];
% plot(xx,yy);
% end
% Z = 1:1:numel(P);
% strValues  = strtrim(cellstr(num2str([Z(:) D(:)],'%d:%6.3f'))); 
% text(P,S,strValues,'VerticalAlignment','bottom','Color','red','FontSize',8);
% savefig(figDir);
% h=openfig(figDir,'new','invisible');
% saveas(h,outputDir,'png');
close all;

end
