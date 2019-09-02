
P = [];
G = [];
M = [];

for z=1:20

templateR = imread(strcat('/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/',num2str(z), ".png"));    
cv = imread(strcat('/home/xenon/git_workspace/results/cv/',num2str(z), ".png"));    
cma = imread(strcat('/home/xenon/git_workspace/results/cma/',num2str(z), ".png"));    

% cv = imread(['/home/xenon/git_workspace/results/cv/' filename]);   
% templateR = zeros(size(templateRA));
% templateR(templateRA > 0) = 1;

result =  cv;
[L,num] = bwlabel(templateR);

for i=1:num
  aux = zeros(size(templateR));
  aux(L == i) = 1;
  area = sum(aux(:));

  b = zeros(size(templateR));
  c = zeros(size(templateR));
  d = zeros(size(templateR));
  e = zeros(size(templateR));
  
  b(result > 0) = 2;
  c = aux - b;
  e(c == -1) = 1;

  
  
   if sum(e(:)) > 0

    commonResult = sum(e & aux);
    unionResult = sum(e | aux);
    cm=sum(e == 1); 
    co=sum(aux == 1); 
    Jaccard=commonResult/unionResult;
    Dice=(2*commonResult)/(cm+co);

  
    if area <= 500
        P = [P Dice];
    elseif area > 500 && area < 2000    
        M = [M Dice];   
    else
        G = [G Dice];
    end 
    
   else
     if area <= 500
        P = [P 0];
    elseif area > 500 && area < 2000    
        M = [M 0];   
    else
        G = [G 0];
    end 

     end 
end

end


% disp('Pequeños');
% disp(numel(P));
% disp(vec2mat(P,1));
% disp('Mean');
% disp(sum(P) ./ numel(P));
% disp('Std');
% disp(std(P));
% disp('----------------');

% disp('Medianos');
% disp(numel(M));
% disp(vec2mat(M,1));
% disp('Mean');
% disp(sum(M) ./ numel(M));
% disp('Std');
% disp(std(M));
disp('------------------');
disp(numel(G));
disp('Grandes');
% disp(vec2mat(G,1));
disp('Std');
disp(std(G));
disp('mean');
disp(mean(G));
disp('median');
disp(median(G));
disp('var');
disp(var(G));
disp('max');
disp(max(G));
disp('min');
disp(min(G));
