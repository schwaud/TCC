function x = rk4u(f,x,u,h,n,t,model)
    
    for i = 1:n
        k1 = f(t,x,u,model); 
        k2 = f(t,x + h/2*k1,u,model);
        k3 = f(t,x + h/2*k2,u,model);
        k4 = f(t,x + h*k3,u,model);
        x = x + h*(k1 + 2*k2 + 2*k3 + k4)/6;
    end

end