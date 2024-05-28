function [E,imBndry]=RandomForest(im,modelpath,imgdir,workdir)

% 	im=gaussianSmooth(im,Sigma);
    if (size(im,3)>1)
        model = 'modelBsds';
    else
        im = repmat(im, [1 1 3]);
        model = 'modelBsdsGS';
    end

    % set opts for training (see edgesTrain.m)
    opts=edgesTrain();                % default options (good settings)
    opts.modelDir=modelpath;          % model will be in models/forest
    opts.modelFnm=model;              % model name
    opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
    opts.useParfor=0;                 % parallelize if sufficient memory
    opts.bsdsDir=imgdir;
%     opts.rgbd=1;
    
    model=edgesTrain(opts);

    % set detection parameters (can set after training)
    model.opts.multiscale=0;          % for top accuracy set multiscale=1
    model.opts.sharpen=2;             % for top speed set sharpen=0
    model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
    model.opts.nThreads=4;            % max number threads for evaluation
    model.opts.nms=0;                 % set to true to enable nms
    
    E=edgesDetect(im,model);
%     [E,O,inds,segs]=edgesDetect(im,model);
%     th = graythresh(E);
%     imBndry = floodHysteresis(E,th,th*0.6);

    cd(workdir);
    
%     E=E/max(E(:));
%     orientim = featureorient(double(E),0,1);
%     NMS=nonmaxsup(E,orientim,1.5);
%     NMS255=uint8(255*NMS);
%     [thrsHyst] = doubleRosinUnimodalThr(NMS,0.01,3);
%     imBndry=histmedcar(NMS255,thrsHyst(2),thrsHyst(1),5);
%     imBndry=cleanLineSegments(imBndry,0.02);
%     HM255=uint8(imBndry*255);
%     imBndry=HM255;
        
end
