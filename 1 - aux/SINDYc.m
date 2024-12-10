function model = SINDYc(X,Xdot,u,polyDeg,fourierLib,epsilon)
    
    % Sistema Identificado
    Xaug = [X u];
    nVars = size(Xaug,2);
    polyLib = getPowers(polyDeg,nVars);
    Theta = getTheta(Xaug,polyLib,fourierLib);
    Xi = stls(Theta,Xdot,epsilon);

    % Biblioteca de Funções (Lista)
    nControl = size(u,2);
    [funcLib,Vars] = getFunctions(Xaug,polyLib,fourierLib,nControl);
    stateVars = Vars(1:nVars-nControl);
    contInputs = Vars(nVars-nControl+1:end);

    % Resultados
    model.stateVars = stateVars;
    model.contInputs = contInputs;
    model.functionLib = funcLib;
    model.polyLib = polyLib;
    model.fourierLib = fourierLib;
    model.Xi = Xi;
    model.model = [table(funcLib) array2table(Xi,'VariableNames',strcat(stateVars,'dot'))];

end