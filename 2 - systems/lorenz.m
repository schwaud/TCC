function xdot = lorenz(~,x,sigma,rho,beta) 
    xdot = [
        sigma * (x(2,:) - x(1,:));
        x(1,:) .* (rho - x(3,:)) - x(2,:);
        x(1,:).*x(2,:) - beta*x(3,:)
    ];
end