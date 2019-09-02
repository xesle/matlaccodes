function [] = main(displayLayers)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%   Section 3, using a GUI, iterate through the segmentation results,
%              and maually or semi-automatically correct the segmented
%              retainl layers.
%   Section 4, calculate and print out retinal thickness (in pixels)
%
close all;clc;
%% Section 1, loads the path of the image.

if nargin < 1
    display('requires 1 input');
    return;
end

outputImgsDir = ['/home/xenon/git_workspace/results/'];



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

[filename, folderPath , filterindex] = uigetfile([inputDir '/*.*'],'Pick some images','MultiSelect', 'on');


if (isequal(filename,0) && isequal(folderPath,0) && isequal(filterindex,0))
    return;
else
    inputDir = folderPath;
    setpref('cropUtility','inputDir',inputDir);
end

% dirOutput = uigetdir('C:\Users\xose\Desktop\Documentacion TFG\img_curvedness\7');
% if (isequal(output_dir,0))
%     return;
% else
%    outputDir = output_dir;
%    setpref('cropUtility','outputDir',outputDir);
% end
if (iscell(filename))
    maxE = numel(filename);
else
    maxE = 1;
end 


%flags for display layers on image
%rpe   isos     oplonl   inlopl    iplinl    nflgcl  ilm
displayLayers = bi2de(displayLayers);

for i = 1:maxE
    if (iscell(filename))
        imagePath{i} = [folderPath ,filename{i}];
    else
        imagePath = [folderPath ,filename];
    end
end

if (iscell(imagePath))
    img = imread(imagePath{i});
else
    img = imread(imagePath);
end

[rows columns nc] = size(img);


if nc == 3
    img = rgb2gray(img);
end

  img = im2double(img);
    
    % get size of image.
%     szImg = size(img);
%     
%     %segment whole image if yrange/xrange is not specified.
%     if isempty(yrange) && isempty(xrange)
%         yrange = 1:szImg(1);
%         xrange = 1:szImg(2);
%     end    
%     
% img = img(yrange,xrange);

[retinalLayers, params, RPE, ILM]  = getRetinalLayers(img, displayLayers, [outputImgsDir '\' filename]);

mask = RPE | ILM;
% 
[r c] = size(mask);
% 
for a=1:c
   frst = find(mask(:,a),1,'first');
   lst = find(mask(:,a),1,'last');
   v = (frst+3):lst;
   s = mask(:,a);
   s(v) = 1;
   s(frst)=0;
   mask(:,a) = s;
end

if size(img,3)==3
     output  = rgb2gray(img);
     output(~mask) = 0;
else
    output  = img;
    output(~mask)=0;
end 

default = zeros(1,c);
a=1;
b = r;

% whos default;
% as = ILM(a+1,:);
% whos as;

while isequal(default, ILM(a,:))
   a = a + 1; 
end    

while isequal(default, RPE(b,:))
   b = b - 1; 
end 

width =  c;
height = b - a;

x1 = a;
y1 = 1;

rect = [y1 x1 width height];
disp(rect);
%newStr = split(filename,".");
% 
% disp(newStr(1));
% 
%filename2 = strcat(newStr(1), "_1.png");
% %
dirTemplate = strcat('/home/xenon/git_workspace/matlaccodes/NewDataSet/Templates/', filename);
output = imread(dirTemplate);

output2 = zeros(size(output));
output2(output > 0) = 1;



dirCrop = strcat('/home/xenon/git_workspace/matlaccodes/NewDataSet/Cropped/', filename);

croppedTemplates = strcat('/home/xenon/git_workspace/matlaccodes/NewDataSet/CroppedTemplates/', filename);
maskCrop = strcat('/home/xenon/git_workspace/matlaccodes/NewDataSet/maskCropped/', filename);
contour = strcat('/home/xenon/git_workspace/matlaccodes/NewDataSet/Contour/', filename);

 
outputRy = imcrop(output2,rect);
imwrite(outputRy,croppedTemplates);
% 
img3y = imcrop(img,rect);
imwrite(img3y,dirCrop);
% 
% 

maskCropy = imcrop(mask,rect);
imwrite(maskCropy,maskCrop);

% figure;
% imshow(outputRy,[]);
% pause(15);

i =   bwperim(outputRy,8);
imwrite(i,contour);



end