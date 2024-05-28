function [imgFeat, imgDiff] = dCF(img,tamW,Dis,Gen,m,q)
% function [imgFeat, imgFeatx, imgFeaty] = dCF(img,tamW,Dis,Gen,m)

% img=gaussianSmooth(img,Sigma);
% [f,c] = size(img);
% Sal=zeros(f,c);

%-------------------------------------------------------------------
%                                 OLD
%-------------------------------------------------------------------

% imgP=padarray(img,[floor(tamW/2) floor(tamW/2)],'symmetric');
% 
% [~,imgPwin] = im2col_3D_sliding_v1(imgP,[tamW tamW],[1 1]);
% 
% imgPwin(round(size(imgPwin,1)/2),:,:,:) = [];
% if (size(img,3)>1)
%     imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[4 1 2 3])));
% else
%     imgDiff = abs(bsxfun(@minus,imgPwin,permute(img,[3 1 2])));
% end
% 
% imgPwinOrd=sort(imgDiff,1,'ascend');

%-------------------------------------------------------------------

imgDiff = abs(extractfuzzyFeatures(img, floor(tamW/2)));
imgDiff = permute(imgDiff,[4 1 2 3]);

imgPwinOrd=sort(imgDiff,1,'ascend');

% ang = deg2rad([135 90 45 180 0 225 270 315])';
% imgDiffCompX = sort(bsxfun(@times,imgDiff,cos(ang)),1,'ascend');
% imgDiffCompY = sort(bsxfun(@times,imgDiff,sin(ang)),1,'ascend');

% N = size(imgPwin,1);
% m = measure(N,q);

% m = OWAwi(0.3,0.8,7);
% m = fliplr(m);



if (ischar(m) && contains(m,'adaptative'))
    adaptF = extractAfter(m,'adaptative-');
    N = tamW.^2 - 1;
    if (strcmp(adaptF,'max'))
        q = max(imgPwinOrd,[],1);
    elseif (strcmp(adaptF,'min'))
        q = min(imgPwinOrd,[],1);
    elseif (strcmp(adaptF,'prod'))
        q = prod(imgPwinOrd,1);
    elseif (strcmp(adaptF,'mean'))
        q = mean(imgPwinOrd,1);
    elseif (strcmp(adaptF,'geomean'))
        q = geomean(imgPwinOrd,1);
    elseif (strcmp(adaptF,'harmmean'))
        q = harmmean(imgPwinOrd,1);
    elseif (strcmp(adaptF,'lukasiewicz'))
        q = sum(imgPwinOrd,1)-N-1;
        q(q<0) = 0;
    elseif (strcmp(adaptF,'hamacher'))
        q_sum = sum(imgPwinOrd,1);
        q_prod = prod(imgPwinOrd,1);
        q = q_prod/(q_sum-q_prod);
        q(q<0) = 0;
    elseif (strcmp(adaptF,'ODiv'))
        q = (prod(imgPwinOrd,1)+min(imgPwinOrd,[],1))/N;
    end
    if (size(img,3)>1)
        q = permute(q,[2 3 4 1]);
        m = permute(reshape(bsxfun(@power,((N-1:-1:1)/N),q(:)),[size(q) N-1]), [4 1 2 3]);
    else
        q = permute(q,[2 3 1]);
        m = permute(reshape(bsxfun(@power,((N-1:-1:1)/N),q(:)),[size(q) N-1]), [3 1 2]);
    end
elseif (ischar(m) && contains(m,'adapVec'))
    adaptF = extractAfter(m,'adapVec-');
    N = tamW.^2 - 1;
    imgVec = extractfuzzyFeatures(img, floor(tamW/2), 0, 0);
    imgVec = permute(imgVec,[4 1 2 3]);

    imgVecOrd=sort(imgVec,1,'ascend');
    imgVec = permute(img,[4 1 2 3]);
    q = mean(Fagg(imgVecOrd,imgVec,adaptF),1);
    if (size(img,3)>1)
        q = permute(q,[2 3 4 1]);
        m = permute(reshape(bsxfun(@power,((N-1:-1:1)/N),q(:)),[size(q) N-1]), [4 1 2 3]);
    else
        q = permute(q,[2 3 1]);
        m = permute(reshape(bsxfun(@power,((N-1:-1:1)/N),q(:)),[size(q) N-1]), [3 1 2]);
    end
end

dXC = imgPwinOrd(1,:,:,:) + sum(RDF(imgPwinOrd,m,Dis,Gen,q));

% Experiment.dtDiffColorMap=createColorMap([0.9, 0.9, 0.9],...
%                                          [0.14, 0.12, 0.1],...
%                                          [0.92, 0.37, 0],...
%                                          256);
% 
% aa = cat(1,imgPwinOrd(1,:,:,:),RDF(imgPwinOrd,m,Dis,Gen,q));
% for idxDir=1:size(aa,1)
%     aa_slice = aa(idxDir,:,:,:);
%     aa_slice = permute(aa_slice./max(aa_slice(:)),[2 3 4 1]);
%     imwrite(ind2rgb(round(sqrt(sum(aa_slice.^2,3)).*255),Experiment.dtDiffColorMap),['/home/cedmarde/Research/ResearchData/11-article-imageStack/test/featIm/29030/ft-29030-gauss-[2-0000]-power-0-1000-dCF-d0-g-hamacher-w-3-dir',num2str(idxDir),'.png'],'png');
% end

if (size(img,3)>1)
    imgFeat=permute(dXC,[2 3 4 1]);
    imgDiff = permute(imgDiff,[2 3 4 1]);
%     dXCx = permute(imgDiffCompX(1,:,:,:) + sum(RDF(imgDiffCompX,m,Dis,Gen)),[2 3 4 1]);
%     dXCy = permute(imgDiffCompY(1,:,:,:) + sum(RDF(imgDiffCompY,m,Dis,Gen)),[2 3 4 1]);
else
    imgFeat=permute(dXC,[2 3 1]);
    imgDiff = permute(imgDiff,[2 3 1]);
%     dXCx = permute(imgDiffCompX(1,:,:) + sum(RDF(imgDiffCompX,m,Dis,Gen)),[2 3 1]);
%     dXCy = permute(imgDiffCompY(1,:,:) + sum(RDF(imgDiffCompY,m,Dis,Gen)),[2 3 1]);
end

%imgFeat=imgFeat./max(imgFeat(:));
% imgFeatx = dXCx./max(dXCx(:));
% imgFeaty = dXCy./max(dXCy(:));

end
