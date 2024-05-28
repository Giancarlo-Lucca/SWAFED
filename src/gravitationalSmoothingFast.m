function [imgs, imgsF]=gravitationalSmoothingFast(im,iterations,params)

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

[maskPosR,maskPosC]=find(mask==1);

imgs=zeros(size(im,1),size(im,2),size(im,3),length(iterations));
imgsF=zeros(size(im,1),size(im,2),size(im,3),length(iterations));
currentImage=im;
currentImageF=zeros(size(im));
varMatrix2=zeros(size(im));

clear('im');

imageOrig=currentImage;

maskArray=repmat(mask,[1 1 length(maskPosR)]);
b=uint8([maskPosR maskPosC (1:length(maskPosR))']);
c=sub2ind(size(maskArray),b(:,1),b(:,2),b(:,3));
d=setdiff(1:size(maskArray(:),1),c);
maskArray(d)=0;
aDist=eucDistMap.*maskArray;
aDist=aDist(aDist~=0);

% maskArray2 = permute(repmat(maskArray,[1 1 1 1]),[1 2 4 3]);
% imgP=padarray(currentImage,[MAX_DIST MAX_DIST],'replicate');

mask2 = maskArray;
mask2(MAX_DIST+1,MAX_DIST+1,:)=-1;
mask2 = permute(repmat(mask2,[1 1 1 1]),[1 2 4 3]);
eucDistMap2 = eucDistMap.*mask;
eucDistVec = eucDistMap2(eucDistMap2~=0);
eucDistVec = permute(eucDistVec,[4 3 2 1]);

% maskMean = mask;
% maskMean(MAX_DIST+1,MAX_DIST+1)=1;
% maskMean(maskMean==1) = 1/sum(maskMean(:));


reverseStr = '';


for idxIt=1:max(iterations)

    tic;
   
%     colorDiffR = imfilter(currentImage(:,:,1),mask2,'full');
%     colorDiffG = imfilter(currentImage(:,:,2),mask2,'full');
%     colorDiffB = imfilter(currentImage(:,:,3),mask2,'full');
%     colorDiff = cat(4,colorDiffR,colorDiffG,colorDiffB);
    colorDiff = imfilter(padarray(currentImage,[MAX_DIST MAX_DIST],'symmetric'),mask2,'full');
%     imgW = imfilter(currentImage,maskArray2,'full');
%     colDiff = imgP-imgW;
%     colorMean = imfilter(currentImage,maskMean,'symmetric');
    
    if (COLOR_METRIC_CODE==METRIC_CODE_EUC)
%         colorDist = sqrt(colorDiffR.^2 + colorDiffG.^2 + colorDiffB.^2) .* COLOR_FACTOR;
        colorDist=sqrt(sum(colorDiff.^2,3)).*COLOR_FACTOR;
%         colorDist = TSdistance(imgP,imgW).*COLOR_FACTOR;
    elseif(COLOR_METRIC_CODE==METRIC_CODE_HAU)
%         colorDiff = cat(4,colorDiffR,colorDiffG,colorDiffB);
        colorDist=max(abs(colorDiff),[],3).*COLOR_FACTOR;
    else
        error('Error at gravitationalSmoothin.m> Unknown color distance [%s]\n',COLOR_METRIC)
    end
    
%     colorDist = permute(colorDist,[1 2 4 3]);
    distFactorMap = G_CONST./(eucDistVec + colorDist).^2;
    
%     varMatrix=bsxfun(@times,colorDiff,distFactorMap);
%     varMatrixR = sum(colorDiffR .* distFactorMap,3);
%     varMatrixG = sum(colorDiffG .* distFactorMap,3);
%     varMatrixB = sum(colorDiffB .* distFactorMap,3);
%     varMatrix = cat(3,varMatrixR,varMatrixG,varMatrixB);
%     varMatrix=permute(sum(bsxfun(@times,permute(colorDiff,[1 2 4 3]),distFactorMap),3),[1 2 4 3]);
    varMatrix = sum(colorDiff.*distFactorMap,4);
    varMatrix = varMatrix(2*MAX_DIST+1:end-2*MAX_DIST,2*MAX_DIST+1:end-2*MAX_DIST,:);
    

    t = toc;
    
    currentImage=currentImage+varMatrix;

    a=find(iterations==idxIt);
    if (~isempty(a))
        imgs(:,:,:,a)=currentImage;
        imgsF(:,:,:,a)=varMatrix;
    end

    msg = sprintf('Smoothing step: %d / %d , time = %.2f secs (est. %s), MAX_DIST = %d\n', idxIt,max(iterations),t,timeToName(t*(max(iterations)-idxIt)),MAX_DIST);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));

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


