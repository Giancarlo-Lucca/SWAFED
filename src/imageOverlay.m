function imOverlay=imageOverlay(im,bdry)

    imOverlayR=im(:,:,1);
    imOverlayG=im(:,:,2);
    imOverlayB=im(:,:,3);

    imOverlayR(bdry)=1;
    imOverlayG(bdry)=0;
    imOverlayB(bdry)=0;
    
    imOverlay=cat(3,imOverlayR,imOverlayG,imOverlayB);
end