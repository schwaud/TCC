SINDYc_Config_F8

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaultLegendInterpreter','latex');

% Simulação
[~,X] = ode45(@(t,x) f(t,x,u(t,x)),tspan,x0,odeOptions);
u_train = u(tspan',X);
Xdot = f(tspan,X',u_train)';

% Plot Simulação
figure
subplot(nVars+2,2,[1,2])
plot(tspan,u_train)
xlabel('$t$')
ylabel('$u$')
for i=1:nVars
    subplot(nVars+2,2,2*i+1)
    plot(tspan,X(:,i))
    xlabel('$t$')
    ylabel(sprintf('$x_{%d}$',i))
    subplot(nVars+2,2,2*i+2)
    plot(tspan,Xdot(:,i))
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
        model = SINDYc(X(Idata,:),Xdot(Idata,:),u_train(Idata,:),polyDeg,fourierLib,eps(i));
        [~,X_id] = ode45(@(t,x) SINDYc_eval(t,x,u(t,x),model),tspan,x0,odeOptions);
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

% Identificação do sistema
model = SINDYc(X,Xdot,u_train,polyDeg,fourierLib,epsilon);

% Validação do Modelo
[~,X_test] = ode45(@(t,x) f(t,x,u_val(t,x)),tspan_test,x0_test,odeOptions);
u_test = u_val(tspan_test',X_test);
[~,X_id] = ode45(@(t,x) SINDYc_eval(t,x,u_val(t,x),model),tspan_test,x0_test,odeOptions);

% Teste
RMSE_test = mean(sqrt(mean((X_test - X_id).^2)));
fprintf('RMSE (Teste): %.4f\n',RMSE_test);

% Plot Teste
figure
subplot(nVars+1,1,1)
plot(tspan_test,u_test)
xlabel('$t$')
ylabel('$u$')
for i=1:nVars
    subplot(nVars+1,1,i+1)
    plot(tspan_test,[X_test(:,i) X_id(:,i)])
    xlabel('$t$')
    ylabel(sprintf('$x_{%d}$',i))
    legend('Sistema','SINDYc')
end
sgtitle('Valida\c{c}\H{a}o do Modelo')

% Modelo
fprintf('\nModelo:\n')
disp(model.model)

% Salvar Dados
save('DATA/F8','model')