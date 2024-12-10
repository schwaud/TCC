function Theta = getTheta(X,polyLib,fourierLib)

    % Inicialização de Theta
    [nData,nVars] = size(X);
    nFunc = size(polyLib,1) + 2*length(fourierLib)*nVars;    
    Theta = ones(nData,nFunc);   

    % Avaliação de Polinômios
    for i = 1:size(polyLib,1)
        for j = 1:size(polyLib,2)
            Theta(:,i) = Theta(:,i) .* X(:,j).^polyLib(i,j); 
        end
    end
    
    % Avaliação de senos e cossenos
    for i = 1:length(fourierLib)
        for j = 1:nVars
            ind = size(polyLib,1) + 2*(i-1)*nVars + 2*j - 1; 
            Theta(:,[ind,ind+1]) = [fourierLib(i)*sin(X(:,j)) fourierLib(i)*cos(X(:,j))];
        end
    end

end