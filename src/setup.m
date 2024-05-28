%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENVIRONMENT SET UP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (strcmp(OS_MODE,'linux'))
    BASE_PATH = '/home/cedmarde/Dropbox/UPNA/DOC/research';
elseif (strcmp(OS_MODE,'mac'))
    BASE_PATH = '/Users/chivo/Dropbox/UPNA/DOC/research';
end

UTILITIES_PATH = strcat(BASE_PATH,'/distributable/utilitiesPackage/');
path(path,UTILITIES_PATH);
KITT_COMP_MEASURES_PATH = strcat(BASE_PATH,'/kitt/boundaryImageComparison');
path(path,KITT_COMP_MEASURES_PATH);
KITT_IMP_PATH = strcat(BASE_PATH,'/kitt/generalImageProcessing');
path(path,KITT_IMP_PATH);

KITT_EDGE_PATH = strcat(BASE_PATH,'/kitt/edgeDetection');
path(path,KITT_EDGE_PATH);

% DISTRIB_IMAGE_PATH = strcat(BASE_PATH,'/distributable/edgeDetection');
% path(path,DISTRIB_IMAGE_PATH);

PDOLLAR_MATLAB_PATH = strcat(BASE_PATH,'/extern/piotr_toolbox/toolbox/matlab');
path(path,PDOLLAR_MATLAB_PATH);

PDOLLAR_CHANNELS_PATH = strcat(BASE_PATH,'/extern/piotr_toolbox/toolbox/channels');
path(path,PDOLLAR_CHANNELS_PATH);

PDOLLAR_CLASSIFY_PATH = strcat(BASE_PATH,'/extern/piotr_toolbox/toolbox/classify');
path(path,PDOLLAR_CLASSIFY_PATH);

PDOLLAR_IMAGES_PATH = strcat(BASE_PATH,'/extern/piotr_toolbox/toolbox/images');
path(path,PDOLLAR_IMAGES_PATH);

PDOLLAR_STRUCTUREDEDGES_PATH = strcat(BASE_PATH,'/extern/structured-edges');
path(path,PDOLLAR_STRUCTUREDEDGES_PATH);