function res = RDFx(vec,m,DSM,Gen,q)
    N = size(vec,1);

    tam = size(x);
    mm = repmat(m,[1 tam(2:end)]);
    x = vec

    if strcmp(Gen,'T_M')
        res = bsxfun(@min,x,m);
    elseif strcmp(Gen,'choquet') % T_P
        res = bsxfun(@times,x,m);
    elseif strcmp(Gen,'T_L')
        res = bsxfun(@max,x+m-1,0);
%     elseif strcmp(Gen,'T_DP')
%         res = zeros(size(x));
%         mm = repmat(m,[1 321 481 3]);
%         res(bsxfun(@eq,x,1)) = m;
%         res(bsxfun(@eq,m,0)) = ;
%     elseif strcmp(Gen,'T_NM')
    elseif strcmp(Gen,'hamacher') % T_HP
        numTn = bsxfun(@times,x,m);
        denomTn = bsxfun(@plus,x,m) - numTn;
        res = numTn./denomTn;
        res(bsxfun(@eq,x,m)) = 0;
    elseif strcmp(Gen,'O_B')
        res = min(bsxfun(@times,x,sqrt(m)),bsxfun(@times,m,sqrt(x)));
    elseif strcmp(Gen,'O_mM')
        res = bsxfun(@min,x,m) .* bsxfun(@max,x.^2,m.^2);
    elseif strcmp(Gen,'O_alpha')
        alpha = 0.1;
        res = bsxfun(@times,x,m) .* (1 + alpha * (bsxfun(@times,1-x,1-m)));
    elseif strcmp(Gen,'O_Div')
        res = (bsxfun(@times,x,m) + bsxfun(@min,x,m)) / 2;
    elseif strcmp(Gen,'GM')
        res = sqrt(bsxfun(@times,x,m));
    elseif strcmp(Gen,'HM')
        res = 2 / ((1/x)+(1/mm));
        res(x==0 | mm==0) = 0;
    elseif strcmp(Gen,'Sin')
        res = sin((pi/2)*(x .* mm).^(1/4));
    elseif strcmp(Gen,'O_RS')
        res = min(((x+1).*sqrt(mm))/2, mm .* sqrt(x));
    elseif strcmp(Gen,'C_F')
        res = (x .* mm) + ((x.^2 .* mm).*(1-x).*(1-mm));
    elseif strcmp(Gen,'C_L')
        res = max(min(x,mm/2),x+mm-1);
    elseif strcmp(Gen,'F_GL')
        res = sqrt((x .* (mm+1))/2);
    elseif strcmp(Gen,'F_BPC')
        res = x .* mm.^2;
    elseif strcmp(Gen,'F_BD1')
        res = min(x, 1 - x + min(x, mm.^q));
    elseif strcmp(Gen,'FNA') % F_NA
        res = bsxfun(@min,x/2,m);
        res(bsxfun(@le,x,m)) = x(bsxfun(@le,x,m));
    elseif strcmp(Gen,'FNA2') % F_NA2
        res = bsxfun(@min,x/2,m);
        cond = (x + mm)/2;
        res(x <= mm & x > 0) = cond(x <= mm & x > 0);
        res(x==0) = 0;
    end

    if strcmp(DSM,'d0')
        res = res(2:N,:,:,:) - res(1:N-1,:,:,:);
    elseif strcmp(DSM,'d1')
        res = (res(2:N,:,:,:) - res(1:N-1,:,:,:)).^2;
    elseif strcmp(DSM,'d2')
        res = sqrt(abs(res(2:N,:,:,:) - res(1:N-1,:,:,:)));
    elseif strcmp(DSM,'d3')
        res = abs(sqrt(res(2:N,:,:,:)) - sqrt(res(1:N-1,:,:,:)));
    elseif strcmp(DSM,'d4')
        res = abs(res(2:N,:,:,:).^2 - res(1:N-1,:,:,:).^2);
    elseif strcmp(DSM,'d5')
        res = (sqrt(res(2:N,:,:,:)) - sqrt(res(1:N-1,:,:,:))).^2;
    end

end