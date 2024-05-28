

imagesList=getFileList(Experiment.orgDir,'*',Experiment.orgImagesExt);


fprintf('\n------\n Smooth Images Maker (smMaker)\n------\n');

%Timing matters
totalT=0;
numImages=0;


imagesFrom=max(1,Experiment.imagesFrom);
imagesTo=min(length(imagesList),Experiment.imagesTo);
time = zeros(imagesTo-imagesFrom,1);

for idxImagesList=imagesFrom:imagesTo

    %Read Image
    fullImageName=char(imagesList(idxImagesList));
    rawImageName=regexprep(fullImageName,strcat('.',Experiment.orgImagesExt),'');
    imagePath=strcat(Experiment.orgDir,fullImageName);
    
    fprintf('\nStarting image %d / %d (%s)...\n',idxImagesList,imagesTo-imagesFrom+1,rawImageName);
    tic;
    img=double(imread(imagePath));
    if (max(img(:))>1.001)
        img=img./255;
    end
    
    for idxSmoothingMethod=1:length(Experiment.smoothingMethod)
    
        smoothingMethod=Experiment.smoothingMethod{idxSmoothingMethod}{1};
        if (strcmp(smoothingMethod,'mshift'))
            config=strcat(num2str(Experiment.mshift.spatialSupport),'-',num2str(Experiment.mshift.tonalSupport),'-',num2str(Experiment.mshift.stopCondition));
        elseif(strcmp(smoothingMethod,'gauss'))
            config=sigma2name(Experiment.gauss.sigma);
        elseif(strcmp(smoothingMethod,'grav'))
            Experiment.grav.iterations=Experiment.smoothingMethod{idxSmoothingMethod}{2};
            Experiment.grav.minDistInfFactor=Experiment.smoothingMethod{idxSmoothingMethod}{3};
            Experiment.grav.gConst=Experiment.smoothingMethod{idxSmoothingMethod}{4};
            Experiment.grav.colorFactor=Experiment.smoothingMethod{idxSmoothingMethod}{5};
            config=sprintf('it-%d-%s-G-%s-cF-%d-%s-%s',Experiment.grav.iterations,sigma2name(Experiment.grav.minDistInfFactor),sigma2name(Experiment.grav.gConst),Experiment.grav.colorFactor,Experiment.grav.colorMetric,Experiment.grav.posMetric);
        end
    
        if (~exist([Experiment.smDir rawImageName],'dir'))
            mkdir([Experiment.smDir rawImageName]);
        end
        
        
        smFileName=sprintf('%s%s-%s-[%s].%s',Experiment.smPrefix,rawImageName,smoothingMethod,config,Experiment.imageExt);
        smFilePath=strcat(Experiment.smDir,rawImageName,'/',smFileName);

        if ((~exist(smFilePath,'file')) || (Experiment.forceSmMaker==1) )

            if (strcmp(smoothingMethod,'mshift'))
                smoothIm = imSmoother(img.*255,...
                                      smoothingMethod,...
                                      Experiment.mshift.spatialSupport,...
                                      Experiment.mshift.tonalSupport,...
                                      Experiment.mshift.stopCondition);
                smoothIm=smoothIm./255;

            elseif(strcmp(smoothingMethod,'gauss'))
                smoothIm = imSmoother(img,smoothingMethod,Experiment.gauss.sigma);
            elseif(strcmp(smoothingMethod,'grav'))
                smoothIm = imSmoother(img,smoothingMethod,Experiment.grav);
            else
                error('Wrong smoothing method %s at smMaker.',smoothingMethod);
            end

            %Wring the file
            imwrite(smoothIm,smFilePath);

            thisT=toc;
            totalT=totalT+thisT;
            fprintf('\t done (%.1f)\n',thisT);
            time(idxImagesList)=thisT;
        end
%         smTFileName=strcat(Experiment.smPrefix,smoothingMethod,'.csv');
%         smTFilePath=strcat(Experiment.smDir,smTFileName);
%         csvwrite(smTFilePath,time);
    
    end
end
