function m = measure(measure,params,tam)
    if strcmp(measure,'power')
        m = powerMeasure(tam,params.power.q);
    elseif strcmp(measure,'owaling')
        m = OWAwi(params.owaling.a,params.owaling.b,tam);
    elseif strcmp(measure,'owa')
        m = OWA(tam);
    elseif strcmp(measure,'wmean')
        m = weightedMean(tam);
    end
    m = m';
end