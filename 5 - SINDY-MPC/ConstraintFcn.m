function [c, ceq] = ConstraintFcn(u,uprev,x,Ts,H,LBx,UBx,LBdu,UBdu,model)
    % u: Variável de otimização (de k a k+H)
    % uprev: Valor prévio da entrada
    % x: Estado atual 
    % Ts: Período de amostragem
    % H: Horizonte de predição (e controle)
    % LBx, UBx: limites inferior e superior da entrada
    % LBdu, UBdu: limites inferior e superior da tx. de var. entrada
    % model: Modelo SINDYc
    % c, ceq: Restrições de desigualdade e igualdade

    nVars = length(x);
    cx = zeros(2*nVars*(H+1),1);
    cdu = zeros(2*(H+1),1);
    xk = x;
    uk = u(1);
    duk = u(1) - uprev;
    for i=0:H
        % Predição do próx. estado 
        xk1 = rk4u(@SINDYc_eval,xk,uk,Ts,1,[],model);
        
        % Limites inferiores
        cx(2*i*nVars+1:(2*i+1)*nVars) = -xk1 + LBx;
        cdu(2*i+1) = -duk + LBdu;
        
        % Limites superiores
        cx((2*i+1)*nVars+1:(2*i+2)*nVars) = xk1 - UBx;
        cdu(2*i+2) = duk - UBdu;
        
        % Atualizar xk, uk, duk
        xk = xk1;
        if i < H
            uk = u(i+2);
            duk = u(i+2)-u(i+1);
        end
    end       
    c = [cx; cdu];
    ceq = [];
end