function [funcLib,Vars] = getFunctions(X,polyLib,fourierLib,nControl)

    % Sem controle
    if ~exist('nControl','var')
        nControl = 0;
    end
    
    % Números (subscrito, superscrito)
    numChars = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
    numSubs = {char(8320), char(8321), char(8322), char(8323), char(8324),...
        char(8325), char(8326), char(8327), char(8328), char(8329)};
    numSups = {char(8304), char(185), char(178), char(179), char(8308),...
        char(8309), char(8310), char(8311), char(8312), char(8313)};

    % Criar variáveis de estado e entradas
    nVars = size(X,2);
    Vars = cell(nVars,1);
    for i = 1:nVars
        if i <= nVars - nControl
            Vars{i} = strcat('x',regexprep(num2str(i),numChars,numSubs));
        elseif nControl == 1
            Vars{i} = 'u';
        else
            Vars{i} = strcat('u',regexprep(num2str(i-nControl+1),numChars,numSubs));
        end
    end

    % Criar Biblioteca de Funções
    nFunc = size(polyLib,1) + 2*length(fourierLib)*nVars;    
    funcLib = cell(nFunc,1);

    % Criar Biblioteca de Polinômios
    for i = 1:size(polyLib,1)
        func = '';
        for j = 1:size(polyLib,2)
            if i > 1 && polyLib(i,j) ~= 0
                func = strcat(func,Vars{j});
                if polyLib(i,j) > 1
                    func = strcat(func,...
                    regexprep(num2str(polyLib(i,j)),numChars,numSups));
                end
            end
        end
        if i == 1
            funcLib{i} = '1';
        else
            funcLib{i} = func;
        end
    end

    % Criar Biblioteca de Senos e Cossenos
    for i = 1:length(fourierLib)
        for j = 1:nVars
            ind = size(polyLib,1) + 2*(i-1)*nVars + 2*j - 1; 
            if fourierLib(i) == 1
                func = Vars{j};
            else 
                func = strcat(num2str(fourierLib(i)),Vars{j});
            end
            funcLib{ind} = strcat('sin(',func,')');
            funcLib{ind+1} = strcat('cos(',func,')');
        end
    end

end