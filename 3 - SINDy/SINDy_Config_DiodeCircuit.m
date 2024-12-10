clc;clear;close

addpath("../1 - aux")
addpath("../2 - systems")

% Sistema
f = @(t,x) diode_circuit(t,x);

% Configs p/ Simulação
x0 = [0.4 0];
nVars = length(x0);
dt = 0.01;
tspan = 0:dt:20; tspan2 = tspan(3:end-2);
odeOptions = odeset('RelTol',1e-10,'AbsTol',1e-10*ones(1,nVars));

% Configs da Biblioteca de Funções Candidatas
polyDeg = 5;
fourierLib = [];

% Configs p/ Validação Cruzada
nFolds = 10;
rng("default");
cv = cvpartition(length(tspan2),"KFold",nFolds);
eps = logspace(-8,1,30);

% Parâmetro Escolhido
epsilon = 1e-1;

% Configs p/ Validação do Modelo
x0_test = [0.8 -0.4];
tspan_test = 0:dt:20;