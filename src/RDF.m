function res = RDF(vec,m,DSM,Gen,q)
    N = size(vec,1);
%     m = m';

    if strcmp(DSM,'d0')
        x = vec(2:N,:,:,:) - vec(1:N-1,:,:,:);
    elseif strcmp(DSM,'d1')
        x = (vec(2:N,:,:,:) - vec(1:N-1,:,:,:)).^2;
    elseif strcmp(DSM,'d2')
        x = sqrt(abs(vec(2:N,:,:,:) - vec(1:N-1,:,:,:)));
    elseif strcmp(DSM,'d3')
        x = abs(sqrt(vec(2:N,:,:,:)) - sqrt(vec(1:N-1,:,:,:)));
    elseif strcmp(DSM,'d4')
        x = abs(vec(2:N,:,:,:).^2 - vec(1:N-1,:,:,:).^2);
    elseif strcmp(DSM,'d5')
        x = (sqrt(vec(2:N,:,:,:)) - sqrt(vec(1:N-1,:,:,:))).^2;
    end

    tam = size(x);
    if (size(m,2) ==1)
        mm = repmat(m,[1 tam(2:end)]);
    else
        mm = m;
    end

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
%         res = bsxfun(@min,bsxfun(@times,x,sqrt(m)),bsxfun(@times,m,sqrt(x)));
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
    

        
    
%     if (F == 0)
%         res = bsxfun(@times,(vec(2:N,:,:,:) - vec(1:N-1,:,:,:)),m);
%     elseif (F == 1)
%         res = bsxfun(@times,(vec(2:N,:,:,:) - vec(1:N-1,:,:,:)).^2,m.^2);
%     elseif (F == 2)
%         res = bsxfun(@times,sqrt(vec(2:N,:,:,:) - vec(1:N-1,:,:,:)),sqrt(m)); 
%     elseif (F == 3)
%          res = bsxfun(@times,(sqrt(vec(2:N,:,:,:)) - sqrt(vec(1:N-1,:,:,:))),sqrt(m));  
%     elseif (F == 4)
%          res = bsxfun(@times,(vec(2:N,:,:,:).^2 - vec(1:N-1,:,:,:).^2),m.^2);
%     elseif (F == 5)
%         res = bsxfun(@times,(sqrt(vec(2:N,:,:,:)) - sqrt(vec(1:N-1,:,:,:))).^2,m);            
%     end
    

%     if strcmp(F,'min')
%         res = bsxfun(@min,vec,m');
%     elseif strcmp(F,'prod')
%         res = bsxfun(@times,vec,m');
%     elseif strcmp(F,'lukasiewicz')
%         res = bsxfun(@max,0,bsxfun(@plus,vec,m'-1));
%     elseif strcmp(F,'hamacker')
%         numTn = bsxfun(@times,vec,m');
%         denomTn = bsxfun(@plus,vec,m') - numTn;
%         res = numTn./denomTn;
%         res(bsxfun(@eq,vec,m')) = 0;
%     elseif strcmp(F,'OB')
%         res = bsxfun(@min,bsxfun(@times,vec,sqrt(m')),bsxfun(@times,m',sqrt(vec)));
%     elseif strcmp(F,'OmM')
%         res = bsxfun(@min,vec,m').*bsxfun(@max,vec.^2,(m').^2);
%     elseif strcmp(F,'ODiv')
%         res = (bsxfun(@times,vec,m')+bsxfun(@min,vec,m'))./2;
%     elseif strcmp(F,'CF')
%         res = bsxfun(@times,vec,m') + bsxfun(@times,vec.^2,bsxfun(@times,m',bsxfun(@times,1-vec,1-m')));
%     elseif strcmp(F,'CL')
%         res = bsxfun(@max,bsxfun(@min,vec,m'.*2),bsxfun(@plus,vec,m'-1));
%     elseif strcmp(F,'FBPC')
%         res = bsxfun(@times,vec,m'.^2);
%     elseif strcmp(F,'FIM')
%         res = bsxfun(@max,1-m',vec);
%     elseif strcmp(F,'FIP')
%         res = bsxfun(@plus,1-m',bsxfun(@times,vec,m'));
%     elseif strcmp(F,'geoMean')
%         res = sqrt(bsxfun(@times,vec,m'));
%     end
    
end