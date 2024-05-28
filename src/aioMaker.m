

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n All In One Maker (aioMaker)\n------\n');

%Timing matte29030rs

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

for idxMtype = 1:length(Experiment.params.measure.power.type)

    mAdapt = Experiment.params.measure.power.type{idxMtype};

    if ~isempty(mAdapt)
        Experiment.params.measure.power.useSelected_q = 1;
        Experiment.params.measure.power.selected_q = 1;
        if Experiment.params.measure.power.useSelected_q
            Experiment.params.measure.power.q = Experiment.params.measure.power.selected_q;
        end
    end
    
    for idxTam = 1:size(Experiment.tamW,2)
        tamW = Experiment.tamW(idxTam);
        measureWeights = [];
    
        fprintf('\nStarting window size %d ...\n',tamW);
        
        if (~Experiment.params.measure.power.useSelected_q)
            
            for idxMeasureType = 1:size(Experiment.config.measure,2)
            
                measureType = Experiment.config.measure{1,idxMeasureType};
                
                measureWeights = [measureWeights measure(measureType,Experiment.params.measure,Experiment.params.measure.tam(idxTam))];
            end
        end
        
    %     measureWeights(1,:) = []; % Remove first measure weight
        
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
        
            smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod}{1};
            if (strcmp(smoothingMethod,'mshift'))
                config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
            elseif(strcmp(smoothingMethod,'gauss'))
                Experiment.gauss.sigma=Experiment.smoothingMethod{idxSmoothingMethod}{2};
                config=sigma2name(Experiment.gauss.sigma);
            elseif(strcmp(smoothingMethod,'grav'))
                Experiment.grav.iterations=Experiment.smoothingMethod{idxSmoothingMethod}{2};
                Experiment.grav.minDistInfFactor=Experiment.smoothingMethod{idxSmoothingMethod}{3};
                Experiment.grav.gConst=Experiment.smoothingMethod{idxSmoothingMethod}{4};
                Experiment.grav.colorFactor=Experiment.smoothingMethod{idxSmoothingMethod}{5};
                config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
            end
            
            cpAllFileName = sprintf('%s[%d-%d]-%s-[%s]-w-%d',Experiment.cpPrefix,imagesFrom,imagesTo,smoothingMethod,config,tamW);
            cpAllDataFilePath = sprintf('%s%s.%s',Experiment.cpDir,cpAllFileName,Experiment.dataExt);
        
            for idxImagesList=imagesFrom:imagesTo
                idxRes = 1;
        
                %Read Image
                fullImageName=char(imagesList(idxImagesList));
                rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
                imagePath=strcat(Experiment.orgDir,fullImageName);
        
                fprintf('\nStarting image %d / %d (%s)...\n',idxImagesList,imagesTo,rawImageName);
                tic;
    
                img=double(imread(imagePath));
                if (max(img(:))>1.001)
                    img=img./255;
                end
                
                reverseStr = '';
                totalT=0;
    
                if (Experiment.writeImages)
                    if (~exist([Experiment.smDir rawImageName],'dir'))
                        mkdir([Experiment.smDir rawImageName]);
                    end
    
                    if (~exist([Experiment.featImDir rawImageName],'dir'))
                        mkdir([Experiment.featImDir rawImageName]);
                    end
        
                    if (~exist([Experiment.bdryDir rawImageName],'dir'))
                        mkdir([Experiment.bdryDir rawImageName]);
                    end
                end
                    
                if (~exist([Experiment.cpDir rawImageName],'dir'))
                    mkdir([Experiment.cpDir rawImageName]);
                end
        
                pathIm = sprintf('%s%s.%s',Experiment.gtBnDir,rawImageName,Experiment.dataExt);
                gtImages=load(pathIm);
        
                bdryFileName = cell(propMethodNum+classicMethodNum,1);
                cpFileName = cell(propMethodNum+classicMethodNum,1);
    
%                 config=sigma2name(Experiment.gauss.sigma);
                smFileName=sprintf('%s%s-%s-[%s].%s',Experiment.smPrefix,rawImageName,smoothingMethod,config,Experiment.imageExt);
                smFilePath=strcat(Experiment.smDir,rawImageName,'/',smFileName);
                
                if ((~exist(smFilePath,'file')) || (Experiment.forceSmMaker==1) )
%                     smImage = imSmoother(img,smoothingMethod,Experiment.gauss.sigma);

                    if (strcmp(smoothingMethod,'mshift'))
                        smImage = imSmoother(img.*255,...
                                              smoothingMethod,...
                                              Experiment.mshift.spatialSupport,...
                                              Experiment.mshift.tonalSupport,...
                                              Experiment.mshift.stopCondition);
                    elseif(strcmp(smoothingMethod,'gauss'))
                        smImage = imSmoother(img,smoothingMethod,Experiment.gauss.sigma);
                    elseif(strcmp(smoothingMethod,'grav'))
                        smImage = imSmoother(img,smoothingMethod,Experiment.grav);
                    else
                        error('Wrong smoothing method %s at smMaker.',smoothingMethod);
                    end

                else
                    smImage=double(imread(smFilePath));
                end
    
                if (max(smImage(:))>1.001)
                    smImage=smImage./255;
                end
    
                %Wring the file
                if (Experiment.writeImages)
                    imwrite(smImage,smFilePath);
                end
        
                for idxFeat = 1:length(Experiment.config.featureMethod)
        	        featureMethod = Experiment.config.featureMethod{idxFeat};
        %             fprintf('\n\t Feature extraction method: %s ...\n',featureMethod);
    %                 if (strcmp(featureMethod,'dCF'))
                    if (ismember(featureMethod,{'dCF','dXCF1F2', 'sugeno', 'FGsugeno'}))
                
                        for idxDis = 1:length(Experiment.config.feat.dCF.Dis)
                            for idxGen = 1:length(Experiment.config.feat.dCF.Gen)
        
                                for idxMeasureType = 1:size(Experiment.config.measureComplete,2)
        %                             for idxTam = 1:size(Experiment.tamW,2)
            
                                        if (Experiment.params.measure.power.useSelected_q)
                                            q = Experiment.params.measure.power.selected_q(idxTam,idxDis);
                                            measureType = sprintf('%s-%s',Experiment.config.measure{1},sigma2name(q));
                                            mW = powerMeasure(Experiment.params.measure.tam(idxTam),q)';
                                        else
                                            measureType = Experiment.config.measureComplete{1,idxMeasureType};
                                            mW = measureWeights(:,idxMeasureType);
                                        end
                                        
                                    
                                        Dis = Experiment.config.feat.dCF.Dis{idxDis};
                                        Gen = Experiment.config.feat.dCF.Gen{idxGen};
                                        if iscell(Gen)
                                            GenStr = [Gen{1} '-' Gen{2}];
                                        elseif strcmp(featureMethod, 'sugeno')
                                            GenStr = Gen;
                                        else
                                            GenStr = Gen;
                                            mW(1) = [];
                                        end
    %                                     tamW = Experiment.tamW(idxTam);
    
                                        ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-g-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,mAdapt,featureMethod,Dis,GenStr,tamW);
                                        ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                                        
                                        bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-g-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,mAdapt,featureMethod,Dis,GenStr,tamW);
                                        bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
    
                                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-g-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,mAdapt,featureMethod,Dis,GenStr,tamW)};
                                        cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName{idxRes},Experiment.dataExt);
    
                                        if ((~exist(cpDataFilePath,'file')) || (Experiment.forceCpMaker==1))
    
                                            % Feature extraction
                                            if contains(measureType,'power')
                                                q = str2double(regexprep(extractAfter(measureType,'power-'),'-','.'));
                                            else
                                                q = 1;
                                            end
        
    
                                            if (strcmp(featureMethod,'dCF'))
                                                if isempty(mAdapt)
                                                    [imgFeat, imgDiff] = dCF(smImage,tamW,Dis,Gen,mW,q);
                                                else
                                                    [imgFeat, imgDiff] = dCF(smImage,tamW,Dis,Gen,mAdapt,q);
                                                end
                                            elseif (strcmp(featureMethod,'dXCF1F2'))
                                                imgFeat = dXCF1F2(smImage,tamW,Gen{1},Gen{2},Dis,mW);
                                            elseif (strcmp(featureMethod,'sugeno'))
                                                [imgFeat, ~, ~]  = sugeno(smImage,tamW,mW);
    %                                             [imgFeat2,~,~]  = sugeno_old(smImage,tamW,mW);
                                            elseif (strcmp(featureMethod,'FGsugeno'))
                                                imgFeat = FGsugeno(smImage,tamW,Gen{1},Gen{2},mW);
                                            end
    
                                            %Boundary maker
                                            
                                            if strcmp(Experiment.colorAgg, 'SqSum')
                                                imgFeat = sqrt(sum(imgFeat.^2,3));
                                            elseif strcmp(Experiment.colorAgg, 'max')
                                                imgFeat = max(imgFeat,[],3);
                                            elseif strcmp(Experiment.colorAgg, 'mean')
                                                imgFeat = mean(imgFeat,3);
                                            end
                                            imgFeat = imgFeat./max(imgFeat(:));
                                            p_val = Experiment.p;
                      
                                            [~,imgBdry]=getBoundaries(imgFeat,p_val);
                                            if (sum(imgBdry(:))==0)
                                                [~,imgBdry]=getBoundaries(imgFeat,0.35);
                                            end
                                            imgBdry = logical(imgBdry./255);
    
                                            %Write images
                                            if (Experiment.writeImages)
                                                imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);
                                                imwrite(imgFeatColorMap,ftImgFilePath,'png');
                                                imwrite(1-imgBdry, bdryImgFilePath, 'png');
                                                if (Experiment.writeImagesDir)
                                                    for idxDir = 1:size(imgDiff,3)
                                                        imgFeatColorMap = ind2rgb(round(imgDiff(:,:,idxDir).*255),Experiment.dtDiffColorMap);
                                                        imwrite(imgFeatColorMap,insertBefore(ftImgFilePath,".",strcat("-dir",num2str(idxDir))),'png');
                                                    end
                                                end
                                            end
    
                                            %Comparison maker
    
                                            res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
                                            save(cpDataFilePath,'res');
                    
                                            cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-g-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,mAdapt,featureMethod,Dis,GenStr,tamW)};
                                        end
                                        idxRes = idxRes+1;
    
                                        
        %                             end
                                end
                            end
                        end
                    elseif (strcmp(featureMethod,'canny'))
                        smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod}{1};
                        if (strcmp(smoothingMethod,'mshift'))
                            config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
                        elseif(strcmp(smoothingMethod,'gauss'))
                            Experiment.gauss.sigma=Experiment.smoothingMethod{idxSmoothingMethod}{2};
                            config=sigma2name(Experiment.gauss.sigma);
                        elseif(strcmp(smoothingMethod,'grav'))
                            Experiment.grav.iterations=Experiment.smoothingMethod{idxSmoothingMethod}{2};
                            Experiment.grav.minDistInfFactor=Experiment.smoothingMethod{idxSmoothingMethod}{3};
                            Experiment.grav.gConst=Experiment.smoothingMethod{idxSmoothingMethod}{4};
                            Experiment.grav.colorFactor=Experiment.smoothingMethod{idxSmoothingMethod}{5};
                            config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
                        end
                        
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma),tamW);
                        ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                        
                        bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma),tamW);
                        bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
    
                        cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma),tamW);
                        cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);
                        idxRes = idxRes+1;
    
                        imgFeat = canny(smImage,Experiment.config.feat.canny.sigma);
    %                     imgFeat = imgFeat./max(imgFeat(:));
                        if strcmp(Experiment.colorAgg, 'SqSum')
                            imgFeat = sqrt(sum(imgFeat.^2,3));
                        elseif strcmp(Experiment.colorAgg, 'max')
                            imgFeat = max(imgFeat,[],3);
                        elseif strcmp(Experiment.colorAgg, 'mean')
                            imgFeat = mean(imgFeat,3);
                        end
                        imgFeat = imgFeat./max(imgFeat(:));
                        p_val = 1;%Experiment.p;
                      
                        [~,imgBdry]=getBoundaries(imgFeat,p_val);
                        imgBdry = logical(imgBdry./255);
    
                        if (Experiment.writeImages)
                            imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);
                            imwrite(imgFeatColorMap,ftImgFilePath,'png');
                            imwrite(1-imgBdry, bdryImgFilePath, 'png');
                        end
    
                        res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
                        save(cpDataFilePath,'res');
                    
                    elseif (strcmp(featureMethod,'sobel'))
                        config=sigma2name(Experiment.gauss.sigma);
                        
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW);
                        ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                        
                        bdryFileName = sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW);
                        bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
    
                        cpFileName = sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW);
                        cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);
                        idxRes = idxRes+1;
    
                        imgFeat = sobel(smImage);
    %                     imgFeat = imgFeat./max(imgFeat(:));
                        if strcmp(Experiment.colorAgg, 'SqSum')
                            imgFeat = sqrt(sum(imgFeat.^2,3));
                        elseif strcmp(Experiment.colorAgg, 'max')
                            imgFeat = max(imgFeat,[],3);
                        elseif strcmp(Experiment.colorAgg, 'mean')
                            imgFeat = mean(imgFeat,3);
                        end
                        imgFeat = imgFeat./max(imgFeat(:));
                        p_val = 1;%Experiment.p;
                      
                        [~,imgBdry]=getBoundaries(imgFeat,p_val);
                        imgBdry = logical(imgBdry./255);
    
                        if (Experiment.writeImages)
                            imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);
                            imwrite(imgFeatColorMap,ftImgFilePath,'png');
                            imwrite(1-imgBdry, bdryImgFilePath, 'png');
                        end
    
                        res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
                        save(cpDataFilePath,'res');
    
                    elseif (strcmp(featureMethod,'fuzzyM'))
                        config=sigma2name(Experiment.gauss.sigma);
    
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3},tamW);
                        ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                        
                        bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3},tamW);
                        bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
    
                        cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3},tamW);
                        cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);
                        idxRes = idxRes+1;
    
                        imgFeat = FuzzyMorph(smImage,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3});
    %                     imgFeat = imgFeat./max(imgFeat(:));
                        if strcmp(Experiment.colorAgg, 'SqSum')
                            imgFeat = sqrt(sum(imgFeat.^2,3));
                        elseif strcmp(Experiment.colorAgg, 'max')
                            imgFeat = max(imgFeat,[],3);
                        elseif strcmp(Experiment.colorAgg, 'mean')
                            imgFeat = mean(imgFeat,3);
                        end
                        imgFeat = imgFeat./max(imgFeat(:));
                        p_val = 1;%Experiment.p;
                      
                        [~,imgBdry]=getBoundaries(imgFeat,p_val);
                        imgBdry = logical(imgBdry./255);
    
                        if (Experiment.writeImages)
                            imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);
                            imwrite(imgFeatColorMap,ftImgFilePath,'png');
                            imwrite(1-imgBdry, bdryImgFilePath, 'png');
                        end
    
                        res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
                        save(cpDataFilePath,'res');
    
                    elseif (strcmp(featureMethod,'ged'))
                        config=sigma2name(Experiment.gauss.sigma);
    
                        for idxGedFunc = 1:length(Experiment.config.feat.ged.F)
                            ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode,tamW);
                            ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                            
                            bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode,tamW);
                            bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
    
                            cpFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode,tamW);
                            cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);
                            idxRes = idxRes+1;
    
                            [imgFeat,~,~] = AFDetection(smImage,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode);
        %                     imgFeat = imgFeat./max(imgFeat(:));
                            if strcmp(Experiment.colorAgg, 'SqSum')
                                imgFeat = sqrt(sum(imgFeat.^2,3));
                            elseif strcmp(Experiment.colorAgg, 'max')
                                imgFeat = max(imgFeat,[],3);
                            elseif strcmp(Experiment.colorAgg, 'mean')
                                imgFeat = mean(imgFeat,3);
                            end
                            imgFeat = imgFeat./max(imgFeat(:));
                            p_val = 1;%Experiment.p;
                          
                            [~,imgBdry]=getBoundaries(imgFeat,p_val);
                            imgBdry = logical(imgBdry./255);
        
                            if (Experiment.writeImages)
                                imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);
                                imwrite(imgFeatColorMap,ftImgFilePath,'png');
                                imwrite(1-imgBdry, bdryImgFilePath, 'png');
                            end
        
                            res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
                            save(cpDataFilePath,'res');
    
                        end
                    elseif (strcmp(featureMethod,'SF'))
                        config=sigma2name(Experiment.gauss.sigma);
                        
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW);
                        ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                        
                        bdryFileName = sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW);
                        bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
    
                        cpFileName = sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW);
                        cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName,Experiment.dataExt);
                        idxRes = idxRes+1;
    
                        imgFeat=RandomForest(smImage,Experiment.config.feat.SF.modelpath,Experiment.orgDir,pwd);
    %                     imgFeat = imgFeat./max(imgFeat(:));
                        if strcmp(Experiment.colorAgg, 'SqSum')
                            imgFeat = sqrt(sum(imgFeat.^2,3));
                        elseif strcmp(Experiment.colorAgg, 'max')
                            imgFeat = max(imgFeat,[],3);
                        elseif strcmp(Experiment.colorAgg, 'mean')
                            imgFeat = mean(imgFeat,3);
                        end
                        imgFeat = imgFeat./max(imgFeat(:));
                        p_val = 1;%Experiment.p;
                      
                        [~,imgBdry]=getBoundaries(imgFeat,p_val);
                        imgBdry = logical(imgBdry./255);
    
                        if (Experiment.writeImages)
                            imgFeatColorMap = ind2rgb(round(imgFeat.*255),Experiment.dtDiffColorMap);
                            imwrite(imgFeatColorMap,ftImgFilePath,'png');
                            imwrite(1-imgBdry, bdryImgFilePath, 'png');
                        end
    
                        res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
                        save(cpDataFilePath,'res');
                    end
                end
    %             idxRes = 1;
    %             for idxCpDataFile=1:length(cpFileName)
    %                 
    %                 
    %                 bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName{idxCpDataFile},Experiment.dataExt);
    %                 cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName{idxCpDataFile},Experiment.dataExt);
    %     
    %                 data = load(bdryDataFilePath);
    %                 imgBdry = data.imgBdry;  
    %     
    %                 tic;
    %                 if ((~exist(cpDataFilePath,'file')) || (Experiment.forceCpMaker==1))
    %     
    %                     imgBdry = logical(imgBdry./255);
    %     
    %                     res=ComparisonResiduals(Experiment.matching,imgBdry,gtImages,Experiment.matchingTolerance);
    %     
    %                     save(cpDataFilePath,'res');
    %     
    %                 else
    %                     data = load(cpDataFilePath);
    %                     res = data.res;
    %                 end
    %                 resMean = mean(res,1);
    %                 resSorted = sortrows(res,3);
    %                 resMax = resSorted(end,:);
    %            
    %                 expConfig = extractBetween(string(cpDataFilePath),"]-",".mat");
    %                 cpAll(idxRes,:,idxImagesList) = {expConfig resMax resMean};
    %     
    %                 thisT=toc;
    %                 totalT = totalT + thisT;
    %                 msg = sprintf('\tBdry image: %d / %d, time = %.2f secs (est. %s)\n', idxRes,Experiment.numRes,thisT,timeToName(thisT*(Experiment.numRes-idxRes)));
    %                 fprintf([reverseStr, msg]);
    %                 reverseStr = repmat(sprintf('\b'), 1, length(msg));                    
    %                 idxRes = idxRes+1;
    %             end
    %             totalTall = totalTall + totalT;
    %             imgDone = imgDone +1;
    %             fprintf('\t done (%s) (est. %s)\n',timeToName(totalT),timeToName((totalTall/imgDone)*(imagesTo-imagesFrom-imgDone-1)));
                thisT=toc;
                totalT=totalT+thisT;
                fprintf('\t\t done (%.1f) (est. %s)\n',thisT);
            end
    %         cpAll = [cpAll(:,1,1) num2cell(mean(cell2mat(cpAll(:,2,:)),3),[size(cpAll,1) 3]) num2cell(mean(cell2mat(cpAll(:,3,:)),3),[size(cpAll,1) 3])];
    %         if ~exist(cpAllDataFilePath,'file')
    %             save(cpAllDataFilePath,'cpAll','Experiment');
    %         end
        end
    end
end
