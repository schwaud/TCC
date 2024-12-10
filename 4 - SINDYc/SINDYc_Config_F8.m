clc;clear;close

addpath("../1 - aux")
addpath("../2 - systems")

% Entrada
u = @(t,x) (0.5*sin(5*t).*sin(0.5*t)+0.1).^3;

% Sistema
f = @(t,x,u) F8(t,x,u);

% Configs p/ Simulação
x0 = [0.3 0.1 -0.5];   
nVars = length(x0);       
dt  = 0.01; 
tspan = 0:dt:60;
odeOptions = odeset('RelTol',1e-10,'AbsTol',1e-10*ones(1,nVars));

% Configs da Biblioteca de Funções Candidatas
polyDeg = 5;
fourierLib = [];

% Configs p/ Validação Cruzada
nFolds = 10;
rng("default");
cv = cvpartition(length(tspan),"KFold",nFolds);
eps = logspace(-8,0,30);

% Parâmetro Escolhido
epsilon = 1e-2;

% Entrada p/ Validação do Modelo
u_val = @(t,x) 0.25*sin(5*t);

% Configs p/ Validação do Modelo
x0_test = [0.2 0.3 0.1];
tspan_test = 0:dt:20;