function res = vecFagg(x,F)

    tam = length(x);
    for idx = 1:tam-1
        if idx == 1
            acum_agg = Fagg(x(idx), x(idx+1),F);
        else
            acum_agg = Fagg(acum_agg, x(idx+1),F);
        end
    end
    res = acum_agg;
end

% 
% tam = len(X)
%         for ix, elem in enumerate(X):
%             if ix == 0:
%                 acum_norm = tnorm(elem, X[ix+1])
%             elif ix < tam - 1:
%                 acum_norm = tnorm(acum_norm, X[ix+1])
% 
%         return acum_norm