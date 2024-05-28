function [imgFeat, imgPwinOrd, imgDiff] = sugeno_old(img,tamW,measureWeights)

imgP=padarray(img,[floor(tamW/2) floor(tamW/2)],'symmetric');

[~,imgPwin] = im2col_3D_sliding_v1(imgP,[tamW tamW],[1 1]);

imgPwin(round(size(imgPwin,1)/2),:,:,:) = [];
if (size(img,3)>1)
    imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[4 1 2 3])));
else
    imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[3 1 2])));
end

imgPwinOrd=sort(imgDiff,1,'ascend');

agg = max(bsxfun(@min,imgPwinOrd,measureWeights));

if (size(img,3)>1)
    imgFeat=permute(agg,[2 3 4 1]);
else
    imgFeat=permute(agg,[2 3 1]);
end
% imgFeat=imgFeat./max(imgFeat(:));

end
