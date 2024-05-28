function valsVector=ComparisonResiduals(emName,bnImage,gtImages,Dist)

% valsVector=zeros(1,size(gtImages,3));
% if(~isempty(contains(emName,'DilbCM-F')))
if(contains(emName,'DilbCM-F'))
    emParams.structEl = sprintf('circ-%f',Dist);
    valsVector=zeros(size(gtImages.groundTruth,2),3);
    for idGTruthImage=1:size(gtImages.groundTruth,2)
        solution=gtImages.groundTruth{1,idGTruthImage}.Boundaries;
        [~,residuals]=areaBasedBinaryImageCM(solution,bnImage,emParams);
        valsVector(idGTruthImage,:)=[residuals.prec residuals.rec residuals.F];
    end
% elseif(~isempty(contains(emName,'DistbCM-F')))
elseif(contains(emName,'DistbCM-F'))
    emParams.dist = sprintf('auc-%f',Dist);
    valsVector=zeros(size(gtImages.groundTruth,2),3);
    for idGTruthImage=1:size(gtImages.groundTruth,2)
        solution=gtImages.groundTruth{1,idGTruthImage}.Boundaries;
        [~,residuals]=distanceBasedConfusionMatrix(solution,bnImage,emParams);
        valsVector(idGTruthImage,:)=[residuals.prec residuals.rec residuals.F];
    end
% elseif(~isempty(contains(emName,'csaBCM-F')))
elseif(contains(emName,'csaBCM-F'))
    emParams.maxDist = Dist;
    valsVector=zeros(size(gtImages.groundTruth,2),3);
    for idGTruthImage=1:size(gtImages.groundTruth,2)
        solution=gtImages.groundTruth{1,idGTruthImage}.Boundaries;
        [~,residuals]=csaBasedConfusionMatrix(solution,bnImage,emParams);
        valsVector(idGTruthImage,:)=[residuals.prec residuals.rec residuals.F];
    end
% elseif(~isempty(contains(emName,'EJMbCM-F')))
elseif(contains(emName,'EJMbCM-F'))
    emParams.maxDist = Dist;
    valsVector=zeros(size(gtImages.groundTruth,2),3);
    for idGTruthImage=1:size(gtImages.groundTruth,2)
        solution=gtImages.groundTruth{1,idGTruthImage}.Boundaries;
%         [~,residuals]=ejmBasedBinaryImageCM(solution,bnImage,emParams);
        [~,residuals]=ejmBasedConfusionMatrix(solution,bnImage,emParams);
        valsVector(idGTruthImage,:)=[residuals.prec residuals.rec residuals.F];
    end
else
    error('Unknown error measure [%s]',emName);
end

