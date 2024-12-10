function J = ObjectiveFcn(u,x,Ts,H,xref,uprev,Q,Rdu,Ru,model)
    % u: Variável de otimização (de k a k+H)
    % x: Estado atual 
    % Ts: Período de amostragem
    % H: Horizonte de predição (e controle)
    % xref: Referências para os estados
    % uprev: Valor prévio da entrada
    % Q,Rdu,R: Matrizes de pesos
    % model: Modelo SINDYc
    % J: Valor da função objetivo

    xk = x;
    uk = u(1);
    J = 0;
    for i=0:H    
        % Predição do próx. estado 
        xk1 = rk4u(@SINDYc_eval,xk,uk,Ts,1,[],model);
        
        % Acumular Custo de Rastreamento
        J = J + (xk1 - xref(:,i+1))'*Q*(xk1 - xref(:,i+1));
        
        % Acumular Custo das Entradas e Txs de Var.
        if i==0
            J = J + (uk-uprev)'*Rdu*(uk-uprev) + uk'*Ru*uk;
        else
            J = J + (uk-u(i))'*Rdu*(uk-u(i)) + uk'*Ru*uk;
        end
        
        % Atualizar xk, uk
        xk = xk1;
        if i < H
            uk = u(i+2);
        end
    end
end