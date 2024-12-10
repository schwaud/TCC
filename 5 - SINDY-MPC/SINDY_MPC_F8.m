clc;clear;close

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaultLegendInterpreter','latex');

load('../4 - SINDYc/DATA/F8.mat');

% Parâmetros MPC
optOptions = optimoptions('fmincon','Algorithm','interior-point','Display','none', ...
    'MaxIterations',100);
Duration = 6;          % Duração da Simulação
Ts = 0.01;             % Período de Amostragem
nPts = 10;             % Define o Passo de Integração
x0 = [0.1 0 0];        % Condição Inicial
nVars = length(x0);    % Número de Variáveis
H  = 10;               % Horizonte de predição
Q = [25 0 0];          % Pesos (Estado)
Rdu = 0.05;            % Pesos (Taxa de Var. Controle)
Ru = 0.05;             % Pesos (Controle)
LB = -0.3*ones(H+1,1); % Limite inferior do controle
UB = 0.5*ones(H+1,1);  % Limite superior do controle
LBdu = -0.1;           % Limite inferior taxa de variação do controle   
UBdu = 0.1;            % Limite superior taxa de variação do controle  
LBx = [-0.2 -1 -1]';   % Limite inferior dos estados
UBx = [0.4 1 1]';      % Limite superior dos estados

% Referência p/ x1
x1ref = @(t) 0.4*(-0.5./(1+exp(t/0.1-8)) + 1./(1+exp(t/0.1-30)) - 0.4);

% Inicialização de Variáveis
nInst = floor((Duration/Ts)+1);             % Total de Instantes
tVals = zeros((nPts-1)*(nInst-1)+1,1);      % Tempo (Contínuo)
rVals = zeros((nPts-1)*(nInst-1)+1,1);      % Valores da Referência
xVals = zeros((nPts-1)*(nInst-1)+1,nVars);  % Valores do Estado
xc = x0';                                   % Estado atual
tMPC = (0:Ts:Duration)';                    % Tempo (Discreto)
uprev = 0;                                  % Valor Prévio do Controle
uopt = uprev.*ones(H+1,1);                  % Controle ao longo do Horizonte
uMPC = zeros(nInst+1,1); uMPC(1) = uopt(1); % Valores do Controle
JMPC = zeros(nInst,1);                      % Valores da Func. Objetivo
tHoriz = zeros(nInst,H+1);                  % Tempo (Predição)
rHoriz = zeros(nInst,H+1);                  % Referência (Predição)
uHoriz = zeros(nInst,H+1);                  % Controle (Predição)
xHoriz = cell(nVars,1);                     % Estado (Predição)
for j = 1:nVars
    xHoriz{j} = zeros(nInst,H+1);
end

% Simulação
for i = 0:nInst-1

    % Referências ao longo do horizonte de predição
    %tH = (i+1:i+1+H).*Ts;
    tH = (i:i+H).*Ts;
    r = [x1ref(tH); zeros(nVars-1,H+1)];

    % MPC Otimização
    Cost = @(u) ObjectiveFcn(u,xc,Ts,H,r,uMPC(i+1),diag(Q),Rdu,Ru,model);
    Const = @(u) ConstraintFcn(u,uMPC(i+1),xc,Ts,H,LBx,UBx,LBdu,UBdu,model);   
    [uopt,J] = fmincon(Cost,uopt,[],[],[],[],LB,UB,Const,optOptions);    

    % Evolução do Sistema (até próx. instante de amostragem)
    tInt = linspace(i*Ts,(i+1)*Ts,nPts);
    [~,X] = ode45(@(t,x) F8(t,x,uopt(1)),tInt,xc);

    % Atualizar Dados de Predição
    tHoriz(i+1,:) = tH;
    rHoriz(i+1,:) = x1ref(tH);
    uHoriz(i+1,:) = uopt';
    xk = xc; 
    for k = 0:H
        for j = 1:nVars
            xHoriz{j}(i+1,k+1) = xk(j); 
        end
        xk1 = rk4u(@SINDYc_eval,xk,uopt(k+1),Ts,1,[],model);       
        xk = xk1;
    end       

    % Atualizar Dados
    uMPC(i+2) = uopt(1);
    JMPC(i+1) = J;
    if i < nInst-1
        tVals(i*(nPts-1)+1:i*(nPts-1)+nPts) = tInt;
        rVals(i*(nPts-1)+1:i*(nPts-1)+nPts) = x1ref(tInt);
        xVals(i*(nPts-1)+1:i*(nPts-1)+nPts,:) = X;    
        xc = X(end,:)';
    end

end
uMPC = uMPC(2:end); 

% Plot
figure
plot(tVals,[xVals rVals])
hold on
stairs(tMPC,[uMPC JMPC])
legend('$x_1$','$x_2$','$x_3$','$r$','$u$','$J$')