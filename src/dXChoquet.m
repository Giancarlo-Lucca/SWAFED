function [imgFeat, imgFeatx, imgFeaty] = dXChoquet(img,tamW,F,m)

% img=gaussianSmooth(img,Sigma);
% [f,c] = size(img);
% Sal=zeros(f,c);

imgP=padarray(img,[floor(tamW(1)/2) floor(tamW(2)/2)],'symmetric');

[~,imgPwin] = im2col_3D_sliding_v1(imgP,[tamW(1) tamW(2)],[1 1]);

imgPwin(round(size(imgPwin,1)/2),:,:,:) = [];
if (size(img,3)>1)
    imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[4 1 2 3])));
else
    imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[3 1 2])));
end

imgPwinOrd=sort(imgDiff,1,'ascend');

ang = deg2rad([135 90 45 180 0 225 270 315])';
imgDiffCompX = sort(bsxfun(@times,imgDiff,cos(ang)),1,'ascend');
imgDiffCompY = sort(bsxfun(@times,imgDiff,sin(ang)),1,'ascend');

% N = size(imgPwin,1);
% m = measure(N,q);

% m = OWAwi(0.3,0.8,7);
% m = fliplr(m);


dXC = imgPwinOrd(1,:,:,:) + sum(RDF(imgPwinOrd,m,F));

if (size(img,3)>1)
    imgFeat=permute(dXC,[2 3 4 1]);
    dXCx = permute(imgDiffCompX(1,:,:,:) + sum(RDF(imgDiffCompX,m,F)),[2 3 4 1]);
    dXCy = permute(imgDiffCompY(1,:,:,:) + sum(RDF(imgDiffCompY,m,F)),[2 3 4 1]);
else
    imgFeat=permute(dXC,[2 3 1]);
    dXCx = permute(imgDiffCompX(1,:,:) + sum(RDF(imgDiffCompX,m,F)),[2 3 1]);
    dXCy = permute(imgDiffCompY(1,:,:) + sum(RDF(imgDiffCompY,m,F)),[2 3 1]);
end

imgFeat=imgFeat./max(imgFeat(:));
imgFeatx = dXCx./max(dXCx(:));
imgFeaty = dXCy./max(dXCy(:));

end
