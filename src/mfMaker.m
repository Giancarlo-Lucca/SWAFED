

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n MultiFeature Maker (mfMaker)\n------\n');

%Timing matters

numImages=0;


imagesFrom=max(1,Experiment.imagesFrom);
imagesTo=min(length(imagesList),Experiment.imagesTo);

measureWeights = [];

for idxMeasureType = 1:size(Experiment.config.measure,2)

    measureType = Experiment.config.measure{1,idxMeasureType};
    
    measureWeights = [measureWeights measure(measureType,Experiment.params.measure)];
end

measureWeights(1,:) = []; % Remove first measure weight

listEmpty = {};

Experiment.numRes = Experiment.numRes/length(Experiment.smoothingMethod);

time = zeros(imagesTo-imagesFrom,1);

for idxSmoothingMethod=1:length(Experiment.smoothingMethod)
    
    totalTall = 0;
    imgDone = 0;
    cpAll = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,3,imagesTo-imagesFrom+1);

    smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
    fprintf('\n\t Smoothing method: %s ...\n',smoothingMethod);
    
    if (strcmp(smoothingMethod,'mshift'))
        config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
    elseif(strcmp(smoothingMethod,'gauss'))
        config=sigma2name(Experiment.gauss.sigma);
    elseif(strcmp(smoothingMethod,'grav'))
        config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
    end
    
    cpAllCFileName = sprintf('%s[%d-%d]-%s-[%s]-SF',Experiment.cpPrefix,imagesFrom,imagesTo,smoothingMethod,config);
    cpAllCDataFilePath = sprintf('%s%s.%s',Experiment.cpDir,cpAllCFileName,Experiment.dataExt);

    for idxImagesList=imagesFrom:imagesTo
        idxRes = 1;

        %Read Image
        fullImageName=char(imagesList(idxImagesList));
        rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
        imagePath=strcat(Experiment.orgDir,fullImageName);

        fprintf('\nStarting image %d / %d (%s)...\n',idxImagesList,imagesTo,rawImageName);
        
        reverseStr = '';
        totalT=0;
        
        if (~exist([Experiment.cpDir rawImageName],'dir'))
            mkdir([Experiment.cpDir rawImageName]);
        end

        pathIm = sprintf('%s%s.%s',Experiment.gtBnDir,rawImageName,Experiment.dataExt);
        gtImages=load(pathIm);
       
        ftFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,1);
        bdryFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,1);
        cpFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,1);
        for idxFeat = 1:length(Experiment.config.featureMethod)
        	featureMethod = Experiment.config.featureMethod{idxFeat};
%             fprintf('\n\t Feature extraction method: %s ...\n',featureMethod);
            if (strcmp(featureMethod,'dXC'))
        
                for idxFunc = 1:length(Experiment.config.feat.dXC.F)

                    for idxMeasureType = 1:size(Experiment.config.measureComplete,2)

                        measureType = Experiment.config.measureComplete{1,idxMeasureType};
                        mW = measureWeights(:,idxMeasureType);
                        F = Experiment.config.feat.dXC.F(idxFunc);

                        ftFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-F-%i',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,F)};
                        bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-F-%i',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,F)};
                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-F-%i',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,F)};
                        idxRes = idxRes+1;
                    end
                end
            elseif (strcmp(featureMethod,'canny'))
                ftFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma))};
                bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma))};
                cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma))};
                idxRes = idxRes+1;
            elseif (strcmp(featureMethod,'fuzzyM'))
                ftFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3})};
                bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3})};
                cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3})};
                idxRes = idxRes+1;
            elseif (strcmp(featureMethod,'ged'))
                for idxGedFunc = 1:length(Experiment.config.feat.ged.F)
                    ftFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode)};
                    bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode)};
                    cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode)};
                    idxRes = idxRes+1;
                end
            elseif (strcmp(featureMethod,'SF'))
                ftFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod)};
                bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod)};
                cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod)};
                idxRes = idxRes+1;
            end
        end
        idxRes = 1;
        for idxCpDataFile=1:length(cpFileName)-5
            
            ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName{idxCpDataFile},Experiment.dataExt);
            SFftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName{59},Experiment.dataExt);

            ftCImgFilePath = sprintf('%s%s/%s-SF.%s',Experiment.featImDir,rawImageName,ftFileName{idxCpDataFile},Experiment.imageExt);
            ftCDataFilePath = sprintf('%s%s/%s-SF.%s',Experiment.featImDir,rawImageName,ftFileName{idxCpDataFile},Experiment.dataExt);
            bdryCImgFilePath = sprintf('%s%s/%s-SF.%s',Experiment.bdryDir,rawImageName,bdryFileName{idxCpDataFile},Experiment.imageExt);
            bdryCDataFilePath = sprintf('%s%s/%s-SF.%s',Experiment.bdryDir,rawImageName,bdryFileName{idxCpDataFile},Experiment.dataExt);
            cpCDataFilePath = sprintf('%s%s/%s-SF.%s',Experiment.cpDir,rawImageName,cpFileName{idxCpDataFile},Experiment.dataExt);

            tic;
            
            if ((~exist(ftCImgFilePath,'file')) || (Experiment.forceFtMaker==1) )
                data = load(ftDataFilePath);
                imgFeatDXC = data.imgFeat;

                imgFeatDXC = sqrt(sum(imgFeatDXC.^2,3));
                imgFeatDXC = imgFeatDXC./max(imgFeatDXC(:));

                dataSF = load(SFftDataFilePath);
                imgFeatSF = dataSF.imgFeat;

                imgFeatSF = sqrt(sum(imgFeatSF.^2,3));
                imgFeatSF = imgFeatSF./max(imgFeatSF(:));

                imgFeat = mean(cat(3,imgFeatDXC,imgFeatSF),3);

                imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);

                imwrite(imgFeatColorMap,ftCImgFilePath,'png');
                save(ftCDataFilePath,'imgFeat');
            else
                data = load(ftCDataFilePath);
                imgFeat = data.imgFeat;
            end
            
            if ((~exist(bdryCImgFilePath,'file')) || (Experiment.forceBnMaker==1) )
                [~,imgBdry]=getBoundaries(imgFeat,Experiment.p);
                imwrite(255-imgBdry, bdryCImgFilePath, 'png');
                save(bdryCDataFilePath,'imgBdry');
            else
                data = load(bdryCDataFilePath);
                imgBdry = data.imgBdry;
            end

            if ((~exist(cpCDataFilePath,'file')) || (Experiment.forceCpMaker==1))

                imgBdry = logical(imgBdry./255);
                res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);

                save(cpCDataFilePath,'res');

            else
                data = load(cpCDataFilePath);
                res = data.res;
            end
            resMean = mean(res,1);
            resSorted = sortrows(res,3);
            resMax = resSorted(end,:);
       
            expConfig = extractBetween(string(cpCDataFilePath),"]-",".mat");
            cpAll(idxRes,:,idxImagesList) = {expConfig resMax resMean};

            thisT=toc;
            totalT = totalT + thisT;
            msg = sprintf('\tFt + Bn + Cp image: %d / %d, time = %.2f secs (est. %s - Total est. %s)\n', idxRes,Experiment.numRes,thisT,timeToName(thisT*(Experiment.numRes-idxRes)),timeToName(thisT*Experiment.numRes*(imagesTo-idxImagesList)-idxRes));
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));                    
            idxRes = idxRes+1;
        end
        totalTall = totalTall + totalT;
        imgDone = imgDone +1;
        fprintf('\t done (%s) (est. %s)\n',timeToName(totalT),timeToName((totalTall/imgDone)*(imagesTo-imagesFrom-imgDone-1)));
    end
    cpAll = [cpAll(:,1,1) num2cell(mean(cell2mat(cpAll(:,2,:)),3),[size(cpAll,1) 3]) num2cell(mean(cell2mat(cpAll(:,3,:)),3),[size(cpAll,1) 3])];
    if ~exist(cpAllCDataFilePath,'file')
        save(cpAllCDataFilePath,'cpAll','Experiment');
    end
    fileID = fopen([Experiment.cpDir cpAllCFileName '.txt'],'a+');
	fprintf(fileID,'%20s %8s %8s %8s %8s %8s %8s\n\n','Exp. config','Prec','Rec','F','Prec','Rec','F');
    for idxResAll = 1:size(cpAll,1)
        fprintf(fileID,'%20s  \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f\n',cpAll{idxResAll,:});
        fprintf(fileID,'\n');
    end
    fclose(fileID);
end

