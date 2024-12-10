function model = SINDY(X,Xdot,polyDeg,fourierLib,epsilon)
    
    % Sistema Identificado
    nVars = size(X,2);
    polyLib = getPowers(polyDeg,nVars);
    Theta = getTheta(X,polyLib,fourierLib);
    Xi = stls(Theta,Xdot,epsilon);

    % Biblioteca de Funções (Lista)
    [funcLib,Vars] = getFunctions(X,polyLib,fourierLib);

    % Resultados
    model.stateVars = Vars;
    model.functionLib = funcLib;
    model.polyLib = polyLib;
    model.fourierLib = fourierLib;
    model.Xi = Xi;
    model.model = [table(funcLib) array2table(Xi, 'VariableNames', strcat(Vars,'dot'))];

end