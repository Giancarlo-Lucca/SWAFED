function map = makeColorMap(vec, hex, N, interpolate)

%     vec = [      100;       83;       68;       44;       30;       15;        0];
%     hex = ['#f8fe34';'#f4771e';'#d94015';'#148b3e';'#085a3f';'#41332d';'#ede6df'];
%     vec = [100; 90; 80 ; 70; 0];
%     hex = ['#ede6df'; '#085a3f'; '#41332d'; '#d94015'; '#ede6df'];
    raw = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
    if interpolate
%         N = 256;
%         N = size(get(gcf,'colormap'),1) % size of the current colormap
        map = interp1(vec,raw,linspace(100,0,N),'pchip');
        map = flipud(map);
    else
        map = raw;
    end
end