function res = dSM(x,y,DSM)
    if strcmp(DSM,'d0')
        res = x - y;
    elseif strcmp(DSM,'d1')
        res = (x - y).^2;
    elseif strcmp(DSM,'d2')
        res = sqrt(abs(x - y));
    elseif strcmp(DSM,'d3')
        res = abs(sqrt(x) - sqrt(y));
    elseif strcmp(DSM,'d4')
        res = abs(x.^2 - y.^2);
    elseif strcmp(DSM,'d5')
        res = (sqrt(x) - sqrt(y)).^2;
    end
end