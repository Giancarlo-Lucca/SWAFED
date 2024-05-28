function imBdry=getBoundaries2(ft,fx,fy,thres)

    ft = ft./max(ft(:));
    fx = fx./max(fx(:));
    fy = fy./max(fy(:));

    [thrsHyst] = doubleRosinUnimodalThr(ft,thres,3);
    ft2 = ft.*directionalNMS(fx,fy);

    imBdry=floodHysteresis(ft2,thrsHyst(2),thrsHyst(1));
    imBdry=cleanLineSegments(imBdry,0.02);
end