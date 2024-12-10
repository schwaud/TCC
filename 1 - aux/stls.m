function Xi = stls(Theta,Xdot,epsilon)
    Xi = Theta\Xdot; 
    for k = 1:size(Xdot,2)        
        smallinds = (abs(Xi(:,k)) < epsilon); 
        while any(Xi(smallinds,k))
            Xi(smallinds,k) = 0;
            biginds = ~smallinds;   
            Xi(biginds,k) = Theta(:,biginds)\Xdot(:,k); 
            smallinds = (abs(Xi(:,k)) < epsilon);
        end
    end
end