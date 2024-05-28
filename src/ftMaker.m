

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Feature Image Maker (smMaker)\n------\n');

%Timing matters
totalT=0;
numImages=0;


imagesFrom=max(1,Experiment.imagesFrom);
imagesTo=min(length(imagesList),Experiment.imagesTo);


for idxTam = 1:size(Experiment.tamW,2)
    measureWeights = [];
    for idxMeasureType = 1:size(Experiment.config.measure,2)
    
        measureType = Experiment.config.measure{1,idxMeasureType};
        
        measureWeights = [measureWeights measure(measureType,Experiment.params.measure,Experiment.params.measure.tam(idxTam))];
    end
    
    measureWeights(1,:) = []; % Remove first measure weight
    
    time = zeros(imagesTo-imagesFrom,1);
    
    for idxImagesList=imagesFrom:imagesTo
    
        %Read Image
        fullImageName=char(imagesList(idxImagesList));
        rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
        imagePath=strcat(Experiment.orgDir,fullImageName);
        
        fprintf('\nStarting image %d / %d (%s)...\n',idxImagesList,imagesTo-imagesFrom+1,rawImageName);
        tic;
        
        if (~exist([Experiment.featImDir rawImageName],'dir'))
            mkdir([Experiment.featImDir rawImageName]);
        end
    
        for idxSmoothingMethod=1:length(Experiment.smoothingMethod)
        
            smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
            fprintf('\n\t Smoothing method: %s ...\n',smoothingMethod);
            if (strcmp(smoothingMethod,'mshift'))
                config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
            elseif(strcmp(smoothingMethod,'gauss'))
                config=sigma2name(Experiment.gauss.sigma);
            elseif(strcmp(smoothingMethod,'grav'))
                config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
            end
        
            smFileName=sprintf('%s%s-%s-[%s].%s',Experiment.smPrefix,rawImageName,smoothingMethod,config,Experiment.imageExt);
            smFilePath=strcat(Experiment.smDir,rawImageName,'/',smFileName);
            
            smImage=double(imread(smFilePath));
            if (max(smImage(:))>1.001)
                smImage=smImage./255;
            end
           
            for idxFeat = 1:length(Experiment.config.featureMethod)
        	    featureMethod = Experiment.config.featureMethod{idxFeat};
                fprintf('\n\t Feature extraction method: %s ...\n',featureMethod);
                if (strcmp(featureMethod,'dCF'))
                    for idxDis = 1:length(Experiment.config.feat.dCF.Dis)
                        for idxGen = 1:length(Experiment.config.feat.dCF.Gen)
    
                            for idxMeasureType = 1:size(Experiment.config.measureComplete,2)
        
                                measureType = Experiment.config.measureComplete{1,idxMeasureType};
                                mW = measureWeights(:,idxMeasureType);
                                Dis = Experiment.config.feat.dCF.Dis{idxDis};
                                Gen = Experiment.config.feat.dCF.Gen{idxGen};
                                tamW = Experiment.tamW(idxTam);
        
                                ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-g-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,Dis,Gen,tamW);
                                ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                                ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
        
                                if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )
        
                %                     smImage_lab = rgb2lab(smImage);
                %                     smImage_lab(:,:,1) = smImage_lab(:,:,1)./100;
                %                     smImage_lab(:,:,2) = (smImage_lab(:,:,2)+86.185)./184.439;
                %                     smImage_lab(:,:,3) = (smImage_lab(:,:,3)+107.863)./202.345;
            
                                    if contains(measureType,'power')
                                        q = str2double(regexprep(extractAfter(measureType,'power-'),'-','.'));
                                    else
                                        q = 1;
                                    end
                                    imgFeat = dCF(smImage,tamW,Dis,Gen,mW,q);
                %                     imgFeat_lab = dXChoquet(smImage_lab,Experiment.tamW,F,mW);
                                    imgFeat1D = sqrt(sum(imgFeat.^2,3));
                %                     imgFeat1D = sqrt(sum(cat(3,imgFeat,imgFeat_lab).^2,3));
                %                     imgFeat1D = max(cat(3,imgFeat,imgFeat_lab),[],3);
                                    imgFeat1D = imgFeat1D./max(imgFeat1D(:));
        
                                    imgFeatColorMap = ind2rgb(round(imgFeat1D.*255),Experiment.dtDiffColorMap);
                                    imwrite(imgFeatColorMap,ftImgFilePath,'png');
                                    save(ftDataFilePath,'imgFeat');
        
                                    thisT=toc;
                                    totalT=totalT+thisT;
                                    fprintf('\t\t done (%.1f)\n',thisT);
                                    time(idxImagesList)=thisT;
                                end
                            end
                        end
                    end
                elseif (strcmp(featureMethod,'canny'))
                    ftFileName = sprintf('%s%s-%s-[%s]-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma));
                    ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
    
                    if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )
                        imgFeat = canny(smImage,Experiment.config.feat.canny.sigma);
                        imgFeat = imgFeat./max(imgFeat(:));
                        imgFeat1D = sqrt(sum(imgFeat.^2,3));
                        imgFeat1D = imgFeat1D./max(imgFeat1D(:));
                        imgFeatColorMap = ind2rgb(round(imgFeat1D.*255),Experiment.dtDiffColorMap);
    
                        imwrite(imgFeatColorMap,ftImgFilePath,'png');
                        save(ftDataFilePath,'imgFeat');
                    end
                elseif (strcmp(featureMethod,'fuzzyM'))
                    ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3});
                    ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
                    
                    if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )
                        imgFeat = FuzzyMorph(smImage,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3});
                        imgFeat = imgFeat./max(imgFeat(:));
                        imgFeat1D = sqrt(sum(imgFeat.^2,3));
                        imgFeat1D = imgFeat1D./max(imgFeat1D(:));
                        imgFeatColorMap = ind2rgb(round(imgFeat1D.*255),Experiment.dtDiffColorMap);
                    
                        imwrite(imgFeatColorMap,ftImgFilePath,'png');
                        save(ftDataFilePath,'imgFeat');
                    end
                elseif (strcmp(featureMethod,'ged'))
                    for idxGedFunc = 1:length(Experiment.config.feat.ged.F)
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode);
                        ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                        ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
    
                        if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )
                            [imgFeat,~,~] = AFDetection(smImage,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode);
                            imgFeat = imgFeat./max(imgFeat(:));
                            imgFeat1D = sqrt(sum(imgFeat.^2,3));
                            imgFeat1D = imgFeat1D./max(imgFeat1D(:));
                            imgFeatColorMap = ind2rgb(round(imgFeat1D.*255),Experiment.dtDiffColorMap);
    
                            imwrite(imgFeatColorMap,ftImgFilePath,'png');
                            save(ftDataFilePath,'imgFeat');
                        end
                    end
                elseif (strcmp(featureMethod,'SF'))
                    ftFileName = sprintf('%s%s-%s-[%s]-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod);
                    ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);
                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
                    
                    if ((~exist(ftImgFilePath,'file')) || (Experiment.forceFtMaker==1) )
                        imgFeat=RandomForest(smImage,Experiment.config.feat.SF.modelpath,Experiment.orgDir,pwd);
                        imgFeat = imgFeat./max(imgFeat(:));
                        imgFeat1D = sqrt(sum(imgFeat.^2,3));
                        imgFeat1D = imgFeat1D./max(imgFeat1D(:));
                        imgFeatColorMap = ind2rgb(round(imgFeat1D.*255),Experiment.dtDiffColorMap);
    
                        imwrite(imgFeatColorMap,ftImgFilePath,'png');
                        save(ftDataFilePath,'imgFeat');
                    end
                end
            end
        end
    end
end
