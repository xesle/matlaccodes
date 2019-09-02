function [] = histcma_multi()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');

sigmaCVl = 0.5;
precisioncvl = 4;
tcvl = 0.8565;

sigmaCVh = 0.7;
precisioncvh = 1;
tcvh = 0.6;

sigmaCVh3 = 0.7;
precisioncvh3 = 1;
tcvh3 = 0.4;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);
maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
                      
outputR =   imga;
outputDouble = im2double(outputR);

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCVl);
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

cmdValueB = zeros(size(lambda1));
div = zeros(size(lambda1));
suma =  zeros(size(lambda1));
sumaq = lambda1 + lambda2;
divq = lambda1 ./ lambda2;
cmdValueB = -(divq .* sumaq);        
cmdValueB(sumaq >= 0) = 0;

generalRater =  roundn(cmdValueB,precisioncvl);

resultl = zeros(size(generalRater));
resultl(abs(tcvl - generalRater) <= eps(generalRater)) = 1;


%result = bwfill(result2,'holes',8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[gxxr2, gxyr2, gyyr2] = imHessian(outputDouble,sigmaCVh);
[lambda1b, lambda2b] = imEigenValues(gxxr2, gxyr2, gyyr2, maskR);

cmdValueB2 = zeros(size(lambda1));
div = zeros(size(lambda1b));
suma =  zeros(size(lambda1b));
sumaq = lambda1b + lambda2b;
divq = lambda1b ./ lambda2b;
cmdValueB2 = -(divq .* sumaq);        
cmdValueB2(sumaq >= 0) = 0;

generalRated2 =  roundn(cmdValueB2,precisioncvh);


resultH = zeros(size(generalRated2));
resultH(abs(tcvh - generalRated2) <= eps(generalRated2)) = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[gxxr3, gxyr3, gyyr3] = imHessian(outputDouble,sigmaCVh3);
[lambda1c, lambda2c] = imEigenValues(gxxr3, gxyr3, gyyr3, maskR);

cmdValuec = zeros(size(lambda1c));
div = zeros(size(lambda1c));
suma =  zeros(size(lambda1));
sumaq = lambda1c + lambda2c;
divq = lambda1c ./ lambda2c;
cmdValuec = -(divq .* sumaq);        
cmdValuec(sumaq >= 0) = 0;

generalRated =  roundn(cmdValuec,precisioncvh3);
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


im = cat(3, outputRPA, outputRPB, outputRPC);




commonResult = sum(resultHisteresis & templateR);
unionResult = sum(resultHisteresis | templateR);
cm=sum(resultHisteresis == 1); % the number of voxels in m
co=sum(templateR == 1); % the number of voxels in o 
Jaccard=commonResult/unionResult;
Dice=(2*commonResult)/(cm+co);

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

disp('Area');
disp(sum(templateR(:)==1));
disp('Area final ');
disp(sum(resultHisteresis(:)==1));

disp('Jaccard');
disp(Jaccard);

disp('Dice');
disp(Dice);

nameImage = sprintf('%s',filename);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(resultHisteresis, outputDir);  


%end

%end

close all;