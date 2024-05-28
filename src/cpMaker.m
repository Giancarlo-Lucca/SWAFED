

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Comparison Maker (cpMaker)\n------\n');

%Timing matters

numImages=0;


imagesFrom=max(1,Experiment.imagesFrom);
imagesTo=min(length(imagesList),Experiment.imagesTo);

classicMethodNum = sum(ismember(Experiment.config.featureMethod,{'canny','fuzzyM','ged','SF'}));
if (any(ismember(Experiment.config.featureMethod,{'ged'})) && length(Experiment.config.feat.ged.F) > 1)
    classicMethodNum = classicMethodNum + 1;
end

if any(ismember(Experiment.config.featureMethod,{'dCF'}))
    propMethodNum = Experiment.numRes/length(Experiment.smoothingMethod);
else
    propMethodNum = 0;
end

for idxTam = 1:size(Experiment.tamW,2)
    measureWeights = [];
    
    for idxMeasureType = 1:size(Experiment.config.measure,2)
    
        measureType = Experiment.config.measure{1,idxMeasureType};
        
        measureWeights = [measureWeights measure(measureType,Experiment.params.measure,Experiment.params.measure.tam(idxTam))];
    end
    
    measureWeights(1,:) = []; % Remove first measure weight
    
    listEmpty = {};
    
    % Experiment.numRes = Experiment.numRes/length(Experiment.smoothingMethod);
    
    time = zeros(imagesTo-imagesFrom,1);
    
    for idxSmoothingMethod=1:length(Experiment.smoothingMethod)
        
        totalTall = 0;
        imgDone = 0;
    
        cpAll = cell(propMethodNum+classicMethodNum,3,imagesTo-imagesFrom+1);
    
    %     if (length(Experiment.config.featureMethod) > 1)
    %         cpAll = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,3,imagesTo-imagesFrom+1);
    %     else
    %         cpAll = cell((Experiment.numRes/length(Experiment.smoothingMethod)),3,imagesTo-imagesFrom+1);
    %     end
    
        smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
        if (strcmp(smoothingMethod,'mshift'))
            config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
        elseif(strcmp(smoothingMethod,'gauss'))
            config=sigma2name(Experiment.gauss.sigma);
        elseif(strcmp(smoothingMethod,'grav'))
            config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
        end
        
        cpAllFileName = sprintf('%s[%d-%d]-%s-[%s]',Experiment.cpPrefix,imagesFrom,imagesTo,smoothingMethod,config);
        cpAllDataFilePath = sprintf('%s%s.%s',Experiment.cpDir,cpAllFileName,Experiment.dataExt);
    
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
    
            bdryFileName = cell(propMethodNum+classicMethodNum,1);
            cpFileName = cell(propMethodNum+classicMethodNum,1);
    
    %         if (length(Experiment.config.featureMethod) > 1)
    %             bdryFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,1);
    %             cpFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,1);
    %         else
    %             bdryFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod)));
    %             cpFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod)));
    %         end
            for idxFeat = 1:length(Experiment.config.featureMethod)
        	    featureMethod = Experiment.config.featureMethod{idxFeat};
    %             fprintf('\n\t Feature extraction method: %s ...\n',featureMethod);
                if (strcmp(featureMethod,'dCF'))
            
                    for idxDis = 1:length(Experiment.config.feat.dCF.Dis)
                        for idxGen = 1:length(Experiment.config.feat.dCF.Gen)
    
                            for idxMeasureType = 1:size(Experiment.config.measureComplete,2)
    %                             for idxTam = 1:size(Experiment.tamW,2)
        
                                    measureType = Experiment.config.measureComplete{1,idxMeasureType};
                                    mW = measureWeights(:,idxMeasureType);
                                    Dis = Experiment.config.feat.dCF.Dis{idxDis};
                                    Gen = Experiment.config.feat.dCF.Gen{idxGen};
                                    tamW = Experiment.tamW(idxTam);
            
                                    bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-g-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,Dis,Gen,tamW)};
                                    cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-g-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,Dis,Gen,tamW)};
                                    idxRes = idxRes+1;

                                    
    %                             end
                            end
                        end
                    end
                elseif (strcmp(featureMethod,'canny'))
                    bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma))};
                    cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma))};
                    idxRes = idxRes+1;
                elseif (strcmp(featureMethod,'fuzzyM'))
                    bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3})};
                    cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3})};
                    idxRes = idxRes+1;
                elseif (strcmp(featureMethod,'ged'))
                    for idxGedFunc = 1:length(Experiment.config.feat.ged.F)
                        bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode)};
                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode)};
                        idxRes = idxRes+1;
                    end
                elseif (strcmp(featureMethod,'SF'))
                    bdryFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod)};
                    cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod)};
                    idxRes = idxRes+1;
                end
            end
            idxRes = 1;
            for idxCpDataFile=1:length(cpFileName)
                
                
                bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName{idxCpDataFile},Experiment.dataExt);
                cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName{idxCpDataFile},Experiment.dataExt);
    
                
    
                tic;
                if ((~exist(cpDataFilePath,'file')) || (Experiment.forceCpMaker==1))

                    data = load(bdryDataFilePath);
                    imgBdry = data.imgBdry; 
    
                    imgBdry = logical(imgBdry./255);
    
                    res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
    
                    save(cpDataFilePath,'res');
    
                else
                    data = load(cpDataFilePath);
                    res = data.res;
                end
                resMean = mean(res,1);
                resSorted = sortrows(res,3);
                resMax = resSorted(end,:);
           
                expConfig = extractBetween(string(cpDataFilePath),"]-",".mat");
                cpAll(idxRes,:,idxImagesList) = {expConfig resMax resMean};
    
                thisT=toc;
                totalT = totalT + thisT;
                msg = sprintf('\tBdry image: %d / %d, time = %.2f secs (est. %s)\n', idxRes,Experiment.numRes,thisT,timeToName(thisT*(Experiment.numRes-idxRes)));
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));                    
                idxRes = idxRes+1;
            end
            totalTall = totalTall + totalT;
            imgDone = imgDone +1;
            fprintf('\t done (%s) (est. %s)\n',timeToName(totalT),timeToName((totalTall/imgDone)*(imagesTo-imagesFrom-imgDone-1)));
        end
        cpAll = [cpAll(:,1,1) num2cell(mean(cell2mat(cpAll(:,2,:)),3),[size(cpAll,1) 3]) num2cell(mean(cell2mat(cpAll(:,3,:)),3),[size(cpAll,1) 3])];
        if ~exist(cpAllDataFilePath,'file')
            save(cpAllDataFilePath,'cpAll','Experiment');
        end
    end
end
