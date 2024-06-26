function [imgs, imgsF]=gravitationalSmoothingEntropy(im,iterations,params)

%
%
% params.GConst=0.1
% params.maxDist=5
% params.colorFactor=1
% params.colorMetric='hau'
% params.posMetric='euc'
%

METRIC_CODE_EUC=1;
METRIC_CODE_HAU=2;

[G_CONST,MAX_DIST,COLOR_FACTOR,COLOR_METRIC,POS_METRIC]=parameterProcessing(params);

if strcmp(COLOR_METRIC,'euc')
    COLOR_METRIC_CODE=METRIC_CODE_EUC;
elseif strcmp(COLOR_METRIC,'hau')
    COLOR_METRIC_CODE=METRIC_CODE_HAU;
end


NUM_CHANNELS=size(im,3);

% Data matrices
[mask,eucDistMap]=makeRadialDist(MAX_DIST,POS_METRIC);
mask(MAX_DIST+1,MAX_DIST+1)=0;

% mask2 = mask;
% mask2(MAX_DIST+1,MAX_DIST+1)=-1;



[maskPosR,maskPosC]=find(mask==1);

% colorDiff = zeros([size(im,1) size(im,2) length(maskPosR) size(im,3)]);


imgs=zeros(size(im,1),size(im,2),size(im,3),length(iterations));
imgsF=zeros(size(im,1),size(im,2),size(im,3),length(iterations));
currentImage=im;
currentImageF=zeros(size(im));
varMatrix2=zeros(size(im));

clear('im');

% currentImage = imnoise(currentImage,'gaussian',0.1,0.03);
imageOrig=currentImage;

% currentImage = imnoise(currentImage,'speckle');
% imageOrig=currentImage;


maskArray=repmat(mask,[1 1 length(maskPosR)]);
b=uint8([maskPosR maskPosC (1:length(maskPosR))']);
c=sub2ind(size(maskArray),b(:,1),b(:,2),b(:,3));
d=setdiff(1:size(maskArray(:),1),c);
maskArray(d)=0;
aDist=eucDistMap.*maskArray;
aDist=aDist(aDist~=0);
% maskArray(MAX_DIST+1,MAX_DIST+1,:)=-1;

[m,n,r]=size(currentImage);
imgP=padarray(currentImage,[MAX_DIST MAX_DIST],'replicate');
[~,~,idxPwin] = im2col_3D_sliding_v1(imgP,[2*MAX_DIST+1 2*MAX_DIST+1],[1 1],mask);

% c = reshape(1:154401,[481 321]);
% d = padarray(c,[MAX_DIST MAX_DIST],'replicate');
% e = d(idxPwin);

reverseStr = '';

entOrig = entropy (currentImage);

for idxIt=1:max(iterations)

%     varMatrix=zeros(size(currentImage));
    
    tic;

    imgP=padarray(currentImage,[MAX_DIST MAX_DIST],'replicate');
    imgPwin = imgP(idxPwin);

    colorDiff = bsxfun(@minus,imgPwin,permute(reshape(currentImage,[m*n r]),[3 1 2]));
    
    if (COLOR_METRIC_CODE==METRIC_CODE_EUC)
        colorDist=sqrt(sum(colorDiff.^2,3)).*COLOR_FACTOR;
    elseif(COLOR_METRIC_CODE==METRIC_CODE_HAU)
        colorDist=max(abs(colorDiff),[],3).*COLOR_FACTOR;
    else
        error('Error at gravitationalSmoothin.m> Unknown color distance [%s]\n',COLOR_METRIC)
    end
    
    distFactorMap=G_CONST./((bsxfun(@plus,colorDist,aDist)).^2);

    varMatrix=bsxfun(@times,colorDiff,distFactorMap);

    varMatrix = reshape(sum(varMatrix,1),[m n r]);
%     varMatrix = sum(varMatrix,1);
%     imgPwin = imgPwin + varMatrix(e);
    
%     varMatrix2 = reshape(varMatrix,[m n r]);
    
    
    t = toc;
    
    currentImage=currentImage+varMatrix;
    currentImageF=currentImageF+varMatrix;

    a=find(iterations==idxIt);
    if (~isempty(a))
        imgs(:,:,:,a)=currentImage;
        imgsF(:,:,:,a)=currentImageF;
    end

    msg = sprintf('Smoothing step: %d / %d, time = %.2f secs\n', idxIt,max(iterations),t);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));

    ent = entropy (double(currentImage));
    if (abs(entOrig - ent) > 0.05)
        break;
    end
    entOrig = ent;
end




function [gConst,maxDist,colorFactor,colorMetric,posMetric] =parameterProcessing(p)

% MIN_DISTANCE_INFLUENCE_FACTOR=0.09;
% maxDist=round(sqrt(1/MIN_DISTANCE_INFLUENCE_FACTOR));

if isfield(p,'minDistInfFactor')
    MIN_DISTANCE_INFLUENCE_FACTOR=p.minDistInfFactor;
else
    MIN_DISTANCE_INFLUENCE_FACTOR=0.02;
end

maxDist=round(sqrt(1/MIN_DISTANCE_INFLUENCE_FACTOR));

if isfield(p,'gConst')
    gConst=p.gConst;
else
    gConst=0.1;
end


if isfield(p,'colorFactor')
    colorFactor=p.colorFactor;
else
    colorFactor=1;
end

if isfield(p,'colorMetric')
    colorMetric=p.colorMetric;
else
    colorMetric='hau';
end

if isfield(p,'posMetric')
    posMetric=p.posMetric;
else
    posMetric='euc';
end

end

end


