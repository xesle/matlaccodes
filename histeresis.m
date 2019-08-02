function [] = histeresis()

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

%sigmaCV2 = 0.1:0.01:5;
sigmaCV1 = 0.7;
precisioncv1 = 3;
tcv1 = 0.259;

sigmaCV2 = 1.01;
precisioncv2 = 1;
tcv2 = 0.1;

% sigmaSI = 0.49;
% precisionsi = 4;
% tsi = -0.9257;


templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
        
[rows columns nc] = size(imga);

if nc == 3
    imga = rgb2gray(imga);
end;
                      
outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCV1);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

generalRate = hypot(lambda1, lambda2);

generalRater =  roundn(generalRate,precisioncv1);

result = zeros(size(generalRater));
result(abs(tcv1 - generalRater) <= eps(generalRater)) = 1;
%result = bwfill(result2,'holes',8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCV2);
[lambda12, lambda22] = imEigenValues(gxxr2, gxyr2, gyyr2, maskR);
generalRate2 = hypot(lambda12, lambda22);

generalRated =  roundn(generalRate2,precisioncv2);

resultH = zeros(size(generalRated));
resultH(abs(tcv2 - generalRated) <= eps(generalRated)) = 1;

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

low = result;

disp('mmm')
disp(sum(low(:)));


[m n] = size(result);
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


[l,m] = size(result);
resultExtend = result;
for a=1:l
    for b=1:m
        if result(a,b) == 1
            if a+3 < l
                aux = a+1;
                resultExtend(a:a+3,b) = 1;
            end
            if a-3 > 0
                aux = a-1;
                resultExtend(a-3:a,b) = 1;
            end    
            if b-3 > 0
                aux = b-1;
                resultExtend(a,b-3:b) = 1;
            end
            if b + 3 < m
                aux = b+1;
                resultExtend(a,b:b+3) = 1;
            end    
        end    
    end    
end    

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


im = cat(3, outputRPA, outputRPB, outputRPC);


commonResult = sum(resultHisteresis & templateR);
unionResult = sum(resultHisteresis | templateR);
%       plotconfusion(templateR,result);
cm=sum(resultHisteresis == 1); % the number of voxels in m
co=sum(templateR == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);


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


nameImage = sprintf('%s_cvh2_%1.7f_sg_%1.7f_.png',filename,tcv1,sigmaCV1);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  


%end

%end

close all;