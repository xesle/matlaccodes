function [] = cma_hight()

close all;clc;

inputDir = '/home/xenon/git_workspace/matlaccodes/NewDataSet/Templates';

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');


precisioncmd = 1;
maxJac = [];
posSig = [];
posCV = [];  

% sigmaCMDl =  1.36;
% precisioncmdl = 3;
% thcmdl = 0.091;

templateR =  imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/' filename]);

[L,num] = bwlabel(templateR);

maskR = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/' filename]);
imga = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/' filename]);
                              
outputR =   imga;
outputDouble = im2double(outputR);
templateDouble = double(templateR);    
%%%%%%%%%%%%%%%%%%%%%%%


% [gxxl, gxyl, gyyl] = imHessian(outputDouble,sigmaCMDl);
% [lambda1l, lambda2l] = imEigenValues(gxxl, gxyl, gyyl, maskR);
% 
% cmdValue = zeros(size(lambda1l));
% div = zeros(size(lambda1l));
% suma =  zeros(size(lambda1l));
% 
% sumaq = lambda1l + lambda2l;
% divq = lambda1l ./ lambda2l;
% cmdValue = -(divq .* sumaq);        
% 
% cmdValue(sumaq >= 0) = 0;
% generalRatel =  roundn(cmdValue,precisioncmdl);
% 
% resultl = zeros(size(generalRatel));
% resultl(abs(thcmdl - generalRatel) <= eps(generalRatel)) = 1;

%%%%%%%%%%%%%%%%%%%%%%%
sigmaCMA = 0.1:0.01:2;


for y = 1:numel(sigmaCMA)

[gxxr, gxyr, gyyr] = imHessian(outputDouble,sigmaCMA(y));
[lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);

generalRate = hypot(lambda1, lambda2);

cmdValue = zeros(size(lambda1));
div = zeros(size(lambda1));
suma =  zeros(size(lambda1));

sumaq = lambda1 + lambda2;
divq = lambda1 ./ lambda2;
cmdValue = -(divq .* sumaq);        

cmdValue(sumaq >= 0) = 0;
generalRater =  roundn(cmdValue,precisioncmd);
positiveUnique = unique(generalRater); 


disp('*******************')
disp(numel(positiveUnique))


for x = 1:numel(positiveUnique)

resulth = zeros(size(generalRater));
resulth(abs(positiveUnique(x) - generalRater) <= eps(generalRater)) = 1;

result = bwfill(resulth,'holes',8);

[L,num] = bwlabel(result);


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

% maxJac = [maxJac recall];
% posSig = [posSig sigmaCV2(y)];
% posCV = [posCV positiveUnique(x)];  


if recall < 1 && Jaccard > 0.01
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     
% low = resultl;
% 
% disp(sum(low(:)));
% [m n] = size(resulth);
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
%                   aux = bwfill(aux,'holes',8);
%                 if low(a,b) == aux(a,b)
%                     resultHisteresis = resultHisteresis + aux;
%                 end
%             end
%         end
%     end
% end    
%     
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
outputRPA = outputR;
outputRPB = outputR;
outputRPC = outputR;

contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);

outputRPA(outputRPA & result) = 246;
outputRPB(outputRPB & result) = 22;
outputRPC(outputRPC & result) = 22;


outputRPA(outputRPA & contour) = 59;
outputRPB(outputRPB & contour) = 246;
outputRPC(outputRPC & contour) = 22;



im = cat(3, outputRPA, outputRPB, outputRPC);

nameImage = sprintf('a%1.7f_cma_%1.7f_Dic_%1.7f_FP_%1.7f_.png',sigmaCMA(y), positiveUnique(x),Dice,FP);
outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
imwrite(im, outputDir);  

end

end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ma, ind] = max(maxJac);
% disp(ma); 
% 
% [gxxr, gxyr, gyyr] = imHessian(outputDouble,posSig(ind));
% [lambda1, lambda2] = imEigenValues(gxxr, gxyr, gyyr, maskR);
% 
% 
% cmdValue = zeros(size(lambda1));
% div = zeros(size(lambda1));
% suma =  zeros(size(lambda1));
% 
% sumaq = lambda1 + lambda2;
% divq = lambda1 ./ lambda2;
% cmdValue = -(divq .* sumaq);        
% 
% cmdValue(sumaq >= 0) = 0;
% 
% generalRateA =  roundn(cmdValue,precisioncmd);
% 
% resultf = zeros(size(generalRateA));
% resultf(abs(posCV(ind) - generalRateA) <= eps(generalRateA)) = 1;
% 
% resultf = bwfill(resultf,'holes',8);
% 
% outputRPA = 255 - outputR;
% outputRPB = 255 - outputR;
% outputRPC = 255 - outputR;
% 
% contour = imread(['/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/' filename]);
% 
% outputRPA(outputRPA & contour) = 59;
% outputRPB(outputRPB & contour) = 246;
% outputRPC(outputRPC & contour) = 22;
% 
% outputRPA(outputRPA & resultf) = 246;
% outputRPB(outputRPB & resultf) = 22;
% outputRPC(outputRPC & resultf) = 22;
% 
% 
% im = cat(3, outputRPA, outputRPB, outputRPC);
% 
% nameImage = sprintf('best_sg_%1.7f_name_%s_cv_%1.7f_Prec_%1.7f_.png',posSig(ind), filename,posCV(ind),ma);
% outputDir = ['/home/xenon/git_workspace/results/'  nameImage];
% imwrite(im, outputDir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




close all;


end
