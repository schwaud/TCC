function xdot = SINDY_eval(~,x,model)

    Theta = getTheta(x',model.polyLib,model.fourierLib);
    xdot = (Theta * model.Xi)';

end