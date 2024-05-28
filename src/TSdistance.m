function dist = TSdistance(x,y)
    dist = Tconorm(x,y) - Tnorm(x,y);
    dist(x==y) = 0;
end

function res = Tnorm(x,y)
    res = x.*y;
end

function res = Tconorm(x,y)
    res = (x+y) - (x.*y);
end
