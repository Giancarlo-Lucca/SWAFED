

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Comparison Collecter (cpCollecter)\n------\n');

imagesFrom=max(1,Experiment.imagesFrom);
imagesTo=min(length(imagesList),Experiment.imagesTo);

classicMethodNum = sum(ismember(Experiment.config.featureMethod,{'canny','sobel','fuzzyM','ged','SF'}));
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
        Experiment.config.measureComplete = {'power-1-0000'};
    end

    for idxSmoothingMethod=1:length(Experiment.smoothingMethod)
        for idxTam = 1:size(Experiment.tamW,2)
            tamW = Experiment.tamW(idxTam);
    
    %         cpAll = cell(length(Experiment.params.measure.power.selected_q(idxTam,:)),3,imagesTo-imagesFrom+1);
        %     cpAll = cell(Experiment.numRes/length(Experiment.smoothingMethod),3,imagesTo-imagesFrom+1);
            cpAll = cell(1,3,imagesTo-imagesFrom+1);
            res = table;
        
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
                fullImageName=char(imagesList(idxImagesList));
                rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
                
                fprintf('\nStarting image %d (%s)...\n',idxImagesList,rawImageName);
        
                cpFileName = cell(length(Experiment.params.measure.power.selected_q(idxTam,:)),1);
                
        %         if (length(Experiment.config.featureMethod) > 1)
        %             cpFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod))+Experiment.config.NumClassicMethods,1);
        %         else
        %             cpFileName = cell((Experiment.numRes/length(Experiment.smoothingMethod)),1);
        %         end
                for idxFeat = 1:length(Experiment.config.featureMethod)
        	        featureMethod = Experiment.config.featureMethod{idxFeat};
        %             fprintf('\n\t Feature extraction method: %s ...\n',featureMethod);
    %                 if (strcmp(featureMethod,'dCF'))
                    if (ismember(featureMethod,{'dCF','dXCF1F2', 'sugeno', 'FGsugeno'}))
                
                        for idxDis = 1:length(Experiment.config.feat.dCF.Dis)
                            for idxGen = 1:length(Experiment.config.feat.dCF.Gen)
        
                                for idxMeasureType = 1:size(Experiment.config.measureComplete,2)
        %                             for idxTam = 1:size(Experiment.tamW,2)
            
    %                                     measureType = Experiment.config.measureComplete{1,idxMeasureType};
    %                                     q = Experiment.params.measure.power.selected_q(idxTam,idxDis);
    %                                     measureType = sprintf('%s-%s',Experiment.config.measure{1},sigma2name(q));
                                        if (Experiment.params.measure.power.useSelected_q)
                                            q = Experiment.params.measure.power.selected_q(idxTam,idxDis);
                                            measureType = sprintf('%s-%s',Experiment.config.measure{1},sigma2name(q));
                                        else
                                            measureType = Experiment.config.measureComplete{1,idxMeasureType};
                                        end
    
                                        Dis = Experiment.config.feat.dCF.Dis{idxDis};
                                        Gen = Experiment.config.feat.dCF.Gen{idxGen};
                                        tamW = Experiment.tamW(idxTam);
                                        if iscell(Gen)
                                            GenStr = [Gen{1} '-' Gen{2}];
                                        elseif strcmp(featureMethod, 'sugeno')
                                            GenStr = Gen;
                                        else
                                            GenStr = Gen;
                                        end

                                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-g-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,mAdapt,featureMethod,Dis,GenStr,tamW)};

                                            
%                                         if ~isempty(mAdapt)
%                                             cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-g-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,featureMethod,Dis,GenStr,tamW)};
%                                         else
%                                             if ~isempty(mAdapt)
%                                                 cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-g-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,mAdapt,featureMethod,Dis,GenStr,tamW)};
%                                             else
%                                                 cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s%s-%s-g-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,measureType,mAdapt,featureMethod,Dis,GenStr,tamW)};
% 
%                                             end
%                                         end
                                        idxRes = idxRes+1;
        %                             end
                                end
                            end
                        end
                    elseif (strcmp(featureMethod,'canny'))
                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,sigma2name(Experiment.config.feat.canny.sigma),tamW)};
                        idxRes = idxRes+1;
                    elseif (strcmp(featureMethod,'sobel'))
                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW)};
                        idxRes = idxRes+1;
                    elseif (strcmp(featureMethod,'fuzzyM'))
                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.fuzzyM{1},Experiment.config.feat.fuzzyM{2},Experiment.config.feat.fuzzyM{3},tamW)};
                        idxRes = idxRes+1;
                    elseif (strcmp(featureMethod,'ged'))
                        for idxGedFunc = 1:length(Experiment.config.feat.ged.F)
                            cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-%s-%s-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,Experiment.config.feat.ged.F{idxGedFunc},Experiment.config.feat.ged.wSize,Experiment.config.feat.ged.kmode,tamW)};
                            idxRes = idxRes+1;
                        end
                    elseif (strcmp(featureMethod,'SF'))
                        cpFileName(idxRes) = {sprintf('%s%s-%s-[%s]-%s-w-%d',Experiment.cpPrefix,rawImageName,smoothingMethod,config,featureMethod,tamW)};
                        idxRes = idxRes+1;
                    end
                end
                idxRes = 1;
                for idxCpDataFile=1:length(cpFileName)
                    if (isempty(cpFileName{idxCpDataFile}) == 0)
        
                        cpDataFilePath = sprintf('%s%s/%s.%s',Experiment.cpDir,rawImageName,cpFileName{idxCpDataFile},Experiment.dataExt);
            
                        data = load(cpDataFilePath);
                        res = data.res;
            
                        resMean = mean(res,1);
                        resSorted = sortrows(res,3);
                        resMax = resSorted(end,:);
                   
                        expConfig = extractBetween(string(cpDataFilePath),"]-",".mat");
                        cpAll(idxRes,:,idxImagesList) = {expConfig resMax resMean};
                            
                        idxRes = idxRes+1;
                    end
                end
            end
%             cpAll = [cpAll(:,1,1) num2cell(mean(cell2mat(cpAll(:,2,:)),3),[size(cpAll,1) 3]) num2cell(mean(cell2mat(cpAll(:,3,:)),3),[size(cpAll,1) 3])];
            reExp = cpAll{:,1,1};
            maxResiduals = permute(cell2mat(cpAll(:,2,:)),[3 2 1]);
            meanResiduals = permute(cell2mat(cpAll(:,3,:)),[3 2 1]);

            globalMaxRes = zeros(size(cpAll,1),size(cpAll,2));
            globalMaxRes(:,1:2) = permute(mean(maxResiduals(:,1:2,:),1),[3 2 1]);
            globalMaxRes(:,3) = (globalMaxRes(:,1).*globalMaxRes(:,2))./((globalMaxRes(:,1).*0.5+globalMaxRes(:,2).*0.5));

            globalMeanRes = zeros(size(cpAll,1),size(cpAll,2));
            globalMeanRes(:,1:2) = permute(mean(meanResiduals(:,1:2,:),1),[3 2 1]);
            globalMeanRes(:,3) = (globalMeanRes(:,1).*globalMeanRes(:,2))./((globalMeanRes(:,1)*0.5+globalMeanRes(:,2)*0.5));

%             cpAll = [cpAll(:,1,1) num2cell(mean(cell2mat(cpAll(:,2,:)),3)) num2cell(mean(cell2mat(cpAll(:,3,:)),3))];
            cpAll = [cpAll(:,1,1) num2cell(globalMaxRes(:,1)) num2cell(globalMaxRes(:,2)) num2cell(globalMaxRes(:,3)) num2cell(globalMeanRes(:,1)) num2cell(globalMeanRes(:,2)) num2cell(globalMeanRes(:,3))];
            save(cpAllDataFilePath,'cpAll','Experiment'); 
            
        %    meanResidualsAllAux = meanResidualsAll';
	        fileID = fopen([Experiment.cpDir cpAllFileName '.txt'],'a+');
% 	        fprintf(fileID,'%20s %8s %8s %8s %8s %8s %8s\n\n','Exp. config','Prec','Rec','F','Prec','Rec','F');
    %         fprintf(fileID,'%20s %8s %8s %8s\n\n','Exp. config','Prec','Rec','F');
            for idxResAll = 1:size(cpAll,1)
%                 fprintf(fileID,'%-50s  \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f\n',cpAll{idxResAll,:});
                fprintf(fileID,'%-50s  \t%.3f \t%.3f \t%.3f\n',cpAll{idxResAll,1:4});
                fprintf(fileID,'\n');
            end
            fclose(fileID);
    
            fileID = fopen([Experiment.cpDir cpAllFileName '.tex'],'a+');
%     	    fprintf(fileID,'%20s %8s %8s %8s %8s %8s %8s\n\n','Exp. config','Prec','Rec','F','Prec','Rec','F');
%             fprintf(fileID,'%20s %8s %8s %8s\n\n','Exp. config','Prec','Rec','F');
            for idxResAll = 1:size(cpAll,1)
    %             fprintf(fileID,'%20s  \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f \t%.4f\n',cpAll{idxResAll,1:4});
%                 line = strrep(sprintf('%-50s   \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f \t%.3f\n',cpAll{idxResAll,:}),'0.','.');
                line = strrep(sprintf('%-50s & \t%.3f & \t%.3f & \t%.3f',cpAll{idxResAll,1:4}),'0.','.');
                fprintf(fileID,line);
                fprintf(fileID,' \\\\');
                fprintf(fileID,'\n');
            end
            fclose(fileID);
        
        
        %    fprintf(fileID,'%20s %.2f %.4f %.4f %.4f %.4f\n',meanResidualsAllAux{:});
        %    fprintf(fileID,'\n');
        %    fclose(fileID);
        end
    end
end
