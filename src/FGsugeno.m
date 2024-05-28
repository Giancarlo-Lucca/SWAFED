function [imgFeat] = FGsugeno(img,tamW,funcF,funcG,measureWeights)

imgDiff = abs(extractfuzzyFeatures(img, floor(tamW/2)));
imgDiff = permute(imgDiff,[4 1 2 3]);

imgPwinOrd=sort(imgDiff,1,'ascend');

N = size(imgDiff,1);

%dxCmF1F2 = min(1,imgPwinOrd(1,:,:,:).*measureWeights(1) + sum(dSM(Fagg(imgPwinOrd(2:N,:,:,:),measureWeights(2:end),F1agg),Fagg(imgPwinOrd(1:N-1,:,:,:),measureWeights(2:end),F2agg),dissim),1));

if strcmp(funcF,'max')
    agg = max(Fagg(imgPwinOrd, measureWeights, funcG));
elseif strcmp(funcF,'sum')
    agg = sum(Fagg(imgPwinOrd, measureWeights, funcG));
elseif strcmp(funcF,'Fi')
    valG = Fagg(imgPwinOrd, measureWeights, funcG);
    agg = 1 - sqrt(prod(1 - valG) .* min(1 - valG));
elseif strcmp(funcF,'DivFi')
    valG = Fagg(imgPwinOrd, measureWeights, funcG);
    agg = max(valG)./(max(valG) + (prod(1 - valG)).^(1/N));
end

if (size(img,3)>1)
    imgFeat=permute(agg,[2 3 4 1]);
else
    imgFeat=permute(agg,[2 3 1]);
end
% imgFeat=imgFeat./max(imgFeat(:));

end
