function [fuzzyFeatures,dist] = extractfuzzyFeatures(img,maxDist, grad, includecenter)

if (nargin == 1)
    maxDist = 1;
    grad = 1;
    includecenter = 0;
elseif (nargin == 2)
    grad = 1;
    includecenter = 0;
elseif (nargin == 3)
    includecenter = 0;
end

mask = ones(2*maxDist+1);
if (~includecenter)
    mask(maxDist+1,maxDist+1)=0;
end
[maskPosR,maskPosC]=find(mask==1);
maskArray=repmat(mask,[1 1 length(maskPosR)]);
b=uint8([maskPosR maskPosC (1:length(maskPosR))']);
c=sub2ind(size(maskArray),b(:,1),b(:,2),b(:,3));
d=setdiff(1:size(maskArray(:),1),c);
maskArray(d)=0;
maskArray = permute(repmat(maskArray,[1 1 1 1]),[1 2 4 3]);

dist = bwdist(1-mask,'chessboard');
dist = dist(:);
dist(round(length(dist)/2)) = [];
% maskArraySel = maskArray(:,:,:,dist==distRing);


imgPad = padarray(img,[maxDist maxDist],'symmetric');
imgPad2 = padarray(img,[2*maxDist 2*maxDist],'symmetric');
if grad
    fuzzyFeatures = imfilter(imgPad,maskArray,'full') - imgPad2;
else
    fuzzyFeatures = imfilter(imgPad,maskArray,'full');
end
fuzzyFeatures = fuzzyFeatures(2*maxDist+1:end-2*maxDist,2*maxDist+1:end-2*maxDist,:,:);

end