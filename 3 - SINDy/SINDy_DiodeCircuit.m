SINDy_Config_DiodeCircuit

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaultLegendInterpreter','latex');

% Simulação
[~,X] = ode45(@(t,x) f(t,x),tspan,x0,odeOptions);
Xdot = f(tspan,X')';

% Derivação Numérica (Dif. Centrais 4a ordem)
[Xdot_approx,X2,tspan2] = centralDiff4th(tspan,X);

% Plot Simulação
figure
for i=1:nVars
    subplot(nVars,2,2*i-1)
    plot(tspan,X(:,i))
    xlabel('$t$')
    ylabel(sprintf('$x_{%d}$',i))

    subplot(nVars,2,2*i)
    plot(tspan,Xdot(:,i),tspan2,Xdot_approx(:,i))
    legend('Sistema','Aproximado')
    xlabel('$t$')
    ylabel(strcat('$\',sprintf('dot{x}_{%d}$',i)))
end
sgtitle('Dados de Simula\c{c}\H{a}o')

% Validação Cruzada
error = zeros(1,length(eps));
for i = 1:length(eps)
    error_eps = zeros(1,nFolds);
    for j = 1:nFolds
        Idata = training(cv,j);
        model = SINDY(X2(Idata,:),Xdot_approx(Idata,:),polyDeg,fourierLib,eps(i));
        [~,X_id] = ode45(@(t,x) SINDY_eval(t,x,model),tspan,x0,odeOptions);
        % RMSE
        Ival = ~Idata;
        RMSE = mean(sqrt(mean((X(Ival,:) - X_id(Ival,:)).^2)));
        error_eps(j) = RMSE;
    end
    error(i) = mean(error_eps);
    disp(i); % Iteração atual
end

% Plot Validação Cruzada
figure
semilogx(eps,error,'Marker','.')
grid on
title('Valida\c{c}\H{a}o Cruzada')
xlabel('$\varepsilon$')
ylabel('RMSE')

% Identificação do Sistema
model = SINDY(X2,Xdot_approx,polyDeg,fourierLib,epsilon);
model_LS = SINDY(X2,Xdot_approx,polyDeg,fourierLib,0);

% Validação do Modelo
[~,X_test] = ode45(@(t,x) f(t,x),tspan_test,x0_test,odeOptions);
[~,X_id] = ode45(@(t,x) SINDY_eval(t,x,model),tspan_test,x0_test,odeOptions);

% Teste
RMSE_test = mean(sqrt(mean((X_test - X_id).^2)));
fprintf('RMSE (Teste): %.4f\n',RMSE_test);

% Plot Teste
figure
for i=1:nVars
    subplot(nVars,1,i)
    plot(tspan_test,[X_test(:,i) X_id(:,i)])
    xlabel('$t$')
    ylabel(sprintf('$x_{%d}$',i))
    legend('Sistema','SINDy')
end
sgtitle('Valida\c{c}\H{a}o do Modelo')

% Solução via Mín. Quadrados
fprintf('\nModelo (via Mín. Quad):\n')
disp(model_LS.model)

% Modelo
fprintf('\nModelo (via reg. esparsa):\n')
disp(model.model)