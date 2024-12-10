function [Xdot_approx,X2,t2] = centralDiff4th(t,X)
    
    t2 = t(3:end-2); dt = t(2) - t(1);
    X2 = X(3:end-2,:);
    Xdot_approx = zeros(size(X,1)-4,size(X,2));
    for i = 3:size(X,1)-2
        for k=1:size(X,2)
            Xdot_approx(i-2,k) = (1/(12*dt))*(-X(i+2,k)+8*X(i+1,k)-8*X(i-1,k)+X(i-2,k));
        end
    end

end