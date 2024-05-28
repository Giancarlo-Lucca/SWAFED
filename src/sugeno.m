function [imgFeat, imgPwinOrd, imgDiff] = sugeno(img,tamW,measureWeights)

imgDiff = abs(extractfuzzyFeatures(img, floor(tamW/2)));
imgDiff = permute(imgDiff,[4 1 2 3]);

imgPwinOrd=sort(imgDiff,1,'ascend');

N = size(imgDiff,1);

%dxCmF1F2 = min(1,imgPwinOrd(1,:,:,:).*measureWeights(1) + sum(dSM(Fagg(imgPwinOrd(2:N,:,:,:),measureWeights(2:end),F1agg),Fagg(imgPwinOrd(1:N-1,:,:,:),measureWeights(2:end),F2agg),dissim),1));

agg = max(bsxfun(@min,imgPwinOrd,measureWeights));

if (size(img,3)>1)
    imgFeat=permute(agg,[2 3 4 1]);
else
    imgFeat=permute(agg,[2 3 1]);
end
% imgFeat=imgFeat./max(imgFeat(:));

end
