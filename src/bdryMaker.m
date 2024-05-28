

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Boundary Image Maker (bdryMaker)\n------\n');

%Timing matters
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
        
        reverseStr = '';
        idxRes = 0;
        totalT=0;
        
        if (~exist([Experiment.bdryDir rawImageName],'dir'))
            mkdir([Experiment.bdryDir rawImageName]);
        end
        
        for idxSmoothingMethod=1:length(Experiment.smoothingMethod)
    
            smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod};
            if (strcmp(smoothingMethod,'mshift'))
                config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
            elseif(strcmp(smoothingMethod,'gauss'))
                config=sigma2name(Experiment.gauss.sigma);
            elseif(strcmp(smoothingMethod,'grav'))
                config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
            end
                    
            for idxFeat = 1:length(Experiment.config.featureMethod)
        	    featureMethod = Experiment.config.featureMethod{idxFeat};
                fprintf('\n\t Feature extraction method: %s ...\n',featureMethod);
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
            
                                    ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-g-%s-w-%d',Experiment.ftPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,Dis,Gen,tamW);
                                    bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-g-%s-w-%d',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,Dis,Gen,tamW);
            
                                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
%                                     ftImgFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.imageExt);

                                    bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
                                    bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.dataExt);
            
                                    if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBnMaker==1) )
            
                                        tic;
            
                                        data = load(ftDataFilePath);
                                        imgFeat = data.imgFeat;
%                                         imgFeat = double(imread(ftImgFilePath));
            
                                        imgFeat = sqrt(sum(imgFeat.^2,3));
                                        imgFeat = imgFeat./max(imgFeat(:));
            
                                        [RES,imgBdry]=getBoundaries(imgFeat,Experiment.p);
                                        RES=uint8(RES.*255);
            
                                        imwrite(255-imgBdry, bdryImgFilePath, 'png');
                                        save(bdryDataFilePath,'imgBdry');
            
                                        thisT=toc;
                                        time(idxImagesList)=thisT;
            
                                        totalT = totalT + thisT;
            
                                        msg = sprintf('\tBdry image: %d / %d, time = %.2f secs (est. %s)\n', idxRes,Experiment.numRes,thisT,timeToName(thisT*(Experiment.numRes-idxRes)));
                                        fprintf([reverseStr, msg]);
                                        reverseStr = repmat(sprintf('\b'), 1, length(msg));
            
                                        idxRes = idxRes +1;
                                    end
    %                             end
                            end
                        end
                    end
                elseif (strcmp(featureMethod,'canny'))
                    ftFileName = sprintf('%s%s-%s-[%s]-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma));
                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
                    
                    bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma));
                    bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
                    bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.dataExt);
    
                    if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBnMaker==1) )
                        data = load(ftDataFilePath);
                        imgFeat = data.imgFeat;
    
                        imgFeat = sqrt(sum(imgFeat.^2,3));
                        imgFeat = imgFeat./max(imgFeat(:));
                        
                        [RES,imgBdry]=getBoundaries(imgFeat,Experiment.p);
                        RES=uint8(RES.*255);
    
                        imwrite(255-imgBdry, bdryImgFilePath, 'png');
                        save(bdryDataFilePath,'imgBdry');
                    end
                elseif (strcmp(featureMethod,'fuzzyM'))
                    ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3});
                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
                    
                    bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3});
                    bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
                    bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.dataExt);
                    
                    if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBnMaker==1) )
                        data = load(ftDataFilePath);
                        imgFeat = data.imgFeat;
    
                        imgFeat = sqrt(sum(imgFeat.^2,3));
                        imgFeat = imgFeat./max(imgFeat(:));
                        
                        [RES,imgBdry]=getBoundaries(imgFeat,Experiment.p);
                        RES=uint8(RES.*255);
    
                        imwrite(255-imgBdry, bdryImgFilePath, 'png');
                        save(bdryDataFilePath,'imgBdry');
                    end
                elseif (strcmp(featureMethod,'ged'))
                    for idxGedFunc = 1:length(Experiment.config.feat.ged.F)
                        ftFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode);
                        ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
                        
                        bdryFileName = sprintf('%s%s-%s-[%s]-%s-%s-%s-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode);
                        bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
                        bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.dataExt);
    
                        if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBnMaker==1) )
                            data = load(ftDataFilePath);
                            imgFeat = data.imgFeat;
    
                            imgFeat = sqrt(sum(imgFeat.^2,3));
                            imgFeat = imgFeat./max(imgFeat(:));
    
                            [RES,imgBdry]=getBoundaries(imgFeat,Experiment.p);
                            RES=uint8(RES.*255);
    
                            imwrite(255-imgBdry, bdryImgFilePath, 'png');
                            save(bdryDataFilePath,'imgBdry');
                        end
                    end
                elseif (strcmp(featureMethod,'SF'))
                    ftFileName = sprintf('%s%s-%s-[%s]-%s',Experiment.ftPrefix,rawImageName,smoothingMethod,config,featureMethod);
                    ftDataFilePath = sprintf('%s%s/%s.%s',Experiment.featImDir,rawImageName,ftFileName,Experiment.dataExt);
                    
                    bdryFileName = sprintf('%s%s-%s-[%s]-%s',Experiment.bdryPrefix,rawImageName,smoothingMethod,config,featureMethod);
                    bdryImgFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.imageExt);
                    bdryDataFilePath = sprintf('%s%s/%s.%s',Experiment.bdryDir,rawImageName,bdryFileName,Experiment.dataExt);
                    
                    if ((~exist(bdryImgFilePath,'file')) || (Experiment.forceBnMaker==1) )
                        data = load(ftDataFilePath);
                        imgFeat = data.imgFeat;
    
                        imgFeat = sqrt(sum(imgFeat.^2,3));
                        imgFeat = imgFeat./max(imgFeat(:));
                        
                        [RES,imgBdry]=getBoundaries(imgFeat,Experiment.p);
                        RES=uint8(RES.*255);
    
                        imwrite(255-imgBdry, bdryImgFilePath, 'png');
                        save(bdryDataFilePath,'imgBdry');
                    end
                end
            end
        end
        fprintf('\t done (%s)\n',timeToName(totalT));
    end
end
