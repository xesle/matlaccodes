function [] = histcv()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');


sigmaCVl = 1.9;
precisioncvl = 4;
tcvl = 0.0364;

sigmaCVH = 3.8;
precisioncvh = 2;
tcvh = 0.01;




% sigmaSI = 0.49;
% precisionsi = 4;
% tsi = -0.9257;


templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);                      

outputR =   imga;

outputDouble = im2double(outputR);

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCVl);

[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
generalRate = hypot(lambda1, lambda2);
generalRater =  roundn(generalRate,precisioncvl);

resultl = zeros(size(generalRater));
resultl(abs(tcvl - generalRater) <= eps(generalRater)) = 1;
%result = bwfill(result2,'holes',8);

% figure;
% imshow(resultl,[]);
% pause(10);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCVH);
[lambda12, lambda22] = imEigenValues(gxxr2, gxyr2, gyyr2, maskR);
generalRate2 = hypot(lambda12, lambda22);
generalRated =  roundn(generalRate2,precisioncvh);
result = zeros(size(generalRated));
result(abs(tcvh - generalRated) <= eps(generalRated)) = 1;

resultH = bwfill(result,'holes',8);


% figure;
% imshow(resultH);
% pause(10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% [gxxr3, gxyr3, gyyr3] = imHessian(outputDouble,sigmaSI);
% [lambda3, lambda33] = imEigenValues(gxxr3, gxyr3, gyyr3, maskR);
% 
% generalRates =  2/pi .* atan((lambda33 + lambda3) ./ (lambda33 - lambda3));
% generalRatess =  roundn(generalRates,precisionsi);
% 
% resultSI = zeros(size(generalRatess));
% resultSI(abs(tsi - generalRatess) <= eps(generalRatess)) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[L,num] = bwlabel(resultH,8);

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

outputRPA(outputRPA & resultHisteresis) = 246;
outputRPB(outputRPB & resultHisteresis) = 22;
outputRPC(outputRPC & resultHisteresis) = 22;


outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;

% figure;
% imshow(resultHisteresis);
% pause(10);
disp('Area pre');
disp(sum(templateR(:) == 1));
disp('Area detect');
disp(sum(resultHisteresis(:) == 1));


im = cat(3, outputRPA, outputRPB, outputRPC);

commonResult = sum(resultHisteresis & templateR);
unionResult = sum(resultHisteresis | templateR);
cm=sum(resultHisteresis == 1); % the number of voxels in m
co=sum(templateR == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);


disp('Jacc');
disp(Jaccard);
disp('Dic');
disp(Dice);
% 


nameImage = sprintf('%1.7f_%s_cvh2_%1.7f_sg_%1.7f_.png',Jaccard,filename,tcvl,sigmaCVH);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('Jaccard');
% disp(Jaccard);
% 
% disp('Dice');
% disp(Dice);

%end

%end

close all;