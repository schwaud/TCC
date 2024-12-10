function xdot = SINDYc_eval(~,x,u,model)

    Theta = getTheta([x; u]',model.polyLib,model.fourierLib);
    xdot = (Theta * model.Xi)';

end