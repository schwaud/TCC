function polyLib = getPowers(polyDeg,nVars)

    polyLib = [];
    for n = 0:polyDeg
        m = nchoosek(n+nVars-1,nVars-1);
        div = [zeros(m,1),nchoosek((1:(n+nVars-1))',nVars-1),ones(m,1)*(n+nVars)];
        polyLib = [polyLib; flip(diff(div,1,2)-1)];
    end

end