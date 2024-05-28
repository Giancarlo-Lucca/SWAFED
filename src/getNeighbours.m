function imgNeig = getNeighbours(img,maxDist)

mask = ones(2*maxDist+1);
mask(maxDist+1,maxDist+1)=0;
[maskPosR,maskPosC]=find(mask==1);
maskArray=repmat(mask,[1 1 length(maskPosR)]);
b=uint8([maskPosR maskPosC (1:length(maskPosR))']);
c=sub2ind(size(maskArray),b(:,1),b(:,2),b(:,3));
d=setdiff(1:size(maskArray(:),1),c);
maskArray(d)=0;
maskArray = permute(repmat(maskArray,[1 1 1 1]),[1 2 4 3]);

imgPad = padarray(img,[maxDist maxDist]);
imgNeig = imfilter(img,maskArray,'full') - imgPad;
imgNeig = imgNeig(maxDist+1:end-maxDist,maxDist+1:end-maxDist,:,:);

end
