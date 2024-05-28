function [imgFeat] = dXCF1F2(img,tamW,F1agg,F2agg,dissim,measureWeights)

% img=gaussianSmooth(img,Sigma);
% [f,c] = size(img);
% Sal=zeros(f,c);

% imgP=padarray(img,[floor(tamW/2) floor(tamW/2)],'symmetric');
% 
% [~,imgPwin] = im2col_3D_sliding_v1(imgP,[tamW tamW],[1 1]);

% imgPwin(round(size(imgPwin,1)/2),:,:,:) = [];
% imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[3 1 2])));
% if (size(img,3)>1)
%     imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[4 1 2 3])));
% else
%     imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[3 1 2])));
% end

imgDiff = abs(extractfuzzyFeatures(img, floor(tamW/2)));
imgDiff = permute(imgDiff,[4 1 2 3]);

imgPwinOrd=sort(imgDiff,1,'ascend');

N = size(imgDiff,1);

dxCmF1F2 = min(1,imgPwinOrd(1,:,:,:).*measureWeights(1) + sum(dSM(Fagg(imgPwinOrd(2:N,:,:,:),measureWeights(2:end),F1agg),Fagg(imgPwinOrd(1:N-1,:,:,:),measureWeights(2:end),F2agg),dissim),1));

if (size(img,3)>1)
    imgFeat=permute(dxCmF1F2,[2 3 4 1]);
else
    imgFeat=permute(dxCmF1F2,[2 3 1]);
end
% imgFeat=imgFeat./max(imgFeat(:));

end
