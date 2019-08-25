function [retinalLayers, params, RPE,ILM] = getRetinalLayers(img,flagplot,imgOutDir,params)
% [retinalLayers params] = getRetinalLayers(img,params)
% identifies the boundaries between retinal layeres given an optical 
% coherence tomography image, 'img'.
% 
% The method for identification of these retinal layer boundaries is
% based on graph theory.
% 
[m MAXCOLUM] = size(img);
myLength = 1:MAXCOLUM;
RPE = zeros(m,MAXCOLUM);
ILM = zeros(m,MAXCOLUM);

if nargin < 1
    display('requires 1 input');
    return;
end
%initialize constants
if nargin <= 3        
    
    % resize the image if 1st value set to 'true',
    % with the second value to be the scale.
    params.isResize = [false];
    
    % parameter for smothing the images.
    params.filter0Params = [5 5 1];
    params.filterParams = [20 20 2];
        
    % constants used for defining the region for segmentation of individual layer
    params.roughILMandISOS.shrinkScale = 0.2;
    params.roughILMandISOS.offsets = -20:20;    
    params.ilm_0 = 4;
    params.ilm_1 = 4;
    params.isos_0 = 14;    %4;
    params.isos_1 = 14;    %4;
    params.rpe_0 = 0.1; %   0.05;
    params.rpe_1 = 0.1; %   0.05;
    params.inlopl_0 = 0.1; %   0.4;%
    params.inlopl_1 = 0.3; %   0.5;%  
    params.nflgcl_0 = 0.05;%  0.01;
    params.nflgcl_1 = 0.3; %   0.1;
    params.iplinl_0 = 0.6;
    params.iplinl_1 = 0.2;
    params.oplonl_0 = 0.05;%4;
    params.oplonl_1 = 0.5;%4;    
        
    % parameters for ploting
    params.txtOffset = -7;
    colorarr=colormap('jet'); 
    params.colorarr=colorarr(64:-8:1,:);
    
    % a constant (not used in this function, used in 'octSegmentationGUI.m'.)
    params.smallIncre = 2;    
    
end

%clear up matlab's mind
clear retinalLayers


%get extension
[pathstr,name,ext] = fileparts(imgOutDir);
if (~(7==exist(pathstr,'dir')))
   mkdir(pathstr); 
end

%get image size
szImg = size(img);

%resize image.
if params.isResize(1)
    img = imresize(img,params.isResize(2),'bilinear');
end

postResSzImg = size(img);

%smooth image with specified kernels
%for denosing
img = imfilter(img,fspecial('gaussian',params.filter0Params(1:2),params.filter0Params(3)),'replicate');        

%for a very smooth image, a "broad stroke" of the image
imgSmo = imfilter(img,fspecial('gaussian',params.filterParams(1:2),params.filterParams(3)),'replicate');

% create adjacency matrices and its elements base on the image.
[params.adjMatrixW, params.adjMatrixMW, params.adjMA, params.adjMB, params.adjMW, params.adjMmW, imgNew] = getAdjacencyMatrix(img);

% % [this is not used as the moment] Create adjacency matrices and its elements based on the smoothed image.
% [params.adjMatrixWSmo, params.adjMatrixMWSmo, params.adjMA, params.adjMB, params.adjMWSmo, params.adjMmWSmo, ~] = getAdjacencyMatrix(imgSmo);

% obtain rough segmentation of the ilm and isos, then find the retinal
% layers in the order of 'retinalLayerSegmentationOrder'
%%vvvvvvvvvvvvvvvDO  NOT  CHANGE BELOW LINE (ORDER OF LAYERS SHALL NOT BE CHANGED)vvvvvvvvvvvvvv%%
retinalLayerSegmentationOrder = {'roughILMandISOS' 'ilm' 'isos' 'rpe' 'inlopl' 'nflgcl' 'iplinl' 'oplonl'};
%%^^^^^^^^^^^^^^^DO  NOT  CHANGE ABOVE LINE (ORDER OF LAYERS SHOULD NOT BE CHANGED)^^^^^^^^^^^^^%%
% segment retinal layers
retinalLayers = [];
for layerInd = 1:numel(retinalLayerSegmentationOrder)        
    [retinalLayers, ~] = getRetinalLayersCore(retinalLayerSegmentationOrder{layerInd},imgNew,params,retinalLayers);
end

%delete elements of the adjacency matrices prior function exit to save memory
toBeDeleted = {'adjMatrixWSmo' 'adjMatrixMWSmo' 'adjMWSmo' 'adjMmWSmo'  'adjMW' 'adjMmW' 'adjMatrixW' 'adjMatrixMW' 'adjMA' 'adjMB'};
for delInd = 1:numel(toBeDeleted)
    params.(toBeDeleted{delInd}) = [];
end


% plot oct image and the obtained retinal layers.
isPlot = 1;
if isPlot
    
    imagesc(img);
%     figure;
%     imshow(img);
    axis image; colormap('gray'); hold on; drawnow;
    imageLayers = {};
    
    if (bitget(flagplot, 1))
    imageLayers = [imageLayers, 'rpe'];
    end
    if (bitget(flagplot, 2))
        imageLayers = [imageLayers, 'isos'];
    end
    if (bitget(flagplot, 3))
        imageLayers = [imageLayers, 'oplonl'];
    end
    if (bitget(flagplot, 4))
        imageLayers = [imageLayers, 'inlopl'];
    end
    if (bitget(flagplot, 5))
        imageLayers = [imageLayers, 'iplinl'];
    end
    if (bitget(flagplot, 6))
        imageLayers = [imageLayers, 'nflgcl'];
    end
    if (bitget(flagplot, 7))
        imageLayers = [imageLayers, 'ilm'];
    end
    layersToPlot = imageLayers;
    %layersToPlot = {'ilm' 'isos' 'rpe' 'inlopl' 'nflgcl' 'iplinl' 'oplonl'};% 'rpeSmooth'}; %
    hOffset =       [40    0      -40    0        0        40       -40      -40]; % for displaying text

    for k = 1:numel(layersToPlot)
        matchedLayers = strcmpi(layersToPlot{k},{retinalLayers(:).name});
        layerToPlotInd = find(matchedLayers == 1);
        if ~isempty(retinalLayers(layerToPlotInd).pathX)
            %weight = img(1, intentar coger la parte de weight que nos
            %interesa de la imagen
            v = retinalLayers(layerToPlotInd).pathY([1,diff(retinalLayers(layerToPlotInd).pathY)]~=0);
            x = find(retinalLayers(layerToPlotInd).pathY==v(end),1);
            a = x - v(end)+1;
            y = x - (x - postResSzImg(2)-1);
            v = v(1:y);
            b = a-1+y;
            retinalLayers(layerToPlotInd).a = a;
            retinalLayers(layerToPlotInd).b = b;
            %b = x
            %plot(v,retinalLayers(retinalLayers(layerToPlotInd).a-1,'-','color','g','linewidth',3.5);
             plot(v,retinalLayers(layerToPlotInd).pathX(a:b)-1,'-','color','g','linewidth',1.5);
             row = v;
             colum = retinalLayers(layerToPlotInd).pathX(a:b)-1;

             if strcmpi(layersToPlot{k},'rpe')
%                  RPE = poly2mask(row,colum,m,MAXCOLUM);
                  for z=1:MAXCOLUM
                    RPE(colum(z),row(z)) = 1;
                  end   
             end    
%              if strcmpi(layersToPlot{k},'oplonl')
%                  for z=1:MAXCOLUM
%                     OPLONL(colum(z),row(z)) = 1;
%                  end
%              end
             if strcmpi(layersToPlot{k},'ilm') 
                 for z=1:MAXCOLUM
                    ILM(colum(z),row(z)) = 1;
                 end
             end     
            plotInd = round(numel(retinalLayers(layerToPlotInd).pathX)/2);
            %Show tag for layer name
            %text(retinalLayers(layerToPlotInd).pathY(plotInd)+hOffset(k),retinalLayers(layerToPlotInd).pathX(plotInd)+params.txtOffset,retinalLayers(layerToPlotInd).name,'color',colora,'linewidth',2);            
            drawnow;
            %set(gcf,'units','normalized','outerposition',[0 0 1 1]);
        end % of if ~isempty            
    end % of k
    
    
    switch (ext)
        case '.png'
%             figure;
%             imshow(imgOutDir);
%             pause(5);
            print(imgOutDir,'-dpng');
        case '.bmp'
            print(imgOutDir,'-dbmp');
        case '.jpg'
            print(imgOutDir,'-djpeg');
        case '.tif'
            print(imgOutDir,'-dtiff');
        otherwise
            print(imgOutDir,'-djpeg');
    end
   % hold off;
  pause(5);
end % of isPlot        
